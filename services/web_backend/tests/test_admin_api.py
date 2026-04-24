from fastapi.testclient import TestClient

from app.main import create_app
from app.repository import OperationalRepository
from app.settings import Settings


def _admin_headers() -> dict[str, str]:
    return {"x-admin-token": "test-admin-token"}


def _ingestion_headers() -> dict[str, str]:
    return {"x-ingestion-token": "test-ingestion-token"}


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


def test_users_and_detail_are_available(client):
    users_response = client.get("/admin/users", headers=_admin_headers())
    assert users_response.status_code == 200
    users = users_response.json()
    assert len(users) >= 1

    detail_response = client.get(
        f"/admin/users/{users[0]['user_id']}",
        headers=_admin_headers(),
    )
    assert detail_response.status_code == 200
    assert detail_response.json()["user_id"] == users[0]["user_id"]


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


def test_models_and_support_routes_exist(client):
    models = client.get("/admin/models", headers=_admin_headers())
    support = client.get("/admin/support/export-delete", headers=_admin_headers())
    assert models.status_code == 200
    assert support.status_code == 200
    assert models.json()["active_provider"] == "openrouter"
    assert len(support.json()) >= 1


def test_internal_ingestion_populates_live_metrics(tmp_path):
    app = create_app(
        settings=Settings(
            admin_token="test-admin-token",
            ingestion_token="test-ingestion-token",
            operational_database_path=str(tmp_path / "live.db"),
            seed_demo_data=False,
        ),
        repository=OperationalRepository(
            str(tmp_path / "live.db"),
            seed_demo_data=False,
        ),
    )
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
    health = client.get("/health")

    assert dashboard.status_code == 200
    assert dashboard.json()["wau"] == 1
    assert dashboard.json()["mission_completion_rate"] == 1.0
    assert users.status_code == 200
    assert users.json()[0]["user_id"] == "live-user"
    assert costs.status_code == 200
    assert costs.json()[0]["endpoint"] == "/v1/missions/daily"
    assert health.json()["mode"] == "live"
    assert health.json()["last_ingestion_at"] is not None


def test_production_rejects_default_tokens():
    try:
        Settings(environment="production")
    except ValueError as exc:
        assert "dev default" in str(exc)
    else:  # pragma: no cover
        raise AssertionError("Production settings should reject default tokens.")
