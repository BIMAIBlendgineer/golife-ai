import pytest
from fastapi.testclient import TestClient

from app.main import create_app
from app.providers.mock import MockLLMProvider
from app.settings import Settings


@pytest.fixture
def client(tmp_path) -> TestClient:
    app = create_app(
        settings=Settings(
            ai_gateway_enable_mock=True,
            llm_provider="openrouter",
            feedback_store_path=str(tmp_path / "mission_feedback.json"),
        ),
        provider=MockLLMProvider(),
    )
    return TestClient(app)
