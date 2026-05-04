import asyncio
from typing import Any

import pytest

from app.errors import AITemporarilyUnavailableError
from app.providers.openrouter import OpenRouterProvider
from app.routing_config_client import (
    GatewayRoutingKey,
    ModelSelectionSnapshot,
    RoutingConfig,
    RoutingConfigResolution,
    RoutingProfile,
)
from app.settings import Settings


def _routing_config() -> RoutingConfig:
    return RoutingConfig(
        config_source="live",
        generated_at="2026-04-24T00:00:00Z",
        openrouter_keys=[
            GatewayRoutingKey(
                key_id="key-a",
                label="Key A",
                secret="sk-or-v1-key-a",
                priority=0,
                status="healthy",
            ),
            GatewayRoutingKey(
                key_id="key-b",
                label="Key B",
                secret="sk-or-v1-key-b",
                priority=1,
                status="healthy",
            ),
        ],
        routing_profiles=[
            RoutingProfile(
                capability="daily_plan",
                strategy="quality_first",
                min_context_length=32000,
                required_parameters=["response_format", "temperature", "max_tokens"],
                preferred_max_latency_seconds=6.0,
                preferred_min_throughput_tokens_per_second=20.0,
                retry_policy={"key_retries": 2, "parse_retries": 1},
                enabled=True,
            ),
            RoutingProfile(
                capability="task_rewrite",
                strategy="quality_first",
                min_context_length=16000,
                required_parameters=["response_format", "temperature", "max_tokens"],
                preferred_max_latency_seconds=4.0,
                preferred_min_throughput_tokens_per_second=30.0,
                retry_policy={"key_retries": 2, "parse_retries": 1},
                enabled=True,
            ),
        ],
        selection_snapshots=[
            ModelSelectionSnapshot(
                capability="daily_plan",
                rank_index=0,
                model_id="anthropic/claude-sonnet-4",
                score=0.96,
                selection_reason={"model_name": "Claude Sonnet 4"},
            ),
            ModelSelectionSnapshot(
                capability="daily_plan",
                rank_index=1,
                model_id="openai/gpt-4.1-mini",
                score=0.95,
                selection_reason={"model_name": "GPT-4.1 mini"},
            ),
            ModelSelectionSnapshot(
                capability="daily_plan",
                rank_index=2,
                model_id="google/gemini-2.5-flash",
                score=0.94,
                selection_reason={"model_name": "Gemini 2.5 Flash"},
            ),
            ModelSelectionSnapshot(
                capability="task_rewrite",
                rank_index=0,
                model_id="openai/gpt-4.1-mini",
                score=0.94,
                selection_reason={"model_name": "GPT-4.1 mini"},
            ),
            ModelSelectionSnapshot(
                capability="task_rewrite",
                rank_index=1,
                model_id="google/gemini-2.5-flash",
                score=0.93,
                selection_reason={"model_name": "Gemini 2.5 Flash"},
            ),
            ModelSelectionSnapshot(
                capability="task_rewrite",
                rank_index=2,
                model_id="anthropic/claude-sonnet-4",
                score=0.92,
                selection_reason={"model_name": "Claude Sonnet 4"},
            ),
        ],
        feature_flags={"semantic_classifier": False},
    )


class FakeRoutingClient:
    def __init__(self, config: RoutingConfig):
        self._config = config
        self.events: list[dict[str, Any]] = []

    async def get_config(self) -> RoutingConfigResolution:
        return RoutingConfigResolution(config=self._config, source="live")

    async def record_key_event(self, payload: dict[str, Any]) -> bool:
        self.events.append(payload)
        return True


class StaticRoutingClient:
    def __init__(self, resolution: RoutingConfigResolution):
        self._resolution = resolution

    async def get_config(self) -> RoutingConfigResolution:
        return self._resolution

    async def record_key_event(self, payload: dict[str, Any]) -> bool:
        return True


class FakeResponse:
    def __init__(self, *, status_code: int, payload: dict[str, Any]) -> None:
        self.status_code = status_code
        self._payload = payload

    def raise_for_status(self) -> None:
        if self.status_code >= 400:
            raise RuntimeError(f"HTTP {self.status_code}")

    def json(self) -> dict[str, Any]:
        return self._payload


def test_request_builder_sends_top_three_models_and_provider_preferences(monkeypatch):
    captured: dict[str, Any] = {}

    class FakeAsyncClient:
        def __init__(self, *args, **kwargs) -> None:
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb) -> None:
            return None

        async def post(self, _url: str, *, headers: dict[str, str], json: dict[str, Any]):
            captured["headers"] = headers
            captured["json"] = json
            return FakeResponse(
                status_code=200,
                payload={
                    "model": "openai/gpt-4.1-mini",
                    "choices": [{"message": {"content": '{"suggestions": []}'}}],
                },
            )

    monkeypatch.setattr("app.providers.openrouter.httpx.AsyncClient", FakeAsyncClient)

    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            routing_control_enabled=True,
            openrouter_api_key=None,
        )
    )
    provider.routing_client = FakeRoutingClient(_routing_config())

    payload = asyncio.run(
        provider.complete_json(
            system_prompt="Return JSON only.",
            user_payload={"intent": "daily_mission"},
            response_schema={"type": "object"},
        )
    )

    assert captured["json"]["models"] == [
        "anthropic/claude-sonnet-4",
        "openai/gpt-4.1-mini",
        "google/gemini-2.5-flash",
    ]
    assert captured["json"]["provider"]["allow_fallbacks"] is True
    assert captured["json"]["provider"]["require_parameters"] is True
    assert captured["json"]["provider"]["sort"] == {"by": "throughput", "partition": "none"}
    assert captured["json"]["provider"]["preferred_max_latency"] == {"p90": 6.0}
    assert captured["json"]["provider"]["preferred_min_throughput"] == {"p90": 20.0}
    assert captured["json"]["provider"]["data_collection"] == "deny"
    assert payload["_provider_meta"]["fallback_used"] is True
    assert payload["_provider_meta"]["key_label"] == "Key A"


def test_key_rotation_moves_from_failing_key_to_next_key(monkeypatch):
    authorizations: list[str] = []

    class FakeAsyncClient:
        call_count = 0

        def __init__(self, *args, **kwargs) -> None:
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb) -> None:
            return None

        async def post(self, _url: str, *, headers: dict[str, str], json: dict[str, Any]):
            type(self).call_count += 1
            authorizations.append(headers["Authorization"])
            if type(self).call_count == 1:
                return FakeResponse(status_code=429, payload={"error": {"message": "rate limited"}})
            return FakeResponse(
                status_code=200,
                payload={
                    "model": "anthropic/claude-sonnet-4",
                    "choices": [{"message": {"content": '{"rewrites": [{"description": "Recovered"}]}'}}],
                },
            )

    monkeypatch.setattr("app.providers.openrouter.httpx.AsyncClient", FakeAsyncClient)

    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            routing_control_enabled=True,
            openrouter_api_key=None,
        )
    )
    routing_client = FakeRoutingClient(_routing_config())
    provider.routing_client = routing_client

    payload = asyncio.run(
        provider.complete_json(
            system_prompt="Return JSON only.",
            user_payload={"intent": "task_rewrite"},
            response_schema={"type": "object"},
        )
    )

    assert authorizations == [
        "Bearer sk-or-v1-key-a",
        "Bearer sk-or-v1-key-b",
    ]
    assert payload["_provider_meta"]["key_label"] == "Key B"
    assert routing_client.events[0]["event_type"] == "failure"
    assert routing_client.events[1]["event_type"] == "success"


def test_all_key_exhaustion_returns_stable_ai_unavailable(monkeypatch):
    class FakeAsyncClient:
        def __init__(self, *args, **kwargs) -> None:
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb) -> None:
            return None

        async def post(self, _url: str, *, headers: dict[str, str], json: dict[str, Any]):
            return FakeResponse(status_code=503, payload={"error": {"message": "down"}})

    monkeypatch.setattr("app.providers.openrouter.httpx.AsyncClient", FakeAsyncClient)

    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            routing_control_enabled=True,
            openrouter_api_key=None,
        )
    )
    provider.routing_client = FakeRoutingClient(_routing_config())

    with pytest.raises(AITemporarilyUnavailableError) as exc:
        asyncio.run(
            provider.complete_json(
                system_prompt="Return JSON only.",
                user_payload={"intent": "daily_mission"},
                response_schema={"type": "object"},
            )
        )

    assert exc.value.code == "ai_temporarily_unavailable"


def test_health_reports_single_key_local_env_when_routing_is_disabled():
    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            routing_control_enabled=False,
            openrouter_api_key="test-key",
        )
    )

    health = asyncio.run(provider.health_snapshot())

    assert health["routing_mode"] == "local_env_fallback"
    assert health["effective_routing_mode"] == "single_key"
    assert health["config_source"] == "local_env"
    assert health["effective_config_source"] == "local_env"
    assert health["control_plane_config_source"] == "fallback"
    assert health["active_key_source"] == "local_env"
    assert health["active_key_count"] == 1


def test_cached_unusable_control_plane_falls_back_to_local_env_health(monkeypatch):
    class FakeAsyncClient:
        def __init__(self, *args, **kwargs) -> None:
            pass

        async def __aenter__(self):
            return self

        async def __aexit__(self, exc_type, exc, tb) -> None:
            return None

        async def post(self, *args, **kwargs) -> FakeResponse:
            return FakeResponse(
                status_code=200,
                payload={
                    "model": "google/gemini-2.0-flash-001",
                    "choices": [{"message": {"content": '{"suggestions": []}'}}],
                },
            )

    monkeypatch.setattr("app.providers.openrouter.httpx.AsyncClient", FakeAsyncClient)

    unusable_config = RoutingConfig(
        config_source="cached",
        generated_at="2026-04-24T00:00:00Z",
        openrouter_keys=[],
        routing_profiles=[],
        selection_snapshots=[],
        feature_flags={},
    )
    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            routing_control_enabled=True,
            openrouter_api_key="test-key",
        )
    )
    provider.routing_client = StaticRoutingClient(
        RoutingConfigResolution(config=unusable_config, source="cached")
    )

    payload = asyncio.run(
        provider.complete_json(
            system_prompt="Return JSON only.",
            user_payload={"intent": "daily_mission"},
            response_schema={"type": "object"},
        )
    )
    health = asyncio.run(provider.health_snapshot())

    assert payload["_provider_meta"]["routing_mode"] == "single_key"
    assert payload["_provider_meta"]["effective_routing_mode"] == "single_key"
    assert payload["_provider_meta"]["config_source"] == "local_env"
    assert payload["_provider_meta"]["control_plane_config_source"] == "cached"
    assert payload["_provider_meta"]["active_key_source"] == "local_env"
    assert health["routing_mode"] == "local_env_fallback"
    assert health["effective_routing_mode"] == "single_key"
    assert health["config_source"] == "local_env"
    assert health["control_plane_config_source"] == "cached"
    assert health["active_key_source"] == "local_env"
    assert health["active_key_count"] == 1


def test_live_control_plane_health_reports_multi_key_mode():
    provider = OpenRouterProvider(
        Settings(
            ai_gateway_enable_mock=False,
            routing_control_enabled=True,
            openrouter_api_key=None,
            routing_backend_internal_token="routing-prod-token",
        )
    )
    provider.routing_client = StaticRoutingClient(
        RoutingConfigResolution(config=_routing_config(), source="live")
    )

    health = asyncio.run(provider.health_snapshot())

    assert health["routing_mode"] == "multi_key_control_plane"
    assert health["effective_routing_mode"] == "multi_key_control_plane"
    assert health["config_source"] == "live"
    assert health["effective_config_source"] == "live"
    assert health["control_plane_config_source"] == "live"
    assert health["active_key_source"] == "control_plane"
    assert health["active_key_count"] == 2
