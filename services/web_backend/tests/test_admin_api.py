from datetime import UTC, datetime, timedelta

import app.main as main_module
from app.main import create_app
from app.repository import OperationalRepository
from app.schemas import ModelCatalogEntry
from app.settings import Settings


def _admin_headers() -> dict[str, str]:
    return {"x-admin-token": "test-admin-token"}


def _ingestion_headers() -> dict[str, str]:
    return {"x-ingestion-token": "test-ingestion-token"}


def _internal_headers() -> dict[str, str]:
    return {"x-internal-service-token": "test-internal-token"}


def test_health_is_public(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"
    assert response.json()["data_source"] == "sqlite_operational_repository"


def test_admin_routes_require_token(client):
    response = client.get("/admin/dashboard")
    assert response.status_code == 401


def test_dashboard_returns_operational_metrics(client):
    response = client.get("/admin/dashboard", headers=_admin_headers())
    assert response.status_code == 200
    data = response.json()
    assert data["wau"] >= 1
    assert "ai_cost_total_usd" in data
    assert "active_key_count" in data


def test_users_and_detail_are_available(client):
    users_response = client.get("/admin/users", headers=_admin_headers())
    assert users_response.status_code == 200
    users_page = users_response.json()
    users = users_page["items"]
    assert users_page["total"] >= 1
    assert users_page["limit"] == 25
    assert len(users) >= 1
    assert users[0]["email_masked"].endswith("@golife.ai")

    detail_response = client.get(
        f"/admin/users/{users[0]['user_id']}",
        headers=_admin_headers(),
    )
    assert detail_response.status_code == 200
    assert detail_response.json()["user_id"] == users[0]["user_id"]
    assert "email_masked" in detail_response.json()

    usage_response = client.get(
        f"/admin/users/{users[0]['user_id']}/usage",
        headers=_admin_headers(),
    )
    privacy_response = client.get(
        f"/admin/users/{users[0]['user_id']}/privacy",
        headers=_admin_headers(),
    )
    support_response = client.get(
        f"/admin/users/{users[0]['user_id']}/support",
        headers=_admin_headers(),
    )
    assert usage_response.status_code == 200
    assert privacy_response.status_code == 200
    assert support_response.status_code == 200
    assert privacy_response.json()["sensitive_data_excluded"] is True


def test_feature_flag_can_be_updated(client):
    response = client.patch(
        "/admin/feature-flags/multi_event_capture",
        headers=_admin_headers(),
        json={"enabled": True},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["key"] == "multi_event_capture"
    assert body["enabled"] is True


def test_models_support_and_runtime_config_routes_exist(client):
    models = client.get("/admin/models", headers=_admin_headers())
    support = client.get("/admin/support/export-delete", headers=_admin_headers())
    runtime_config = client.get("/public/mobile/runtime-config")
    assert models.status_code == 200
    assert support.status_code == 200
    assert runtime_config.status_code == 200
    assert models.json()["active_provider"] == "openrouter"
    assert len(support.json()) >= 1
    assert runtime_config.json()["gateway_base_url"] == "http://127.0.0.1:8000"
    assert "openrouter_keys" not in runtime_config.json()


def test_organizations_and_plans_routes_exist(client):
    organizations = client.get("/admin/organizations", headers=_admin_headers())
    assert organizations.status_code == 200
    payload = organizations.json()
    assert len(payload) >= 1
    assert payload[0]["organization_id"]

    detail = client.get(
        f"/admin/organizations/{payload[0]['organization_id']}",
        headers=_admin_headers(),
    )
    assert detail.status_code == 200
    assert detail.json()["members"]

    plans = client.get("/admin/plans", headers=_admin_headers())
    assert plans.status_code == 200
    assert len(plans.json()) >= 1


def test_openrouter_keys_are_masked_for_admin_and_decrypted_for_internal(client):
    created = client.post(
        "/admin/openrouter/keys",
        headers=_admin_headers(),
        json={
            "label": "Primary key",
            "secret": "sk-or-v1-abcdefghijklmnopqrstuvwxyz",
            "priority": 1,
            "enabled": True,
        },
    )
    assert created.status_code == 200
    created_body = created.json()
    assert created_body["label"] == "Primary key"
    assert created_body["secret_last4"] == "wxyz"
    assert "secret" not in created_body

    listing = client.get("/admin/openrouter/keys", headers=_admin_headers())
    assert listing.status_code == 200
    assert listing.json()[0]["secret_last4"] == "wxyz"

    internal = client.get("/internal/ai-routing/config", headers=_internal_headers())
    assert internal.status_code == 200
    internal_body = internal.json()
    assert len(internal_body["openrouter_keys"]) == 1
    assert internal_body["openrouter_keys"][0]["secret"] == "sk-or-v1-abcdefghijklmnopqrstuvwxyz"


def test_model_catalog_refresh_and_selection_snapshots(client, monkeypatch):
    now = datetime.now(UTC)

    async def fake_fetch(_base_url: str):
        return [
            ModelCatalogEntry(
                model_id="anthropic/claude-sonnet-4",
                canonical_slug="anthropic/claude-sonnet-4",
                name="Claude Sonnet 4",
                description="Ranked high",
                context_length=200000,
                output_modalities=["text"],
                supported_parameters=["response_format", "temperature", "max_tokens"],
                prompt_price_usd_per_million=3.0,
                completion_price_usd_per_million=15.0,
                request_price_usd=0.0,
                top_provider_json={"max_completion_tokens": 8192},
                architecture_json={"output_modalities": ["text"]},
                expiration_date=now + timedelta(days=7),
                refreshed_at=now,
            ),
            ModelCatalogEntry(
                model_id="openai/gpt-4.1-mini",
                canonical_slug="openai/gpt-4.1-mini",
                name="GPT-4.1 mini",
                description="Reliable",
                context_length=128000,
                output_modalities=["text"],
                supported_parameters=["response_format", "temperature", "max_tokens"],
                prompt_price_usd_per_million=0.8,
                completion_price_usd_per_million=3.2,
                request_price_usd=0.0,
                top_provider_json={"max_completion_tokens": 8192},
                architecture_json={"output_modalities": ["text"]},
                expiration_date=now + timedelta(days=7),
                refreshed_at=now,
            ),
            ModelCatalogEntry(
                model_id="google/gemini-2.5-flash",
                canonical_slug="google/gemini-2.5-flash",
                name="Gemini 2.5 Flash",
                description="Fast",
                context_length=100000,
                output_modalities=["text"],
                supported_parameters=["response_format", "temperature", "max_tokens"],
                prompt_price_usd_per_million=0.4,
                completion_price_usd_per_million=1.6,
                request_price_usd=0.0,
                top_provider_json={"max_completion_tokens": 8192},
                architecture_json={"output_modalities": ["text"]},
                expiration_date=now + timedelta(days=7),
                refreshed_at=now,
            ),
        ]

    monkeypatch.setattr(main_module, "fetch_openrouter_model_catalog", fake_fetch)

    refresh = client.post("/admin/model-catalog/refresh", headers=_admin_headers())
    assert refresh.status_code == 200
    assert len(refresh.json()) == 3

    selections = client.get("/admin/model-selections", headers=_admin_headers())
    assert selections.status_code == 200
    by_capability = [item for item in selections.json() if item["capability"] == "daily_plan"]
    assert len(by_capability) == 3
    assert by_capability[0]["rank_index"] == 0
    assert by_capability[0]["selection_reason"]["model_name"]


def test_routing_profile_can_be_patched(client):
    response = client.patch(
        "/admin/routing-profiles/daily_plan",
        headers=_admin_headers(),
        json={
            "preferred_max_latency_seconds": 5.0,
            "preferred_min_throughput_tokens_per_second": 25.0,
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert body["capability"] == "daily_plan"
    assert body["preferred_max_latency_seconds"] == 5.0
    assert body["preferred_min_throughput_tokens_per_second"] == 25.0


def test_internal_ingestion_populates_live_metrics(tmp_path):
    app = create_app(
        settings=Settings(
            admin_token="test-admin-token",
            ingestion_token="test-ingestion-token",
            internal_service_token="test-internal-token",
            operational_database_path=str(tmp_path / "live.db"),
            seed_demo_data=False,
        ),
        repository=OperationalRepository(
            str(tmp_path / "live.db"),
            seed_demo_data=False,
        ),
    )
    from fastapi.testclient import TestClient

    client = TestClient(app)

    usage_response = client.post(
        "/internal/usage-events",
        headers=_ingestion_headers(),
        json={
            "event_id": "usage-live-1",
            "user_id": "live-user",
            "event_type": "capture_classification_requested",
            "endpoint": "/v1/events/classify",
            "domain": "finance",
            "quantity": 1,
            "created_at": "2026-04-24T12:00:00Z",
            "metadata": {"source": "test"},
        },
    )
    invocation_response = client.post(
        "/internal/ai-invocations",
        headers=_ingestion_headers(),
        json={
            "invocation_id": "invoke-live-1",
            "user_id": "live-user",
            "endpoint": "/v1/missions/daily",
            "provider": "mock",
            "model": "mock",
            "latency_ms": 245.0,
            "fallback": True,
            "suggestions_count": 3,
            "estimated_cost_usd": 0.0,
            "schema_valid": True,
            "status": "success",
            "created_at": "2026-04-24T12:00:01Z",
            "metadata": {"intent": "daily_mission"},
        },
    )
    mission_response = client.post(
        "/internal/mission-audits",
        headers=_ingestion_headers(),
        json=[
            {
                "mission_id": "mission-live-1",
                "user_id": "live-user",
                "title": "Use pantry first",
                "status": "generated",
                "usefulness": None,
                "domains": ["finance", "pantry"],
                "matched_risks": ["food_spend_overlap"],
                "final_score": 0.81,
                "created_at": "2026-04-24T12:00:02Z",
            }
        ],
    )
    feedback_response = client.post(
        "/internal/feedback-audits",
        headers=_ingestion_headers(),
        json={
            "feedback_id": "feedback-live-1",
            "user_id": "live-user",
            "suggestion_id": "mission-live-1",
            "status": "completed",
            "reason": "Useful plan.",
            "domains": ["finance", "pantry"],
            "created_at": "2026-04-24T12:05:00Z",
        },
    )
    safety_response = client.post(
        "/internal/safety-events",
        headers=_ingestion_headers(),
        json=[
            {
                "event_id": "safety-live-1",
                "user_id": "live-user",
                "category": "finance",
                "rule": "regulated_advice",
                "severity": "medium",
                "endpoint": "/v1/missions/daily",
                "created_at": "2026-04-24T12:00:03Z",
            }
        ],
    )

    assert usage_response.status_code == 202
    assert invocation_response.status_code == 202
    assert mission_response.status_code == 202
    assert feedback_response.status_code == 202
    assert safety_response.status_code == 202

    dashboard = client.get("/admin/dashboard", headers=_admin_headers())
    users = client.get("/admin/users", headers=_admin_headers())
    costs = client.get("/admin/ai-costs", headers=_admin_headers())
    feedback = client.get("/admin/feedback", headers=_admin_headers())
    health = client.get("/health")

    assert dashboard.status_code == 200
    assert dashboard.json()["wau"] == 1
    assert dashboard.json()["mission_completion_rate"] == 1.0
    assert users.status_code == 200
    assert users.json()["items"][0]["user_id"] == "live-user"
    assert costs.status_code == 200
    assert costs.json()[0]["endpoint"] == "/v1/missions/daily"
    assert feedback.status_code == 200
    assert feedback.json()[0]["reason"] == "private_note_redacted"
    assert health.json()["mode"] == "live"
    assert health.json()["last_ingestion_at"] is not None


def test_production_rejects_default_tokens():
    try:
        Settings(environment="production")
    except ValueError as exc:
        assert "dev default" in str(exc)
    else:  # pragma: no cover
        raise AssertionError("Production settings should reject default tokens.")


def test_production_requires_master_key():
    try:
        Settings(
            environment="production",
            admin_token="a" * 24,
            ingestion_token="b" * 24,
            internal_service_token="c" * 24,
        )
    except ValueError as exc:
        assert "OPENROUTER_KEYS_MASTER_KEY" in str(exc)
    else:  # pragma: no cover
        raise AssertionError("Production settings should reject the default master key.")
