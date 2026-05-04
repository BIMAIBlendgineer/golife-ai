from functools import lru_cache

from pydantic import AliasChoices, Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    environment: str = Field(
        default="dev",
        validation_alias=AliasChoices("environment", "AI_GATEWAY_ENV", "ENVIRONMENT"),
    )
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

    model_config = SettingsConfigDict(extra="ignore")

    @property
    def normalized_environment(self) -> str:
        return self.environment.strip().lower() or "dev"

    @property
    def is_production(self) -> bool:
        return self.normalized_environment == "production"

    @property
    def has_openrouter_key(self) -> bool:
        return bool(self.openrouter_api_key)

    @property
    def routing_backend_uses_default_dev_token(self) -> bool:
        return self.routing_backend_internal_token == "golife-internal-dev"

    @property
    def has_routing_backend_config(self) -> bool:
        return bool(
            self.routing_control_enabled
            and self.routing_backend_base_url
            and self.routing_backend_internal_token
        )

    @property
    def has_local_or_remote_openrouter(self) -> bool:
        return bool(self.has_openrouter_key or self.has_routing_backend_config)

    @property
    def resolved_mock_mode(self) -> bool:
        return bool(self.ai_gateway_enable_mock or not self.has_local_or_remote_openrouter)

    @property
    def mock_fallback_reason(self) -> str:
        if self.ai_gateway_enable_mock:
            return "explicit_dev_mock"
        if self.routing_control_enabled:
            return "routing_unavailable_dev"
        return "missing_openrouter_key_dev"

    @model_validator(mode="after")
    def validate_production_configuration(self) -> "Settings":
        if not self.is_production:
            return self
        if self.ai_gateway_enable_mock:
            raise ValueError("AI_GATEWAY_ENABLE_MOCK must be false in production.")
        if (
            self.routing_control_enabled
            and self.routing_backend_uses_default_dev_token
        ):
            raise ValueError(
                "ROUTING_BACKEND_INTERNAL_TOKEN must not use the default dev token in production."
            )
        if not self.has_openrouter_key and not self.has_routing_backend_config:
            raise ValueError(
                "Production requires OPENROUTER_API_KEY or a valid routing backend configuration."
            )
        return self


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings(_env_file=".env")
