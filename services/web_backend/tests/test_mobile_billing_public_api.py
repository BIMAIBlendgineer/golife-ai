import asyncio
from datetime import UTC, datetime

import httpx
from fastapi.testclient import TestClient

from app.google_play_billing import GooglePlayBillingValidator
from app.main import create_app
from app.repository import OperationalRepository
from app.schemas import MobileBillingValidationRequest, MobileBillingValidationResponse
from app.settings import Settings


def test_runtime_config_exposes_google_play_sandbox_by_default(client: TestClient):
    response = client.get("/public/mobile/runtime-config")

    assert response.status_code == 200
    payload = response.json()
    assert payload["billing"]["enabled"] is True
    assert payload["billing"]["provider"] == "google_play"
    assert payload["billing"]["mode"] == "google_play_sandbox"
    assert payload["billing"]["sandbox_only"] is True
    assert payload["billing"]["production_purchases_enabled"] is False
    assert payload["billing"]["restore_purchases"] is True
    assert payload["billing"]["validation_path"] == "/public/mobile/billing/google-play/validate"
    assert len(payload["billing"]["catalog"]) == 2
    assert "openrouter_keys" not in payload


def test_google_play_validation_returns_validator_not_configured_by_default(
    client: TestClient,
):
    response = client.post(
        "/public/mobile/billing/google-play/validate",
        json={
            "provider": "google_play",
            "mode": "google_play_sandbox",
            "package_name": "ai.golife.mobile",
            "product_id": "golife_premium_monthly_sandbox",
            "purchase_token": "sandbox-token-1",
            "purchase_status": "purchase_purchased",
            "trace": {"provider": "google_play"},
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["verified"] is False
    assert payload["status_code"] == "validator_not_configured"
    assert payload["plan"] == "free"
    assert payload["billing_provider"] == "disabled"


def test_google_play_validation_rejects_package_name_mismatch(client: TestClient):
    response = client.post(
        "/public/mobile/billing/google-play/validate",
        json={
            "provider": "google_play",
            "mode": "google_play_sandbox",
            "package_name": "ai.other.app",
            "product_id": "golife_premium_monthly_sandbox",
            "purchase_token": "sandbox-token-2",
            "purchase_status": "purchase_purchased",
            "trace": {"provider": "google_play"},
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["verified"] is False
    assert payload["status_code"] == "package_name_mismatch"


def test_google_play_validation_endpoint_can_return_verified_sandbox_decision(
    monkeypatch,
    tmp_path,
):
    async def fake_validate(_payload):
        return MobileBillingValidationResponse(
            verified=True,
            plan="premium",
            quota={
                "daily_mission_refreshes": 120,
                "ai_assisted_captures": 120,
                "export_bundles": 1,
            },
            billing_provider="google_play",
            renewal_state="active",
            sandbox=True,
            status_code="validated",
            message="Google Play sandbox purchase validated.",
            validated_at_iso=datetime.now(UTC),
            trace={"mode": "google_play_sandbox"},
        )

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
    monkeypatch.setattr(
        app.state.google_play_billing_validator,
        "validate",
        fake_validate,
    )

    with TestClient(app) as client:
        response = client.post(
            "/public/mobile/billing/google-play/validate",
            json={
                "provider": "google_play",
                "mode": "google_play_sandbox",
                "package_name": "ai.golife.mobile",
                "product_id": "golife_premium_monthly_sandbox",
                "purchase_token": "sandbox-token-3",
                "purchase_status": "purchase_purchased",
                "trace": {"provider": "google_play"},
            },
        )

    assert response.status_code == 200
    payload = response.json()
    assert payload["verified"] is True
    assert payload["plan"] == "premium"
    assert payload["billing_provider"] == "google_play"
    assert payload["sandbox"] is True


class _StaticAsyncClient:
    def __init__(self, response):
        self._response = response

    async def get(self, *_args, **_kwargs):
        return self._response

    async def aclose(self):
        return None


def test_google_play_validator_marks_cancelled_subscription_state():
    validator = GooglePlayBillingValidator(
        settings=Settings(
            mobile_billing_mode="google_play_sandbox",
            mobile_google_play_service_account_json='{"client_email":"test@example.com"}',
        ),
        client=_StaticAsyncClient(
            httpx.Response(
                status_code=200,
                json={
                    "subscriptionState": "SUBSCRIPTION_STATE_CANCELED",
                    "testPurchase": {},
                    "acknowledgementState": "ACKNOWLEDGEMENT_STATE_ACKNOWLEDGED",
                    "canceledStateContext": {
                        "userInitiatedCancellation": {}
                    },
                    "lineItems": [
                        {
                            "productId": "golife_premium_monthly_sandbox",
                            "expiryTime": "2026-06-01T10:00:00Z",
                        }
                    ],
                },
            )
        ),
    )
    validator._build_access_token = lambda _info: "token"  # type: ignore[attr-defined]

    decision = asyncio.run(
        validator.validate(
            MobileBillingValidationRequest(
                provider="google_play",
                mode="google_play_sandbox",
                package_name="ai.golife.mobile",
                product_id="golife_premium_monthly_sandbox",
                purchase_token="sandbox-token-cancelled",
                purchase_status="purchase_restored",
                restored=True,
            )
        )
    )

    assert decision.verified is False
    assert decision.billing_provider == "google_play"
    assert decision.renewal_state == "cancelled"
    assert decision.status_code == "validated_cancelled"
    assert decision.trace["cancellation_reason"] == "user"


def test_google_play_validator_maps_product_not_owned_to_refunded_state():
    validator = GooglePlayBillingValidator(
        settings=Settings(
            mobile_billing_mode="google_play_sandbox",
            mobile_google_play_service_account_json='{"client_email":"test@example.com"}',
        ),
        client=_StaticAsyncClient(
            httpx.Response(
                status_code=400,
                json={
                    "error": {
                        "errors": [
                            {
                                "reason": "productNotOwnedByUser",
                            }
                        ]
                    }
                },
            )
        ),
    )
    validator._build_access_token = lambda _info: "token"  # type: ignore[attr-defined]

    decision = asyncio.run(
        validator.validate(
            MobileBillingValidationRequest(
                provider="google_play",
                mode="google_play_sandbox",
                package_name="ai.golife.mobile",
                product_id="golife_premium_monthly_sandbox",
                purchase_token="sandbox-token-refunded",
                purchase_status="purchase_purchased",
            )
        )
    )

    assert decision.verified is False
    assert decision.billing_provider == "google_play"
    assert decision.renewal_state == "refunded"
    assert decision.status_code == "google_play_error"
    assert decision.trace["renewal_state_inferred"] is True
