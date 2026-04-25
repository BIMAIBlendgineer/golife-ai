from fastapi.testclient import TestClient

from app.main import create_app
from app.providers.factory import build_provider
from app.feedback_store import MissionFeedbackStore
from app.providers.mock import MockLLMProvider
from app.providers.base import LLMProvider
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


class FakeOperationalClient:
    def __init__(self) -> None:
        self.usage_events: list[dict] = []
        self.invocations: list[dict] = []
        self.mission_batches: list[list[dict]] = []
        self.feedback_items: list[dict] = []
        self.safety_batches: list[list[dict]] = []
        self.model_settings: list[dict] = []

    async def record_usage_event(self, payload: dict) -> bool:
        self.usage_events.append(payload)
        return True

    async def record_ai_invocation(self, payload: dict) -> bool:
        self.invocations.append(payload)
        return True

    async def record_mission_audits(self, payload: list[dict]) -> bool:
        self.mission_batches.append(payload)
        return True

    async def record_feedback_audit(self, payload: dict) -> bool:
        self.feedback_items.append(payload)
        return True

    async def record_safety_events(self, payload: list[dict]) -> bool:
        self.safety_batches.append(payload)
        return True

    async def record_model_settings(self, payload: dict) -> bool:
        self.model_settings.append(payload)
        return True


class SemanticClassificationProvider(LLMProvider):
    provider_name = "semantic-openrouter"

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict,
        response_schema: dict | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ):
        if user_payload.get("multi_item"):
            return {
                "items": [
                    {
                        "text": "Compre cafe 4.50",
                        "domain": "finance",
                        "event_type": "expense_logged",
                        "confidence": 0.9,
                        "rationale": "Detected finance language.",
                        "hints": {"amount": 4.5},
                    },
                    {
                        "text": "la lechuga vence manana",
                        "domain": "pantry",
                        "event_type": "ingredient_flagged",
                        "confidence": 0.87,
                        "rationale": "Detected expiry wording.",
                        "hints": {"expiry_hint": "manana"},
                    },
                ],
                "_provider_meta": {
                    "provider": self.provider_name,
                    "model": "openai/gpt-4.1-mini",
                },
            }
        return {
            "domain": "pantry",
            "event_type": "ingredient_flagged",
            "confidence": 0.91,
            "rationale": "Detected pantry expiry language.",
            "_provider_meta": {
                "provider": self.provider_name,
                "model": "openai/gpt-4.1-mini",
            },
        }

    async def runtime_flags(self) -> dict[str, bool]:
        return {"semantic_classifier": True}


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
    assert len(data["suggestions"]) == 3
    assert data["trace"]["validate_consent"]["filtered_events_count"] == 1
    assert data["trace"]["generate_candidates"]["mock"] is True
    assert "feedback_learning" in data["trace"]["nodes"]
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
            routing_control_enabled=False,
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


def test_event_classification_endpoint_routes_capture_text(client):
    response = client.post(
        "/v1/events/classify",
        json={
            "user_id": "user-1",
            "text": "Compre cafe y pague 4.50 antes de entrar a trabajar.",
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["finance"]},
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["domain"] == "finance"
    assert data["event_type"] == "expense_logged"
    assert data["trace"]["classifier"] == "deterministic_capture_router"


def test_event_classification_uses_semantic_provider_when_flag_enabled(tmp_path):
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=False,
            llm_provider="openrouter",
            routing_control_enabled=False,
            openrouter_api_key="test-key",
            feedback_store_path=str(tmp_path / "mission_feedback.json"),
        ),
        provider=SemanticClassificationProvider(),
    )
    client = TestClient(app)

    response = client.post(
        "/v1/events/classify",
        json={
            "user_id": "user-1",
            "text": "The spinach expires tomorrow.",
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["pantry"]},
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert data["domain"] == "pantry"
    assert data["event_type"] == "ingredient_flagged"
    assert data["trace"]["classifier"] == "semantic_openrouter"


def test_event_parse_endpoint_splits_multi_item_capture(client):
    response = client.post(
        "/v1/events/parse",
        json={
            "user_id": "user-1",
            "text": "Compre cafe 4.50, la lechuga vence manana y debo pagar internet",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["finance", "pantry", "task"],
            },
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 3
    assert data["items"][0]["domain"] == "finance"
    assert data["items"][1]["domain"] == "pantry"
    assert data["items"][2]["domain"] == "task"
    assert data["trace"]["parser"] == "deterministic_capture_parser"


def test_event_parse_uses_semantic_provider_when_flag_enabled(tmp_path):
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=False,
            llm_provider="openrouter",
            routing_control_enabled=False,
            openrouter_api_key="test-key",
            feedback_store_path=str(tmp_path / "mission_feedback.json"),
        ),
        provider=SemanticClassificationProvider(),
    )
    client = TestClient(app)

    response = client.post(
        "/v1/events/parse",
        json={
            "user_id": "user-1",
            "text": "Compre cafe 4.50, la lechuga vence manana",
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["finance", "pantry"],
            },
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["items"]) == 2
    assert data["items"][0]["domain"] == "finance"
    assert data["trace"]["parser"] == "semantic_openrouter"


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


def test_feedback_summary_is_isolated_per_user(tmp_path):
    store = MissionFeedbackStore(tmp_path / "feedback.json")
    store.record(
        MissionFeedbackRequest(
            user_id="user-1",
            suggestion_id="mission-1",
            status="useful",
            domain_targets=["task"],
        )
    )
    store.record(
        MissionFeedbackRequest(
            user_id="user-2",
            suggestion_id="mission-1",
            status="rejected",
            domain_targets=["task"],
        )
    )

    user_one_summary = store.summarize("user-1")
    user_two_summary = store.summarize("user-2")

    assert user_one_summary["item_count"] == 1
    assert user_one_summary["totals"]["useful"] == 1
    assert "rejected" not in user_one_summary["totals"]
    assert user_two_summary["totals"]["rejected"] == 1


def test_feedback_summary_is_visible_in_followup_daily_plan(client):
    feedback_response = client.post(
        "/v1/feedback",
        json={
            "user_id": "user-1",
            "suggestion_id": "mock-daily-task-habit",
            "status": "useful",
            "domain_targets": ["task", "habit"],
            "recommendation_type": "mission",
            "trace": {"screen": "dashboard"},
        },
    )
    assert feedback_response.status_code == 200

    response = client.post(
        "/v1/missions/daily",
        json={
            "user_id": "user-1",
            "allowed_domains": ["task", "habit"],
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["task", "habit"]},
            "life_events": [
                _event("evt-1", "task", "ai_allowed"),
                _event("evt-2", "habit", "ai_allowed"),
            ],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert "feedback_learning" in data["trace"]["nodes"]
    assert data["trace"]["feedback_learning"]["totals"]["useful"] == 1


def test_feedback_from_other_user_does_not_change_daily_plan_trace(client):
    feedback_response = client.post(
        "/v1/feedback",
        json={
            "user_id": "user-2",
            "suggestion_id": "mock-daily-task-habit",
            "status": "rejected",
            "domain_targets": ["task", "habit"],
            "recommendation_type": "mission",
        },
    )
    assert feedback_response.status_code == 200

    response = client.post(
        "/v1/missions/daily",
        json={
            "user_id": "user-1",
            "allowed_domains": ["task", "habit"],
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["task", "habit"]},
            "life_events": [
                _event("evt-1", "task", "ai_allowed"),
                _event("evt-2", "habit", "ai_allowed"),
            ],
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data["trace"]["feedback_learning"]["totals"] == {}


def test_daily_mission_reports_operational_events(tmp_path):
    operational_client = FakeOperationalClient()
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=True,
            llm_provider="openrouter",
            feedback_store_path=str(tmp_path / "mission_feedback.json"),
            operational_backend_enabled=True,
        ),
        provider=MockLLMProvider(),
        operational_client=operational_client,
    )
    client = TestClient(app)

    response = client.post(
        "/v1/missions/daily",
        json={
            "user_id": "user-1",
            "allowed_domains": ["finance", "pantry"],
            "privacy_settings": {
                "ai_enabled": True,
                "allowed_domains": ["finance", "pantry"],
            },
            "life_events": [
                _event("evt-1", "finance", "ai_allowed"),
                _event("evt-2", "pantry", "ai_allowed"),
            ],
        },
    )

    assert response.status_code == 200
    assert len(operational_client.usage_events) == 1
    assert operational_client.usage_events[0]["event_type"] == "daily_plan_requested"
    assert len(operational_client.invocations) == 1
    assert operational_client.invocations[0]["endpoint"] == "/v1/missions/daily"
    assert len(operational_client.mission_batches) == 1
    assert len(operational_client.mission_batches[0]) == 3
    assert len(operational_client.model_settings) == 1


def test_classification_and_feedback_report_operational_audits(tmp_path):
    operational_client = FakeOperationalClient()
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=True,
            llm_provider="openrouter",
            feedback_store_path=str(tmp_path / "mission_feedback.json"),
            operational_backend_enabled=True,
        ),
        provider=MockLLMProvider(),
        operational_client=operational_client,
    )
    client = TestClient(app)

    classify_response = client.post(
        "/v1/events/classify",
        json={
            "user_id": "user-1",
            "text": "Compre cafe y pague 4.50 antes de entrar a trabajar.",
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["finance"]},
        },
    )
    feedback_response = client.post(
        "/v1/feedback",
        json={
            "user_id": "user-1",
            "suggestion_id": "mock-daily-task-habit",
            "status": "completed",
            "notes": "finished it",
            "domain_targets": ["task"],
            "recommendation_type": "mission",
        },
    )
    parse_response = client.post(
        "/v1/events/parse",
        json={
            "user_id": "user-1",
            "text": "Compre cafe 4.50 y la lechuga vence manana",
            "privacy_settings": {"ai_enabled": True, "allowed_domains": ["finance", "pantry"]},
        },
    )

    assert classify_response.status_code == 200
    assert feedback_response.status_code == 200
    assert parse_response.status_code == 200
    assert len(operational_client.usage_events) == 3
    assert operational_client.usage_events[0]["event_type"] == "capture_classification_requested"
    assert operational_client.usage_events[1]["event_type"] == "mission_feedback_recorded"
    assert operational_client.usage_events[2]["event_type"] == "capture_parse_requested"
    assert len(operational_client.invocations) == 2
    assert operational_client.invocations[0]["endpoint"] == "/v1/events/classify"
    assert operational_client.invocations[1]["endpoint"] == "/v1/events/parse"
    assert len(operational_client.feedback_items) == 1
    assert operational_client.feedback_items[0]["status"] == "completed"


def test_task_rewrite_reports_operational_events(tmp_path):
    operational_client = FakeOperationalClient()
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=True,
            llm_provider="openrouter",
            feedback_store_path=str(tmp_path / "mission_feedback.json"),
            operational_backend_enabled=True,
        ),
        provider=MockLLMProvider(),
        operational_client=operational_client,
    )
    client = TestClient(app)

    response = client.post(
        "/v1/tasks/rewrite",
        json={
            "user_id": "user-1",
            "task_title": "Prepare weekly budget",
            "privacy_level": "ai_allowed",
        },
    )

    assert response.status_code == 200
    assert len(operational_client.usage_events) == 1
    assert operational_client.usage_events[0]["event_type"] == "task_rewrite_requested"
    assert len(operational_client.invocations) == 1
    assert operational_client.invocations[0]["endpoint"] == "/v1/tasks/rewrite"
    assert operational_client.invocations[0]["status"] == "success"


def test_task_rewrite_privacy_rejection_reports_safety(tmp_path):
    operational_client = FakeOperationalClient()
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=True,
            llm_provider="openrouter",
            feedback_store_path=str(tmp_path / "mission_feedback.json"),
            operational_backend_enabled=True,
        ),
        provider=MockLLMProvider(),
        operational_client=operational_client,
    )
    client = TestClient(app)

    response = client.post(
        "/v1/tasks/rewrite",
        json={
            "user_id": "user-1",
            "task_title": "Prepare weekly budget",
            "privacy_level": "local_only",
        },
    )

    assert response.status_code == 403
    assert len(operational_client.usage_events) == 1
    assert len(operational_client.invocations) == 1
    assert operational_client.invocations[0]["status"] == "error"
    assert len(operational_client.safety_batches) == 1
    assert operational_client.safety_batches[0][0]["rule"] == "task_rewrite_requires_ai_allowed"
