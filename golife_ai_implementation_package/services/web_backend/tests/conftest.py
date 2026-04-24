import pytest
from fastapi.testclient import TestClient

from app.main import create_app
from app.repository import OperationalRepository
from app.settings import Settings


@pytest.fixture
def client() -> TestClient:
    app = create_app(
        settings=Settings(admin_token="test-admin-token"),
        repository=OperationalRepository(),
    )
    return TestClient(app)
