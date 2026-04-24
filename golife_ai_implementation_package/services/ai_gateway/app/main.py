from time import perf_counter

from fastapi import BackgroundTasks, FastAPI, HTTPException, Request

from app.feedback_store import MissionFeedbackStore
from app.operational_client import NoopOperationalEventsClient, OperationalEventsClient
from app.operational_payloads import (
    build_classification_operation_payloads,
    build_feedback_operation_payloads,
    build_model_settings_payload,
    build_suggestion_operation_payloads,
    build_task_rewrite_operation_payloads,
)
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
    operational_client: OperationalEventsClient | None = None,
) -> FastAPI:
    resolved_settings = settings or Settings()
    resolved_provider = provider or build_provider(resolved_settings)
    resolved_operational_client = operational_client or (
        OperationalEventsClient(
            enabled=resolved_settings.operational_backend_enabled,
            base_url=resolved_settings.operational_backend_base_url,
            ingestion_token=resolved_settings.operational_backend_ingestion_token,
            timeout_seconds=resolved_settings.operational_backend_timeout_seconds,
            max_retries=resolved_settings.operational_backend_max_retries,
        )
        if resolved_settings.operational_backend_enabled
        else NoopOperationalEventsClient()
    )

    app = FastAPI(title="GoLife AI Gateway", version="0.2.0")
    app.state.settings = resolved_settings
    app.state.provider = resolved_provider
    app.state.operational_client = resolved_operational_client
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
        background_tasks: BackgroundTasks,
    ) -> SuggestionResponse:
        started_at = perf_counter()
        response = await run_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            intent="generic_suggestions",
        )
        _schedule_suggestion_reporting(
            background_tasks,
            request=request,
            payload=payload,
            response=response,
            endpoint="/v1/suggestions/generate",
            latency_ms=(perf_counter() - started_at) * 1000,
        )
        return response

    @app.post("/v1/missions/daily", response_model=SuggestionResponse)
    async def daily_mission(
        payload: SuggestionRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> SuggestionResponse:
        started_at = perf_counter()
        response = await run_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            intent="daily_mission",
        )
        _schedule_suggestion_reporting(
            background_tasks,
            request=request,
            payload=payload,
            response=response,
            endpoint="/v1/missions/daily",
            latency_ms=(perf_counter() - started_at) * 1000,
        )
        return response

    @app.post("/v1/events/classify", response_model=EventClassificationResponse)
    async def classify_event(
        payload: EventClassificationRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> EventClassificationResponse:
        started_at = perf_counter()
        response = run_event_classification(payload)
        telemetry = build_classification_operation_payloads(
            request=payload,
            response=response,
            latency_ms=(perf_counter() - started_at) * 1000,
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_usage_event,
            telemetry["usage_event"],
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_ai_invocation,
            telemetry["ai_invocation"],
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_model_settings,
            build_model_settings_payload(
                request.app.state.settings,
                request.app.state.provider.provider_name,
            ),
        )
        return response

    @app.post("/v1/tasks/rewrite", response_model=TaskRewriteResponse)
    async def rewrite_task(
        payload: TaskRewriteRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> TaskRewriteResponse:
        started_at = perf_counter()
        try:
            response = await run_task_rewrite(
                payload,
                settings=request.app.state.settings,
                provider=request.app.state.provider,
            )
        except HTTPException as exc:
            telemetry = build_task_rewrite_operation_payloads(
                request=payload,
                response=None,
                latency_ms=(perf_counter() - started_at) * 1000,
                status="error",
                error_detail=str(exc.detail),
            )
            await request.app.state.operational_client.record_usage_event(
                telemetry["usage_event"]
            )
            await request.app.state.operational_client.record_ai_invocation(
                telemetry["ai_invocation"]
            )
            if telemetry["safety_events"]:
                await request.app.state.operational_client.record_safety_events(
                    telemetry["safety_events"]
                )
            raise

        telemetry = build_task_rewrite_operation_payloads(
            request=payload,
            response=response,
            latency_ms=(perf_counter() - started_at) * 1000,
            status="success",
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_usage_event,
            telemetry["usage_event"],
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_ai_invocation,
            telemetry["ai_invocation"],
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_model_settings,
            build_model_settings_payload(
                request.app.state.settings,
                request.app.state.provider.provider_name,
            ),
        )
        return response

    @app.post("/v1/finance/reflect", response_model=SuggestionResponse)
    async def finance_reflect(
        payload: SuggestionRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> SuggestionResponse:
        started_at = perf_counter()
        response = await run_domain_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            required_domain="finance",
            intent="finance_reflect",
        )
        _schedule_suggestion_reporting(
            background_tasks,
            request=request,
            payload=payload,
            response=response,
            endpoint="/v1/finance/reflect",
            latency_ms=(perf_counter() - started_at) * 1000,
        )
        return response

    @app.post("/v1/pantry/rescue", response_model=SuggestionResponse)
    async def pantry_rescue(
        payload: SuggestionRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> SuggestionResponse:
        started_at = perf_counter()
        response = await run_domain_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            required_domain="pantry",
            intent="pantry_rescue",
        )
        _schedule_suggestion_reporting(
            background_tasks,
            request=request,
            payload=payload,
            response=response,
            endpoint="/v1/pantry/rescue",
            latency_ms=(perf_counter() - started_at) * 1000,
        )
        return response

    @app.post("/v1/closet/decision", response_model=SuggestionResponse)
    async def closet_decision(
        payload: SuggestionRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> SuggestionResponse:
        started_at = perf_counter()
        response = await run_domain_suggestions(
            payload,
            settings=request.app.state.settings,
            provider=request.app.state.provider,
            feedback_store=request.app.state.feedback_store,
            required_domain="wardrobe",
            intent="closet_decision",
        )
        _schedule_suggestion_reporting(
            background_tasks,
            request=request,
            payload=payload,
            response=response,
            endpoint="/v1/closet/decision",
            latency_ms=(perf_counter() - started_at) * 1000,
        )
        return response

    @app.post("/v1/feedback", response_model=MissionFeedbackResponse)
    async def record_feedback(
        payload: MissionFeedbackRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> MissionFeedbackResponse:
        feedback_id = request.app.state.feedback_store.record(payload)
        telemetry = build_feedback_operation_payloads(
            request=payload,
            feedback_id=feedback_id,
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_usage_event,
            telemetry["usage_event"],
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_feedback_audit,
            telemetry["feedback_audit"],
        )
        return MissionFeedbackResponse(
            stored=True,
            feedback_id=feedback_id,
            trace={
                "feedback_count": len(request.app.state.feedback_store.all()),
                "status": payload.status,
            },
        )

    return app


def _schedule_suggestion_reporting(
    background_tasks: BackgroundTasks,
    *,
    request: Request,
    payload: SuggestionRequest,
    response: SuggestionResponse,
    endpoint: str,
    latency_ms: float,
) -> None:
    telemetry = build_suggestion_operation_payloads(
        endpoint=endpoint,
        request=payload,
        response=response,
        latency_ms=latency_ms,
    )
    background_tasks.add_task(
        request.app.state.operational_client.record_usage_event,
        telemetry["usage_event"],
    )
    background_tasks.add_task(
        request.app.state.operational_client.record_ai_invocation,
        telemetry["ai_invocation"],
    )
    if telemetry["mission_audits"]:
        background_tasks.add_task(
            request.app.state.operational_client.record_mission_audits,
            telemetry["mission_audits"],
        )
    if telemetry["safety_events"]:
        background_tasks.add_task(
            request.app.state.operational_client.record_safety_events,
            telemetry["safety_events"],
        )
    background_tasks.add_task(
        request.app.state.operational_client.record_model_settings,
        build_model_settings_payload(
            request.app.state.settings,
            request.app.state.provider.provider_name,
        ),
    )


app = create_app()
