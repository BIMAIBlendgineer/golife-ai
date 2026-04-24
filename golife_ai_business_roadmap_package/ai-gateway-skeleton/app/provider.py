from __future__ import annotations

import json
import os
from abc import ABC, abstractmethod
from dataclasses import dataclass
from typing import Any

import httpx


class AIProviderError(RuntimeError):
    """Raised when a provider cannot return a usable structured payload."""


@dataclass
class ProviderResult:
    payload: dict[str, Any]
    provider_name: str
    used_fallback: bool = False


class AIProvider(ABC):
    name = "provider"

    @abstractmethod
    async def complete_structured(
        self,
        *,
        operation: str,
        prompt: str,
        schema: dict[str, Any],
        fallback_payload: dict[str, Any],
    ) -> dict[str, Any]:
        raise NotImplementedError


class MockProvider(AIProvider):
    name = "mock"

    async def complete_structured(
        self,
        *,
        operation: str,
        prompt: str,
        schema: dict[str, Any],
        fallback_payload: dict[str, Any],
    ) -> dict[str, Any]:
        payload = dict(fallback_payload)
        payload["mock"] = True
        return payload


class OpenRouterProvider(AIProvider):
    name = "openrouter"

    def __init__(
        self,
        api_key: str,
        model: str,
        *,
        base_url: str = "https://openrouter.ai/api/v1/chat/completions",
        timeout: float = 20.0,
    ) -> None:
        self.api_key = api_key
        self.model = model
        self.base_url = base_url
        self.timeout = timeout

    async def complete_structured(
        self,
        *,
        operation: str,
        prompt: str,
        schema: dict[str, Any],
        fallback_payload: dict[str, Any],
    ) -> dict[str, Any]:
        if not self.api_key:
            raise AIProviderError("OPENROUTER_API_KEY is missing")

        payload = {
            "model": self.model,
            "messages": [
                {
                    "role": "system",
                    "content": (
                        "You are GoLife AI. Return one valid JSON object only. "
                        "Respect the provided schema and avoid prose outside JSON."
                    ),
                },
                {"role": "user", "content": prompt},
            ],
            "response_format": {
                "type": "json_schema",
                "json_schema": {
                    "name": f"golife_{operation.replace('-', '_')}",
                    "schema": schema,
                },
            },
        }

        async with httpx.AsyncClient(timeout=self.timeout) as client:
            response = await client.post(
                self.base_url,
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                },
                json=payload,
            )

        if response.status_code >= 400:
            raise AIProviderError(
                f"OpenRouter returned HTTP {response.status_code}: {response.text[:200]}"
            )

        try:
            data = response.json()
            content = data["choices"][0]["message"]["content"]
            if isinstance(content, list):
                content = "".join(
                    item.get("text", "") for item in content if isinstance(item, dict)
                )
            return json.loads(content)
        except (KeyError, IndexError, ValueError, TypeError) as exc:
            raise AIProviderError(f"OpenRouter payload was not usable JSON: {exc}") from exc


class ProviderChain:
    def __init__(self, providers: list[AIProvider]) -> None:
        self.providers = providers

    @property
    def provider_names(self) -> list[str]:
        return [provider.name for provider in self.providers]

    async def complete_structured(
        self,
        *,
        operation: str,
        prompt: str,
        schema: dict[str, Any],
        fallback_payload: dict[str, Any],
    ) -> ProviderResult:
        errors: list[str] = []
        for index, provider in enumerate(self.providers):
            try:
                payload = await provider.complete_structured(
                    operation=operation,
                    prompt=prompt,
                    schema=schema,
                    fallback_payload=fallback_payload,
                )
                return ProviderResult(
                    payload=payload,
                    provider_name=provider.name,
                    used_fallback=index > 0 or provider.name == "mock",
                )
            except Exception as exc:  # pragma: no cover - aggregated into the next provider.
                errors.append(f"{provider.name}: {exc}")

        raise AIProviderError("All providers failed: " + " | ".join(errors))


def build_provider_chain_from_env() -> ProviderChain:
    mode = os.getenv("AI_PROVIDER", "mock").strip().lower()
    providers: list[AIProvider] = []

    if mode != "mock":
        providers.append(
            OpenRouterProvider(
                api_key=os.getenv("OPENROUTER_API_KEY", ""),
                model=os.getenv("OPENROUTER_MODEL", "openai/gpt-4o-mini"),
            )
        )

    providers.append(MockProvider())
    return ProviderChain(providers)
