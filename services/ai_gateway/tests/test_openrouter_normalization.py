import asyncio
from typing import Any

from fastapi.testclient import TestClient

from app.main import create_app
from app.providers.base import LLMProvider
from app.providers.openrouter import OpenRouterProvider
from app.settings import Settings


def _event(event_id: str, domain: str, event_type: str = "logged") -> dict[str, Any]:
    return {
        "event_id": event_id,
        "user_id": "user-1",
        "domain": domain,
        "event_type": event_type,
        "timestamp": "2026-04-24T10:00:00Z",
        "payload": {"value": 1},
        "source": "manual",
        "privacy_level": "ai_allowed",
    }


class ArrayTaskRewriteProvider(LLMProvider):
    provider_name = "array-task-rewrite"

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ) -> Any:
        return [
            {
                "step_id": 1,
                "description": "Confirm the demo closure requirements and schedule.",
                "confirmation_required": True,
            },
            {
                "step_id": 2,
                "description": "Write the release summary and verify open questions.",
                "confirmation_required": False,
                "minutes": 15,
                "confidence": "high",
            },
        ]


class ExternalSuggestionProvider(LLMProvider):
    provider_name = "external-suggestion"

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ) -> Any:
        return {
            "suggestions": [
                {
                    "suggestion_id": "sug-pan-real-1",
                    "domain": "pantry",
                    "type": "eat_soon",
                    "reason": "Use spinach today before buying more food.",
                    "evidence": [
                        {
                            "event_id": "evt-pan-real-1",
                            "relevance": "high",
                            "explanation": "Spinach expires tomorrow.",
                        }
                    ],
                    "uncertainty": "low",
                    "actionable": True,
                },
                {
                    "suggestion_id": "sug-fin-real-1",
                    "domain": "finance",
                    "type": "track_spending",
                    "reason": "Delay extra grocery spend until pantry items are used.",
                    "evidence": [
                        {
                            "event_id": "evt-fin-real-1",
                            "relevance": "medium",
                            "explanation": "Food spending is already elevated this week.",
                        }
                    ],
                    "uncertainty": "medium",
                },
            ]
        }


def _real_provider_settings(tmp_path) -> Settings:
    return Settings(
        ai_gateway_enable_mock=False,
        llm_provider="openrouter",
        openrouter_api_key="test-key",
        routing_control_enabled=False,
        feedback_store_path=str(tmp_path / "mission_feedback.json"),
    )


def test_openrouter_wraps_json_array_payloads(monkeypatch):
    class FakeResponse:
        def raise_for_status(self) -> None:
            return None

        def json(self) -> dict[str, Any]:
            return {
                "choices": [
                    {
                        "message": {
                            "content": """
                            ```json
                            [
                              {"description": "Confirm the final scope."}
                            ]
                            ```
                            """
                        }
                    }
                ]
            }

    class FakeAsyncClient:
        def __init__(self, *args, **kwargs) -> None:
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb) -> None:
            return None

        async def post(self, *args, **kwargs) -> FakeResponse:
            return FakeResponse()

    monkeypatch.setattr("app.providers.openrouter.httpx.AsyncClient", FakeAsyncClient)

    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            openrouter_api_key="test-key",
            routing_control_enabled=False,
        )
    )
    payload = asyncio.run(
        provider.complete_json(
            system_prompt="Return JSON only.",
            user_payload={"intent": "task_rewrite"},
            response_schema={"type": "array"},
        )
    )

    assert payload["items"][0]["description"] == "Confirm the final scope."
    assert payload["_provider_meta"]["provider"] == "openrouter"


def test_openrouter_retries_after_invalid_json(monkeypatch):
    class FakeResponse:
        def __init__(self, content: str) -> None:
            self._content = content

        def raise_for_status(self) -> None:
            return None

        def json(self) -> dict[str, Any]:
            return {"choices": [{"message": {"content": self._content}}]}

    class FakeAsyncClient:
        call_count = 0

        def __init__(self, *args, **kwargs) -> None:
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb) -> None:
            return None

        async def post(self, *args, **kwargs) -> FakeResponse:
            type(self).call_count += 1
            if type(self).call_count == 1:
                return FakeResponse('{"rewrites": [{"description": "broken"}')
            return FakeResponse('{"rewrites": [{"description": "recovered"}]}')

    monkeypatch.setattr("app.providers.openrouter.httpx.AsyncClient", FakeAsyncClient)

    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            openrouter_api_key="test-key",
            routing_control_enabled=False,
        )
    )
    payload = asyncio.run(
        provider.complete_json(
            system_prompt="Return JSON only.",
            user_payload={"intent": "task_rewrite"},
            response_schema={"type": "object"},
        )
    )

    assert FakeAsyncClient.call_count == 2
    assert payload["rewrites"][0]["description"] == "recovered"


def test_task_rewrite_accepts_provider_array_shape(tmp_path):
    app = create_app(
        settings=_real_provider_settings(tmp_path),
        provider=ArrayTaskRewriteProvider(),
    )
    client = TestClient(app)

    response = client.post(
        "/v1/tasks/rewrite",
        json={
            "user_id": "user-1",
            "task_title": "Close the demo checklist",
            "privacy_level": "ai_allowed",
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["rewrites"]) == 2
    assert data["rewrites"][0]["title"] == "Confirm the demo closure requirements and schedule."
    assert data["rewrites"][1]["confidence"] >= 0.8
    assert data["trace"]["provider"] == "array-task-rewrite"
    assert data["trace"]["rewrite_count"] == 2


def test_daily_mission_normalizes_external_suggestion_schema(tmp_path):
    app = create_app(
        settings=_real_provider_settings(tmp_path),
        provider=ExternalSuggestionProvider(),
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
                _event("evt-fin-real-1", "finance", "expense_logged"),
                _event("evt-pan-real-1", "pantry", "ingredient_flagged"),
            ],
        },
    )

    assert response.status_code == 200
    data = response.json()
    assert len(data["suggestions"]) == 2
    assert data["suggestions"][0]["domain_targets"] == ["pantry"]
    assert data["suggestions"][0]["recommendation_type"] == "mission"
    assert data["suggestions"][0]["evidence"][0]["entity_id"] == "evt-pan-real-1"
    assert data["suggestions"][0]["uncertainty"] == "Model reported low uncertainty."
    assert data["trace"]["active_provider"] == "external-suggestion"
