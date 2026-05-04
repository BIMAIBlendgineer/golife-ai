import json
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from app.main import create_app
from app.providers.base import LLMProvider
from app.settings import Settings


class FixtureSuggestionProvider(LLMProvider):
    provider_name = "fixture-suggestion-provider"

    def __init__(self, suggestions: list[dict]) -> None:
        self._suggestions = suggestions
        self.payloads: list[dict] = []

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict,
        response_schema: dict | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ) -> dict:
        self.payloads.append(user_payload)
        return {"suggestions": self._suggestions}


def _fixture_cases() -> list[dict]:
    fixture_path = Path(__file__).with_name("fixtures") / "mission_ranking_cases.json"
    return json.loads(fixture_path.read_text(encoding="utf-8"))


@pytest.mark.parametrize(
    "case",
    _fixture_cases(),
    ids=[item["case_id"] for item in _fixture_cases()],
)
def test_mission_ranking_evaluation_cases(case, tmp_path):
    provider = FixtureSuggestionProvider(case["suggestions"])
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=False,
            llm_provider="openrouter",
            feedback_store_path=str(tmp_path / f'{case["case_id"]}.json'),
        ),
        provider=provider,
    )

    with TestClient(app) as client:
        for feedback_item in case.get("feedback", []):
            feedback_response = client.post("/v1/feedback", json=feedback_item)
            assert feedback_response.status_code == 200

        response = client.post("/v1/missions/daily", json=case["request"])

    assert response.status_code == 200
    data = response.json()
    assert data["suggestions"][0]["suggestion_id"] == case["expected"]["first_suggestion_id"]

    suggestion_map = {
        item["suggestion_id"]: item
        for item in data["suggestions"]
    }

    for suggestion_id, min_score in case["expected"].get("min_feedback_score", {}).items():
        assert suggestion_map[suggestion_id]["ranking"]["feedback_score"] >= min_score

    for suggestion_id, max_score in case["expected"].get("max_feedback_score", {}).items():
        assert suggestion_map[suggestion_id]["ranking"]["feedback_score"] <= max_score

    for suggestion_id, max_score in case["expected"].get("max_novelty_score", {}).items():
        assert suggestion_map[suggestion_id]["ranking"]["novelty_score"] <= max_score

    filtered_events_count = case["expected"].get("filtered_events_count")
    if filtered_events_count is not None:
        assert data["trace"]["validate_consent"]["filtered_events_count"] == filtered_events_count

    provider_event_domains = case["expected"].get("provider_event_domains")
    if provider_event_domains is not None:
        assert [item["domain"] for item in provider.payloads[-1]["events"]] == provider_event_domains
