from abc import ABC, abstractmethod
from typing import Any


class LLMProvider(ABC):
    provider_name = "unknown"

    @abstractmethod
    async def complete_json(
        self,
        *,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None = None,
        model: str | None = None,
        temperature: float = 0.0,
    ) -> Any:
        raise NotImplementedError

    async def health_snapshot(self) -> dict[str, Any]:
        return {}

    async def runtime_flags(self) -> dict[str, bool]:
        return {}
