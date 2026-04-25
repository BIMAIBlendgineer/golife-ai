from __future__ import annotations

import json
from time import perf_counter
from typing import Any
from uuid import uuid4

import httpx

from app.errors import AITemporarilyUnavailableError
from app.providers.base import LLMProvider
from app.providers.mock import MockLLMProvider
from app.routing_config_client import (
    RoutingCapability,
    RoutingConfigClient,
    RoutingConfigResolution,
    RoutingProfile,
)
from app.settings import Settings


class OpenRouterRequestError(RuntimeError):
    def __init__(
        self,
        message: str,
        *,
        status_code: int | None = None,
        should_rotate_key: bool = False,
    ) -> None:
        super().__init__(message)
        self.status_code = status_code
        self.should_rotate_key = should_rotate_key


class OpenRouterProvider(LLMProvider):
    provider_name = "openrouter"

    def __init__(self, settings: Settings):
        self.settings = settings
        self.routing_client = RoutingConfigClient(settings)
        self._last_health: dict[str, Any] = {
            "routing_mode": "local_env_fallback",
            "active_key_count": 0,
            "config_source": "fallback",
            "capability_model_counts": {},
        }

    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ) -> Any:
        if self.settings.resolved_mock_mode:
            return await MockLLMProvider(reason="mock_mode_or_missing_key").complete_json(
                system_prompt=system_prompt,
                user_payload=user_payload,
                response_schema=response_schema,
                model=model,
                temperature=temperature,
            )

        capability = self._capability_from_payload(user_payload)
        resolution = await self.routing_client.get_config()
        routed_config = resolution.config
        if (
            routed_config is not None
            and routed_config.openrouter_keys
            and routed_config.models_for(capability)
        ):
            self._set_health_from_resolution(resolution)
            return await self._complete_with_remote_routing(
                capability=capability,
                resolution=resolution,
                system_prompt=system_prompt,
                user_payload=user_payload,
                response_schema=response_schema,
                temperature=temperature,
            )

        self._last_health = {
            "routing_mode": "local_env_fallback",
            "active_key_count": 0,
            "config_source": resolution.source,
            "capability_model_counts": {},
        }
        return await self._complete_with_local_key(
            system_prompt=system_prompt,
            user_payload=user_payload,
            response_schema=response_schema,
            temperature=temperature,
            override_model=model,
        )

    async def health_snapshot(self) -> dict[str, Any]:
        resolution = await self.routing_client.get_config()
        if resolution.config is not None:
            self._set_health_from_resolution(resolution)
        return dict(self._last_health)

    async def runtime_flags(self) -> dict[str, bool]:
        resolution = await self.routing_client.get_config()
        if resolution.config is None:
            return {}
        return dict(resolution.config.feature_flags)

    async def _complete_with_remote_routing(
        self,
        *,
        capability: RoutingCapability,
        resolution: RoutingConfigResolution,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None,
        temperature: float,
    ) -> Any:
        config = resolution.config
        if config is None:
            raise AITemporarilyUnavailableError()

        models = config.models_for(capability)
        profile = config.profile_for(capability)
        if not models or profile is None:
            raise AITemporarilyUnavailableError()

        last_error: Exception | None = None
        for key in sorted(config.openrouter_keys, key=lambda item: item.priority):
            request_started_at = perf_counter()
            try:
                payload = await self._request_completion(
                    key_secret=key.secret,
                    model_name=models[0],
                    fallback_models=models[1:],
                    system_prompt=system_prompt,
                    user_payload=user_payload,
                    response_schema=response_schema,
                    temperature=temperature,
                    profile=profile,
                )
                final_meta = payload.setdefault("_provider_meta", {})
                final_meta.update(
                    {
                        "provider": self.provider_name,
                        "requested_models": models,
                        "key_id": key.key_id,
                        "key_label": key.label,
                        "config_source": resolution.source,
                        "routing_mode": "multi_key_fallback",
                        "active_key_count": len(config.openrouter_keys),
                        "fallback_used": final_meta.get("model") not in {None, models[0]},
                    }
                )
                await self.routing_client.record_key_event(
                    {
                        "event_id": f"key-event-{uuid4()}",
                        "key_id": key.key_id,
                        "key_label": key.label,
                        "event_type": "success",
                        "endpoint": self._endpoint_for_capability(capability),
                        "model": final_meta.get("model"),
                        "notes": f"Resolved in {round((perf_counter() - request_started_at) * 1000, 1)}ms",
                        "created_at": self._utcnow_iso(),
                    }
                )
                return payload
            except OpenRouterRequestError as exc:
                last_error = exc
                await self.routing_client.record_key_event(
                    {
                        "event_id": f"key-event-{uuid4()}",
                        "key_id": key.key_id,
                        "key_label": key.label,
                        "event_type": "failure",
                        "endpoint": self._endpoint_for_capability(capability),
                        "model": models[0],
                        "error_code": str(exc.status_code or "transport_error"),
                        "notes": str(exc),
                        "created_at": self._utcnow_iso(),
                    }
                )
                if exc.should_rotate_key:
                    continue
                raise

        raise AITemporarilyUnavailableError(str(last_error or "ai_temporarily_unavailable"))

    async def _complete_with_local_key(
        self,
        *,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None,
        temperature: float,
        override_model: str | None,
    ) -> Any:
        models_to_try = [override_model or self.settings.openrouter_default_model]
        if self.settings.openrouter_fallback_model:
            models_to_try.append(self.settings.openrouter_fallback_model)

        last_error: Exception | None = None
        for selected_model in list(dict.fromkeys(models_to_try)):
            try:
                payload = await self._request_completion(
                    key_secret=self.settings.openrouter_api_key or "",
                    model_name=selected_model,
                    fallback_models=[],
                    system_prompt=system_prompt,
                    user_payload=user_payload,
                    response_schema=response_schema,
                    temperature=temperature,
                    profile=None,
                )
                payload.setdefault("_provider_meta", {}).update(
                    {
                        "provider": self.provider_name,
                        "requested_models": [selected_model],
                        "config_source": "fallback",
                        "routing_mode": "single_key",
                        "active_key_count": 1,
                        "fallback_used": False,
                    }
                )
                return payload
            except Exception as exc:  # pragma: no cover - exercised by normalization tests
                last_error = exc
        raise RuntimeError(f"OpenRouter completion failed: {last_error}") from last_error

    async def _request_completion(
        self,
        *,
        key_secret: str,
        model_name: str,
        fallback_models: list[str],
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None,
        temperature: float,
        profile: RoutingProfile | None,
    ) -> Any:
        prompt = system_prompt
        if response_schema:
            prompt = (
                f"{system_prompt}\n"
                f"Schema hint: {json.dumps(response_schema, ensure_ascii=False)}"
            )

        payload = {
            "model": model_name,
            "messages": [
                {"role": "system", "content": prompt},
                {
                    "role": "user",
                    "content": json.dumps(user_payload, ensure_ascii=False),
                },
            ],
            "temperature": temperature,
            "response_format": {"type": "json_object"},
        }
        if fallback_models:
            payload["models"] = [model_name, *fallback_models]
        if profile is not None:
            payload["provider"] = self._provider_preferences(profile)

        headers = {
            "Authorization": f"Bearer {key_secret}",
            "Content-Type": "application/json",
        }

        last_error: Exception | None = None
        for _attempt in range(2):
            try:
                async with httpx.AsyncClient(
                    timeout=self.settings.request_timeout_seconds
                ) as client:
                    response = await client.post(
                        f"{self.settings.openrouter_base_url}/chat/completions",
                        headers=headers,
                        json=payload,
                    )
                status_code = getattr(response, "status_code", 200)
                if status_code >= 400:
                    raise OpenRouterRequestError(
                        f"OpenRouter returned {status_code}",
                        status_code=status_code,
                        should_rotate_key=self._should_rotate_key(status_code),
                    )
                if hasattr(response, "raise_for_status"):
                    response.raise_for_status()

                data = response.json()
                content = self._extract_content(data)
                parsed = self._parse_json_content(content)
                normalized = dict(parsed) if isinstance(parsed, dict) else {"items": parsed}
                normalized["_provider_meta"] = {
                    "provider": self.provider_name,
                    "model": data.get("model") or model_name,
                }
                return normalized
            except OpenRouterRequestError:
                raise
            except (httpx.ConnectError, httpx.ReadTimeout, httpx.ConnectTimeout) as exc:
                last_error = exc
                raise OpenRouterRequestError(
                    "OpenRouter transport error",
                    should_rotate_key=True,
                ) from exc
            except json.JSONDecodeError as exc:
                last_error = exc
            except ValueError as exc:
                last_error = exc
        raise OpenRouterRequestError(
            f"OpenRouter JSON normalization failed: {last_error}",
            should_rotate_key=False,
        ) from last_error

    def _provider_preferences(self, profile: RoutingProfile) -> dict[str, Any]:
        provider: dict[str, Any] = {
            "allow_fallbacks": True,
            "require_parameters": True,
            "sort": {"by": "throughput", "partition": "none"},
            "preferred_max_latency": {"p90": profile.preferred_max_latency_seconds},
            "preferred_min_throughput": {
                "p90": profile.preferred_min_throughput_tokens_per_second
            },
            "data_collection": "deny",
        }
        return provider

    def _set_health_from_resolution(self, resolution: RoutingConfigResolution) -> None:
        config = resolution.config
        capability_counts: dict[str, int] = {}
        if config is not None:
            for snapshot in config.selection_snapshots:
                capability_counts[snapshot.capability] = (
                    capability_counts.get(snapshot.capability, 0) + 1
                )
        self._last_health = {
            "routing_mode": "multi_key_control_plane" if config else "fallback",
            "active_key_count": len(config.openrouter_keys) if config else 0,
            "config_source": resolution.source,
            "capability_model_counts": capability_counts,
        }

    @staticmethod
    def _should_rotate_key(status_code: int | None) -> bool:
        if status_code is None:
            return True
        return status_code in {401, 402, 408, 409, 429} or status_code >= 500

    @staticmethod
    def _capability_from_payload(user_payload: dict[str, Any]) -> RoutingCapability:
        intent = str(user_payload.get("intent", "")).lower()
        mapping: dict[str, RoutingCapability] = {
            "task_rewrite": "task_rewrite",
            "daily_mission": "daily_plan",
            "generic_suggestions": "daily_plan",
            "finance_reflect": "daily_plan",
            "pantry_rescue": "daily_plan",
            "closet_decision": "daily_plan",
            "weekly_summary": "weekly_summary",
            "semantic_classify": "semantic_classify",
            "proof_parse": "semantic_classify",
        }
        return mapping.get(intent, "daily_plan")

    @staticmethod
    def _endpoint_for_capability(capability: RoutingCapability) -> str:
        endpoints = {
            "daily_plan": "/v1/missions/daily",
            "task_rewrite": "/v1/tasks/rewrite",
            "semantic_classify": "/v1/events/classify",
            "weekly_summary": "/v1/weekly/summary",
        }
        return endpoints[capability]

    @staticmethod
    def _utcnow_iso() -> str:
        from datetime import UTC, datetime

        return datetime.now(UTC).isoformat()

    @staticmethod
    def _extract_content(data: dict[str, Any]) -> str:
        try:
            content = data["choices"][0]["message"]["content"]
        except (KeyError, IndexError, TypeError) as exc:  # pragma: no cover
            raise ValueError("OpenRouter response did not contain JSON content.") from exc

        if isinstance(content, list):
            parts: list[str] = []
            for item in content:
                if isinstance(item, dict):
                    parts.append(str(item.get("text", "")))
                else:
                    parts.append(str(item))
            return "".join(parts)
        return str(content)

    @staticmethod
    def _strip_code_fences(content: str) -> str:
        cleaned = content.strip()
        if cleaned.startswith("```"):
            cleaned = cleaned.strip("`")
            if cleaned.startswith("json"):
                cleaned = cleaned[4:]
        return cleaned.strip()

    @classmethod
    def _parse_json_content(cls, content: str) -> Any:
        cleaned = cls._strip_code_fences(content)
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError:
            fragment = cls._extract_json_fragment(cleaned)
            if fragment is None:
                raise
            return json.loads(fragment)

    @staticmethod
    def _extract_json_fragment(content: str) -> str | None:
        for opener, closer in (("{", "}"), ("[", "]")):
            start = content.find(opener)
            end = content.rfind(closer)
            if start != -1 and end != -1 and end > start:
                return content[start : end + 1]
        return None
