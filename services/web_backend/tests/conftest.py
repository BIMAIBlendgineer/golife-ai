import pytest
from fastapi.testclient import TestClient

from app.main import create_app
from app.repository import OperationalRepository
from app.settings import Settings


@pytest.fixture
def client(tmp_path) -> TestClient:
    app = create_app(
        settings=Settings(
            admin_token="test-admin-token",
            ingestion_token="test-ingestion-token",
            internal_service_token="test-internal-token",
            operational_database_path=str(tmp_path / "web_backend.db"),
            seed_demo_data=True,
        ),
        repository=OperationalRepository(
            str(tmp_path / "web_backend.db"),
            seed_demo_data=True,
        ),
    )
    return TestClient(app)
