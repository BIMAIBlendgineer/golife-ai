from app.providers.factory import build_provider
from app.feedback_store import MissionFeedbackStore
from app.providers.mock import MockLLMProvider
from app.schemas import MissionFeedbackRequest
from app.settings import Settings


def _event(event_id: str, domain: str, privacy_level: str, event_type: str = "logged") -> dict:
    return {
        "event_id": event_id,
        "user_id": "user-1",
        "domain": domain,
        "event_type": event_type,
        "timestamp": "2026-04-24T10:00:00Z",
        "payload": {"value": 1},
        "source": "manual",
        "privacy_level": privacy_level,
    }


def test_health_reports_mock_mode(client):
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert data["active_provider"] == "mock"
    assert data["mock_mode"] is True


def test_suggestions_filter_non_ai_events_and_include_trace(client):
    response = client.post(
        "/v1/suggestions/generate",
        json={
            "user_id": "user-1",
            "allowed_domains": ["task", "habit"],
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["task", "habit"]},
            "life_events": [
                _event("evt-1", "task", "ai_allowed"),
                _event("evt-2", "habit", "ai_allowed"),
                _event("evt-3", "finance", "local_only"),
            ],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert 1 <= len(data["suggestions"]) <= 3
    assert data["trace"]["validate_consent"]["filtered_events_count"] == 1
    assert data["trace"]["generate_candidates"]["mock"] is True
    assert data["suggestions"][0]["requires_confirmation"] is True


def test_task_rewrite_rejects_non_ai_allowed_payload(client):
    response = client.post(
        "/v1/tasks/rewrite",
        json={
            "user_id": "user-1",
            "task_title": "Preparar presupuesto semanal",
            "privacy_level": "local_only",
        },
    )
    assert response.status_code == 403


def test_task_rewrite_returns_structured_steps(client):
    response = client.post(
        "/v1/tasks/rewrite",
        json={
            "user_id": "user-1",
            "task_title": "Preparar presupuesto semanal",
            "privacy_level": "ai_allowed",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data["rewrites"]) >= 2
    assert data["trace"]["provider"] == "mock"
    assert all(step["estimated_minutes"] > 0 for step in data["rewrites"])


def test_finance_reflect_avoids_regulated_advice_terms(client):
    response = client.post(
        "/v1/finance/reflect",
        json={
            "user_id": "user-1",
            "allowed_domains": ["finance"],
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["finance"]},
            "life_events": [_event("evt-1", "finance", "ai_allowed")],
        },
    )
    assert response.status_code == 200
    body = response.json()["suggestions"][0]["body"].lower()
    assert "invest" not in body
    assert "stock" not in body


def test_provider_factory_falls_back_to_mock_without_api_key():
    provider = build_provider(
        Settings(
            ai_gateway_enable_mock=False,
            llm_provider="openrouter",
            openrouter_api_key=None,
        )
    )
    assert isinstance(provider, MockLLMProvider)


def test_feedback_endpoint_stores_structured_feedback(client):
    response = client.post(
        "/v1/feedback",
        json={
            "user_id": "user-1",
            "suggestion_id": "mock-daily-task-habit",
            "status": "useful",
            "notes": "This mission matched the actual day.",
            "trace": {"screen": "dashboard"},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["stored"] is True
    assert data["feedback_id"].startswith("feedback-")
    assert data["trace"]["status"] == "useful"


def test_feedback_store_persists_items(tmp_path):
    store_path = tmp_path / "feedback.json"
    store = MissionFeedbackStore(store_path)
    feedback_id = store.record(
        MissionFeedbackRequest(
            user_id="user-1",
            suggestion_id="mission-1",
            status="useful",
            notes="kept locally",
            trace={"source": "test"},
        )
    )
    assert feedback_id.startswith("feedback-")
    reloaded_store = MissionFeedbackStore(store_path)
    items = reloaded_store.all()
    assert len(items) == 1
    assert items[0]["status"] == "useful"
