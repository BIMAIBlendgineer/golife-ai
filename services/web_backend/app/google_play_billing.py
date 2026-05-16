from __future__ import annotations

import base64
import json
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

import httpx
from google.auth.transport.requests import Request as GoogleAuthRequest
from google.oauth2 import service_account

from app.schemas import MobileBillingValidationRequest, MobileBillingValidationResponse
from app.settings import Settings

ANDROID_PUBLISHER_SCOPE = "https://www.googleapis.com/auth/androidpublisher"
ANDROID_PUBLISHER_BASE_URL = "https://androidpublisher.googleapis.com/androidpublisher/v3"


class GooglePlayBillingValidator:
    def __init__(
        self,
        *,
        settings: Settings,
        client: httpx.AsyncClient | None = None,
    ) -> None:
        self._settings = settings
        self._client = client or httpx.AsyncClient(timeout=8.0)

    async def validate(
        self,
        payload: MobileBillingValidationRequest,
    ) -> MobileBillingValidationResponse:
        now = datetime.now(UTC)
        if self._settings.mobile_billing_mode not in {
            "google_play_sandbox",
            "google_play_live",
        }:
            return self._decision(
                now=now,
                verified=False,
                status_code="billing_not_enabled",
                message="Google Play billing is not enabled in this backend runtime.",
            )

        if payload.package_name != self._settings.mobile_google_play_package_name:
            return self._decision(
                now=now,
                verified=False,
                status_code="package_name_mismatch",
                message="The submitted package name does not match the configured Android package.",
            )

        service_account_info = self._load_service_account_info()
        if service_account_info is None:
            return self._decision(
                now=now,
                verified=False,
                status_code="validator_not_configured",
                message="Google Play sandbox validator is not configured on the backend.",
            )

        access_token = self._build_access_token(service_account_info)
        api_response = await self._client.get(
            (
                f"{ANDROID_PUBLISHER_BASE_URL}/applications/"
                f"{payload.package_name}/purchases/subscriptionsv2/tokens/{payload.purchase_token}"
            ),
            headers={"Authorization": f"Bearer {access_token}"},
        )
        if api_response.status_code == 404:
            return self._decision(
                now=now,
                verified=False,
                status_code="purchase_not_found",
                message="Google Play did not find the submitted sandbox purchase token.",
            )
        if api_response.status_code >= 400:
            return self._decision(
                now=now,
                verified=False,
                status_code="google_play_error",
                message=f"Google Play validation returned HTTP {api_response.status_code}.",
            )

        body = api_response.json()
        line_items = body.get("lineItems") or []
        if not line_items:
            return self._decision(
                now=now,
                verified=False,
                status_code="line_items_missing",
                message="Google Play returned no purchasable line items for this token.",
            )

        product_ids = {
            str(item.get("productId"))
            for item in line_items
            if str(item.get("productId", "")).strip()
        }
        if payload.product_id not in product_ids:
            return self._decision(
                now=now,
                verified=False,
                status_code="product_mismatch",
                message="The submitted product does not match the Google Play purchase token.",
                trace={
                    "google_subscription_state": body.get("subscriptionState"),
                    "matched_product_ids": sorted(product_ids),
                },
            )

        sandbox_purchase = body.get("testPurchase") is not None
        if (
            self._settings.mobile_billing_mode == "google_play_sandbox"
            and not sandbox_purchase
        ):
            return self._decision(
                now=now,
                verified=False,
                status_code="sandbox_purchase_required",
                message="Sandbox mode only accepts Google Play test purchases.",
                trace={
                    "google_subscription_state": body.get("subscriptionState"),
                },
            )

        subscription_state = str(body.get("subscriptionState", ""))
        renewal_state = _renewal_state_for_google_subscription(subscription_state)
        verified = subscription_state in {
            "SUBSCRIPTION_STATE_ACTIVE",
            "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
            "SUBSCRIPTION_STATE_ON_HOLD",
            "SUBSCRIPTION_STATE_PAUSED",
        }
        plan, quota = _plan_and_quota(
            product_id=payload.product_id,
            premium_product_id=self._settings.mobile_google_play_premium_product_id,
            pro_product_id=self._settings.mobile_google_play_pro_product_id,
        )

        return MobileBillingValidationResponse(
            verified=verified,
            plan=plan if verified else "free",
            quota=quota if verified else _free_quota(),
            billing_provider="google_play" if verified else "disabled",
            renewal_state=renewal_state,
            sandbox=sandbox_purchase,
            status_code="validated" if verified else "validated_inactive",
            message=(
                "Google Play sandbox purchase validated."
                if verified
                else "Google Play purchase is valid but not active."
            ),
            validated_at_iso=now,
            trace={
                "google_subscription_state": subscription_state,
                "sandbox_purchase": sandbox_purchase,
                "mode": self._settings.mobile_billing_mode,
                "matched_product_ids": sorted(product_ids),
            },
        )

    async def aclose(self) -> None:
        await self._client.aclose()

    def _load_service_account_info(self) -> dict[str, Any] | None:
        raw_json = self._settings.mobile_google_play_service_account_json.strip()
        if raw_json:
            try:
                if raw_json.startswith("{"):
                    return json.loads(raw_json)
                decoded = base64.b64decode(raw_json).decode("utf-8")
                return json.loads(decoded)
            except (ValueError, json.JSONDecodeError):
                return None

        file_path = self._settings.mobile_google_play_service_account_file.strip()
        if not file_path:
            return None
        path = Path(file_path)
        if not path.exists():
            return None
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError:
            return None

    def _build_access_token(self, service_account_info: dict[str, Any]) -> str:
        credentials = service_account.Credentials.from_service_account_info(
            service_account_info,
            scopes=[ANDROID_PUBLISHER_SCOPE],
        )
        credentials.refresh(GoogleAuthRequest())
        if not credentials.token:  # pragma: no cover
            raise RuntimeError("Google Play service account token refresh failed.")
        return credentials.token

    def _decision(
        self,
        *,
        now: datetime,
        verified: bool,
        status_code: str,
        message: str,
        trace: dict[str, Any] | None = None,
    ) -> MobileBillingValidationResponse:
        return MobileBillingValidationResponse(
            verified=verified,
            plan="free",
            quota=_free_quota(),
            billing_provider="disabled",
            renewal_state="disabled",
            sandbox=False,
            status_code=status_code,
            message=message,
            validated_at_iso=now,
            trace=trace or {},
        )


def _renewal_state_for_google_subscription(subscription_state: str) -> str:
    mapping = {
        "SUBSCRIPTION_STATE_PENDING": "pending",
        "SUBSCRIPTION_STATE_ACTIVE": "active",
        "SUBSCRIPTION_STATE_IN_GRACE_PERIOD": "grace",
        "SUBSCRIPTION_STATE_ON_HOLD": "grace",
        "SUBSCRIPTION_STATE_PAUSED": "paused",
        "SUBSCRIPTION_STATE_CANCELED": "expired",
        "SUBSCRIPTION_STATE_EXPIRED": "expired",
    }
    return mapping.get(subscription_state, "disabled")


def _plan_and_quota(
    *,
    product_id: str,
    premium_product_id: str,
    pro_product_id: str,
) -> tuple[str, dict[str, int]]:
    if product_id == pro_product_id:
        return "pro", {
            "daily_mission_refreshes": 240,
            "ai_assisted_captures": 240,
            "export_bundles": 1,
        }
    if product_id == premium_product_id:
        return "premium", {
            "daily_mission_refreshes": 120,
            "ai_assisted_captures": 120,
            "export_bundles": 1,
        }
    return "free", _free_quota()


def _free_quota() -> dict[str, int]:
    return {
        "daily_mission_refreshes": 24,
        "ai_assisted_captures": 24,
        "export_bundles": 1,
    }
