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
    routing_control_enabled: bool = True
    routing_backend_base_url: str = "http://127.0.0.1:8010"
    routing_backend_internal_token: str = "golife-internal-dev"
    routing_config_timeout_seconds: float = 3.0
    routing_config_cache_path: str = ".runtime/ai_routing_config.json"
    crisis_resources_region: str = "global"
    crisis_resources_catalog_path: str | None = None

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    @property
    def resolved_mock_mode(self) -> bool:
        has_local_or_remote_openrouter = bool(
            self.openrouter_api_key
            or (
                self.routing_control_enabled
                and self.routing_backend_base_url
                and self.routing_backend_internal_token
            )
        )
        return bool(self.ai_gateway_enable_mock or not has_local_or_remote_openrouter)


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
