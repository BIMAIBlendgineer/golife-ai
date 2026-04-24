from __future__ import annotations

import asyncio
import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Literal

import httpx
from pydantic import BaseModel, Field

from app.settings import Settings

RoutingConfigSource = Literal["live", "cached", "fallback"]
RoutingCapability = Literal[
    "daily_plan",
    "task_rewrite",
    "semantic_classify",
    "weekly_summary",
]


class GatewayRoutingKey(BaseModel):
    key_id: str = Field(min_length=1)
    label: str = Field(min_length=1)
    secret: str = Field(min_length=1)
    priority: int = Field(ge=0)
    status: str = Field(default="unknown")


class RoutingProfile(BaseModel):
    capability: RoutingCapability
    strategy: str = "quality_first"
    min_context_length: int = Field(ge=1)
    required_parameters: list[str] = Field(default_factory=list)
    preferred_max_latency_seconds: float = Field(ge=0.0)
    preferred_min_throughput_tokens_per_second: float = Field(ge=0.0)
    retry_policy: dict[str, int] = Field(default_factory=dict)
    enabled: bool = True


class ModelSelectionSnapshot(BaseModel):
    capability: RoutingCapability
    rank_index: int = Field(ge=0)
    model_id: str = Field(min_length=1)
    score: float = Field(ge=0.0)
    selection_reason: dict[str, Any] = Field(default_factory=dict)


class RoutingConfig(BaseModel):
    config_source: RoutingConfigSource = "fallback"
    generated_at: str
    openrouter_keys: list[GatewayRoutingKey] = Field(default_factory=list)
    routing_profiles: list[RoutingProfile] = Field(default_factory=list)
    selection_snapshots: list[ModelSelectionSnapshot] = Field(default_factory=list)
    feature_flags: dict[str, bool] = Field(default_factory=dict)

    def models_for(self, capability: RoutingCapability) -> list[str]:
        selected = [
            snapshot.model_id
            for snapshot in sorted(
                self.selection_snapshots,
                key=lambda item: (item.capability, item.rank_index),
            )
            if snapshot.capability == capability
        ]
        return selected[:3]

    def profile_for(self, capability: RoutingCapability) -> RoutingProfile | None:
        for profile in self.routing_profiles:
            if profile.capability == capability:
                return profile
        return None


@dataclass(frozen=True)
class RoutingConfigResolution:
    config: RoutingConfig | None
    source: RoutingConfigSource


class RoutingConfigClient:
    def __init__(self, settings: Settings):
        self.settings = settings
        self._cache_path = Path(settings.routing_config_cache_path)
        self._cached_config: RoutingConfig | None = None
        self._cached_source: RoutingConfigSource = "fallback"

    async def get_config(self) -> RoutingConfigResolution:
        if not self.settings.routing_control_enabled:
            return RoutingConfigResolution(config=None, source="fallback")

        live_config = await self._fetch_live_config()
        if live_config is not None:
            self._cached_config = live_config
            self._cached_source = "live"
            self._write_cache(live_config)
            return RoutingConfigResolution(config=live_config, source="live")

        cached_config = self._cached_config or self._read_cache()
        if cached_config is not None:
            self._cached_config = cached_config
            self._cached_source = "cached"
            return RoutingConfigResolution(config=cached_config, source="cached")

        return RoutingConfigResolution(config=None, source="fallback")

    async def record_key_event(
        self,
        payload: dict[str, Any],
    ) -> bool:
        if not self.settings.routing_control_enabled:
            return False

        last_error: Exception | None = None
        for attempt in range(2):
            try:
                async with httpx.AsyncClient(
                    timeout=self.settings.routing_config_timeout_seconds
                ) as client:
                    response = await client.post(
                        f"{self.settings.routing_backend_base_url.rstrip('/')}/internal/openrouter-key-events",
                        headers={
                            "content-type": "application/json",
                            "x-internal-service-token": self.settings.routing_backend_internal_token,
                        },
                        json=payload,
                    )
                response.raise_for_status()
                return True
            except Exception as exc:  # pragma: no cover - network-specific
                last_error = exc
                if attempt == 0:
                    await asyncio.sleep(0.15)
        return False if last_error else True

    async def _fetch_live_config(self) -> RoutingConfig | None:
        try:
            async with httpx.AsyncClient(
                timeout=self.settings.routing_config_timeout_seconds
            ) as client:
                response = await client.get(
                    f"{self.settings.routing_backend_base_url.rstrip('/')}/internal/ai-routing/config",
                    headers={
                        "x-internal-service-token": self.settings.routing_backend_internal_token,
                    },
                )
            response.raise_for_status()
            return RoutingConfig.model_validate(response.json())
        except Exception:  # pragma: no cover - network-specific
            return None

    def _write_cache(self, config: RoutingConfig) -> None:
        self._cache_path.parent.mkdir(parents=True, exist_ok=True)
        self._cache_path.write_text(
            json.dumps(config.model_dump(mode="json"), ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    def _read_cache(self) -> RoutingConfig | None:
        if not self._cache_path.exists():
            return None
        try:
            return RoutingConfig.model_validate(
                json.loads(self._cache_path.read_text(encoding="utf-8"))
            )
        except Exception:
            return None
