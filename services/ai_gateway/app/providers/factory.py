from app.providers.base import LLMProvider
from app.providers.mock import MockLLMProvider
from app.providers.openrouter import OpenRouterProvider
from app.settings import Settings


def build_provider(settings: Settings) -> LLMProvider:
    if settings.llm_provider == "openrouter":
        if settings.resolved_mock_mode:
            if settings.is_production:
                raise ValueError(
                    "Mock provider resolution is disabled in production. Check AI Gateway settings."
                )
            return MockLLMProvider(reason=settings.mock_fallback_reason)
        return OpenRouterProvider(settings)
    raise ValueError(f"Unsupported LLM provider: {settings.llm_provider}")
