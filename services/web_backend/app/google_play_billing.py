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
        error_body = _safe_json(api_response)
        error_reason = _google_error_reason(error_body)
        if api_response.status_code == 404:
            return self._decision(
                now=now,
                verified=False,
                status_code="purchase_not_found",
                message="Google Play did not find the submitted purchase token.",
                billing_provider="google_play",
                renewal_state="expired",
                sandbox=payload.mode == "google_play_sandbox",
                trace={
                    "google_error_reason": error_reason,
                    "renewal_state_inferred": True,
                    "mode": self._settings.mobile_billing_mode,
                },
            )
        if api_response.status_code >= 400:
            inferred_renewal_state = _renewal_state_for_google_error_reason(
                error_reason
            )
            return self._decision(
                now=now,
                verified=False,
                status_code="google_play_error",
                message=f"Google Play validation returned HTTP {api_response.status_code}.",
                billing_provider=(
                    "google_play"
                    if inferred_renewal_state != "disabled"
                    else "disabled"
                ),
                renewal_state=inferred_renewal_state,
                sandbox=payload.mode == "google_play_sandbox",
                trace={
                    "google_error_reason": error_reason,
                    "renewal_state_inferred": inferred_renewal_state != "disabled",
                    "mode": self._settings.mobile_billing_mode,
                },
            )

        body = error_body
        sandbox_purchase = body.get("testPurchase") is not None
        line_items = body.get("lineItems") or []
        if not line_items:
            return self._decision(
                now=now,
                verified=False,
                status_code="line_items_missing",
                message="Google Play returned no purchasable line items for this token.",
                billing_provider="google_play",
                renewal_state="disabled",
                sandbox=sandbox_purchase,
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
        cancellation_reason = _cancellation_reason(body)
        plan, quota = _plan_and_quota(
            product_id=payload.product_id,
            premium_product_id=self._settings.mobile_google_play_premium_product_id,
            pro_product_id=self._settings.mobile_google_play_pro_product_id,
        )

        status_code = "validated" if verified else _inactive_status_code(renewal_state)
        message = (
            "Google Play purchase validated."
            if verified
            else _inactive_status_message(renewal_state)
        )
        return MobileBillingValidationResponse(
            verified=verified,
            plan=plan if verified else "free",
            quota=quota if verified else _free_quota(),
            billing_provider="google_play",
            renewal_state=renewal_state,
            sandbox=sandbox_purchase,
            status_code=status_code,
            message=message,
            validated_at_iso=now,
            trace={
                "google_subscription_state": subscription_state,
                "sandbox_purchase": sandbox_purchase,
                "mode": self._settings.mobile_billing_mode,
                "matched_product_ids": sorted(product_ids),
                "acknowledgement_state": body.get("acknowledgementState"),
                "cancellation_reason": cancellation_reason,
                "latest_order_id": body.get("latestOrderId"),
                "linked_purchase_token_present": bool(body.get("linkedPurchaseToken")),
                "line_item_expiry_times": [
                    item.get("expiryTime")
                    for item in line_items
                    if item.get("expiryTime")
                ],
                "auto_renew_enabled": any(
                    bool((item.get("autoRenewingPlan") or {}).get("autoRenewEnabled"))
                    for item in line_items
                ),
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
        billing_provider: str = "disabled",
        renewal_state: str = "disabled",
        sandbox: bool = False,
        trace: dict[str, Any] | None = None,
    ) -> MobileBillingValidationResponse:
        return MobileBillingValidationResponse(
            verified=verified,
            plan="free",
            quota=_free_quota(),
            billing_provider=billing_provider,
            renewal_state=renewal_state,
            sandbox=sandbox,
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
        "SUBSCRIPTION_STATE_CANCELED": "cancelled",
        "SUBSCRIPTION_STATE_EXPIRED": "expired",
        "SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED": "cancelled",
    }
    return mapping.get(subscription_state, "disabled")


def _renewal_state_for_google_error_reason(error_reason: str | None) -> str:
    mapping = {
        "productNotOwnedByUser": "refunded",
        "subscriptionExpired": "expired",
        "subscriptionNoLongerAvailable": "expired",
        "purchaseTokenNoLongerValid": "expired",
        "notFound": "expired",
    }
    return mapping.get(error_reason or "", "disabled")


def _inactive_status_code(renewal_state: str) -> str:
    mapping = {
        "pending": "validated_pending",
        "cancelled": "validated_cancelled",
        "expired": "validated_expired",
        "refunded": "validated_refunded",
    }
    return mapping.get(renewal_state, "validated_inactive")


def _inactive_status_message(renewal_state: str) -> str:
    mapping = {
        "pending": "Google Play purchase is pending and premium access is not active yet.",
        "cancelled": "Google Play subscription is cancelled and will not renew.",
        "expired": "Google Play subscription is expired and premium access is no longer active.",
        "refunded": "Google Play subscription was refunded or revoked and premium access is no longer active.",
    }
    return mapping.get(renewal_state, "Google Play purchase is valid but not active.")


def _cancellation_reason(body: dict[str, Any]) -> str | None:
    context = body.get("canceledStateContext") or {}
    if not isinstance(context, dict):
        return None
    if context.get("userInitiatedCancellation") is not None:
        return "user"
    if context.get("systemInitiatedCancellation") is not None:
        return "system"
    if context.get("developerInitiatedCancellation") is not None:
        return "developer"
    if context.get("replacementCancellation") is not None:
        return "replacement"
    return None


def _google_error_reason(body: dict[str, Any]) -> str | None:
    error = body.get("error")
    if not isinstance(error, dict):
        return None
    errors = error.get("errors")
    if isinstance(errors, list):
        for item in errors:
            if isinstance(item, dict) and item.get("reason"):
                return str(item.get("reason"))
    if error.get("status"):
        return str(error.get("status"))
    return None


def _safe_json(response: httpx.Response) -> dict[str, Any]:
    try:
        payload = response.json()
    except ValueError:
        return {}
    if isinstance(payload, dict):
        return payload
    return {}


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
