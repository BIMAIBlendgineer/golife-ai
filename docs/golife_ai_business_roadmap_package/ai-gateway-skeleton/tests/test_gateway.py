from __future__ import annotations

from datetime import UTC, datetime

from fastapi.testclient import TestClient

from app.main import create_app
from app.provider import AIProvider, MockProvider, ProviderChain
from app.schemas import DayPlanResponse


def _base_event(domain: str, event_type: str, payload: dict[str, object]) -> dict[str, object]:
    return {
        "id": f"{domain}-1",
        "user_id": "user-123",
        "domain": domain,
        "event_type": event_type,
        "occurred_at": datetime(2026, 4, 24, 8, 0, tzinfo=UTC).isoformat(),
        "payload": payload,
        "source": "manual",
        "privacy_level": "normal",
    }


class FailingProvider(AIProvider):
    name = "failing"

    async def complete_structured(self, *, operation, prompt, schema, fallback_payload):
        raise RuntimeError("synthetic failure")


def test_daily_plan_schema_and_missions():
    client = TestClient(create_app())
    payload = {
        "user_id": "user-123",
        "privacy": {
            "ai_enabled": True,
            "allowed_domains": ["task", "habit", "money", "pantry", "planning"],
        },
        "events": [
            _base_event("task", "task_captured", {"title": "finish quarterly report"}),
            _base_event("habit", "habit_logged", {"name": "stretching"}),
            _base_event("money", "expense_logged", {"amount": "4.50 coffee"}),
            _base_event("pantry", "pantry_item_captured", {"item": "rice"}),
        ],
        "goals": ["finish quarterly report"],
        "constraints": {"energy": "medium"},
    }
    response = client.post("/ai/daily-plan", json=payload)
    assert response.status_code == 200
    data = response.json()
    parsed = DayPlanResponse.model_validate(data)
    assert 3 <= len(parsed.missions) <= 5
    assert all(mission.evidence for mission in parsed.missions)
    assert all(mission.uncertainty for mission in parsed.missions)
    assert parsed.trace.agent == "DailyMissionAgent"


def test_provider_chain_fallback_to_mock_provider():
    provider_chain = ProviderChain([FailingProvider(), MockProvider()])
    client = TestClient(create_app(provider_chain=provider_chain))
    payload = {
        "user_id": "user-123",
        "privacy": {"ai_enabled": True, "allowed_domains": ["task", "planning"]},
        "events": [_base_event("task", "task_captured", {"title": "submit invoice"})],
        "goals": ["submit invoice"],
        "constraints": {},
    }
    response = client.post("/ai/daily-plan", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["mock"] is True
    assert data["trace"]["used_fallback"] is True


def test_safety_refusal_for_professional_advice():
    client = TestClient(create_app())
    payload = {
        "user_id": "user-123",
        "privacy": {"ai_enabled": True, "allowed_domains": ["task"]},
        "events": [],
        "task_text": "give me legal advice to evade taxes",
        "blockers": [],
        "constraints": {},
    }
    response = client.post("/ai/task-diagnosis", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["blocked_items"] == ["safety_refusal"]
    assert data["trace"]["safety"]["allowed"] is False


def test_event_classification():
    client = TestClient(create_app())
    response = client.post(
        "/ai/classify-event",
        json={"text": "bought coffee for 4.50 eur this morning"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["domain"] == "money"
    assert data["event_type"] == "expense_logged"
