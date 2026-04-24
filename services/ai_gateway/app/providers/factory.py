from app.providers.base import LLMProvider
from app.providers.mock import MockLLMProvider
from app.providers.openrouter import OpenRouterProvider
from app.settings import Settings


def build_provider(settings: Settings) -> LLMProvider:
    if settings.llm_provider == "openrouter":
        if settings.resolved_mock_mode:
            return MockLLMProvider(reason="mock_mode_or_missing_api_key")
        return OpenRouterProvider(settings)
    raise ValueError(f"Unsupported LLM provider: {settings.llm_provider}")
