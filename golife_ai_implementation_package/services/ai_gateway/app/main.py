from fastapi import FastAPI, Request

from app.feedback_store import MissionFeedbackStore
from app.providers.base import LLMProvider
from app.providers.factory import build_provider
from app.schemas import (
    EventClassificationRequest,
    EventClassificationResponse,
    MissionFeedbackRequest,
    MissionFeedbackResponse,
    SuggestionRequest,
    SuggestionResponse,
    TaskRewriteRequest,
    TaskRewriteResponse,
)
from app.settings import Settings
from app.use_cases import (
    run_domain_suggestions,
    run_event_classification,
    run_suggestions,
    run_task_rewrite,
)


def create_app(
    *,
    settings: Settings | None = None,
    provider: LLMProvider | None = None,
) -> FastAPI:
    resolved_settings = settings or Settings()
    resolved_provider = provider or build_provider(resolved_settings)

    app = FastAPI(title="GoLife AI Gateway", version="0.2.0")
    app.state.settings = resolved_settings
    app.state.provider = resolved_provider
    app.state.feedback_store = MissionFeedbackStore(
        resolved_settings.feedback_store_path
    )

    @app.get("/health")
    async def health() -> dict[str, object]:
        return {
            "status": "ok",
            "configured_provider": resolved_settings.llm_provider,
            "active_provider": resolved_provider.provider_name,
            "mock_mode": resolved_settings.resolved_mock_mode,
        }

    @app.post("/v1/suggestions/generate", response_model=SuggestionResponse)
    async def generate_suggestions(
        payload: SuggestionRequest,
        request: Request,
    ) -> SuggestionResponse:
        return await run_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            intent="generic_suggestions",
        )

    @app.post("/v1/missions/daily", response_model=SuggestionResponse)
    async def daily_mission(
        payload: SuggestionRequest,
        request: Request,
    ) -> SuggestionResponse:
        return await run_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            intent="daily_mission",
        )

    @app.post("/v1/events/classify", response_model=EventClassificationResponse)
    async def classify_event(
        payload: EventClassificationRequest,
    ) -> EventClassificationResponse:
        return run_event_classification(payload)

    @app.post("/v1/tasks/rewrite", response_model=TaskRewriteResponse)
    async def rewrite_task(
        payload: TaskRewriteRequest,
        request: Request,
    ) -> TaskRewriteResponse:
        return await run_task_rewrite(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
        )

    @app.post("/v1/finance/reflect", response_model=SuggestionResponse)
    async def finance_reflect(
        payload: SuggestionRequest,
        request: Request,
    ) -> SuggestionResponse:
        return await run_domain_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            required_domain="finance",
            intent="finance_reflect",
        )

    @app.post("/v1/pantry/rescue", response_model=SuggestionResponse)
    async def pantry_rescue(
        payload: SuggestionRequest,
        request: Request,
    ) -> SuggestionResponse:
        return await run_domain_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            required_domain="pantry",
            intent="pantry_rescue",
        )

    @app.post("/v1/closet/decision", response_model=SuggestionResponse)
    async def closet_decision(
        payload: SuggestionRequest,
        request: Request,
    ) -> SuggestionResponse:
        return await run_domain_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            required_domain="wardrobe",
            intent="closet_decision",
        )

    @app.post("/v1/feedback", response_model=MissionFeedbackResponse)
    async def record_feedback(
        payload: MissionFeedbackRequest,
        request: Request,
    ) -> MissionFeedbackResponse:
        feedback_id = request.app.state.feedback_store.record(payload)
        return MissionFeedbackResponse(
            stored=True,
            feedback_id=feedback_id,
            trace={
                "feedback_count": len(request.app.state.feedback_store.all()),
                "status": payload.status,
            },
        )

    return app


app = create_app()
