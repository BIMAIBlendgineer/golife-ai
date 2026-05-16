from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate that billing is either properly documented as disabled or has the minimum contract fields.",
    )
    parser.add_argument(
        "--artifact",
        default="docs/operations/release_artifacts/commercial_premium_release_artifact.json",
        help="Path to the release artifact JSON.",
    )
    parser.add_argument(
        "--format",
        choices=("text", "json"),
        default="text",
        help="Output format.",
    )
    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    repo_root = Path(__file__).resolve().parents[2]
    artifact_path = (repo_root / args.artifact).resolve()
    artifact = json.loads(artifact_path.read_text(encoding="utf-8"))
    billing = artifact.get("billing", {})

    status = str(billing.get("status", "")).strip()
    decision_document = str(billing.get("decisionDocument", "")).strip()
    restore_purchases = billing.get("restorePurchases")
    renewal_state = billing.get("renewalState")
    decision_document_path = (
        (repo_root / decision_document).resolve() if decision_document else None
    )

    passed = True
    reasons: list[str] = []

    if not status:
        passed = False
        reasons.append("missing billing.status")

    if status in {"disabled", "pending"} and not decision_document:
        passed = False
        reasons.append("billing is not enabled but no decisionDocument was provided")
    if (
        status in {"disabled", "pending"}
        and decision_document_path is not None
        and not decision_document_path.exists()
    ):
        passed = False
        reasons.append("billing decisionDocument does not exist")

    if status == "enabled":
        if restore_purchases is not True:
            passed = False
            reasons.append("billing enabled without restorePurchases=true")
        if not renewal_state:
            passed = False
            reasons.append("billing enabled without renewalState")

    report = {
        "status": "pass" if passed else "fail",
        "artifact": artifact_path.relative_to(repo_root).as_posix(),
        "billing_status": status,
        "decision_document": decision_document or None,
        "decision_document_exists": (
            decision_document_path.exists()
            if decision_document_path is not None
            else False
        ),
        "reasons": reasons,
    }

    if args.format == "json":
        print(json.dumps(report, indent=2))
    else:
        print(f"billing-contract-check: {report['status']}")
        print(f"artifact: {report['artifact']}")
        print(f"billing_status: {report['billing_status']}")
        for reason in reasons:
            print(f"- {reason}")

    return 0 if passed else 1


if __name__ == "__main__":
    sys.exit(main())
