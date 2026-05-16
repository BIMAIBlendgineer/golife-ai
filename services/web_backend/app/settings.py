from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    environment: str = "dev"
    admin_token: str = "golife-admin-dev"
    admin_operator_secret: str = ""
    ingestion_token: str = "golife-ingest-dev"
    internal_service_token: str = "golife-internal-dev"
    openrouter_keys_master_key: str = "MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY="
    openrouter_base_url: str = "https://openrouter.ai/api/v1"
    operational_database_url: str | None = None
    operational_database_path: str = ".runtime/web_backend.db"
    seed_demo_data: bool = False
    cors_origins: list[str] = [
        "http://127.0.0.1:3000",
        "http://localhost:3000",
    ]
    mobile_gateway_base_url: str = "http://127.0.0.1:8000"
    mobile_runtime_config_ttl_seconds: int = 21600
    mobile_billing_mode: str = "google_play_sandbox"
    mobile_google_play_package_name: str = "ai.golife.mobile"
    mobile_google_play_premium_product_id: str = "golife_premium_monthly_sandbox"
    mobile_google_play_pro_product_id: str = "golife_pro_monthly_sandbox"
    mobile_google_play_service_account_json: str = ""
    mobile_google_play_service_account_file: str = ""

    @property
    def resolved_operational_database(self) -> str:
        return self.operational_database_url or self.operational_database_path

    @model_validator(mode="after")
    def validate_production_settings(self) -> "Settings":
        if self.environment.lower() != "production":
            return self

        dev_defaults = {
            "admin_token": ("golife-admin-dev", "ADMIN_TOKEN"),
            "ingestion_token": ("golife-ingest-dev", "INGESTION_TOKEN"),
            "internal_service_token": ("golife-internal-dev", "INTERNAL_SERVICE_TOKEN"),
            "openrouter_keys_master_key": (
                "MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=",
                "OPENROUTER_KEYS_MASTER_KEY",
            ),
        }
        for field_name, (default_value, public_name) in dev_defaults.items():
            if getattr(self, field_name) == default_value:
                raise ValueError(f"{public_name} must not use the dev default in production.")

        if len(self.admin_token) < 24 or len(self.ingestion_token) < 24:
            raise ValueError("Production admin and ingestion tokens must be at least 24 characters long.")
        if len(self.admin_operator_secret) < 12:
            raise ValueError("ADMIN_OPERATOR_SECRET must be configured in production.")
        if len(self.internal_service_token) < 24:
            raise ValueError("INTERNAL_SERVICE_TOKEN must be at least 24 characters long in production.")
        if len(self.openrouter_keys_master_key) < 32:
            raise ValueError("OPENROUTER_KEYS_MASTER_KEY must be configured in production.")
        return self
