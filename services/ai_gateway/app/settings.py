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
    operational_backend_enabled: bool = False
    operational_backend_base_url: str = "http://127.0.0.1:8010"
    operational_backend_ingestion_token: str = "golife-ingest-dev"
    operational_backend_timeout_seconds: float = 2.0
    operational_backend_max_retries: int = 2

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def resolved_mock_mode(self) -> bool:
        return bool(self.ai_gateway_enable_mock or not self.openrouter_api_key)


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
