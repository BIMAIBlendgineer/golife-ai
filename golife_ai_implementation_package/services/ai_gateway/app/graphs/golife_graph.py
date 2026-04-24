from functools import lru_cache
from statistics import mean
from typing import Any, TypedDict

from langgraph.graph import END, StateGraph

from app.guardrails import filter_ai_events, sanitize_suggestions
from app.providers.base import LLMProvider
from app.schemas import AISuggestion, SuggestionRequest, SuggestionResponse
from app.settings import Settings

SYSTEM_PROMPT = """
You are GoLife AI.
Return JSON only.
Generate safe, explainable suggestions.
Each suggestion must include evidence and uncertainty.
Do not provide regulated financial advice.
Do not provide medical diagnosis or treatment.
Do not trigger or imply external actions without human confirmation.
"""


class MissionGraphState(TypedDict, total=False):
    intent: str
    request: SuggestionRequest
    settings: Settings
    provider: LLMProvider
    feedback_summary: dict[str, Any]
    consent_granted: bool
    allowed_events: list[Any]
    filtered_events: list[dict[str, str]]
    domain_summaries: list[dict[str, Any]]
    day_state: str
    risks: list[dict[str, Any]]
    patterns: list[dict[str, Any]]
    candidates: list[AISuggestion]
    reviewed_candidates: list[AISuggestion]
    ranked_candidates: list[AISuggestion]
    provider_meta: dict[str, Any]
    trace: dict[str, Any]
    response: SuggestionResponse


def _append_trace(
    trace: dict[str, Any],
    *,
    node_name: str,
    payload: dict[str, Any],
) -> dict[str, Any]:
    nodes = list(trace.get("nodes", []))
    nodes.append(node_name)
    updated = dict(trace)
    updated["nodes"] = nodes
    updated[node_name] = payload
    return updated


def _derive_domain_summaries(state: MissionGraphState) -> list[dict[str, Any]]:
    request = state["request"]
    if request.domain_summaries:
        return [summary.model_dump(mode="json") for summary in request.domain_summaries]

    counts: dict[str, int] = {}
    for event in state.get("allowed_events", []):
        counts[event.domain] = counts.get(event.domain, 0) + 1

    summaries: list[dict[str, Any]] = []
    for domain, count in sorted(counts.items()):
        summaries.append(
            {
                "domain": domain,
                "summary": f"{count} AI-allowed events available for {domain}.",
                "evidence_count": count,
                "ai_allowed": True,
            }
        )
    return summaries


def _classify_day_state_from_events(state: MissionGraphState) -> str:
    domains = {event.domain for event in state.get("allowed_events", [])}
    if not state.get("consent_granted"):
        return "unknown"
    if "task" in domains and "habit" in domains:
        return "steady"
    if "finance" in domains and "pantry" in domains:
        return "recovery"
    if len(domains) >= 3:
        return "overloaded"
    if domains:
        return "unstructured"
    return "unknown"


def _detect_patterns_from_state(state: MissionGraphState) -> list[dict[str, Any]]:
    domains = {event.domain for event in state.get("allowed_events", [])}
    patterns: list[dict[str, Any]] = []

    if {"task", "habit"}.issubset(domains):
        patterns.append(
            {
                "pattern": "tasks_habits_overlap",
                "domains": ["task", "habit"],
                "summary": "Task pressure and habit continuity are both visible.",
            }
        )
    if {"finance", "pantry"}.issubset(domains):
        patterns.append(
            {
                "pattern": "finance_pantry_overlap",
                "domains": ["finance", "pantry"],
                "summary": "Food usage can reduce near-term spend.",
            }
        )
    if "wardrobe" in domains:
        has_purchase_intention = any(
            event.event_type == "purchase_intention" for event in state.get("allowed_events", [])
        )
        if has_purchase_intention:
            patterns.append(
                {
                    "pattern": "wardrobe_purchase_intention",
                    "domains": ["wardrobe"],
                    "summary": "Wardrobe activity includes a purchase intention signal.",
                }
            )

    return patterns


def _assess_risks_from_state(state: MissionGraphState) -> list[dict[str, Any]]:
    events = state.get("allowed_events", [])
    domains = {event.domain for event in events}
    risks: list[dict[str, Any]] = []

    if {"finance", "pantry"}.issubset(domains):
        risks.append(
            {
                "risk_id": "food_spend_overlap",
                "title": "Food spend may rise before pantry is used",
                "summary": "There is both finance and pantry context, so buying before using what exists can create waste and extra spend.",
                "severity": "medium",
                "domains": ["finance", "pantry"],
            }
        )

    if {"task", "habit"}.issubset(domains):
        risks.append(
            {
                "risk_id": "task_habit_tradeoff",
                "title": "Task pressure may crowd out recovery habits",
                "summary": "Tasks and habits are both active, so the day can drift into reaction mode unless a habit stays protected.",
                "severity": "medium",
                "domains": ["task", "habit"],
            }
        )

    if any(event.event_type == "purchase_intention" for event in events):
        risks.append(
            {
                "risk_id": "purchase_intention_active",
                "title": "A purchase intention may trigger an avoidable buy",
                "summary": "Wardrobe intent is active, so a pause or comparison may be needed before spending.",
                "severity": "low",
                "domains": ["wardrobe"],
            }
        )

    if state.get("day_state") == "overloaded":
        risks.append(
            {
                "risk_id": "overloaded_day",
                "title": "The day looks overloaded",
                "summary": "Several domains are active at once, so the plan should reduce scope instead of adding more moving parts.",
                "severity": "high",
                "domains": sorted(domains),
            }
        )

    return risks[:3]


def _feedback_delta(
    suggestion: AISuggestion,
    feedback_summary: dict[str, Any],
) -> tuple[float, list[str]]:
    by_suggestion = feedback_summary.get("by_suggestion", {})
    by_domain = feedback_summary.get("by_domain", {})
    reasons: list[str] = []
    delta = 0.0

    suggestion_stats = by_suggestion.get(suggestion.suggestion_id, {})
    if suggestion_stats:
        useful = int(suggestion_stats.get("useful", 0))
        completed = int(suggestion_stats.get("completed", 0))
        accepted = int(suggestion_stats.get("accepted", 0))
        rejected = int(suggestion_stats.get("rejected", 0))
        delta += useful * 0.05
        delta += completed * 0.06
        delta += accepted * 0.03
        delta -= rejected * 0.08
        reasons.append(
            f"suggestion useful={useful} completed={completed} rejected={rejected}"
        )

    for domain in suggestion.domain_targets:
        domain_stats = by_domain.get(domain, {})
        if not domain_stats:
            continue
        useful = int(domain_stats.get("useful", 0))
        completed = int(domain_stats.get("completed", 0))
        rejected = int(domain_stats.get("rejected", 0))
        delta += useful * 0.02
        delta += completed * 0.03
        delta -= rejected * 0.04
        reasons.append(
            f"domain {domain} useful={useful} completed={completed} rejected={rejected}"
        )

    return delta, reasons


def validate_consent(state: MissionGraphState) -> MissionGraphState:
    allowed_events, filtered_events = filter_ai_events(state["request"])
    consent_granted = bool(state["request"].privacy_settings.ai_enabled)
    trace = _append_trace(
        state.get("trace", {}),
        node_name="validate_consent",
        payload={
            "consent_granted": consent_granted,
            "allowed_events_count": len(allowed_events),
            "filtered_events_count": len(filtered_events),
        },
    )
    return {
        "consent_granted": consent_granted,
        "allowed_events": allowed_events,
        "filtered_events": filtered_events,
        "trace": trace,
    }


def summarize_events(state: MissionGraphState) -> MissionGraphState:
    domain_summaries = _derive_domain_summaries(state)
    trace = _append_trace(
        state.get("trace", {}),
        node_name="summarize_events",
        payload={"domain_summaries_count": len(domain_summaries)},
    )
    return {"domain_summaries": domain_summaries, "trace": trace}


def classify_day_state(state: MissionGraphState) -> MissionGraphState:
    day_state = _classify_day_state_from_events(state)
    trace = _append_trace(
        state.get("trace", {}),
        node_name="classify_day_state",
        payload={"day_state": day_state},
    )
    return {"day_state": day_state, "trace": trace}


def assess_risks(state: MissionGraphState) -> MissionGraphState:
    risks = _assess_risks_from_state(state)
    trace = _append_trace(
        state.get("trace", {}),
        node_name="assess_risks",
        payload={
            "risk_count": len(risks),
            "risks": risks,
        },
    )
    return {"risks": risks, "trace": trace}


def detect_patterns(state: MissionGraphState) -> MissionGraphState:
    patterns = _detect_patterns_from_state(state)
    trace = _append_trace(
        state.get("trace", {}),
        node_name="detect_patterns",
        payload={"patterns_count": len(patterns)},
    )
    return {"patterns": patterns, "trace": trace}


async def generate_candidates(state: MissionGraphState) -> MissionGraphState:
    if not state.get("consent_granted"):
        trace = _append_trace(
            state.get("trace", {}),
            node_name="generate_candidates",
            payload={"provider_called": False, "reason": "consent_not_granted"},
        )
        return {"candidates": [], "provider_meta": {"mock": True}, "trace": trace}

    provider_result = await state["provider"].complete_json(
        system_prompt=SYSTEM_PROMPT,
        user_payload={
            "intent": state["intent"],
            "user_id": state["request"].user_id,
            "scope": state["request"].scope,
            "allowed_domains": state["request"].privacy_settings.allowed_domains,
            "events": [event.model_dump(mode="json") for event in state.get("allowed_events", [])],
            "domain_summaries": state.get("domain_summaries", []),
            "day_state": state.get("day_state", "unknown"),
            "risks": state.get("risks", []),
            "patterns": state.get("patterns", []),
            "feedback_summary": state.get("feedback_summary", {}),
            "constraints": state["request"].constraints,
        },
    )

    candidates = [
        AISuggestion.model_validate(item)
        for item in provider_result.get("suggestions", [])
    ]
    trace = _append_trace(
        state.get("trace", {}),
        node_name="generate_candidates",
        payload={
            "provider_called": True,
            "candidates_count": len(candidates),
            "mock": provider_result.get("mock", False),
        },
    )
    return {
        "candidates": candidates,
        "provider_meta": provider_result.get("_provider_meta", {}),
        "trace": trace,
    }


def apply_feedback_learning(state: MissionGraphState) -> MissionGraphState:
    feedback_summary = state.get("feedback_summary", {})
    adjusted_candidates: list[AISuggestion] = []

    for suggestion in state.get("candidates", []):
        delta, _reasons = _feedback_delta(suggestion, feedback_summary)
        adjusted_confidence = min(max(suggestion.confidence + delta, 0.0), 1.0)
        adjusted_candidates.append(
            suggestion.model_copy(update={"confidence": adjusted_confidence})
        )

    trace = _append_trace(
        state.get("trace", {}),
        node_name="feedback_learning",
        payload={
            "adjusted_count": len(adjusted_candidates),
            "totals": feedback_summary.get("totals", {}),
        },
    )
    return {"candidates": adjusted_candidates, "trace": trace}


def guardrail_review(state: MissionGraphState) -> MissionGraphState:
    reviewed_candidates, rejected = sanitize_suggestions(
        state.get("candidates", []),
        max_items=state["request"].max_suggestions,
    )
    trace = _append_trace(
        state.get("trace", {}),
        node_name="guardrail_review",
        payload={
            "accepted_count": len(reviewed_candidates),
            "rejected": rejected,
        },
    )
    return {"reviewed_candidates": reviewed_candidates, "trace": trace}


def rank(state: MissionGraphState) -> MissionGraphState:
    risks = state.get("risks", [])

    def score_breakdown(suggestion: AISuggestion) -> dict[str, Any]:
        evidence_scores = [item.confidence for item in suggestion.evidence] or [0.0]
        evidence_strength = mean(evidence_scores)
        impact = min(
            1.0,
            suggestion.confidence + max(0, len(suggestion.domain_targets) - 1) * 0.05,
        )
        matched_risks = [
            risk
            for risk in risks
            if set(risk.get("domains", [])) & set(suggestion.domain_targets)
        ]
        urgency = min(1.0, 0.45 + (len(matched_risks) * 0.18))
        effort_fit = 0.72 if suggestion.recommendation_type in {"reflection", "warning"} else 0.64
        final_score = (
            (impact * 0.35)
            + (urgency * 0.30)
            + (effort_fit * 0.20)
            + (evidence_strength * 0.15)
        )
        return {
            "suggestion_id": suggestion.suggestion_id,
            "impact": round(impact, 4),
            "urgency": round(urgency, 4),
            "effort_fit": round(effort_fit, 4),
            "evidence_strength": round(evidence_strength, 4),
            "matched_risks": [risk.get("risk_id") for risk in matched_risks],
            "final_score": round(final_score, 4),
        }

    ranked_with_scores = sorted(
        [
            (suggestion, score_breakdown(suggestion))
            for suggestion in state.get("reviewed_candidates", [])
        ],
        key=lambda item: item[1]["final_score"],
        reverse=True,
    )[: state["request"].max_suggestions]

    ranked_candidates = [item[0] for item in ranked_with_scores]
    trace = _append_trace(
        state.get("trace", {}),
        node_name="rank",
        payload={
            "ranked_count": len(ranked_candidates),
            "score_breakdown": [item[1] for item in ranked_with_scores],
        },
    )
    return {"ranked_candidates": ranked_candidates, "trace": trace}


def build_response(state: MissionGraphState) -> MissionGraphState:
    trace = _append_trace(
        state.get("trace", {}),
        node_name="build_response",
        payload={"suggestions_count": len(state.get("ranked_candidates", []))},
    )
    trace.update(
        {
            "active_provider": state["provider"].provider_name,
            "configured_provider": state["settings"].llm_provider,
            "mock_mode": state["settings"].resolved_mock_mode,
            "filtered_events": state.get("filtered_events", []),
            "provider_meta": state.get("provider_meta", {}),
        }
    )
    return {
        "response": SuggestionResponse(
            suggestions=state.get("ranked_candidates", []),
            trace=trace,
        )
    }


@lru_cache(maxsize=1)
def _compiled_graph():
    graph = StateGraph(MissionGraphState)
    graph.add_node("validate_consent", validate_consent)
    graph.add_node("summarize_events", summarize_events)
    graph.add_node("classify_day_state", classify_day_state)
    graph.add_node("assess_risks", assess_risks)
    graph.add_node("detect_patterns", detect_patterns)
    graph.add_node("generate_candidates", generate_candidates)
    graph.add_node("feedback_learning", apply_feedback_learning)
    graph.add_node("guardrail_review", guardrail_review)
    graph.add_node("rank", rank)
    graph.add_node("build_response", build_response)
    graph.set_entry_point("validate_consent")
    graph.add_edge("validate_consent", "summarize_events")
    graph.add_edge("summarize_events", "classify_day_state")
    graph.add_edge("classify_day_state", "assess_risks")
    graph.add_edge("assess_risks", "detect_patterns")
    graph.add_edge("detect_patterns", "generate_candidates")
    graph.add_edge("generate_candidates", "feedback_learning")
    graph.add_edge("feedback_learning", "guardrail_review")
    graph.add_edge("guardrail_review", "rank")
    graph.add_edge("rank", "build_response")
    graph.add_edge("build_response", END)
    return graph.compile()


async def run_suggestion_graph(
    request: SuggestionRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
    feedback_summary: dict[str, Any],
    intent: str,
) -> SuggestionResponse:
    result = await _compiled_graph().ainvoke(
        {
            "intent": intent,
            "request": request,
            "settings": settings,
            "provider": provider,
            "feedback_summary": feedback_summary,
            "trace": {},
        }
    )
    return result["response"]
