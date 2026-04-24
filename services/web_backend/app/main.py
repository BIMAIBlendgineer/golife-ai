from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.repository import OperationalRepository
from app.schemas import (
    AIInvocationRecord,
    AdminHealth,
    DashboardMetrics,
    FeatureFlag,
    FeatureFlagPatch,
    FeedbackAuditUpsert,
    MissionAuditUpsert,
    ModelSettingsSnapshot,
    ModelSettingsUpsert,
    SafetyAuditUpsert,
    UsageEventRecord,
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

    app = FastAPI(title="GoLife Web Backend", version="0.1.0")
    app.state.settings = resolved_settings
    app.state.repository = resolved_repository
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

    @app.get("/health", response_model=AdminHealth)
    async def health() -> AdminHealth:
        return resolved_repository.health()

    @app.get("/admin/dashboard", response_model=DashboardMetrics)
    async def dashboard(_: None = Depends(require_admin)) -> DashboardMetrics:
        return resolved_repository.dashboard()

    @app.get("/admin/users")
    async def users(_: None = Depends(require_admin)) -> list[dict[str, object]]:
        return [item.model_dump(mode="json") for item in resolved_repository.list_users()]

    @app.get("/admin/users/{user_id}")
    async def user_detail(user_id: str, _: None = Depends(require_admin)) -> dict[str, object]:
        user = resolved_repository.get_user(user_id)
        if user is None:
            raise HTTPException(status_code=404, detail="User not found.")
        return user.model_dump(mode="json")

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
