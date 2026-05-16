from datetime import UTC, datetime
from functools import lru_cache
from statistics import mean
from typing import Any, TypedDict
from uuid import uuid4

from langgraph.graph import END, StateGraph

from app.guardrails import filter_ai_events, sanitize_suggestions
from app.learning_memory import build_learning_key
from app.policy_engine import POLICY_VERSION
from app.providers.base import LLMProvider
from app.schemas import (
    AISuggestion,
    MissionRanking,
    SuggestionEvidence,
    SuggestionRequest,
    SuggestionResponse,
)
from app.settings import Settings

SYSTEM_PROMPT = """
You are GoLife AI.
Return JSON only.
Generate safe, explainable suggestions.
Each suggestion must include evidence and uncertainty.
Do not provide regulated financial advice.
Do not provide medical diagnosis or treatment.
Do not trigger or imply external actions without human confirmation.
Write titles, bodies, evidence, and uncertainty in the locale requested in `user_payload.locale`.
Do not mix languages unless the user input already mixes them.
Return an object with a top-level `suggestions` array using the requested schema.
"""

RANKING_VERSION = "mission_ranker_v1"


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
    by_pattern = feedback_summary.get("by_pattern", {})
    by_recommendation_type = feedback_summary.get("by_recommendation_type", {})
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

    pattern_key = _suggestion_learning_key(suggestion)
    pattern_stats = by_pattern.get(pattern_key, {})
    if pattern_stats:
        positive_count = int(pattern_stats.get("positive_count", 0))
        negative_count = int(pattern_stats.get("negative_count", 0))
        net_score = float(pattern_stats.get("net_score", 0.0) or 0.0)
        delta += positive_count * 0.06
        delta -= negative_count * 0.07
        delta += net_score * 0.05
        reasons.append(
            "pattern "
            f"{pattern_key} score={round(net_score, 4)} "
            f"positive={positive_count} negative={negative_count}"
        )

    for domain in suggestion.domain_targets:
        domain_stats = by_domain.get(domain, {})
        if not domain_stats:
            continue
        useful = int(domain_stats.get("useful", 0))
        completed = int(domain_stats.get("completed", 0))
        rejected = int(domain_stats.get("rejected", 0))
        delta += useful * 0.01
        delta += completed * 0.01
        delta -= rejected * 0.02
        reasons.append(
            f"domain {domain} useful={useful} completed={completed} rejected={rejected}"
        )

    recommendation_stats = by_recommendation_type.get(
        suggestion.recommendation_type,
        {},
    )
    if recommendation_stats:
        positive_count = int(recommendation_stats.get("positive_count", 0))
        negative_count = int(recommendation_stats.get("negative_count", 0))
        net_score = float(recommendation_stats.get("net_score", 0.0) or 0.0)
        delta += positive_count * 0.01
        delta -= negative_count * 0.015
        delta += net_score * 0.01
        reasons.append(
            "recommendation_type "
            f"{suggestion.recommendation_type} score={round(net_score, 4)} "
            f"positive={positive_count} negative={negative_count}"
        )

    return delta, reasons


def _suggestion_learning_key(suggestion: AISuggestion) -> str:
    return build_learning_key(
        suggestion.domain_targets,
        suggestion.recommendation_type,
    )


def _candidate_bias_map(state: MissionGraphState) -> dict[str, dict[str, Any]]:
    feedback_learning = state.get("trace", {}).get("feedback_learning", {})
    if not isinstance(feedback_learning, dict):
        return {}
    raw_items = feedback_learning.get("candidate_biases", [])
    if not isinstance(raw_items, list):
        return {}
    items: dict[str, dict[str, Any]] = {}
    for raw in raw_items:
        if not isinstance(raw, dict):
            continue
        suggestion_id = raw.get("suggestion_id")
        if isinstance(suggestion_id, str) and suggestion_id:
            items[suggestion_id] = raw
    return items


def _risk_severity_weight(severity: object) -> float:
    if severity == "high":
        return 0.28
    if severity == "medium":
        return 0.18
    if severity == "low":
        return 0.08
    return 0.0


def _bounded(value: float) -> float:
    return round(max(0.0, min(1.0, value)), 4)


def _effort_score_for_suggestion(suggestion: AISuggestion) -> float:
    recommendation_type = suggestion.recommendation_type
    domain_span = len(suggestion.domain_targets)
    if recommendation_type in {"reflection", "warning"}:
        base_score = 0.86
    elif recommendation_type == "plan_adjustment":
        base_score = 0.78
    elif recommendation_type == "task_rewrite":
        base_score = 0.72
    else:
        base_score = 0.74

    if domain_span >= 3:
        base_score -= 0.2
    elif domain_span == 2:
        base_score -= 0.1

    if len(suggestion.evidence) >= 3:
        base_score -= 0.03
    return _bounded(base_score)


def _novelty_score_for_suggestion(
    suggestion: AISuggestion,
    feedback_summary: dict[str, Any],
) -> tuple[float, str]:
    pattern_key = _suggestion_learning_key(suggestion)
    pattern_stats = feedback_summary.get("by_pattern", {}).get(pattern_key, {})
    recent_feedback = feedback_summary.get("memory_profile", {}).get(
        "recent_feedback",
        [],
    )
    recent_same_pattern = [
        item
        for item in recent_feedback
        if isinstance(item, dict) and item.get("pattern_key") == pattern_key
    ]

    if not pattern_stats:
        return 0.82, "new pattern in current mission memory"

    negative_count = int(pattern_stats.get("negative_count", 0) or 0)
    positive_count = int(pattern_stats.get("positive_count", 0) or 0)
    repeated_count = int(pattern_stats.get("repeated_count", 0) or 0)
    if recent_same_pattern and any(
        item.get("status") == "rejected" for item in recent_same_pattern if isinstance(item, dict)
    ):
        return 0.16, "recent rejection reduced novelty"
    if negative_count > positive_count:
        return 0.24, "pattern was rejected more often than reinforced"
    if positive_count > 0 and negative_count == 0 and repeated_count == 0:
        return 0.72, "pattern was reinforced without recent rejection"
    if positive_count > 0 and repeated_count == 0:
        return 0.62, "pattern is familiar and mostly reinforced"
    if repeated_count > 0:
        return 0.34, "pattern repeats often in recent feedback"
    return 0.58, "pattern is known with mixed recent history"


def _privacy_score_for_suggestion(
    state: MissionGraphState,
    suggestion: AISuggestion,
) -> tuple[float, str]:
    request = state["request"]
    allowed_domains = set(request.privacy_settings.allowed_domains)
    evidence_domains = {item.source_domain for item in suggestion.evidence}
    cross_domain = len(set(suggestion.domain_targets)) > 1
    filtered_events = state.get("filtered_events", [])
    filtered_domains = {
        str(item.get("domain"))
        for item in filtered_events
        if isinstance(item, dict) and item.get("domain")
    }

    if cross_domain and not request.privacy_settings.allow_cross_domain_patterns:
        return 0.18, "cross-domain mission was privacy-constrained"
    if evidence_domains and not evidence_domains.issubset(allowed_domains):
        return 0.0, "evidence domains fell outside AI-allowed scope"
    if cross_domain and filtered_domains & set(suggestion.domain_targets):
        return 0.58, "privacy filters reduced cross-domain evidence"
    if cross_domain:
        return 0.76, "cross-domain mission stayed inside consented scope"
    return 0.92, "single-domain mission stayed inside consented scope"


def _build_ranking_reason(
    *,
    matched_risks: list[dict[str, Any]],
    privacy_reason: str,
    novelty_reason: str,
    feedback_reasons: list[str],
    final_score: float,
) -> str:
    reasons: list[str] = []
    if matched_risks:
        risk_titles = [str(risk.get("title", "")).strip() for risk in matched_risks]
        first_risk = next((title for title in risk_titles if title), "")
        if first_risk:
            reasons.append(first_risk)
    if feedback_reasons:
        reasons.append(feedback_reasons[0])
    reasons.append(privacy_reason)
    reasons.append(novelty_reason)
    reasons.append(f"final score {round(final_score, 2)}")
    return "; ".join(reasons[:4])


def _score_suggestion(
    state: MissionGraphState,
    suggestion: AISuggestion,
) -> dict[str, Any]:
    risks = state.get("risks", [])
    matched_risks = [
        risk
        for risk in risks
        if set(risk.get("domains", [])) & set(suggestion.domain_targets)
    ]
    bias_map = _candidate_bias_map(state)
    bias = bias_map.get(suggestion.suggestion_id, {})
    feedback_delta = float(bias.get("delta", 0.0) or 0.0)
    feedback_reasons = [
        str(reason)
        for reason in bias.get("reasons", [])
        if isinstance(reason, str) and reason.strip()
    ]

    evidence_scores = [item.confidence for item in suggestion.evidence] or [0.0]
    evidence_strength = mean(evidence_scores)
    severity_score = sum(_risk_severity_weight(risk.get("severity")) for risk in matched_risks)
    impact_score = _bounded(
        0.42
        + (evidence_strength * 0.22)
        + (min(len(suggestion.domain_targets), 3) - 1) * 0.08
        + min(len(matched_risks), 3) * 0.08
    )
    urgency_score = _bounded(
        0.32
        + severity_score
        + (0.12 if state.get("day_state") == "overloaded" else 0.0)
        + (0.08 if state.get("day_state") == "recovery" else 0.0)
    )
    effort_score = _effort_score_for_suggestion(suggestion)
    confidence_score = _bounded(suggestion.confidence)
    privacy_score, privacy_reason = _privacy_score_for_suggestion(state, suggestion)
    feedback_score = _bounded(0.5 + (feedback_delta * 1.25))
    novelty_score, novelty_reason = _novelty_score_for_suggestion(
        suggestion,
        state.get("feedback_summary", {}),
    )
    effort_penalty = 1.0 - effort_score
    final_score = _bounded(
        (impact_score * 0.25)
        + (urgency_score * 0.20)
        + (confidence_score * 0.15)
        + (feedback_score * 0.15)
        + (novelty_score * 0.10)
        + (privacy_score * 0.10)
        - (effort_penalty * 0.05)
    )
    evidence_refs = [
        f"{item.source_domain}:{item.claim}"
        for item in suggestion.evidence[:3]
    ]
    ranking_reason = _build_ranking_reason(
        matched_risks=matched_risks,
        privacy_reason=privacy_reason,
        novelty_reason=novelty_reason,
        feedback_reasons=feedback_reasons,
        final_score=final_score,
    )

    ranking = MissionRanking(
        impact_score=impact_score,
        urgency_score=urgency_score,
        effort_score=effort_score,
        confidence_score=confidence_score,
        privacy_score=privacy_score,
        feedback_score=feedback_score,
        novelty_score=novelty_score,
        final_score=final_score,
        ranking_reason=ranking_reason,
        evidence_refs=evidence_refs,
    )
    return {
        "suggestion": suggestion.model_copy(update={"ranking": ranking}),
        "breakdown": {
            "suggestion_id": suggestion.suggestion_id,
            "impact_score": impact_score,
            "urgency_score": urgency_score,
            "effort_score": effort_score,
            "confidence_score": confidence_score,
            "privacy_score": privacy_score,
            "feedback_score": feedback_score,
            "novelty_score": novelty_score,
            "final_score": final_score,
            "ranking_reason": ranking_reason,
            "matched_risks": [risk.get("risk_id") for risk in matched_risks],
            "evidence_refs": evidence_refs,
        },
    }


def _coerce_domain(value: object, fallback: str = "system") -> str:
    allowed = {"task", "habit", "week", "finance", "pantry", "wardrobe", "mission", "system"}
    if isinstance(value, str) and value in allowed:
        return value
    return fallback


def _coerce_confidence(value: object, default: float) -> float:
    if isinstance(value, (int, float)):
        return max(0.0, min(1.0, float(value)))
    if isinstance(value, str):
        lowered = value.strip().lower()
        if lowered == "low":
            return 0.58
        if lowered == "medium":
            return 0.74
        if lowered == "high":
            return 0.88
        try:
            return max(0.0, min(1.0, float(lowered)))
        except ValueError:
            return default
    return default


def _normalize_uncertainty(value: object) -> str:
    if isinstance(value, str) and value.strip():
        lowered = value.strip().lower()
        if lowered in {"low", "medium", "high"}:
            return f"Model reported {lowered} uncertainty."
        return value.strip()
    return "Model uncertainty was not specified."


def _map_recommendation_type(raw_type: object) -> str:
    if not isinstance(raw_type, str):
        return "mission"
    lowered = raw_type.strip().lower()
    if lowered in {"mission", "task_rewrite", "warning", "reflection", "plan_adjustment"}:
        return lowered
    if lowered in {"eat_soon", "complete_task", "use_pantry", "do_now"}:
        return "mission"
    if lowered in {"track_spending", "review", "pause_spend"}:
        return "reflection"
    if lowered in {"risk", "alert"}:
        return "warning"
    return "mission"


def _normalize_evidence_items(
    raw_items: object,
    *,
    fallback_domain: str,
) -> list[SuggestionEvidence]:
    if not isinstance(raw_items, list):
        return []

    evidence_items: list[SuggestionEvidence] = []
    for raw in raw_items:
        if not isinstance(raw, dict):
            continue
        claim = raw.get("claim") or raw.get("explanation") or raw.get("reason")
        if not claim:
            continue
        evidence_items.append(
            SuggestionEvidence(
                source_domain=_coerce_domain(raw.get("source_domain"), fallback_domain),
                entity_id=raw.get("entity_id") or raw.get("event_id"),
                claim=str(claim),
                confidence=_coerce_confidence(raw.get("confidence") or raw.get("relevance"), 0.68),
            )
        )
    return evidence_items


def _normalize_provider_suggestions(provider_result: object) -> list[AISuggestion]:
    if isinstance(provider_result, list):
        raw_items = provider_result
    elif isinstance(provider_result, dict):
        raw_items = (
            provider_result.get("suggestions")
            or provider_result.get("missions")
            or provider_result.get("recommendations")
            or provider_result.get("items")
            or []
        )
        if not raw_items and ("title" in provider_result or "reason" in provider_result):
            raw_items = [provider_result]
    else:
        raw_items = []

    normalized_items: list[AISuggestion] = []
    for index, raw in enumerate(raw_items, start=1):
        if not isinstance(raw, dict):
            continue
        try:
            normalized_items.append(AISuggestion.model_validate(raw))
        except Exception:
            # Fall through to the compatibility normalizer for legacy payloads.
            ...
        else:
            continue

        domain_targets = raw.get("domain_targets")
        if not isinstance(domain_targets, list) or not domain_targets:
            domain_targets = [_coerce_domain(raw.get("domain"), "system")]
        else:
            domain_targets = [_coerce_domain(item, "system") for item in domain_targets]

        body = raw.get("body") or raw.get("reason") or raw.get("summary") or "Suggested action."
        title = raw.get("title")
        if not title:
            title = str(body).split(".")[0][:80] or f"Suggestion {index}"

        normalized_items.append(
            AISuggestion(
                suggestion_id=str(raw.get("suggestion_id") or f"normalized-{index}"),
                title=str(title),
                domain_targets=domain_targets,
                recommendation_type=_map_recommendation_type(
                    raw.get("recommendation_type") or raw.get("type")
                ),
                body=str(body),
                evidence=_normalize_evidence_items(
                    raw.get("evidence"),
                    fallback_domain=domain_targets[0] if domain_targets else "system",
                ),
                confidence=_coerce_confidence(raw.get("confidence"), 0.74),
                uncertainty=_normalize_uncertainty(raw.get("uncertainty")),
                requires_confirmation=bool(raw.get("requires_confirmation", True)),
                forbidden_actions=list(raw.get("forbidden_actions", []))
                if isinstance(raw.get("forbidden_actions", []), list)
                else [],
                status=str(raw.get("status", "draft")),
            )
        )
    return normalized_items


def _build_fallback_suggestion(
    state: MissionGraphState,
    *,
    domain_targets: list[str],
    index: int,
) -> AISuggestion:
    primary_domain = domain_targets[0] if domain_targets else "system"
    summaries = {
        summary.get("domain"): summary
        for summary in state.get("domain_summaries", [])
        if isinstance(summary, dict)
    }
    matching_risk = next(
        (
            risk
            for risk in state.get("risks", [])
            if set(risk.get("domains", [])) & set(domain_targets)
        ),
        None,
    )

    if primary_domain == "task":
        title = "Close one task block"
        body = "Finish or timebox one active task before opening another thread."
        claim = "Task pressure is visible in the current graph."
    elif primary_domain == "habit":
        title = "Protect one small habit"
        body = "Keep one low-friction habit alive today even if the day feels noisy."
        claim = "Habit continuity is visible in the current graph."
    elif primary_domain == "finance":
        title = "Review one spend before the next purchase"
        body = "Pause and review the most recent spend before opening another money decision."
        claim = "Spending activity is visible in the current graph."
    elif primary_domain == "pantry":
        title = "Use one pantry item first"
        body = "Use one pantry item before buying more food so waste stays lower."
        claim = "A pantry usage opportunity is visible in the current graph."
    elif primary_domain == "wardrobe":
        title = "Pause one purchase for 24 hours"
        body = "Hold one wardrobe purchase intention for a day and compare it against what already exists."
        claim = "A purchase intention is active in the current graph."
    elif primary_domain == "week":
        title = "Reduce one load point this week"
        body = "Remove or move one item so the week feels more survivable."
        claim = "Weekly planning pressure is visible in the current graph."
    else:
        title = "Do one stabilizing action"
        body = "Choose one small action that reduces the most friction right now."
        claim = "The current graph still supports a small next step."

    evidence_claim = (
        matching_risk.get("summary")
        if isinstance(matching_risk, dict)
        else summaries.get(primary_domain, {}).get("summary")
        if primary_domain in summaries
        else claim
    )

    return AISuggestion(
        suggestion_id=f"synth-{primary_domain}-{index}",
        title=title,
        domain_targets=domain_targets,
        recommendation_type="mission",
        body=body,
        evidence=[
            SuggestionEvidence(
                source_domain=primary_domain,
                claim=str(evidence_claim),
                confidence=0.66,
            )
        ],
        confidence=0.62,
        uncertainty="This suggestion was synthesized locally because the model returned fewer items than requested.",
        requires_confirmation=True,
        forbidden_actions=[],
        status="draft",
    )


def _ensure_suggestion_count(
    state: MissionGraphState,
    suggestions: list[AISuggestion],
) -> tuple[list[AISuggestion], int]:
    target_count = state["request"].max_suggestions
    if len(suggestions) >= target_count:
        return suggestions[:target_count], 0

    expanded = list(suggestions)
    synthesized_count = 0
    existing_keys = {tuple(item.domain_targets) for item in expanded}
    candidate_targets: list[list[str]] = []

    for risk in state.get("risks", []):
        domains = [
            _coerce_domain(domain)
            for domain in risk.get("domains", [])
            if isinstance(domain, str)
        ]
        if domains:
            candidate_targets.append(domains)

    for summary in state.get("domain_summaries", []):
        domain = summary.get("domain") if isinstance(summary, dict) else None
        if isinstance(domain, str):
            candidate_targets.append([_coerce_domain(domain)])

    for domain in state["request"].privacy_settings.allowed_domains:
        candidate_targets.append([_coerce_domain(domain)])

    candidate_targets.append(["system"])

    for targets in candidate_targets:
        key = tuple(targets)
        if key in existing_keys:
            continue
        expanded.append(
            _build_fallback_suggestion(
                state,
                domain_targets=targets,
                index=len(expanded) + 1,
            )
        )
        existing_keys.add(key)
        synthesized_count += 1
        if len(expanded) >= target_count:
            break

    return expanded[:target_count], synthesized_count


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
            "locale": state["request"].locale,
            "scope": state["request"].scope,
            "allowed_domains": state["request"].privacy_settings.allowed_domains,
            "events": [event.model_dump(mode="json") for event in state.get("allowed_events", [])],
            "domain_summaries": state.get("domain_summaries", []),
            "day_state": state.get("day_state", "unknown"),
            "risks": state.get("risks", []),
            "patterns": state.get("patterns", []),
            "feedback_summary": state.get("feedback_summary", {}),
            "mission_memory": state.get("feedback_summary", {}).get(
                "memory_profile",
                {},
            ),
            "constraints": state["request"].constraints,
        },
        response_schema=SuggestionResponse.model_json_schema(),
        temperature=0.0,
    )

    candidates = _normalize_provider_suggestions(provider_result)
    provider_trace = provider_result if isinstance(provider_result, dict) else {}
    trace = _append_trace(
        state.get("trace", {}),
        node_name="generate_candidates",
        payload={
            "provider_called": True,
            "candidates_count": len(candidates),
            "mock": provider_trace.get("mock", False),
        },
    )
    return {
        "candidates": candidates,
        "provider_meta": provider_trace.get("_provider_meta", {}),
        "trace": trace,
    }


def apply_feedback_learning(state: MissionGraphState) -> MissionGraphState:
    feedback_summary = state.get("feedback_summary", {})
    candidate_biases: list[dict[str, Any]] = []

    for suggestion in state.get("candidates", []):
        delta, reasons = _feedback_delta(suggestion, feedback_summary)
        adjusted_confidence = min(max(suggestion.confidence + delta, 0.0), 1.0)
        candidate_biases.append(
            {
                "suggestion_id": suggestion.suggestion_id,
                "learning_key": _suggestion_learning_key(suggestion),
                "delta": round(delta, 4),
                "adjusted_confidence": round(adjusted_confidence, 4),
                "reasons": reasons,
            }
        )

    trace = _append_trace(
        state.get("trace", {}),
        node_name="feedback_learning",
        payload={
            "adjusted_count": len(state.get("candidates", [])),
            "totals": feedback_summary.get("totals", {}),
            "mission_memory": feedback_summary.get("memory_profile", {}),
            "candidate_biases": candidate_biases,
        },
    )
    return {"trace": trace}


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
    ranked_with_scores = sorted(
        [_score_suggestion(state, suggestion) for suggestion in state.get("reviewed_candidates", [])],
        key=lambda item: item["breakdown"]["final_score"],
        reverse=True,
    )[: state["request"].max_suggestions]

    ranked_candidates = [item["suggestion"] for item in ranked_with_scores]
    trace = _append_trace(
        state.get("trace", {}),
        node_name="rank",
        payload={
            "ranked_count": len(ranked_candidates),
            "score_breakdown": [item["breakdown"] for item in ranked_with_scores],
        },
    )
    return {"ranked_candidates": ranked_candidates, "trace": trace}


def build_response(state: MissionGraphState) -> MissionGraphState:
    ranked_candidates, synthesized_count = _ensure_suggestion_count(
        state,
        state.get("ranked_candidates", []),
    )
    provider_meta = state.get("provider_meta", {})
    used_local_mock = bool(
        state["settings"].resolved_mock_mode
        or state["provider"].provider_name == "mock"
        or provider_meta.get("mock") is True
    )
    fallback_used = bool(used_local_mock or synthesized_count > 0 or not state.get("consent_granted"))
    if used_local_mock:
        source_state = "local"
    elif fallback_used:
        source_state = "degraded"
    else:
        source_state = "live"
    mission_date = datetime.now(UTC).date().isoformat()
    mission_set_id = f"mission-set-{mission_date}-{uuid4().hex[:8]}"
    learning_keys_by_suggestion_id = {
        suggestion.suggestion_id: _suggestion_learning_key(suggestion)
        for suggestion in ranked_candidates
    }
    trace = _append_trace(
        state.get("trace", {}),
        node_name="build_response",
        payload={
            "suggestions_count": len(ranked_candidates),
            "synthesized_count": synthesized_count,
        },
    )
    trace.update(
        {
            "missionSetId": mission_set_id,
            "date": mission_date,
            "sourceState": source_state,
            "fallbackUsed": fallback_used,
            "policyVersion": POLICY_VERSION,
            "rankingVersion": RANKING_VERSION,
            "active_provider": state["provider"].provider_name,
            "configured_provider": state["settings"].llm_provider,
            "mock_mode": state["settings"].resolved_mock_mode,
            "filtered_events": state.get("filtered_events", []),
            "provider_meta": provider_meta,
            "mission_memory": state.get("feedback_summary", {}).get(
                "memory_profile",
                {},
            ),
            "learning_keys_by_suggestion_id": learning_keys_by_suggestion_id,
            "ranking_model": RANKING_VERSION,
            "policyBlocks": [
                item.get("reason")
                for item in state.get("trace", {}).get("guardrail_review", {}).get("rejected", [])
                if isinstance(item, dict) and item.get("reason")
            ],
        }
    )
    return {
        "response": SuggestionResponse(
            mission_set_id=mission_set_id,
            date=mission_date,
            source_state=source_state,  # type: ignore[arg-type]
            fallback_used=fallback_used,
            policy_version=POLICY_VERSION,
            ranking_version=RANKING_VERSION,
            suggestions=ranked_candidates,
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
