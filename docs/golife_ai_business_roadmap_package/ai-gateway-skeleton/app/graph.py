from __future__ import annotations

from datetime import UTC, datetime
from typing import Any, TypedDict
from uuid import uuid4

from langgraph.graph import END, START, StateGraph
from pydantic import ValidationError

from app.memory import InMemoryTraceStore
from app.provider import ProviderChain, build_provider_chain_from_env
from app.retrieval import build_life_context, classify_text_domain, dominant_domain
from app.safety import evaluate_safety
from app.schemas import (
    AIRecommendation,
    AITrace,
    BaseAIRequest,
    ClassifyEventResponse,
    DayPlanResponse,
    Domain,
    PantryPlanRequest,
    PantryPlanResponse,
    RecommendationType,
    SafetySummary,
    SpendingInsightRequest,
    SpendingInsightResponse,
    TaskDiagnosisRequest,
    TaskDiagnosisResponse,
    TraceStep,
    WardrobeNoBuyRequest,
    WardrobeNoBuyResponse,
)


class GatewayState(TypedDict, total=False):
    operation: str
    trace_id: str
    request_data: dict[str, Any]
    normalized_input: dict[str, Any]
    domain: str
    life_context: list[str]
    safety: dict[str, Any]
    agent: str
    prompt: str
    draft_payload: dict[str, Any]
    provider_payload: dict[str, Any]
    provider_name: str
    used_fallback: bool
    mock: bool
    trace_steps: list[dict[str, Any]]
    response: dict[str, Any]


RESPONSE_MODELS = {
    "daily-plan": DayPlanResponse,
    "task-diagnosis": TaskDiagnosisResponse,
    "spending-insight": SpendingInsightResponse,
    "pantry-plan": PantryPlanResponse,
    "wardrobe-no-buy": WardrobeNoBuyResponse,
}

AGENT_BY_OPERATION = {
    "daily-plan": "DailyMissionAgent",
    "task-diagnosis": "TaskDoctorAgent",
    "spending-insight": "MoneyMirrorAgent",
    "pantry-plan": "FridgeZeroAgent",
    "wardrobe-no-buy": "ClosetLessAgent",
}

DOMAIN_BY_OPERATION = {
    "daily-plan": "planning",
    "task-diagnosis": "task",
    "spending-insight": "money",
    "pantry-plan": "pantry",
    "wardrobe-no-buy": "wardrobe",
}


def _timestamp() -> datetime:
    return datetime.now(UTC)


def _trace_step(node: str, detail: str) -> dict[str, Any]:
    return {"node": node, "detail": detail, "at": _timestamp()}


def _privacy_allows_ai(normalized: dict[str, Any], domain: str) -> bool:
    privacy = normalized.get("privacy") or {}
    if not privacy.get("ai_enabled", True):
        return False

    allowed_domains = {str(item) for item in privacy.get("allowed_domains", [])}
    return not allowed_domains or domain in allowed_domains


def _build_trace(state: GatewayState) -> dict[str, Any]:
    safety = state.get("safety") or {}
    return {
        "trace_id": state["trace_id"],
        "operation": state["operation"],
        "domain": state.get("domain", "system"),
        "agent": state.get("agent", "UnknownAgent"),
        "provider": state.get("provider_name", "mock"),
        "used_fallback": state.get("used_fallback", False),
        "safety": {
            "allowed": safety.get("allowed", True),
            "reasons": safety.get("reasons", []),
            "requires_confirmation": safety.get("requires_confirmation", False),
        },
        "life_context": state.get("life_context", []),
        "steps": state.get("trace_steps", []),
    }


def _event_payload_value(event: dict[str, Any], *keys: str) -> str | None:
    payload = event.get("payload") or {}
    for key in keys:
        value = payload.get(key)
        if value:
            return str(value)
    return None


def _domain_links(*values: str) -> list[str]:
    return [value for value in values if value]


def _build_daily_missions(normalized: dict[str, Any], life_context: list[str], safety: dict[str, Any]) -> dict[str, Any]:
    events = normalized.get("events", [])
    goals = normalized.get("goals", [])
    recommendations: list[dict[str, Any]] = []

    first_task = next((event for event in events if event.get("domain") == "task"), None)
    first_habit = next((event for event in events if event.get("domain") == "habit"), None)
    first_money = next((event for event in events if event.get("domain") == "money"), None)
    first_pantry = next((event for event in events if event.get("domain") == "pantry"), None)

    focus_target = goals[0] if goals else _event_payload_value(first_task or {}, "title", "name") or "one important task"
    habit_target = _event_payload_value(first_habit or {}, "name", "title") or "your minimum habit"
    pantry_target = _event_payload_value(first_pantry or {}, "item", "name") or "one pantry item already at home"

    recommendations.append(
        {
            "id": "mission-focus",
            "type": RecommendationType.DAILY_MISSION.value,
            "title": f"Protect one focus block for {focus_target}",
            "summary": "Start the day with one realistic task block before adding more work.",
            "evidence": [
                f"Goals captured: {len(goals)}",
                life_context[0] if life_context else "Limited context available",
            ],
            "uncertainty": [
                "Task priority is inferred from captured context.",
            ],
            "action_minimum": f"Work 20 minutes on {focus_target}.",
            "risk_level": "low",
            "domain_links": _domain_links("task", "planning"),
            "requires_user_confirmation": False,
        }
    )
    recommendations.append(
        {
            "id": "mission-habit",
            "type": RecommendationType.DAILY_MISSION.value,
            "title": f"Keep {habit_target} alive at the minimum dose",
            "summary": "Protect continuity instead of chasing a perfect routine.",
            "evidence": [
                "Habit continuity improves retention.",
                f"Detected habit context: {habit_target}",
            ],
            "uncertainty": [
                "The ideal minimum dose is estimated from sparse event history.",
            ],
            "action_minimum": f"Do the smallest repeatable version of {habit_target} today.",
            "risk_level": "low",
            "domain_links": _domain_links("habit"),
            "requires_user_confirmation": False,
        }
    )

    if first_money:
        amount = _event_payload_value(first_money, "amount", "value") or "recent spend"
        recommendations.append(
            {
                "id": "mission-money",
                "type": RecommendationType.DAILY_MISSION.value,
                "title": "Pause one avoidable spend",
                "summary": "Review one recent discretionary expense before repeating it.",
                "evidence": [f"Recent money signal: {amount}"],
                "uncertainty": ["This is a behavioral suggestion, not financial advice."],
                "action_minimum": "Delay one non-essential purchase for 24 hours.",
                "risk_level": "low",
                "domain_links": _domain_links("money"),
                "requires_user_confirmation": False,
            }
        )

    if first_pantry or len(recommendations) < 3:
        recommendations.append(
            {
                "id": "mission-pantry",
                "type": RecommendationType.DAILY_MISSION.value,
                "title": f"Use {pantry_target} before buying more",
                "summary": "Turn pantry context into one concrete anti-waste action.",
                "evidence": [f"Pantry context: {pantry_target}"],
                "uncertainty": ["Shelf life and quantity may be incomplete."],
                "action_minimum": f"Plan one meal or snack using {pantry_target}.",
                "risk_level": "low",
                "domain_links": _domain_links("pantry"),
                "requires_user_confirmation": False,
            }
        )

    while len(recommendations) < 3:
        recommendations.append(
            {
                "id": f"mission-generic-{len(recommendations) + 1}",
                "type": RecommendationType.DAILY_MISSION.value,
                "title": "Do one small reset before the day drifts",
                "summary": "Use a short cleanup step to regain clarity.",
                "evidence": ["Low context fallback"],
                "uncertainty": ["Mission is generic because little structured data was provided."],
                "action_minimum": "Spend 10 minutes clearing your next action list.",
                "risk_level": "low",
                "domain_links": _domain_links("planning"),
                "requires_user_confirmation": False,
            }
        )

    risks: list[str] = []
    if len(events) > 8:
        risks.append("The day may be overloaded because many events were captured.")
    if not life_context:
        risks.append("Low context: mission quality may be generic until more data is captured.")
    if safety.get("requires_confirmation"):
        risks.append("At least one suggested action needs explicit user confirmation.")

    return {
        "date": normalized.get("date") or _timestamp().date().isoformat(),
        "recommendations": recommendations[:5],
        "missions": recommendations[:5],
        "risks": risks,
        "blocked_items": [],
        "estimated_effort_minutes": 45,
        "plan_realism_score": 0.72,
    }


def _build_task_diagnosis(normalized: dict[str, Any], life_context: list[str], safety: dict[str, Any]) -> dict[str, Any]:
    task_text = normalized.get("task_text", "this task")
    blockers = normalized.get("blockers", [])
    diagnosis = "The task looks fuzzy or oversized, so the first move should reduce ambiguity."
    if blockers:
        diagnosis = f"Detected blockers: {', '.join(blockers[:2])}. Reduce scope and choose the first reversible step."

    recommendation = {
        "id": "task-diagnosis-1",
        "type": RecommendationType.TASK_FIX.value,
        "title": "Shrink the task until it becomes executable",
        "summary": "Convert the task into the smallest visible outcome you can finish today.",
        "evidence": [
            f"Task text: {task_text}",
            life_context[0] if life_context else "No prior task context found",
        ],
        "uncertainty": ["The diagnosis is based on text, not outcome history."],
        "action_minimum": f"Write the first 10-minute step for: {task_text}",
        "risk_level": "low",
        "domain_links": _domain_links("task"),
        "requires_user_confirmation": safety.get("requires_confirmation", False),
    }
    return {
        "task": task_text,
        "diagnosis": diagnosis,
        "recommendations": [recommendation],
        "risks": [],
        "blocked_items": [],
        "estimated_effort_minutes": 10,
    }


def _build_spending_insight(normalized: dict[str, Any], life_context: list[str], safety: dict[str, Any]) -> dict[str, Any]:
    period = normalized.get("period", "week")
    recommendation = {
        "id": "money-1",
        "type": RecommendationType.SPENDING_INSIGHT.value,
        "title": "Name one avoidable spend category",
        "summary": "The goal is awareness and one small pause, not rigid budgeting.",
        "evidence": [life_context[0] if life_context else "Recent expense event detected"],
        "uncertainty": ["This is not tax, investment or credit advice."],
        "action_minimum": "Pause the next repeat discretionary purchase for 24 hours.",
        "risk_level": "low",
        "domain_links": _domain_links("money"),
        "requires_user_confirmation": False,
    }
    return {
        "period": period,
        "recommendations": [recommendation],
        "risks": [],
        "blocked_items": [],
        "estimated_effort_minutes": 5,
    }


def _build_pantry_plan(normalized: dict[str, Any], life_context: list[str], safety: dict[str, Any]) -> dict[str, Any]:
    available_minutes = normalized.get("available_minutes", 20)
    target = life_context[0] if life_context else "one pantry item close to expiry"
    recommendation = {
        "id": "pantry-1",
        "type": RecommendationType.PANTRY_PLAN.value,
        "title": "Use what is already at home first",
        "summary": "Prioritize one low-friction meal built from current inventory.",
        "evidence": [target],
        "uncertainty": ["The exact inventory may be incomplete or outdated."],
        "action_minimum": f"Plan a {available_minutes}-minute meal from current pantry items.",
        "risk_level": "low",
        "domain_links": _domain_links("pantry"),
        "requires_user_confirmation": False,
    }
    return {
        "servings": 1,
        "recommendations": [recommendation],
        "risks": [],
        "blocked_items": [],
        "estimated_effort_minutes": available_minutes,
    }


def _build_wardrobe_no_buy(normalized: dict[str, Any], life_context: list[str], safety: dict[str, Any]) -> dict[str, Any]:
    purchase_intent = normalized.get("purchase_intent", "new clothing purchase")
    recommendation = {
        "id": "wardrobe-1",
        "type": RecommendationType.NO_BUY.value,
        "title": "Delay the purchase and verify a substitute first",
        "summary": "Challenge the purchase with a concrete reuse or styling test.",
        "evidence": [f"Purchase intent: {purchase_intent}"],
        "uncertainty": ["The current wardrobe inventory may be incomplete."],
        "action_minimum": "Wait 24 hours and try one outfit using what you already own.",
        "risk_level": "low",
        "domain_links": _domain_links("wardrobe"),
        "requires_user_confirmation": False,
    }
    return {
        "purchase_intent": purchase_intent,
        "recommendations": [recommendation],
        "risks": [],
        "blocked_items": [],
        "estimated_effort_minutes": 5,
    }


def _build_refusal(operation: str, normalized: dict[str, Any], safety: dict[str, Any]) -> dict[str, Any]:
    base_recommendation = {
        "id": "safety-refusal",
        "type": {
            "daily-plan": RecommendationType.DAILY_MISSION.value,
            "task-diagnosis": RecommendationType.TASK_FIX.value,
            "spending-insight": RecommendationType.SPENDING_INSIGHT.value,
            "pantry-plan": RecommendationType.PANTRY_PLAN.value,
            "wardrobe-no-buy": RecommendationType.NO_BUY.value,
        }[operation],
        "title": "Human review required",
        "summary": "This request touches a professional or high-risk area, so GoLife will not generate an automated answer.",
        "evidence": safety.get("reasons", ["Safety policy triggered."]),
        "uncertainty": ["A qualified human should handle this case."],
        "action_minimum": "Rephrase the request as a planning or tracking question, or ask a qualified professional.",
        "risk_level": "high",
        "domain_links": _domain_links(DOMAIN_BY_OPERATION[operation]),
        "requires_user_confirmation": True,
    }
    if operation == "daily-plan":
        return {
            "date": normalized.get("date") or _timestamp().date().isoformat(),
            "recommendations": [],
            "missions": [],
            "risks": safety.get("reasons", []),
            "blocked_items": ["safety_refusal"],
            "estimated_effort_minutes": 0,
            "plan_realism_score": 0.0,
        }
    if operation == "task-diagnosis":
        return {
            "task": normalized.get("task_text", ""),
            "diagnosis": "Safety refusal",
            "recommendations": [base_recommendation],
            "risks": safety.get("reasons", []),
            "blocked_items": ["safety_refusal"],
            "estimated_effort_minutes": 0,
        }
    if operation == "spending-insight":
        return {
            "period": normalized.get("period", "week"),
            "recommendations": [base_recommendation],
            "risks": safety.get("reasons", []),
            "blocked_items": ["safety_refusal"],
            "estimated_effort_minutes": 0,
        }
    if operation == "pantry-plan":
        return {
            "servings": 0,
            "recommendations": [base_recommendation],
            "risks": safety.get("reasons", []),
            "blocked_items": ["safety_refusal"],
            "estimated_effort_minutes": 0,
        }
    return {
        "purchase_intent": normalized.get("purchase_intent", ""),
        "recommendations": [base_recommendation],
        "risks": safety.get("reasons", []),
        "blocked_items": ["safety_refusal"],
        "estimated_effort_minutes": 0,
    }


def _build_draft_payload(operation: str, normalized: dict[str, Any], life_context: list[str], safety: dict[str, Any]) -> dict[str, Any]:
    if not _privacy_allows_ai(normalized, DOMAIN_BY_OPERATION[operation]):
        muted_safety = dict(safety)
        muted_safety.setdefault("reasons", []).append("AI is disabled or not allowed for this domain.")
        muted_safety["allowed"] = False
        return _build_refusal(operation, normalized, muted_safety)

    if not safety.get("allowed", True):
        return _build_refusal(operation, normalized, safety)

    if operation == "daily-plan":
        return _build_daily_missions(normalized, life_context, safety)
    if operation == "task-diagnosis":
        return _build_task_diagnosis(normalized, life_context, safety)
    if operation == "spending-insight":
        return _build_spending_insight(normalized, life_context, safety)
    if operation == "pantry-plan":
        return _build_pantry_plan(normalized, life_context, safety)
    return _build_wardrobe_no_buy(normalized, life_context, safety)


class GoLifeGateway:
    def __init__(
        self,
        provider_chain: ProviderChain | None = None,
        trace_store: InMemoryTraceStore | None = None,
    ) -> None:
        self.provider_chain = provider_chain or build_provider_chain_from_env()
        self.trace_store = trace_store or InMemoryTraceStore()
        self._graph = self._build_graph()

    def _build_graph(self):
        workflow = StateGraph(GatewayState)
        workflow.add_node("normalize_input", self.normalize_input)
        workflow.add_node("classify_domain", self.classify_domain)
        workflow.add_node("retrieve_life_context", self.retrieve_life_context)
        workflow.add_node("safety_check", self.safety_check)
        workflow.add_node("route_agent", self.route_agent)
        workflow.add_node("generate_recommendation", self.generate_recommendation)
        workflow.add_node("validate_schema", self.validate_schema)
        workflow.add_node("build_explanation", self.build_explanation)
        workflow.add_node("persist_trace", self.persist_trace)
        workflow.add_node("return_response", self.return_response)

        workflow.add_edge(START, "normalize_input")
        workflow.add_edge("normalize_input", "classify_domain")
        workflow.add_edge("classify_domain", "retrieve_life_context")
        workflow.add_edge("retrieve_life_context", "safety_check")
        workflow.add_edge("safety_check", "route_agent")
        workflow.add_edge("route_agent", "generate_recommendation")
        workflow.add_edge("generate_recommendation", "validate_schema")
        workflow.add_edge("validate_schema", "build_explanation")
        workflow.add_edge("build_explanation", "persist_trace")
        workflow.add_edge("persist_trace", "return_response")
        workflow.add_edge("return_response", END)
        return workflow.compile()

    def normalize_input(self, state: GatewayState) -> GatewayState:
        normalized = dict(state["request_data"])
        normalized["events"] = list(normalized.get("events", []))[:50]
        trace_steps = state.get("trace_steps", []) + [
            _trace_step("normalize_input", f"Normalized {len(normalized.get('events', []))} events.")
        ]
        return {"normalized_input": normalized, "trace_steps": trace_steps}

    def classify_domain(self, state: GatewayState) -> GatewayState:
        normalized = state["normalized_input"]
        default_domain = DOMAIN_BY_OPERATION.get(state["operation"], "planning")
        domain = dominant_domain(normalized.get("events", []), default_domain)
        trace_steps = state["trace_steps"] + [
            _trace_step("classify_domain", f"Selected domain {domain}.")
        ]
        return {"domain": domain, "trace_steps": trace_steps}

    def retrieve_life_context(self, state: GatewayState) -> GatewayState:
        life_context = build_life_context(state["normalized_input"].get("events", []), state["domain"])
        trace_steps = state["trace_steps"] + [
            _trace_step("retrieve_life_context", f"Collected {len(life_context)} context lines.")
        ]
        return {"life_context": life_context, "trace_steps": trace_steps}

    def safety_check(self, state: GatewayState) -> GatewayState:
        normalized = state["normalized_input"]
        text_fragments = [
            str(normalized.get("task_text", "")),
            str(normalized.get("purchase_intent", "")),
            " ".join(str(goal) for goal in normalized.get("goals", [])),
        ]
        text_fragments.extend(str(item) for item in normalized.get("constraints", {}).values())
        safety = evaluate_safety([fragment for fragment in text_fragments if fragment.strip()])
        trace_steps = state["trace_steps"] + [
            _trace_step(
                "safety_check",
                "Request passed safety checks." if safety.allowed else "Safety policy blocked generation.",
            )
        ]
        return {
            "safety": {
                "allowed": safety.allowed,
                "reasons": safety.reasons,
                "requires_confirmation": safety.requires_confirmation,
            },
            "trace_steps": trace_steps,
        }

    def route_agent(self, state: GatewayState) -> GatewayState:
        agent = AGENT_BY_OPERATION[state["operation"]]
        trace_steps = state["trace_steps"] + [_trace_step("route_agent", f"Routed to {agent}.")]
        return {"agent": agent, "trace_steps": trace_steps}

    async def generate_recommendation(self, state: GatewayState) -> GatewayState:
        normalized = state["normalized_input"]
        safety = state["safety"]
        draft_payload = _build_draft_payload(
            state["operation"],
            normalized,
            state.get("life_context", []),
            safety,
        )
        prompt = (
            f"Operation: {state['operation']}\n"
            f"Agent: {state['agent']}\n"
            f"Domain: {state['domain']}\n"
            f"Life context: {state.get('life_context', [])}\n"
            f"Safety: {safety}\n"
            f"Request: {normalized}\n"
            "Return a JSON object only."
        )
        provider_result = await self.provider_chain.complete_structured(
            operation=state["operation"],
            prompt=prompt,
            schema=RESPONSE_MODELS[state["operation"]].model_json_schema(),
            fallback_payload=draft_payload,
        )
        trace_steps = state["trace_steps"] + [
            _trace_step(
                "generate_recommendation",
                f"Provider {provider_result.provider_name} returned a payload.",
            )
        ]
        return {
            "prompt": prompt,
            "draft_payload": draft_payload,
            "provider_payload": provider_result.payload,
            "provider_name": provider_result.provider_name,
            "used_fallback": provider_result.used_fallback,
            "mock": provider_result.provider_name == "mock" or bool(provider_result.payload.get("mock")),
            "trace_steps": trace_steps,
        }

    def validate_schema(self, state: GatewayState) -> GatewayState:
        response_model = RESPONSE_MODELS[state["operation"]]
        candidate = dict(state.get("provider_payload") or state["draft_payload"])
        candidate.setdefault("trace", _build_trace(state))
        candidate.setdefault("mock", state.get("mock", False))

        try:
            validated = response_model.model_validate(candidate)
        except ValidationError:
            fallback = dict(state["draft_payload"])
            fallback.setdefault("risks", [])
            fallback["risks"] = list(fallback["risks"]) + ["Provider output failed schema validation; deterministic fallback used."]
            fallback["trace"] = _build_trace(state)
            fallback["mock"] = True
            validated = response_model.model_validate(fallback)
            state["mock"] = True
            state["used_fallback"] = True
            state["provider_name"] = f"{state.get('provider_name', 'provider')}-invalid"

        trace_steps = state["trace_steps"] + [
            _trace_step("validate_schema", "Validated response against the Pydantic JSON schema.")
        ]
        response = validated.model_dump(mode="json")
        response["trace"]["steps"] = trace_steps
        response["trace"]["used_fallback"] = state.get("used_fallback", False)
        response["trace"]["provider"] = state.get("provider_name", "mock")
        return {"response": response, "trace_steps": trace_steps}

    def build_explanation(self, state: GatewayState) -> GatewayState:
        response = dict(state["response"])
        recommendations = response.get("recommendations") or response.get("missions") or []
        for recommendation in recommendations:
            if not recommendation.get("explanation"):
                evidence = recommendation.get("evidence", [])
                recommendation["explanation"] = (
                    "Based on: " + "; ".join(evidence[:2]) if evidence else "Based on limited context."
                )
            if state.get("safety", {}).get("requires_confirmation"):
                recommendation["requires_user_confirmation"] = True

        if response.get("missions"):
            response["missions"] = recommendations
        response["recommendations"] = recommendations

        trace_steps = state["trace_steps"] + [
            _trace_step("build_explanation", "Added explanation text and confirmation flags.")
        ]
        response["trace"]["steps"] = trace_steps
        return {"response": response, "trace_steps": trace_steps}

    def persist_trace(self, state: GatewayState) -> GatewayState:
        trace = AITrace.model_validate(state["response"]["trace"])
        self.trace_store.persist(trace)
        trace_steps = state["trace_steps"] + [_trace_step("persist_trace", "Stored trace in memory.")]
        response = dict(state["response"])
        response["trace"]["steps"] = trace_steps
        return {"response": response, "trace_steps": trace_steps}

    def return_response(self, state: GatewayState) -> GatewayState:
        trace_steps = state["trace_steps"] + [_trace_step("return_response", "Returning structured payload.")]
        response = dict(state["response"])
        response["trace"]["steps"] = trace_steps
        return {"response": response, "trace_steps": trace_steps}

    async def _run(self, operation: str, request_data: BaseAIRequest) -> Any:
        result = await self._graph.ainvoke(
            {
                "operation": operation,
                "trace_id": str(uuid4()),
                "request_data": request_data.model_dump(mode="json"),
                "trace_steps": [],
            }
        )
        return RESPONSE_MODELS[operation].model_validate(result["response"])

    async def daily_plan(self, request: BaseAIRequest) -> DayPlanResponse:
        return await self._run("daily-plan", request)

    async def task_diagnosis(self, request: TaskDiagnosisRequest) -> TaskDiagnosisResponse:
        return await self._run("task-diagnosis", request)

    async def spending_insight(self, request: SpendingInsightRequest) -> SpendingInsightResponse:
        return await self._run("spending-insight", request)

    async def pantry_plan(self, request: PantryPlanRequest) -> PantryPlanResponse:
        return await self._run("pantry-plan", request)

    async def wardrobe_no_buy(self, request: WardrobeNoBuyRequest) -> WardrobeNoBuyResponse:
        return await self._run("wardrobe-no-buy", request)

    def classify_event(self, text: str, hints: dict[str, Any] | None = None) -> ClassifyEventResponse:
        domain, event_type, confidence, rationale = classify_text_domain(text, hints)
        return ClassifyEventResponse(
            domain=Domain(domain),
            event_type=event_type,
            confidence=confidence,
            rationale=rationale,
        )
