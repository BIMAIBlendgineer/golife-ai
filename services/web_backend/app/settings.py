from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    environment: str = "dev"
    admin_token: str = "golife-admin-dev"
    ingestion_token: str = "golife-ingest-dev"
    operational_database_url: str | None = None
    operational_database_path: str = ".runtime/web_backend.db"
    seed_demo_data: bool = False
    cors_origins: list[str] = [
        "http://127.0.0.1:3000",
        "http://localhost:3000",
    ]

    @property
    def resolved_operational_database(self) -> str:
        return self.operational_database_url or self.operational_database_path

    @model_validator(mode="after")
    def validate_production_settings(self) -> "Settings":
        if self.environment.lower() != "production":
            return self

        if self.admin_token == "golife-admin-dev":
            raise ValueError("ADMIN_TOKEN must not use the dev default in production.")
        if self.ingestion_token == "golife-ingest-dev":
            raise ValueError("INGESTION_TOKEN must not use the dev default in production.")
        if len(self.admin_token) < 24 or len(self.ingestion_token) < 24:
            raise ValueError("Production tokens must be at least 24 characters long.")
        return self
