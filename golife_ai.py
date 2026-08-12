import argparse
import json
import os
import socket
import subprocess
import sys
import threading
import time
import shutil
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict
from urllib.request import urlopen


LAUNCHER_DIR = Path(__file__).resolve().parent
REPO_ROOT = Path(
    os.environ.get("GOLIFE_REPO_ROOT", str(LAUNCHER_DIR))
).expanduser().resolve()

EXPECTED_BRANCH = "stabilize/human-beta-readiness"
PR_NUMBER = 28
ADMIN_PORT = 3060
BACKEND_PORT = 3061
GATEWAY_PORT = 3062
WEB_APP_PORT = 3070
LOCAL_HOST = "127.0.0.1"
ANDROID_EMULATOR_HOST = "10.0.2.2"
BIND_HOST = "0.0.0.0"


@dataclass(frozen=True)
class ServiceConfig:
    key: str
    cwd: Path
    cmd: str
    port: int | None
    tag: str
    env: dict[str, str]
    startup_url: str | None = None


class GoLifeControlTower:
    def __init__(self) -> None:
        self._ensure_utf8_console()
        self.running = True
        self.processes: Dict[str, subprocess.Popen] = {}
        self._watchers: list[threading.Thread] = []
        self.lan_host = self._detect_lan_host()

        self.colors = {
            "MOBILE": "\033[94m",
            "ADMIN": "\033[93m",
            "BACKEND": "\033[96m",
            "GATEWAY": "\033[92m",
            "SYS": "\033[97m",
            "ERR": "\033[91m",
            "WARN": "\033[33m",
            "DIM": "\033[90m",
            "RESET": "\033[0m",
        }

        self.services = {
            "BACKEND": ServiceConfig(
                key="BACKEND",
                cwd=REPO_ROOT / "services" / "web_backend",
                cmd=f"python -m uvicorn app.main:app --host {BIND_HOST} --port {BACKEND_PORT} --reload",
                port=BACKEND_PORT,
                tag="[BACK]",
                env={
                    "ENVIRONMENT": "dev",
                    "ADMIN_TOKEN": "golife-admin-dev",
                    "INGESTION_TOKEN": "golife-ingest-dev",
                    "OPERATIONAL_DATABASE_PATH": ".runtime/web_backend.db",
                    "MOBILE_GATEWAY_BASE_URL": self._mobile_gateway_base_url(),
                    "PYTHONUNBUFFERED": "1",
                },
                startup_url=f"http://{LOCAL_HOST}:{BACKEND_PORT}",
            ),
            "GATEWAY": ServiceConfig(
                key="GATEWAY",
                cwd=REPO_ROOT / "services" / "ai_gateway",
                cmd=f"python -m uvicorn app.main:app --host {BIND_HOST} --port {GATEWAY_PORT} --reload",
                port=GATEWAY_PORT,
                tag="[GATE]",
                env={
                    "AI_GATEWAY_ENV": "dev",
                    "OPERATIONAL_BACKEND_ENABLED": "true",
                    "OPERATIONAL_BACKEND_BASE_URL": f"http://{LOCAL_HOST}:{BACKEND_PORT}",
                    "OPERATIONAL_BACKEND_INGESTION_TOKEN": "golife-ingest-dev",
                    "PYTHONUNBUFFERED": "1",
                },
                startup_url=f"http://{LOCAL_HOST}:{GATEWAY_PORT}",
            ),
            "ADMIN": ServiceConfig(
                key="ADMIN",
                cwd=REPO_ROOT / "apps" / "admin_next",
                cmd=f"npm run dev -- --hostname {BIND_HOST} --port {ADMIN_PORT}",
                port=ADMIN_PORT,
                tag="[ADMN]",
                env={
                    "GOLIFE_ADMIN_API_BASE_URL": f"http://{LOCAL_HOST}:{BACKEND_PORT}",
                    "GOLIFE_ADMIN_API_TOKEN": "golife-admin-dev",
                    "PORT": str(ADMIN_PORT),
                },
                startup_url=f"http://{LOCAL_HOST}:{ADMIN_PORT}",
            ),
            "MOBILE": ServiceConfig(
                key="MOBILE",
                cwd=REPO_ROOT / "apps" / "mobile_flutter",
                cmd=(
                    "flutter run "
                    f"--dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://{LOCAL_HOST}:{GATEWAY_PORT} "
                    f"--dart-define=GOLIFE_RUNTIME_CONFIG_BASE_URL=http://{LOCAL_HOST}:{BACKEND_PORT}"
                ),
                port=None,
                tag="[MOBL]",
                env={},
                startup_url=None,
            ),
        }

    def _mobile_gateway_base_url(self) -> str:
        return f"http://{self.lan_host}:{GATEWAY_PORT}"

    def _detect_lan_host(self) -> str:
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
                sock.connect(("8.8.8.8", 80))
                return sock.getsockname()[0]
        except Exception:
            return LOCAL_HOST

    def _ensure_utf8_console(self) -> None:
        for stream_name in ("stdout", "stderr"):
            stream = getattr(sys, stream_name, None)
            if stream and hasattr(stream, "reconfigure"):
                try:
                    stream.reconfigure(encoding="utf-8", errors="replace")
                except Exception:
                    pass

    def _git(self, *args: str, check: bool = False) -> subprocess.CompletedProcess:
        return subprocess.run(
            ["git", "-C", str(REPO_ROOT), *args],
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
            check=check,
        )

    def validate_repo_context(self) -> bool:
        """Fail closed if this launcher would operate on the wrong checkout."""
        if not REPO_ROOT.exists():
            self.log(
                "SYS",
                f"Worktree esperado no existe: {REPO_ROOT}",
                "ERROR",
            )
            return False

        required = [
            REPO_ROOT / "apps" / "mobile_flutter" / "pubspec.yaml",
            REPO_ROOT / "apps" / "admin_next" / "package.json",
            REPO_ROOT / "services" / "web_backend",
            REPO_ROOT / "services" / "ai_gateway",
        ]
        missing = [str(path) for path in required if not path.exists()]
        if missing:
            self.log(
                "SYS",
                "El worktree no tiene la estructura GoLife esperada: "
                + "; ".join(missing),
                "ERROR",
            )
            return False

        top = self._git("rev-parse", "--show-toplevel")
        if top.returncode != 0:
            self.log("SYS", f"No es un worktree Git valido: {REPO_ROOT}", "ERROR")
            return False

        try:
            actual_top = Path(top.stdout.strip()).resolve()
        except Exception:
            actual_top = REPO_ROOT

        if actual_top != REPO_ROOT:
            self.log(
                "SYS",
                f"Git resolvio otro worktree: {actual_top}",
                "ERROR",
            )
            return False

        branch_result = self._git("branch", "--show-current")
        branch = branch_result.stdout.strip() if branch_result.returncode == 0 else ""
        if branch != EXPECTED_BRANCH:
            self.log(
                "SYS",
                f"Rama incorrecta: '{branch or 'DETACHED'}'. "
                f"Se requiere '{EXPECTED_BRANCH}' para PR #{PR_NUMBER}.",
                "ERROR",
            )
            return False

        head_result = self._git("rev-parse", "--short=12", "HEAD")
        head = head_result.stdout.strip() if head_result.returncode == 0 else "unknown"
        self.log(
            "SYS",
            f"Contexto verificado: PR #{PR_NUMBER} | {EXPECTED_BRANCH} | HEAD {head}",
            "INFO",
        )

        dirty = self._git("status", "--porcelain")
        if dirty.returncode == 0 and dirty.stdout.strip():
            self.log(
                "SYS",
                "El worktree tiene cambios locales. Se permite arrancar para QA, "
                "pero revisa 'git status' antes de cualquier commit.",
                "WARN",
            )
        return True

    def _color(self, key: str) -> str:
        return self.colors.get(key, self.colors["SYS"])

    def log(self, key: str, message: str, level: str = "INFO") -> None:
        text = (message or "").strip()
        if not text:
            return
        now = datetime.now().strftime("%H:%M:%S")
        color = self._color(key)
        if level == "ERROR":
            color = self.colors["ERR"]
        elif level == "WARN":
            color = self.colors["WARN"]
        tag = self.services.get(key, None).tag if key in self.services else "[SYS ]"
        print(
            f"{self.colors['DIM']}[{now}]{self.colors['RESET']} "
            f"{color}{tag}{self.colors['RESET']} {text}"
        )

    def menu(self) -> None:
        sep = "-" * 74
        print()
        print(f"{self.colors['GATEWAY']}+{sep}+{self.colors['RESET']}")
        print("|   GOLIFE CONTROL TOWER — HUMAN BETA / PR #28                          |")
        print("|   Stack util: web_backend + ai_gateway + admin_next                   |")
        print(f"|   Puertos: admin {ADMIN_PORT} | backend {BACKEND_PORT} | gateway {GATEWAY_PORT}                     |")
        print("|   Mobile Flutter queda aparte porque depende del device conectado     |")
        print(f"+{sep}+")
        print("|   [T] Start stack útil   [R] Restart stack   [K] Stop managed         |")
        print("|   [B] Backend only       [G] Gateway only    [A] Solo admin panel     |")
        print("|   [M] Mobile Flutter     [W] Flutter Web PC  [Y] Flutter Web LAN      |")
        print("|   [D] Flutter devices    [P] Purge known ports                         |")
        print("|   [H] Health check       [L] Install deps     [S] Status              |")
        print("|   [Q] Quit                                                           |")
        print(f"+{sep}+{self.colors['RESET']}")
        print(f"Repo QA: {REPO_ROOT}")
        print(f"Rama requerida: {EXPECTED_BRANCH}")
        print(
            "Nota: [T] levanta backend + gateway + admin. [A] solo abre el panel si las APIs ya corren aparte."
        )
        print(
            f"Abre admin en: http://{LOCAL_HOST}:{ADMIN_PORT}/dashboard o http://{self.lan_host}:{ADMIN_PORT}/dashboard"
        )
        print(
            f"Abre Flutter Web LAN en: http://{self.lan_host}:{WEB_APP_PORT}"
        )

    def _spawn(self, config: ServiceConfig) -> None:
        if config.key in self.processes and self.processes[config.key].poll() is None:
            self.log(config.key, "Ya estaba corriendo.", "WARN")
            return
        if not config.cwd.exists():
            self.log(config.key, f"No existe: {config.cwd}", "ERROR")
            return
        if config.key == "ADMIN":
            self._reset_admin_build_cache()
        env = os.environ.copy()
        env.update(config.env)
        self.log(config.key, f"Iniciando en {config.cwd}", "INFO")
        process = subprocess.Popen(
            config.cmd,
            cwd=str(config.cwd),
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            encoding="utf-8",
            errors="replace",
            env=env,
        )
        self.processes[config.key] = process
        watcher = threading.Thread(
            target=self._watch_process,
            args=(config.key, process),
            daemon=True,
        )
        watcher.start()
        self._watchers.append(watcher)
        if config.startup_url:
            self.log(config.key, f"Esperado en {config.startup_url}", "INFO")
            if config.key == "ADMIN":
                self.log(
                    config.key,
                    f"LAN: http://{self.lan_host}:{ADMIN_PORT}/dashboard",
                    "INFO",
                )

    def _reset_admin_build_cache(self) -> None:
        for cache_name in (".next-dev", ".next"):
            next_dir = self.services["ADMIN"].cwd / cache_name
            if not next_dir.exists():
                continue
            try:
                shutil.rmtree(next_dir)
                self.log("ADMIN", f"Cache {cache_name} limpiada antes de arrancar.", "INFO")
            except Exception as exc:
                self.log("ADMIN", f"No se pudo limpiar {cache_name}: {exc}", "WARN")

    def _watch_process(self, key: str, process: subprocess.Popen) -> None:
        if process.stdout is None:
            return
        try:
            for line in process.stdout:
                self.log(key, line.rstrip())
        finally:
            if self.running and process.poll() is not None:
                self.log(key, f"Proceso terminado con código {process.returncode}", "WARN")

    def start_stack(self) -> None:
        if not self.validate_repo_context():
            return
        for key in ("BACKEND", "GATEWAY", "ADMIN"):
            self._spawn(self.services[key])
            time.sleep(1)

    def restart_stack(self) -> None:
        if not self.validate_repo_context():
            return
        self.stop_managed()
        self.purge_known_ports()
        time.sleep(1)
        self.start_stack()

    def start_mobile(self) -> None:
        if not self.validate_repo_context():
            return
        device = self._pick_mobile_flutter_device()
        config = self.services["MOBILE"]

        if device:
            target_device = str(device.get("id"))
            is_emulator = bool(device.get("emulator")) or target_device.lower().startswith("emulator-")
            api_host = ANDROID_EMULATOR_HOST if is_emulator else self.lan_host
            self.log(
                "MOBILE",
                "Mobile usara backend/gateway por "
                + ("Android emulator bridge" if is_emulator else "LAN")
                + f": http://{api_host}:{BACKEND_PORT} y http://{api_host}:{GATEWAY_PORT}",
                "INFO",
            )
            config = ServiceConfig(
                key=config.key,
                cwd=config.cwd,
                cmd=(
                    "flutter run "
                    f"-d {target_device} "
                    f"--dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://{api_host}:{GATEWAY_PORT} "
                    f"--dart-define=GOLIFE_RUNTIME_CONFIG_BASE_URL=http://{api_host}:{BACKEND_PORT}"
                ),
                port=config.port,
                tag=config.tag,
                env=config.env,
                startup_url=config.startup_url,
            )
            self.log("MOBILE", f"Target Flutter seleccionado: {target_device}", "INFO")
        else:
            self.log(
                "MOBILE",
                "No se detecto Android soportado; Flutter elegira target interactivamente.",
                "WARN",
            )
        self._spawn(config)

    def start_mobile_web_chrome(self) -> None:
        if not self.validate_repo_context():
            return
        self.log(
            "MOBILE",
            f"Flutter Web para PC en http://{LOCAL_HOST}:{WEB_APP_PORT}",
            "INFO",
        )
        config = ServiceConfig(
            key="MOBILE",
            cwd=self.services["MOBILE"].cwd,
            cmd=(
                "flutter run "
                "-d chrome "
                f"--web-port {WEB_APP_PORT} "
                f"--dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://{self.lan_host}:{GATEWAY_PORT} "
                f"--dart-define=GOLIFE_RUNTIME_CONFIG_BASE_URL=http://{self.lan_host}:{BACKEND_PORT}"
            ),
            port=WEB_APP_PORT,
            tag=self.services["MOBILE"].tag,
            env=self.services["MOBILE"].env,
            startup_url=f"http://{LOCAL_HOST}:{WEB_APP_PORT}",
        )
        self._spawn(config)

    def start_mobile_web_server(self) -> None:
        if not self.validate_repo_context():
            return
        self.log(
            "MOBILE",
            f"Flutter Web LAN en http://{self.lan_host}:{WEB_APP_PORT}",
            "INFO",
        )
        config = ServiceConfig(
            key="MOBILE",
            cwd=self.services["MOBILE"].cwd,
            cmd=(
                "flutter run "
                "-d web-server "
                f"--web-hostname {BIND_HOST} "
                f"--web-port {WEB_APP_PORT} "
                f"--dart-define=GOLIFE_AI_GATEWAY_BASE_URL=http://{self.lan_host}:{GATEWAY_PORT} "
                f"--dart-define=GOLIFE_RUNTIME_CONFIG_BASE_URL=http://{self.lan_host}:{BACKEND_PORT}"
            ),
            port=WEB_APP_PORT,
            tag=self.services["MOBILE"].tag,
            env=self.services["MOBILE"].env,
            startup_url=f"http://{LOCAL_HOST}:{WEB_APP_PORT}",
        )
        self._spawn(config)

    def _pick_mobile_flutter_device(self) -> dict | None:
        try:
            result = subprocess.run(
                "flutter devices --machine",
                cwd=str(self.services["MOBILE"].cwd),
                shell=True,
                capture_output=True,
                text=True,
                encoding="utf-8",
                errors="replace",
                timeout=20,
            )
            if result.returncode != 0 or not result.stdout.strip():
                return None
            devices = json.loads(result.stdout)
            android_mobile = [
                device
                for device in devices
                if device.get("isSupported")
                and str(device.get("targetPlatform", "")).startswith("android-")
            ]
            return android_mobile[0] if android_mobile else None
        except Exception:
            return None

    def stop_managed(self) -> None:
        self.log("SYS", "Deteniendo procesos lanzados por esta torre...", "INFO")
        for key, process in list(self.processes.items()):
            if process.poll() is None:
                try:
                    process.kill()
                except Exception:
                    pass
            self.processes.pop(key, None)

    def purge_known_ports(self) -> None:
        self.log(
            "SYS",
            f"Purgando puertos {ADMIN_PORT}, {BACKEND_PORT} y {GATEWAY_PORT}...",
            "WARN",
        )
        for port in (ADMIN_PORT, BACKEND_PORT, GATEWAY_PORT, WEB_APP_PORT):
            self._kill_windows_port(port)

    def _kill_windows_port(self, port: int) -> None:
        if os.name != "nt":
            return
        result = subprocess.run(
            f'netstat -ano -p tcp | findstr ":{port} "',
            shell=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
            errors="replace",
        )
        if result.returncode != 0:
            return
        seen: set[str] = set()
        for line in result.stdout.splitlines():
            parts = line.split()
            if len(parts) < 5:
                continue
            pid = parts[-1]
            if not pid.isdigit() or pid in seen:
                continue
            seen.add(pid)
            subprocess.run(
                f"taskkill /F /PID {pid}",
                shell=True,
                capture_output=True,
                text=True,
            )
            self.log("SYS", f"PID {pid} liberado de puerto {port}", "INFO")

    def install_deps(self) -> None:
        if not self.validate_repo_context():
            return
        commands = [
            (
                REPO_ROOT / "services" / "ai_gateway",
                "python -m pip install -e .[dev]",
                "GATEWAY",
            ),
            (
                REPO_ROOT / "services" / "web_backend",
                "python -m pip install -e .[dev]",
                "BACKEND",
            ),
            (
                REPO_ROOT / "apps" / "admin_next",
                "npm ci",
                "ADMIN",
            ),
            (
                REPO_ROOT / "apps" / "mobile_flutter",
                "flutter pub get",
                "MOBILE",
            ),
        ]
        for cwd, cmd, key in commands:
            self.log(key, f"Instalando dependencias: {cmd}", "INFO")
            subprocess.run(cmd, cwd=str(cwd), shell=True, check=False)

    def flutter_devices(self) -> None:
        if not self.validate_repo_context():
            return
        subprocess.run(
            "flutter devices",
            cwd=str(self.services["MOBILE"].cwd),
            shell=True,
            check=False,
        )

    def health_check(self) -> None:
        if not self.validate_repo_context():
            return
        checks = [
            ("BACKEND", f"http://127.0.0.1:{BACKEND_PORT}/health"),
            ("GATEWAY", f"http://127.0.0.1:{GATEWAY_PORT}/health"),
            ("GATEWAY", f"http://127.0.0.1:{GATEWAY_PORT}/ready"),
        ]
        for key, url in checks:
            try:
                with urlopen(url, timeout=3) as response:
                    self.log(key, f"{url} -> {response.status}", "INFO")
            except Exception as exc:
                self.log(key, f"{url} -> offline ({exc})", "WARN")

        runtime_config_url = (
            f"http://{LOCAL_HOST}:{BACKEND_PORT}/public/mobile/runtime-config"
        )
        expected_gateway = self._mobile_gateway_base_url()
        try:
            with urlopen(runtime_config_url, timeout=3) as response:
                payload = json.loads(response.read().decode("utf-8"))
            advertised_gateway = payload["gateway_base_url"]
            if advertised_gateway == expected_gateway:
                self.log(
                    "BACKEND",
                    f"Runtime config mobile gateway OK: {advertised_gateway}",
                    "INFO",
                )
            else:
                self.log(
                    "BACKEND",
                    "Runtime config mobile gateway MISMATCH: "
                    f"advertised={advertised_gateway} expected={expected_gateway}; "
                    "restart the managed stack with R/T",
                    "WARN",
                )
        except Exception as exc:
            self.log(
                "BACKEND",
                f"{runtime_config_url} -> offline ({exc})",
                "WARN",
            )

    def status(self) -> None:
        self.validate_repo_context()
        for key in ("BACKEND", "GATEWAY", "ADMIN", "MOBILE"):
            process = self.processes.get(key)
            state = "RUNNING" if process and process.poll() is None else "STOPPED"
            self.log(key, state, "INFO")

    def run_interactive(self) -> None:
        if not self.validate_repo_context():
            return
        while self.running:
            self.menu()
            try:
                command = input(">>> COMANDO GOLIFE: ").strip().upper()
            except (EOFError, KeyboardInterrupt):
                command = "Q"

            if command == "T":
                self.start_stack()
            elif command == "R":
                self.restart_stack()
            elif command == "K":
                self.stop_managed()
            elif command == "B":
                if self.validate_repo_context():
                    self._spawn(self.services["BACKEND"])
            elif command == "G":
                if self.validate_repo_context():
                    self._spawn(self.services["GATEWAY"])
            elif command == "A":
                if not self.validate_repo_context():
                    continue
                self.log(
                    "ADMIN",
                    "Modo solo admin: util si backend y gateway ya estan levantados por fuera.",
                    "INFO",
                )
                self._spawn(self.services["ADMIN"])
            elif command == "M":
                self.start_mobile()
            elif command == "W":
                self.start_mobile_web_chrome()
            elif command == "Y":
                self.start_mobile_web_server()
            elif command == "D":
                self.flutter_devices()
            elif command == "P":
                self.purge_known_ports()
            elif command == "H":
                self.health_check()
            elif command == "L":
                self.install_deps()
            elif command == "S":
                self.status()
            elif command == "Q":
                self.running = False
                self.stop_managed()
                break
            else:
                self.log("SYS", "Comando no reconocido.", "WARN")

        self.log("SYS", "Saliendo de GoLife Control Tower.", "INFO")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Launcher local útil para GoLife AI.",
    )
    parser.add_argument(
        "action",
        nargs="?",
        default="interactive",
        choices=[
            "interactive",
            "stack",
            "backend",
            "gateway",
            "admin",
            "mobile",
            "web",
            "web-lan",
            "install",
            "health",
            "status",
            "devices",
            "purge",
        ],
    )
    args = parser.parse_args()
    tower = GoLifeControlTower()

    try:
        if args.action == "interactive":
            tower.run_interactive()
        elif args.action == "stack":
            tower.start_stack()
            while True:
                time.sleep(1)
        elif args.action == "backend":
            if not tower.validate_repo_context():
                return 2
            tower._spawn(tower.services["BACKEND"])
            while True:
                time.sleep(1)
        elif args.action == "gateway":
            if not tower.validate_repo_context():
                return 2
            tower._spawn(tower.services["GATEWAY"])
            while True:
                time.sleep(1)
        elif args.action == "admin":
            if not tower.validate_repo_context():
                return 2
            tower._spawn(tower.services["ADMIN"])
            while True:
                time.sleep(1)
        elif args.action == "mobile":
            tower.start_mobile()
            while True:
                time.sleep(1)
        elif args.action == "web":
            tower.start_mobile_web_chrome()
            while True:
                time.sleep(1)
        elif args.action == "web-lan":
            tower.start_mobile_web_server()
            while True:
                time.sleep(1)
        elif args.action == "install":
            tower.install_deps()
        elif args.action == "health":
            tower.health_check()
        elif args.action == "status":
            tower.status()
        elif args.action == "devices":
            tower.flutter_devices()
        elif args.action == "purge":
            tower.purge_known_ports()
    except KeyboardInterrupt:
        tower.stop_managed()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
