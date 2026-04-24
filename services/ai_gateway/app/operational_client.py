from __future__ import annotations

import asyncio
from typing import Any

import httpx


class OperationalEventsClient:
    def __init__(
        self,
        *,
        enabled: bool,
        base_url: str,
        ingestion_token: str,
        timeout_seconds: float,
        max_retries: int,
    ) -> None:
        self.enabled = enabled
        self.base_url = base_url.rstrip("/")
        self.ingestion_token = ingestion_token
        self.timeout_seconds = timeout_seconds
        self.max_retries = max(0, max_retries)

    async def record_usage_event(self, payload: dict[str, Any]) -> bool:
        return await self._post("/internal/usage-events", payload)

    async def record_ai_invocation(self, payload: dict[str, Any]) -> bool:
        return await self._post("/internal/ai-invocations", payload)

    async def record_mission_audits(self, payload: list[dict[str, Any]]) -> bool:
        return await self._post("/internal/mission-audits", payload)

    async def record_feedback_audit(self, payload: dict[str, Any]) -> bool:
        return await self._post("/internal/feedback-audits", payload)

    async def record_safety_events(self, payload: list[dict[str, Any]]) -> bool:
        return await self._post("/internal/safety-events", payload)

    async def record_model_settings(self, payload: dict[str, Any]) -> bool:
        return await self._post("/internal/model-settings", payload)

    async def _post(self, path: str, payload: Any) -> bool:
        if not self.enabled:
            return False

        last_error: Exception | None = None
        for attempt in range(self.max_retries + 1):
            try:
                async with httpx.AsyncClient(timeout=self.timeout_seconds) as client:
                    response = await client.post(
                        f"{self.base_url}{path}",
                        headers={
                            "content-type": "application/json",
                            "x-ingestion-token": self.ingestion_token,
                        },
                        json=payload,
                    )
                response.raise_for_status()
                return True
            except Exception as exc:  # pragma: no cover - network failure is environment-specific
                last_error = exc
                if attempt < self.max_retries:
                    await asyncio.sleep(0.15 * (attempt + 1))

        return False if last_error else True


class NoopOperationalEventsClient(OperationalEventsClient):
    def __init__(self) -> None:
        super().__init__(
            enabled=False,
            base_url="",
            ingestion_token="",
            timeout_seconds=0.0,
            max_retries=0,
        )

    async def record_usage_event(self, payload: dict[str, Any]) -> bool:
        return False

    async def record_ai_invocation(self, payload: dict[str, Any]) -> bool:
        return False

    async def record_mission_audits(self, payload: list[dict[str, Any]]) -> bool:
        return False

    async def record_feedback_audit(self, payload: dict[str, Any]) -> bool:
        return False

    async def record_safety_events(self, payload: list[dict[str, Any]]) -> bool:
        return False

    async def record_model_settings(self, payload: dict[str, Any]) -> bool:
        return False
