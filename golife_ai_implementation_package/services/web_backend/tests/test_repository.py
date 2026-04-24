import app.repository as repository_module
from app.repository import OperationalRepository
from app.settings import Settings


def test_postgres_connection_uses_dict_row(monkeypatch):
    captured: dict[str, object] = {}
    sentinel_row_factory = object()

    class FakeConnection:
        def execute(self, *_args, **_kwargs):
            return self

        def fetchone(self):
            return None

        def fetchall(self):
            return []

        def commit(self):
            return None

    class FakePsycopg:
        @staticmethod
        def connect(dsn, *, autocommit, row_factory):
            captured["dsn"] = dsn
            captured["autocommit"] = autocommit
            captured["row_factory"] = row_factory
            return FakeConnection()

    monkeypatch.setattr(repository_module, "psycopg", FakePsycopg())
    monkeypatch.setattr(repository_module, "dict_row", sentinel_row_factory)
    monkeypatch.setattr(OperationalRepository, "_create_schema", lambda self: None)
    monkeypatch.setattr(OperationalRepository, "_ensure_defaults", lambda self: None)

    OperationalRepository("postgresql://localhost/golife_ops", seed_demo_data=False)

    assert captured["dsn"] == "postgresql://localhost/golife_ops"
    assert captured["autocommit"] is False
    assert captured["row_factory"] is sentinel_row_factory


def test_production_accepts_strong_tokens():
    settings = Settings(
        environment="production",
        admin_token="a" * 24,
        ingestion_token="b" * 24,
    )

    assert settings.environment == "production"
    assert settings.admin_token == "a" * 24
    assert settings.ingestion_token == "b" * 24
