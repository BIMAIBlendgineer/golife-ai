from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path


REQUIRED_ARTIFACT_KEYS = [
    "releaseVersion",
    "scope",
    "ci",
    "deviceQa",
    "billing",
    "entitlementRuntime",
    "privacy",
    "legal",
    "storeAssets",
    "mockDisabled",
    "readyEndpoint",
    "gitleaks",
]

REQUIRED_JOBS = [
    "ai-gateway-test",
    "web-backend-test",
    "mobile-flutter-analyze",
    "mobile-flutter-test",
    "admin-lint",
    "admin-typecheck",
    "admin-build",
    "gitleaks",
    "billing-contract-test",
    "store-copy-lint",
    "release-gate",
]


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate commercialization release evidence and output a machine-readable summary.",
    )
    parser.add_argument(
        "--artifact",
        default="docs/operations/release_artifacts/commercial_premium_release_artifact.json",
        help="Path to the release artifact JSON.",
    )
    parser.add_argument(
        "--format",
        choices=("json", "markdown", "both"),
        default="both",
        help="Output format.",
    )
    return parser.parse_args()


def _status(ok: bool) -> str:
    return "pass" if ok else "fail"


def _load_artifact(repo_root: Path, artifact_arg: str) -> tuple[Path, dict]:
    artifact_path = (repo_root / artifact_arg).resolve()
    artifact = json.loads(artifact_path.read_text(encoding="utf-8"))
    return artifact_path, artifact


def _run_store_copy_lint(repo_root: Path) -> tuple[bool, dict]:
    script = repo_root / "scripts/release/store_copy_lint.py"
    completed = subprocess.run(
        [sys.executable, str(script), "--format", "json"],
        cwd=repo_root,
        capture_output=True,
        text=True,
        check=False,
    )
    payload = json.loads(completed.stdout or "{}")
    return completed.returncode == 0, payload


def _artifact_doc_exists(repo_root: Path, raw_path: str | None) -> bool:
    if not raw_path:
        return False
    return (repo_root / raw_path).resolve().exists()


def _artifact_status_is_blocking(section: dict) -> bool:
    return section.get("status") == "fail"


def _billing_check(artifact: dict) -> tuple[bool, str]:
    billing = artifact.get("billing", {})
    status = billing.get("status")
    if status in {"disabled", "pending"}:
        return True, str(billing.get("decisionDocument", ""))
    if status == "sandbox":
        ok = (
            billing.get("restorePurchases") is True
            and billing.get("renewalState") == "sandbox_only"
            and billing.get("provider") == "google_play"
            and billing.get("productionPurchasesEnabled") is False
            and _artifact_doc_exists(
                Path(__file__).resolve().parents[2],
                str(billing.get("decisionDocument", "")),
            )
        )
        return ok, str(billing.get("decisionDocument", ""))
    if status == "enabled":
        return True, str(billing.get("decisionDocument", ""))
    return False, str(billing.get("decisionDocument", ""))


def _entitlement_runtime_check(section: dict, billing: dict) -> bool:
    if section.get("status") != "pass":
        return False
    if section.get("exportDeleteAlwaysAvailable") is not True:
        return False
    provider = section.get("billingProvider")
    if provider == "disabled":
        return section.get("restorePurchases") is False
    if provider == "google_play":
        return (
            billing.get("status") == "sandbox"
            and section.get("restorePurchases") is True
            and section.get("sandboxOnly") is True
            and section.get("productionPurchasesEnabled") is False
        )
    return False


def _render_markdown(report: dict[str, object]) -> str:
    lines = [
        f"## Release Gate: {report['status']}",
        "",
    ]
    for name, payload in report["checks"].items():
        lines.append(f"- `{name}`: {payload['status']} - {payload['message']}")
    return "\n".join(lines)


def main() -> int:
    args = _parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    artifact_path, artifact = _load_artifact(repo_root, args.artifact)

    missing_keys = [key for key in REQUIRED_ARTIFACT_KEYS if key not in artifact]
    ci_jobs = artifact.get("ci", {}).get("requiredJobs", [])
    missing_jobs = [job for job in REQUIRED_JOBS if job not in ci_jobs]

    support_runbook = repo_root / "docs/operations/COMMERCIAL_SUPPORT_RUNBOOK.md"
    data_map = repo_root / "docs/compliance/DATA_MAP.md"
    store_lint_ok, store_lint_report = _run_store_copy_lint(repo_root)
    device_qa = artifact.get("deviceQa", {})
    legal = artifact.get("legal", {})
    store_assets = artifact.get("storeAssets", {})
    entitlement_runtime = artifact.get("entitlementRuntime", {})
    billing = artifact.get("billing", {})

    legal_doc_paths = [
        legal.get("privacyPolicyDocument"),
        legal.get("termsDocument"),
        legal.get("supportDocument"),
    ]
    legal_docs_ok = all(_artifact_doc_exists(repo_root, path) for path in legal_doc_paths)
    legal_urls_ok = all(
        str(legal.get(key, "")).startswith("https://")
        for key in ("privacyPolicyUrl", "termsUrl", "supportUrl")
    )

    device_qa_doc = str(device_qa.get("checklist", ""))
    device_qa_ok = _artifact_doc_exists(repo_root, device_qa_doc) and not _artifact_status_is_blocking(device_qa)

    store_packet_doc = str(store_assets.get("packetDocument", ""))
    screenshot_doc = str(store_assets.get("screenshotChecklist", ""))
    store_assets_ok = (
        _artifact_doc_exists(repo_root, store_packet_doc)
        and _artifact_doc_exists(repo_root, screenshot_doc)
        and not _artifact_status_is_blocking(store_assets)
    )

    billing_ok, billing_message = _billing_check(artifact)

    checks = {
        "artifact": {
            "status": _status(not missing_keys),
            "message": "required artifact keys present"
            if not missing_keys
            else f"missing keys: {', '.join(missing_keys)}",
        },
        "ci_jobs": {
            "status": _status(not missing_jobs),
            "message": "required job names declared"
            if not missing_jobs
            else f"missing job declarations: {', '.join(missing_jobs)}",
        },
        "store_copy_lint": {
            "status": _status(store_lint_ok),
            "message": f"{store_lint_report.get('scanned_files', 0)} files scanned",
        },
        "support_runbook": {
            "status": _status(support_runbook.exists()),
            "message": support_runbook.relative_to(repo_root).as_posix(),
        },
        "privacy_data_map": {
            "status": _status(data_map.exists()),
            "message": data_map.relative_to(repo_root).as_posix(),
        },
        "device_qa": {
            "status": _status(device_qa_ok),
            "message": f"{device_qa.get('status', 'missing')} - {device_qa_doc}",
        },
        "legal": {
            "status": _status(legal_docs_ok and legal_urls_ok),
            "message": legal.get("privacyPolicyDocument", ""),
        },
        "store_assets": {
            "status": _status(store_assets_ok),
            "message": f"{store_assets.get('status', 'missing')} - {store_packet_doc}",
        },
        "mock_disabled": {
            "status": artifact.get("mockDisabled", {}).get("status", "fail"),
            "message": str(artifact.get("mockDisabled", {}).get("document", "")),
        },
        "ready_endpoint": {
            "status": artifact.get("readyEndpoint", {}).get("status", "fail"),
            "message": str(artifact.get("readyEndpoint", {}).get("path", "")),
        },
        "gitleaks": {
            "status": artifact.get("gitleaks", {}).get("status", "fail"),
            "message": str(artifact.get("gitleaks", {}).get("command", "")),
        },
        "billing": {
            "status": _status(billing_ok),
            "message": billing_message,
        },
        "entitlement_runtime": {
            "status": _status(_entitlement_runtime_check(entitlement_runtime, billing)),
            "message": json.dumps(entitlement_runtime, sort_keys=True),
        },
    }

    blocking_failures = [
        name for name, payload in checks.items() if payload["status"] == "fail"
    ]
    report = {
        "status": _status(not blocking_failures),
        "artifact": artifact_path.relative_to(repo_root).as_posix(),
        "checks": checks,
        "blockingFailures": blocking_failures,
    }

    if args.format in {"json", "both"}:
        print(json.dumps(report, indent=2))
    if args.format in {"markdown", "both"}:
        if args.format == "both":
            print()
        print(_render_markdown(report))

    return 0 if report["status"] == "pass" else 1


if __name__ == "__main__":
    sys.exit(main())
