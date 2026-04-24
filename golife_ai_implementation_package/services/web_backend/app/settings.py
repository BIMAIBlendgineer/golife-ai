from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    admin_token: str = "golife-admin-dev"
    ingestion_token: str = "golife-ingest-dev"
    operational_database_path: str = ".runtime/web_backend.db"
    seed_demo_data: bool = False
    cors_origins: list[str] = [
        "http://127.0.0.1:3000",
        "http://localhost:3000",
    ]
