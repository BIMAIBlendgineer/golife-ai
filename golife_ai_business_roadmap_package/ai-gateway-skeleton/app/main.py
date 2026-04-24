from __future__ import annotations

from fastapi import FastAPI, Request

from app.graph import GoLifeGateway
from app.memory import InMemoryTraceStore
from app.provider import ProviderChain, build_provider_chain_from_env
from app.schemas import (
    ClassifyEventRequest,
    ClassifyEventResponse,
    DailyPlanRequest,
    DayPlanResponse,
    FeedbackRequest,
    FeedbackResponse,
    HealthResponse,
    PantryPlanRequest,
    PantryPlanResponse,
    SpendingInsightRequest,
    SpendingInsightResponse,
    TaskDiagnosisRequest,
    TaskDiagnosisResponse,
    WardrobeNoBuyRequest,
    WardrobeNoBuyResponse,
)


def create_app(
    *,
    provider_chain: ProviderChain | None = None,
    trace_store: InMemoryTraceStore | None = None,
) -> FastAPI:
    app = FastAPI(title="GoLife AI Gateway", version="0.2.0")
    app.state.gateway = GoLifeGateway(
        provider_chain=provider_chain or build_provider_chain_from_env(),
        trace_store=trace_store or InMemoryTraceStore(),
    )

    def get_gateway(request: Request) -> GoLifeGateway:
        return request.app.state.gateway

    @app.get("/health", response_model=HealthResponse)
    async def health(request: Request) -> HealthResponse:
        gateway = get_gateway(request)
        return HealthResponse(
            status="ok",
            service="golife-ai-gateway",
            providers=gateway.provider_chain.provider_names,
        )

    @app.post("/ai/classify-event", response_model=ClassifyEventResponse)
    async def classify_event(payload: ClassifyEventRequest, request: Request) -> ClassifyEventResponse:
        gateway = get_gateway(request)
        return gateway.classify_event(payload.text, payload.hints)

    @app.post("/ai/daily-plan", response_model=DayPlanResponse)
    async def daily_plan(payload: DailyPlanRequest, request: Request) -> DayPlanResponse:
        gateway = get_gateway(request)
        return await gateway.daily_plan(payload)

    @app.post("/ai/task-diagnosis", response_model=TaskDiagnosisResponse)
    async def task_diagnosis(
        payload: TaskDiagnosisRequest,
        request: Request,
    ) -> TaskDiagnosisResponse:
        gateway = get_gateway(request)
        return await gateway.task_diagnosis(payload)

    @app.post("/ai/spending-insight", response_model=SpendingInsightResponse)
    async def spending_insight(
        payload: SpendingInsightRequest,
        request: Request,
    ) -> SpendingInsightResponse:
        gateway = get_gateway(request)
        return await gateway.spending_insight(payload)

    @app.post("/ai/pantry-plan", response_model=PantryPlanResponse)
    async def pantry_plan(payload: PantryPlanRequest, request: Request) -> PantryPlanResponse:
        gateway = get_gateway(request)
        return await gateway.pantry_plan(payload)

    @app.post("/ai/wardrobe/no-buy", response_model=WardrobeNoBuyResponse)
    async def wardrobe_no_buy(
        payload: WardrobeNoBuyRequest,
        request: Request,
    ) -> WardrobeNoBuyResponse:
        gateway = get_gateway(request)
        return await gateway.wardrobe_no_buy(payload)

    @app.post("/ai/feedback", response_model=FeedbackResponse)
    async def feedback(payload: FeedbackRequest) -> FeedbackResponse:
        return FeedbackResponse(
            status="accepted",
            stored=True,
        )

    return app


app = create_app()
