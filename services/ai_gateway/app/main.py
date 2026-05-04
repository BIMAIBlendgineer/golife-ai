from pathlib import Path
from time import perf_counter
from uuid import uuid4

from fastapi import BackgroundTasks, FastAPI, HTTPException, Request

from app.errors import AITemporarilyUnavailableError
from app.feedback_store import MissionFeedbackStore
from app.guardrails import (
    assess_reflection_safety,
    enforce_safe_capture_input,
    enforce_safe_proof_input,
    enforce_safe_task_rewrite_content,
)
from app.operational_client import NoopOperationalEventsClient, OperationalEventsClient
from app.operational_payloads import (
    build_ai_unavailable_operation_payload,
    build_classification_operation_payloads,
    build_feedback_operation_payloads,
    build_model_settings_payload,
    build_parse_operation_payloads,
    build_proof_parse_operation_payloads,
    build_reflection_safety_operation_payloads,
    build_suggestion_operation_payloads,
    build_task_rewrite_operation_payloads,
)
from app.providers.base import LLMProvider
from app.providers.factory import build_provider
from app.schemas import (
    EventClassificationRequest,
    EventClassificationResponse,
    EventParseRequest,
    EventParseResponse,
    MissionFeedbackRequest,
    MissionFeedbackResponse,
    ProofParseRequest,
    ProofParseResponse,
    ReflectionSafetyRequest,
    ReflectionSafetyResponse,
    SuggestionRequest,
    SuggestionResponse,
    TaskRewriteRequest,
    TaskRewriteResponse,
)
from app.settings import Settings, get_settings
from app.use_cases import (
    run_domain_suggestions,
    run_event_classification,
    run_event_classification_semantic,
    run_event_parse,
    run_event_parse_semantic,
    run_proof_parse,
    run_proof_parse_semantic,
    run_suggestions,
    run_task_rewrite,
)


def create_app(
    *,
    settings: Settings | None = None,
    provider: LLMProvider | None = None,
    operational_client: OperationalEventsClient | None = None,
) -> FastAPI:
    resolved_settings = settings or get_settings()
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

    @app.middleware("http")
    async def correlation_id_middleware(request: Request, call_next):
        correlation_id = _resolve_correlation_id(request)
        request.state.correlation_id = correlation_id
        response = await call_next(request)
        response.headers["x-correlation-id"] = correlation_id
        return response

    @app.get("/health")
    async def health() -> dict[str, object]:
        provider_health = await resolved_provider.health_snapshot()
        return {
            "status": "ok",
            "configured_provider": resolved_settings.llm_provider,
            "active_provider": resolved_provider.provider_name,
            "mock_mode": resolved_settings.resolved_mock_mode,
            **provider_health,
        }

    async def readiness_snapshot() -> tuple[dict[str, object], bool]:
        provider_health = await resolved_provider.health_snapshot()
        crisis_catalog_ready = not resolved_settings.crisis_resources_catalog_path or Path(
            resolved_settings.crisis_resources_catalog_path
        ).exists()
        routing_source = str(provider_health.get("config_source", "fallback"))
        active_key_count = int(provider_health.get("active_key_count", 0) or 0)
        ai_configured = bool(
            resolved_settings.has_openrouter_key
            or (
                routing_source in {"live", "cached"}
                and active_key_count > 0
            )
        )
        checks = {
            "provider_real": resolved_provider.provider_name != "mock",
            "mock_mode_disabled": not resolved_settings.resolved_mock_mode,
            "ai_configured": ai_configured,
            "crisis_catalog_ready": crisis_catalog_ready,
        }
        production_ready = all(checks.values())
        return (
            {
                "status": "ready" if production_ready else "not_ready",
                "environment": resolved_settings.normalized_environment,
                "configured_provider": resolved_settings.llm_provider,
                "active_provider": resolved_provider.provider_name,
                "mock_mode": resolved_settings.resolved_mock_mode,
                "production_ready": production_ready,
                "checks": checks,
                **provider_health,
            },
            production_ready,
        )

    @app.get("/ready")
    async def ready() -> dict[str, object]:
        payload, production_ready = await readiness_snapshot()
        if resolved_settings.is_production and not production_ready:
            raise HTTPException(status_code=503, detail=payload)
        return payload

    @app.post("/v1/suggestions/generate", response_model=SuggestionResponse)
    async def generate_suggestions(
        payload: SuggestionRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> SuggestionResponse:
        started_at = perf_counter()
        try:
            response = await run_suggestions(
                payload,
                settings=request.app.state.settings,
                provider=request.app.state.provider,
                feedback_store=request.app.state.feedback_store,
                intent="generic_suggestions",
            )
        except AITemporarilyUnavailableError as exc:
            _schedule_ai_unavailable_reporting(
                background_tasks,
                request=request,
                user_id=payload.user_id,
                endpoint="/v1/suggestions/generate",
                latency_ms=(perf_counter() - started_at) * 1000,
            )
            raise HTTPException(
                status_code=503,
                detail={
                    "code": exc.code,
                    "message": "GoLife AI is temporarily unavailable. Local fallback is still available.",
                },
            ) from exc
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
        try:
            response = await run_suggestions(
                payload,
                settings=request.app.state.settings,
                provider=request.app.state.provider,
                feedback_store=request.app.state.feedback_store,
                intent="daily_mission",
            )
        except AITemporarilyUnavailableError as exc:
            _schedule_ai_unavailable_reporting(
                background_tasks,
                request=request,
                user_id=payload.user_id,
                endpoint="/v1/missions/daily",
                latency_ms=(perf_counter() - started_at) * 1000,
            )
            raise HTTPException(
                status_code=503,
                detail={
                    "code": exc.code,
                    "message": "GoLife AI is temporarily unavailable. Local fallback is still available.",
                },
            ) from exc
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
        try:
            enforce_safe_capture_input(
                payload,
                region=request.app.state.settings.crisis_resources_region,
                catalog_path=request.app.state.settings.crisis_resources_catalog_path,
            )
            runtime_flags = await request.app.state.provider.runtime_flags()
            if runtime_flags.get("semantic_classifier") and payload.privacy_settings.ai_enabled:
                try:
                    response = await run_event_classification_semantic(
                        payload,
                        settings=request.app.state.settings,
                        provider=request.app.state.provider,
                    )
                except Exception:
                    response = run_event_classification(payload)
            else:
                response = run_event_classification(payload)
        except HTTPException as exc:
            telemetry = build_classification_operation_payloads(
                request=payload,
                response=None,
                latency_ms=(perf_counter() - started_at) * 1000,
                correlation_id=_request_correlation_id(request),
                status="error",
                error_detail=exc.detail,
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
            await request.app.state.operational_client.record_model_settings(
                build_model_settings_payload(
                    request.app.state.settings,
                    request.app.state.provider.provider_name,
                )
            )
            raise
        telemetry = build_classification_operation_payloads(
            request=payload,
            response=response,
            latency_ms=(perf_counter() - started_at) * 1000,
            correlation_id=_request_correlation_id(request),
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

    @app.post("/v1/events/parse", response_model=EventParseResponse)
    async def parse_event(
        payload: EventParseRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> EventParseResponse:
        started_at = perf_counter()
        try:
            enforce_safe_capture_input(
                payload,
                region=request.app.state.settings.crisis_resources_region,
                catalog_path=request.app.state.settings.crisis_resources_catalog_path,
            )
            runtime_flags = await request.app.state.provider.runtime_flags()
            if runtime_flags.get("semantic_classifier") and payload.privacy_settings.ai_enabled:
                try:
                    response = await run_event_parse_semantic(
                        payload,
                        settings=request.app.state.settings,
                        provider=request.app.state.provider,
                    )
                except Exception:
                    response = run_event_parse(payload)
            else:
                response = run_event_parse(payload)
        except HTTPException as exc:
            telemetry = build_parse_operation_payloads(
                request=payload,
                response=None,
                latency_ms=(perf_counter() - started_at) * 1000,
                correlation_id=_request_correlation_id(request),
                status="error",
                error_detail=exc.detail,
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
            await request.app.state.operational_client.record_model_settings(
                build_model_settings_payload(
                    request.app.state.settings,
                    request.app.state.provider.provider_name,
                )
            )
            raise
        telemetry = build_parse_operation_payloads(
            request=payload,
            response=response,
            latency_ms=(perf_counter() - started_at) * 1000,
            correlation_id=_request_correlation_id(request),
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

    @app.post("/v1/proofs/parse", response_model=ProofParseResponse)
    async def parse_proof(
        payload: ProofParseRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> ProofParseResponse:
        started_at = perf_counter()
        try:
            enforce_safe_proof_input(
                payload,
                region=request.app.state.settings.crisis_resources_region,
                catalog_path=request.app.state.settings.crisis_resources_catalog_path,
            )
            runtime_flags = await request.app.state.provider.runtime_flags()
            if runtime_flags.get("proof_parser") and payload.privacy_settings.ai_enabled:
                try:
                    response = await run_proof_parse_semantic(
                        payload,
                        settings=request.app.state.settings,
                        provider=request.app.state.provider,
                    )
                except Exception:
                    response = run_proof_parse(payload)
            else:
                response = run_proof_parse(payload)
        except HTTPException as exc:
            telemetry = build_proof_parse_operation_payloads(
                request=payload,
                response=None,
                latency_ms=(perf_counter() - started_at) * 1000,
                correlation_id=_request_correlation_id(request),
                status="error",
                error_detail=exc.detail,
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
            await request.app.state.operational_client.record_model_settings(
                build_model_settings_payload(
                    request.app.state.settings,
                    request.app.state.provider.provider_name,
                )
            )
            raise
        telemetry = build_proof_parse_operation_payloads(
            request=payload,
            response=response,
            latency_ms=(perf_counter() - started_at) * 1000,
            correlation_id=_request_correlation_id(request),
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
            enforce_safe_task_rewrite_content(
                payload,
                region=request.app.state.settings.crisis_resources_region,
                catalog_path=request.app.state.settings.crisis_resources_catalog_path,
            )
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
                correlation_id=_request_correlation_id(request),
                error_detail=exc.detail,
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
            await request.app.state.operational_client.record_model_settings(
                build_model_settings_payload(
                    request.app.state.settings,
                    request.app.state.provider.provider_name,
                )
            )
            raise
        except AITemporarilyUnavailableError as exc:
            telemetry = build_ai_unavailable_operation_payload(
                endpoint="/v1/tasks/rewrite",
                user_id=payload.user_id,
                latency_ms=(perf_counter() - started_at) * 1000,
                provider_name=request.app.state.provider.provider_name,
                correlation_id=_request_correlation_id(request),
            )
            await request.app.state.operational_client.record_usage_event(
                telemetry["usage_event"]
            )
            await request.app.state.operational_client.record_ai_invocation(
                telemetry["ai_invocation"]
            )
            await request.app.state.operational_client.record_model_settings(
                build_model_settings_payload(
                    request.app.state.settings,
                    request.app.state.provider.provider_name,
                )
            )
            raise HTTPException(
                status_code=503,
                detail={
                    "code": exc.code,
                    "message": "GoLife AI is temporarily unavailable. Try again later.",
                },
            ) from exc

        telemetry = build_task_rewrite_operation_payloads(
            request=payload,
            response=response,
            latency_ms=(perf_counter() - started_at) * 1000,
            status="success",
            correlation_id=_request_correlation_id(request),
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
        try:
            response = await run_domain_suggestions(
                payload,
                settings=request.app.state.settings,
                provider=request.app.state.provider,
                feedback_store=request.app.state.feedback_store,
                required_domain="finance",
                intent="finance_reflect",
            )
        except AITemporarilyUnavailableError as exc:
            _schedule_ai_unavailable_reporting(
                background_tasks,
                request=request,
                user_id=payload.user_id,
                endpoint="/v1/finance/reflect",
                latency_ms=(perf_counter() - started_at) * 1000,
            )
            raise HTTPException(
                status_code=503,
                detail={
                    "code": exc.code,
                    "message": "GoLife AI is temporarily unavailable. Local fallback is still available.",
                },
            ) from exc
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
        try:
            response = await run_domain_suggestions(
                payload,
                settings=request.app.state.settings,
                provider=request.app.state.provider,
                feedback_store=request.app.state.feedback_store,
                required_domain="pantry",
                intent="pantry_rescue",
            )
        except AITemporarilyUnavailableError as exc:
            _schedule_ai_unavailable_reporting(
                background_tasks,
                request=request,
                user_id=payload.user_id,
                endpoint="/v1/pantry/rescue",
                latency_ms=(perf_counter() - started_at) * 1000,
            )
            raise HTTPException(
                status_code=503,
                detail={
                    "code": exc.code,
                    "message": "GoLife AI is temporarily unavailable. Local fallback is still available.",
                },
            ) from exc
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
        try:
            response = await run_domain_suggestions(
                payload,
                settings=request.app.state.settings,
                provider=request.app.state.provider,
                feedback_store=request.app.state.feedback_store,
                required_domain="wardrobe",
                intent="closet_decision",
            )
        except AITemporarilyUnavailableError as exc:
            _schedule_ai_unavailable_reporting(
                background_tasks,
                request=request,
                user_id=payload.user_id,
                endpoint="/v1/closet/decision",
                latency_ms=(perf_counter() - started_at) * 1000,
            )
            raise HTTPException(
                status_code=503,
                detail={
                    "code": exc.code,
                    "message": "GoLife AI is temporarily unavailable. Local fallback is still available.",
                },
            ) from exc
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
            correlation_id=_request_correlation_id(request),
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

    @app.post("/v1/reflection/check", response_model=ReflectionSafetyResponse)
    async def reflection_check(
        payload: ReflectionSafetyRequest,
        request: Request,
        background_tasks: BackgroundTasks,
    ) -> ReflectionSafetyResponse:
        response = assess_reflection_safety(
            payload,
            region=request.app.state.settings.crisis_resources_region,
            catalog_path=request.app.state.settings.crisis_resources_catalog_path,
        )
        telemetry = build_reflection_safety_operation_payloads(
            request=payload,
            response=response,
            correlation_id=_request_correlation_id(request),
        )
        background_tasks.add_task(
            request.app.state.operational_client.record_usage_event,
            telemetry["usage_event"],
        )
        if telemetry["safety_events"]:
            background_tasks.add_task(
                request.app.state.operational_client.record_safety_events,
                telemetry["safety_events"],
            )
        return response

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
        correlation_id=_request_correlation_id(request),
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


def _schedule_ai_unavailable_reporting(
    background_tasks: BackgroundTasks,
    *,
    request: Request,
    user_id: str,
    endpoint: str,
    latency_ms: float,
) -> None:
    telemetry = build_ai_unavailable_operation_payload(
        endpoint=endpoint,
        user_id=user_id,
        latency_ms=latency_ms,
        provider_name=request.app.state.provider.provider_name,
        correlation_id=_request_correlation_id(request),
    )
    background_tasks.add_task(
        request.app.state.operational_client.record_usage_event,
        telemetry["usage_event"],
    )
    background_tasks.add_task(
        request.app.state.operational_client.record_ai_invocation,
        telemetry["ai_invocation"],
    )


def _resolve_correlation_id(request: Request) -> str:
    for header_name in ("x-correlation-id", "x-request-id"):
        candidate = (request.headers.get(header_name) or "").strip()
        if candidate:
            return candidate
    return f"corr-{uuid4()}"


def _request_correlation_id(request: Request) -> str:
    return getattr(request.state, "correlation_id", _resolve_correlation_id(request))


app = create_app()
