import json
from typing import Any

import httpx

from app.providers.base import LLMProvider
from app.providers.mock import MockLLMProvider
from app.settings import Settings


class OpenRouterProvider(LLMProvider):
    provider_name = "openrouter"

    def __init__(self, settings: Settings):
        self.settings = settings

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

        models_to_try = [model or self.settings.openrouter_default_model]
        if self.settings.openrouter_fallback_model:
            models_to_try.append(self.settings.openrouter_fallback_model)

        last_error: Exception | None = None
        for selected_model in list(dict.fromkeys(models_to_try)):
            for _attempt in range(2):
                try:
                    return await self._request_completion(
                        model_name=selected_model,
                        system_prompt=system_prompt,
                        user_payload=user_payload,
                        response_schema=response_schema,
                        temperature=temperature,
                    )
                except Exception as exc:  # pragma: no cover - exercised by fallback test indirectly
                    last_error = exc

        raise RuntimeError(f"OpenRouter completion failed: {last_error}") from last_error

    async def _request_completion(
        self,
        *,
        model_name: str,
        system_prompt: str,
        user_payload: dict[str, Any],
        response_schema: dict[str, Any] | None,
        temperature: float,
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
        headers = {
            "Authorization": f"Bearer {self.settings.openrouter_api_key}",
            "Content-Type": "application/json",
        }

        async with httpx.AsyncClient(timeout=self.settings.request_timeout_seconds) as client:
            response = await client.post(
                f"{self.settings.openrouter_base_url}/chat/completions",
                headers=headers,
                json=payload,
            )
            response.raise_for_status()
            data = response.json()

        content = self._extract_content(data)
        parsed = self._parse_json_content(content)
        if isinstance(parsed, dict):
            normalized: dict[str, Any] = dict(parsed)
        else:
            normalized = {"items": parsed}
        normalized["_provider_meta"] = {
            "provider": self.provider_name,
            "model": model_name,
        }
        return normalized

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
