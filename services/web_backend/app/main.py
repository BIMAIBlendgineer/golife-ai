from __future__ import annotations

from datetime import UTC, datetime
from uuid import uuid4

from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.crypto import SecretBox
from app.openrouter_client import fetch_openrouter_model_catalog
from app.repository import OperationalRepository
from app.routing import (
    build_mobile_runtime_config,
    build_model_history,
    capability_for_endpoint,
    rank_models_for_capability,
    utcnow,
)
from app.schemas import (
    AIInvocationRecord,
    AdminHealth,
    AiUsageLedgerRow,
    BillingAccountRow,
    DashboardMetrics,
    FeatureFlag,
    FeatureFlagPatch,
    FeedbackAuditUpsert,
    InternalRoutingConfig,
    MissionAuditUpsert,
    MobileRuntimeConfig,
    ModelCatalogEntry,
    ModelSelectionSnapshot,
    ModelSettingsSnapshot,
    ModelSettingsUpsert,
    OrganizationDetail,
    OrganizationRow,
    OpenRouterByokKeyCreate,
    OpenRouterByokKeyPatch,
    OpenRouterByokKeyRecord,
    OpenRouterApiKeyCreate,
    OpenRouterApiKeyPatch,
    OpenRouterApiKeyRecord,
    OpenRouterKeyEventRecord,
    OpenRouterKeyEventUpsert,
    PaginatedResponse,
    PlanRow,
    RoutingCapability,
    RoutingProfile,
    RoutingProfilePatch,
    SafetyAuditUpsert,
    UserManagementRow,
    UserPrivacySummary,
    UserSummary,
    UserSupportSummary,
    UserUsageSummary,
    UsageEventRecord,
    StorageSummary,
    StorageUsageRow,
    XInsightCreditSummary,
)
from app.settings import Settings


def create_app(
    *,
    settings: Settings | None = None,
    repository: OperationalRepository | None = None,
) -> FastAPI:
    resolved_settings = settings or Settings()
    resolved_repository = repository or OperationalRepository(
        resolved_settings.resolved_operational_database,
        seed_demo_data=resolved_settings.seed_demo_data,
    )
    secret_box = SecretBox(resolved_settings.openrouter_keys_master_key)

    app = FastAPI(title="GoLife Web Backend", version="0.2.0")
    app.state.settings = resolved_settings
    app.state.repository = resolved_repository
    app.state.secret_box = secret_box
    app.add_middleware(
        CORSMiddleware,
        allow_origins=resolved_settings.cors_origins,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    def require_admin(
        x_admin_token: str | None = Header(default=None),
    ) -> None:
        if x_admin_token != resolved_settings.admin_token:
            raise HTTPException(status_code=401, detail="Invalid admin token.")

    def require_ingestion(
        x_ingestion_token: str | None = Header(default=None),
    ) -> None:
        if x_ingestion_token != resolved_settings.ingestion_token:
            raise HTTPException(status_code=401, detail="Invalid ingestion token.")

    def require_internal_service(
        x_internal_service_token: str | None = Header(default=None),
    ) -> None:
        if x_internal_service_token != resolved_settings.internal_service_token:
            raise HTTPException(status_code=401, detail="Invalid internal service token.")

    def feature_flags_map() -> dict[str, bool]:
        return {
            flag.key: flag.enabled
            for flag in resolved_repository.list_feature_flags()
        }

    def refresh_selection_snapshots() -> list[ModelSelectionSnapshot]:
        profiles = [profile for profile in resolved_repository.list_routing_profiles() if profile.enabled]
        catalog = resolved_repository.list_model_catalog()
        generated: list[ModelSelectionSnapshot] = []
        for profile in profiles:
            history = build_model_history(
                resolved_repository.list_ai_invocations_for_capability(profile.capability)
            )
            generated.extend(
                rank_models_for_capability(
                    capability=profile.capability,
                    profile=profile,
                    models=catalog,
                    invocation_history=history,
                )
            )
        resolved_repository.replace_selection_snapshots(generated)
        return generated

    def ensure_selection_snapshots() -> list[ModelSelectionSnapshot]:
        snapshots = resolved_repository.list_selection_snapshots()
        now = utcnow()
        if not snapshots:
            return refresh_selection_snapshots()
        if any(snapshot.expires_at <= now for snapshot in snapshots):
            return refresh_selection_snapshots()
        return snapshots

    def build_internal_config(*, source: str = "live") -> InternalRoutingConfig:
        snapshots = ensure_selection_snapshots()
        active_keys = []
        for item in resolved_repository.get_active_key_materials():
            active_keys.append(
                {
                    "key_id": item["key_id"],
                    "label": item["label"],
                    "secret": secret_box.decrypt(str(item["secret_ciphertext"])),
                    "priority": item["priority"],
                    "status": item["status"],
                }
            )
        return InternalRoutingConfig(
            config_source=source,
            generated_at=utcnow(),
            openrouter_keys=active_keys,
            routing_profiles=resolved_repository.list_routing_profiles(),
            selection_snapshots=snapshots,
            feature_flags=feature_flags_map(),
        )

    def build_runtime_config() -> MobileRuntimeConfig:
        dashboard = resolved_repository.dashboard()
        snapshots = ensure_selection_snapshots()
        ai_status = {
            "active_provider": resolved_repository.model_settings().active_provider,
            "active_key_count": dashboard.active_key_count,
            "disabled_key_count": dashboard.disabled_key_count,
            "routing_snapshot_age_seconds": dashboard.routing_snapshot_age_seconds,
            "selected_capabilities": sorted(
                {snapshot.capability for snapshot in snapshots}
            ),
        }
        return build_mobile_runtime_config(
            gateway_base_url=resolved_settings.mobile_gateway_base_url,
            ttl_seconds=resolved_settings.mobile_runtime_config_ttl_seconds,
            feature_flags=feature_flags_map(),
            ai_status=ai_status,
        )

    @app.get("/health", response_model=AdminHealth)
    async def health() -> AdminHealth:
        return resolved_repository.health()

    @app.get("/public/mobile/runtime-config", response_model=MobileRuntimeConfig)
    async def public_mobile_runtime_config() -> MobileRuntimeConfig:
        return build_runtime_config()

    @app.get("/admin/dashboard", response_model=DashboardMetrics)
    async def dashboard(_: None = Depends(require_admin)) -> DashboardMetrics:
        return resolved_repository.dashboard()

    @app.get("/admin/users", response_model=PaginatedResponse[UserManagementRow])
    async def users(
        limit: int = 25,
        offset: int = 0,
        query: str | None = None,
        status: str | None = None,
        plan: str | None = None,
        locale: str | None = None,
        _: None = Depends(require_admin),
    ) -> PaginatedResponse[UserManagementRow]:
        capped_limit = min(max(limit, 1), 100)
        safe_offset = max(offset, 0)
        return resolved_repository.list_user_management(
            limit=capped_limit,
            offset=safe_offset,
            query=query,
            status=status,
            plan=plan,
            locale=locale,
        )

    @app.get("/admin/users/{user_id}", response_model=UserSummary)
    async def user_detail(user_id: str, _: None = Depends(require_admin)) -> UserSummary:
        user = resolved_repository.get_user_summary(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found.")
        return user

    @app.get("/admin/users/{user_id}/summary", response_model=UserSummary)
    async def user_summary(user_id: str, _: None = Depends(require_admin)) -> UserSummary:
        user = resolved_repository.get_user_summary(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found.")
        return user

    @app.get("/admin/users/{user_id}/usage", response_model=UserUsageSummary)
    async def user_usage(user_id: str, _: None = Depends(require_admin)) -> UserUsageSummary:
        user = resolved_repository.get_user_usage_summary(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found.")
        return user

    @app.get("/admin/users/{user_id}/privacy", response_model=UserPrivacySummary)
    async def user_privacy(
        user_id: str,
        _: None = Depends(require_admin),
    ) -> UserPrivacySummary:
        user = resolved_repository.get_user_privacy_summary(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found.")
        return user

    @app.get("/admin/users/{user_id}/support", response_model=UserSupportSummary)
    async def user_support(
        user_id: str,
        _: None = Depends(require_admin),
    ) -> UserSupportSummary:
        user = resolved_repository.get_user_support_summary(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found.")
        return user

    @app.get("/admin/organizations", response_model=list[OrganizationRow])
    async def organizations(_: None = Depends(require_admin)) -> list[OrganizationRow]:
        return resolved_repository.list_organizations()

    @app.get("/admin/organizations/{organization_id}", response_model=OrganizationDetail)
    async def organization_detail(
        organization_id: str,
        _: None = Depends(require_admin),
    ) -> OrganizationDetail:
        organization = resolved_repository.get_organization(organization_id)
        if organization is None:
            raise HTTPException(status_code=404, detail="Organization not found.")
        return organization

    @app.get("/admin/plans", response_model=list[PlanRow])
    async def plans(_: None = Depends(require_admin)) -> list[PlanRow]:
        return resolved_repository.list_plans()

    @app.get("/admin/openrouter-byok", response_model=list[OpenRouterByokKeyRecord])
    async def list_openrouter_byok(
        _: None = Depends(require_admin),
    ) -> list[OpenRouterByokKeyRecord]:
        return resolved_repository.list_openrouter_byok_keys()

    @app.post("/admin/openrouter-byok", response_model=OpenRouterByokKeyRecord)
    async def create_openrouter_byok(
        payload: OpenRouterByokKeyCreate,
        _: None = Depends(require_admin),
    ) -> OpenRouterByokKeyRecord:
        return resolved_repository.create_openrouter_byok_key(
            payload,
            secret_ciphertext=secret_box.encrypt(payload.secret),
            secret_last4=SecretBox.secret_last4(payload.secret),
            key_id=f"byok-{uuid4()}",
        )

    @app.patch("/admin/openrouter-byok/{key_id}", response_model=OpenRouterByokKeyRecord)
    async def patch_openrouter_byok(
        key_id: str,
        payload: OpenRouterByokKeyPatch,
        _: None = Depends(require_admin),
    ) -> OpenRouterByokKeyRecord:
        updated = resolved_repository.patch_openrouter_byok_key(
            key_id,
            payload,
            secret_ciphertext=(
                secret_box.encrypt(payload.secret) if payload.secret is not None else None
            ),
            secret_last4=(
                SecretBox.secret_last4(payload.secret) if payload.secret is not None else None
            ),
        )
        if updated is None:
            raise HTTPException(status_code=404, detail="BYOK key not found.")
        return updated

    @app.post("/admin/openrouter-byok/{key_id}/test", response_model=OpenRouterByokKeyRecord)
    async def test_openrouter_byok(
        key_id: str,
        _: None = Depends(require_admin),
    ) -> OpenRouterByokKeyRecord:
        updated = resolved_repository.test_openrouter_byok_key(key_id)
        if updated is None:
            raise HTTPException(status_code=404, detail="BYOK key not found or disabled.")
        return updated

    @app.post(
        "/admin/openrouter-byok/{key_id}/disable",
        response_model=OpenRouterByokKeyRecord,
    )
    async def disable_openrouter_byok(
        key_id: str,
        _: None = Depends(require_admin),
    ) -> OpenRouterByokKeyRecord:
        updated = resolved_repository.disable_openrouter_byok_key(key_id)
        if updated is None:
            raise HTTPException(status_code=404, detail="BYOK key not found.")
        return updated

    @app.post("/admin/openrouter-byok/{key_id}/rotate", response_model=OpenRouterByokKeyRecord)
    async def rotate_openrouter_byok(
        key_id: str,
        payload: OpenRouterByokKeyPatch,
        _: None = Depends(require_admin),
    ) -> OpenRouterByokKeyRecord:
        if payload.secret is None:
            raise HTTPException(status_code=400, detail="secret is required for rotation.")
        updated = resolved_repository.patch_openrouter_byok_key(
            key_id,
            payload,
            secret_ciphertext=secret_box.encrypt(payload.secret),
            secret_last4=SecretBox.secret_last4(payload.secret),
        )
        if updated is None:
            raise HTTPException(status_code=404, detail="BYOK key not found.")
        return updated

    @app.get("/admin/xinsightai/usage", response_model=list[AiUsageLedgerRow])
    async def xinsight_usage(_: None = Depends(require_admin)) -> list[AiUsageLedgerRow]:
        return resolved_repository.list_ai_usage_ledger()

    @app.get("/admin/xinsightai/credits", response_model=XInsightCreditSummary)
    async def xinsight_credits(
        _: None = Depends(require_admin),
    ) -> XInsightCreditSummary:
        return resolved_repository.get_xinsight_credit_summary()

    @app.get("/admin/xinsightai/plans", response_model=list[PlanRow])
    async def xinsight_plans(_: None = Depends(require_admin)) -> list[PlanRow]:
        return resolved_repository.list_xinsight_plan_rows()

    @app.get("/admin/billing/accounts", response_model=list[BillingAccountRow])
    async def billing_accounts(_: None = Depends(require_admin)) -> list[BillingAccountRow]:
        return resolved_repository.list_billing_accounts()

    @app.get("/admin/billing/plans", response_model=list[PlanRow])
    async def billing_plans(_: None = Depends(require_admin)) -> list[PlanRow]:
        return resolved_repository.list_plans()

    @app.get("/admin/storage/summary", response_model=StorageSummary)
    async def storage_summary(_: None = Depends(require_admin)) -> StorageSummary:
        return resolved_repository.get_storage_summary()

    @app.get("/admin/storage/usage", response_model=list[StorageUsageRow])
    async def storage_usage(_: None = Depends(require_admin)) -> list[StorageUsageRow]:
        return resolved_repository.list_storage_usage()

    @app.get("/admin/usage")
    async def usage(_: None = Depends(require_admin)) -> list[dict[str, object]]:
        return [item.model_dump(mode="json") for item in resolved_repository.list_usage()]

    @app.get("/admin/ai-costs")
    async def ai_costs(_: None = Depends(require_admin)) -> list[dict[str, object]]:
        return [item.model_dump(mode="json") for item in resolved_repository.list_ai_costs()]

    @app.get("/admin/missions")
    async def missions(_: None = Depends(require_admin)) -> list[dict[str, object]]:
        return [item.model_dump(mode="json") for item in resolved_repository.list_missions()]

    @app.get("/admin/feedback")
    async def feedback(_: None = Depends(require_admin)) -> list[dict[str, object]]:
        return [item.model_dump(mode="json") for item in resolved_repository.list_feedback()]

    @app.get("/admin/safety")
    async def safety(_: None = Depends(require_admin)) -> list[dict[str, object]]:
        return [item.model_dump(mode="json") for item in resolved_repository.list_safety()]

    @app.get("/admin/feature-flags", response_model=list[FeatureFlag])
    async def feature_flags(_: None = Depends(require_admin)) -> list[FeatureFlag]:
        return resolved_repository.list_feature_flags()

    @app.patch("/admin/feature-flags/{flag_key}", response_model=FeatureFlag)
    async def patch_feature_flag(
        flag_key: str,
        payload: FeatureFlagPatch,
        _: None = Depends(require_admin),
    ) -> FeatureFlag:
        updated = resolved_repository.update_feature_flag(flag_key, payload.enabled)
        if updated is None:
            raise HTTPException(status_code=404, detail="Feature flag not found.")
        return updated

    @app.get("/admin/models", response_model=ModelSettingsSnapshot)
    async def model_settings(_: None = Depends(require_admin)) -> ModelSettingsSnapshot:
        return resolved_repository.model_settings()

    @app.get("/admin/support/export-delete")
    async def support_requests(_: None = Depends(require_admin)) -> list[dict[str, object]]:
        return [
            item.model_dump(mode="json")
            for item in resolved_repository.list_support_requests()
        ]

    @app.get("/admin/openrouter/keys", response_model=list[OpenRouterApiKeyRecord])
    async def list_openrouter_keys(_: None = Depends(require_admin)) -> list[OpenRouterApiKeyRecord]:
        return resolved_repository.list_openrouter_keys()

    @app.post("/admin/openrouter/keys", response_model=OpenRouterApiKeyRecord)
    async def create_openrouter_key(
        payload: OpenRouterApiKeyCreate,
        _: None = Depends(require_admin),
    ) -> OpenRouterApiKeyRecord:
        created = resolved_repository.create_openrouter_key(
            payload,
            secret_ciphertext=secret_box.encrypt(payload.secret),
            secret_last4=SecretBox.secret_last4(payload.secret),
            key_id=f"or-key-{uuid4()}",
        )
        refresh_selection_snapshots()
        resolved_repository.record_openrouter_key_event(
            OpenRouterKeyEventUpsert(
                event_id=f"key-event-{uuid4()}",
                key_id=created.key_id,
                key_label=created.label,
                event_type="created",
                notes="Key created from admin.",
                created_at=utcnow(),
            )
        )
        return created

    @app.patch("/admin/openrouter/keys/{key_id}", response_model=OpenRouterApiKeyRecord)
    async def patch_openrouter_key(
        key_id: str,
        payload: OpenRouterApiKeyPatch,
        _: None = Depends(require_admin),
    ) -> OpenRouterApiKeyRecord:
        updated = resolved_repository.patch_openrouter_key(
            key_id,
            payload,
            secret_ciphertext=(
                secret_box.encrypt(payload.secret) if payload.secret is not None else None
            ),
            secret_last4=(
                SecretBox.secret_last4(payload.secret) if payload.secret is not None else None
            ),
        )
        if updated is None:
            raise HTTPException(status_code=404, detail="OpenRouter key not found.")
        refresh_selection_snapshots()
        return updated

    @app.post("/admin/openrouter/keys/{key_id}/disable", response_model=OpenRouterApiKeyRecord)
    async def disable_openrouter_key(
        key_id: str,
        _: None = Depends(require_admin),
    ) -> OpenRouterApiKeyRecord:
        updated = resolved_repository.disable_openrouter_key(key_id)
        if updated is None:
            raise HTTPException(status_code=404, detail="OpenRouter key not found.")
        resolved_repository.record_openrouter_key_event(
            OpenRouterKeyEventUpsert(
                event_id=f"key-event-{uuid4()}",
                key_id=updated.key_id,
                key_label=updated.label,
                event_type="disabled",
                notes="Key disabled from admin.",
                created_at=utcnow(),
            )
        )
        refresh_selection_snapshots()
        return updated

    @app.get("/admin/openrouter/key-events", response_model=list[OpenRouterKeyEventRecord])
    async def list_openrouter_key_events(
        _: None = Depends(require_admin),
    ) -> list[OpenRouterKeyEventRecord]:
        return resolved_repository.list_openrouter_key_events()

    @app.get("/admin/routing-profiles", response_model=list[RoutingProfile])
    async def list_routing_profiles(_: None = Depends(require_admin)) -> list[RoutingProfile]:
        return resolved_repository.list_routing_profiles()

    @app.patch("/admin/routing-profiles/{capability}", response_model=RoutingProfile)
    async def patch_routing_profile(
        capability: RoutingCapability,
        payload: RoutingProfilePatch,
        _: None = Depends(require_admin),
    ) -> RoutingProfile:
        updated = resolved_repository.update_routing_profile(capability, payload)
        if updated is None:
            raise HTTPException(status_code=404, detail="Routing profile not found.")
        refresh_selection_snapshots()
        return updated

    @app.get("/admin/model-catalog", response_model=list[ModelCatalogEntry])
    async def list_model_catalog(_: None = Depends(require_admin)) -> list[ModelCatalogEntry]:
        return resolved_repository.list_model_catalog()

    @app.post("/admin/model-catalog/refresh", response_model=list[ModelCatalogEntry])
    async def refresh_model_catalog(_: None = Depends(require_admin)) -> list[ModelCatalogEntry]:
        entries = await fetch_openrouter_model_catalog(resolved_settings.openrouter_base_url)
        resolved_repository.replace_model_catalog(entries)
        refresh_selection_snapshots()
        return resolved_repository.list_model_catalog()

    @app.get("/admin/model-selections", response_model=list[ModelSelectionSnapshot])
    async def list_model_selections(
        _: None = Depends(require_admin),
    ) -> list[ModelSelectionSnapshot]:
        return ensure_selection_snapshots()

    @app.get("/internal/ai-routing/config", response_model=InternalRoutingConfig)
    async def internal_ai_routing_config(
        _: None = Depends(require_internal_service),
    ) -> InternalRoutingConfig:
        return build_internal_config(source="live")

    @app.post("/internal/ai-routing/selection-refresh", response_model=list[ModelSelectionSnapshot])
    async def internal_selection_refresh(
        _: None = Depends(require_internal_service),
    ) -> list[ModelSelectionSnapshot]:
        return refresh_selection_snapshots()

    @app.post("/internal/openrouter-key-events", status_code=202)
    async def record_openrouter_key_event(
        payload: OpenRouterKeyEventUpsert,
        _: None = Depends(require_internal_service),
    ) -> dict[str, bool]:
        resolved_repository.record_openrouter_key_event(payload)
        refresh_selection_snapshots()
        return {"accepted": True}

    @app.post("/internal/usage-events", status_code=202)
    async def record_usage_event(
        payload: UsageEventRecord,
        _: None = Depends(require_ingestion),
    ) -> dict[str, bool]:
        resolved_repository.record_usage_event(payload)
        return {"accepted": True}

    @app.post("/internal/ai-invocations", status_code=202)
    async def record_ai_invocation(
        payload: AIInvocationRecord,
        _: None = Depends(require_ingestion),
    ) -> dict[str, bool]:
        resolved_repository.record_ai_invocation(payload)
        capability = capability_for_endpoint(payload.endpoint)
        if capability is not None:
            refresh_selection_snapshots()
        return {"accepted": True}

    @app.post("/internal/mission-audits", status_code=202)
    async def record_mission_audits(
        payload: list[MissionAuditUpsert],
        _: None = Depends(require_ingestion),
    ) -> dict[str, int]:
        for item in payload:
            resolved_repository.record_mission_audit(item)
        return {"accepted": len(payload)}

    @app.post("/internal/feedback-audits", status_code=202)
    async def record_feedback_audit(
        payload: FeedbackAuditUpsert,
        _: None = Depends(require_ingestion),
    ) -> dict[str, bool]:
        resolved_repository.record_feedback_audit(payload)
        return {"accepted": True}

    @app.post("/internal/safety-events", status_code=202)
    async def record_safety_events(
        payload: list[SafetyAuditUpsert],
        _: None = Depends(require_ingestion),
    ) -> dict[str, int]:
        for item in payload:
            resolved_repository.record_safety_event(item)
        return {"accepted": len(payload)}

    @app.post("/internal/model-settings", status_code=202)
    async def record_model_settings(
        payload: ModelSettingsUpsert,
        _: None = Depends(require_ingestion),
    ) -> dict[str, bool]:
        resolved_repository.set_model_settings(payload)
        return {"accepted": True}

    return app


app = create_app()
