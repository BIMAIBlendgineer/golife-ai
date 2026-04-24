from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    llm_provider: str = "openrouter"
    ai_gateway_enable_mock: bool = True
    openrouter_api_key: str | None = None
    openrouter_base_url: str = "https://openrouter.ai/api/v1"
    openrouter_default_model: str = "google/gemini-2.0-flash-001"
    openrouter_fallback_model: str | None = None
    request_timeout_seconds: float = 45.0
    feedback_store_path: str = ".runtime/mission_feedback.json"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def resolved_mock_mode(self) -> bool:
        return bool(self.ai_gateway_enable_mock or not self.openrouter_api_key)


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
