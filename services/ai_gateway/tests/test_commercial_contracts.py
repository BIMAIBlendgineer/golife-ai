from datetime import UTC, datetime

from app.schemas import (
    EntitlementContract,
    EvidenceItem,
    PrivacyJob,
    SuggestionResponse,
)


def test_mission_set_contract_shape_supports_top_level_release_fields():
    response = SuggestionResponse.model_validate(
        {
            "mission_set_id": "mission-set-2026-05-16",
            "date": "2026-05-16",
            "source_state": "live",
            "fallback_used": False,
            "policy_version": "policy_v1",
            "ranking_version": "mission_ranker_v1",
            "suggestions": [],
            "trace": {"sourceState": "live"},
        }
    )

    assert response.mission_set_id == "mission-set-2026-05-16"
    assert response.source_state == "live"
    assert response.policy_version == "policy_v1"


def test_entitlement_contract_shape_matches_commercial_scope():
    contract = EntitlementContract.model_validate(
        {
            "plan": "premium",
            "quota": {
                "daily_mission_refreshes": 6,
                "ai_assisted_captures": 20,
                "export_bundles": 3,
            },
            "trial_status": "active",
            "billing_provider": "disabled",
            "renewal_state": "trial",
        }
    )

    assert contract.plan == "premium"
    assert contract.quota.export_bundles == 3
    assert contract.renewal_state == "trial"


def test_evidence_item_contract_preserves_privacy_bounded_fields():
    item = EvidenceItem.model_validate(
        {
            "evidence_id": "evidence-1",
            "source_type": "capture",
            "local_payload_ref": "vault://capture/1",
            "privacy_class": "ai_allowed",
            "allowed_for_ai": True,
            "created_at": datetime(2026, 5, 16, tzinfo=UTC),
            "hash": "abc123",
        }
    )

    assert item.privacy_class == "ai_allowed"
    assert item.allowed_for_ai is True
    assert item.hash == "abc123"


def test_privacy_job_contract_supports_export_and_delete_audits():
    job = PrivacyJob.model_validate(
        {
            "job_id": "privacy-job-1",
            "kind": "export",
            "status": "completed",
            "audit_ref": "audit-123",
            "trace": {"sourceState": "local"},
        }
    )

    assert job.kind == "export"
    assert job.status == "completed"
    assert job.audit_ref == "audit-123"
