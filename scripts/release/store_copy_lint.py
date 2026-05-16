from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Scan store and user-facing copy for unsupported claims.",
    )
    parser.add_argument(
        "--config",
        default=str(Path(__file__).with_name("store_copy_lint_config.json")),
        help="Path to the lint configuration JSON.",
    )
    parser.add_argument(
        "--format",
        choices=("text", "json", "markdown"),
        default="text",
        help="Output format.",
    )
    return parser.parse_args()


def _load_config(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _included_files(repo_root: Path, config: dict) -> list[Path]:
    include_globs = config.get("include_globs", [])
    exclude_globs = config.get("exclude_globs", [])
    matches: set[Path] = set()
    for pattern in include_globs:
        matches.update(path for path in repo_root.glob(pattern) if path.is_file())

    filtered: list[Path] = []
    for path in sorted(matches):
        relative = path.relative_to(repo_root).as_posix()
        if any(path.match(pattern) or relative == pattern for pattern in exclude_globs):
            continue
        filtered.append(path)
    return filtered


def _scan_file(
    repo_root: Path,
    path: Path,
    *,
    banned_phrases: list[str],
    allow_patterns: list[re.Pattern[str]],
) -> list[dict[str, object]]:
    violations: list[dict[str, object]] = []
    relative = path.relative_to(repo_root).as_posix()
    for line_number, line in enumerate(
        path.read_text(encoding="utf-8", errors="ignore").splitlines(),
        start=1,
    ):
        lowered = line.lower()
        for phrase in banned_phrases:
            if phrase not in lowered:
                continue
            if any(pattern.search(line) for pattern in allow_patterns):
                continue
            violations.append(
                {
                    "path": relative,
                    "line": line_number,
                    "phrase": phrase,
                    "text": line.strip(),
                }
            )
    return violations


def _build_report(repo_root: Path, config_path: Path) -> dict[str, object]:
    config = _load_config(config_path)
    allow_patterns = [
        re.compile(pattern)
        for pattern in config.get("allow_regexes", [])
    ]
    banned_phrases = [phrase.lower() for phrase in config.get("banned_phrases", [])]
    files = _included_files(repo_root, config)
    violations: list[dict[str, object]] = []
    for path in files:
        violations.extend(
            _scan_file(
                repo_root,
                path,
                banned_phrases=banned_phrases,
                allow_patterns=allow_patterns,
            )
        )
    return {
        "status": "pass" if not violations else "fail",
        "config": config_path.relative_to(repo_root).as_posix(),
        "scanned_files": len(files),
        "violations": violations,
    }


def _render_text(report: dict[str, object]) -> str:
    lines = [
        f"store-copy-lint: {report['status']}",
        f"scanned_files: {report['scanned_files']}",
    ]
    for violation in report["violations"]:
        lines.append(
            f"{violation['path']}:{violation['line']} [{violation['phrase']}] {violation['text']}"
        )
    return "\n".join(lines)


def _render_markdown(report: dict[str, object]) -> str:
    lines = [
        f"## Store Copy Lint: {report['status']}",
        "",
        f"- Scanned files: {report['scanned_files']}",
        f"- Violations: {len(report['violations'])}",
    ]
    for violation in report["violations"]:
        lines.append(
            f"- `{violation['path']}:{violation['line']}` matched `{violation['phrase']}`: {violation['text']}"
        )
    return "\n".join(lines)


def main() -> int:
    args = _parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    config_path = Path(args.config).resolve()
    report = _build_report(repo_root, config_path)

    if args.format == "json":
        print(json.dumps(report, indent=2))
    elif args.format == "markdown":
        print(_render_markdown(report))
    else:
        print(_render_text(report))

    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
