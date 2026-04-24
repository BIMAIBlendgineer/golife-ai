from fastapi import Depends, FastAPI, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from app.repository import OperationalRepository
from app.schemas import (
    DashboardMetrics,
    FeatureFlag,
    FeatureFlagPatch,
    ModelSettingsSnapshot,
)
from app.settings import Settings


def create_app(
    *,
    settings: Settings | None = None,
    repository: OperationalRepository | None = None,
) -> FastAPI:
    resolved_settings = settings or Settings()
    resolved_repository = repository or OperationalRepository()

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

    @app.get("/health")
    async def health() -> dict[str, str]:
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

    return app


app = create_app()
