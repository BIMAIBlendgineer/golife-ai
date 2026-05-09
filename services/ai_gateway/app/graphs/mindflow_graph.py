from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from app.capture_parser import parse_capture_request
from app.guardrails import sanitize_decision_cards
from app.providers.base import LLMProvider
from app.schemas import (
    ActionContract,
    DecisionCard,
    DecisionPlanRequest,
    DecisionPlanResponse,
    EventParseRequest,
    MentalLoadItem,
    MindFlowParseRequest,
    MindFlowParseResponse,
    MissionRanking,
    PrivacySummary,
    SuggestionEvidence,
)
from app.settings import Settings

MINDFLOW_PARSE_SYSTEM_PROMPT = """
Return JSON only.
Convert free-form user text into mental load items.
Do not execute external actions.
Do not infer sensitive facts beyond the text.
Every item must include type, domain, title, summary, urgency_score,
effort_score, confidence, evidence_refs, privacy recommendation,
and whether user confirmation is required.
Allowed item types: task, reminder, decision, shopping, document,
calendar, money, home_memory, meal, note.
"""

DECISION_PLAN_SYSTEM_PROMPT = """
Return JSON only.
Generate at most 3 DecisionCards.
Each decision must be safe, small, explainable and confirmable.
Use only privacy-allowed context.
Every decision must include evidence, uncertainty, confidence,
privacy_summary and action_contract.
No external action without human confirmation.
"""

_REMOTE_ONLY_COLLECTIONS = [
    "journal_entries",
    "quick_notes",
    "purchase_proofs",
    "claim_drafts",
]


def _utcnow_iso() -> str:
    return datetime.now(UTC).isoformat()


async def run_mindflow_parse_graph(
    request: MindFlowParseRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> MindFlowParseResponse:
    runtime_flags = await provider.runtime_flags()
    trace: dict[str, Any] = {
        "nodes": [
            "validate_consent",
            "parse_inbox",
            "build_mental_load_items",
            "build_response",
        ],
        "configured_provider": settings.llm_provider,
        "provider": provider.provider_name,
        "text_length": len(request.text),
        "ai_enabled": request.privacy_settings.ai_enabled,
    }

    if request.privacy_settings.ai_enabled and runtime_flags.get("mindflow_parse"):
        try:
            provider_result = await provider.complete_json(
                system_prompt=MINDFLOW_PARSE_SYSTEM_PROMPT,
                user_payload={
                    "intent": "mindflow_parse",
                    "user_id": request.user_id,
                    "locale": request.locale,
                    "text": request.text,
                    "allowed_domains": request.privacy_settings.allowed_domains,
                },
                response_schema=MindFlowParseResponse.model_json_schema(),
                temperature=0.0,
            )
            items = _normalize_provider_mindflow_items(
                provider_result,
                request=request,
            )
            if items:
                trace["provider_meta"] = (
                    provider_result.get("_provider_meta", {})
                    if isinstance(provider_result, dict)
                    else {}
                )
                trace["parser"] = "semantic_openrouter"
                trace["item_count"] = len(items)
                return MindFlowParseResponse(items=items, trace=trace)
        except Exception as exc:
            trace["provider_error"] = type(exc).__name__

    parsed_items = parse_capture_request(
        EventParseRequest(
            user_id=request.user_id,
            locale=request.locale,
            text=request.text,
            privacy_settings=request.privacy_settings,
        )
    )
    items = [
        _mental_load_from_parsed_item(
            request=request,
            raw_item=raw_item,
            index=index,
        )
        for index, raw_item in enumerate(parsed_items)
    ]
    trace["clientFallback"] = True
    trace["fallbackReason"] = trace.get("provider_error", "deterministic_parser")
    trace["parser"] = "deterministic_mindflow"
    trace["item_count"] = len(items)
    return MindFlowParseResponse(items=items, trace=trace)


async def run_decision_plan_graph(
    request: DecisionPlanRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> DecisionPlanResponse:
    allowed_items, blocked_items = _filter_ai_allowed_items(request.mental_load_items, request)
    runtime_flags = await provider.runtime_flags()
    max_decisions = getattr(request, "max_decisions", 3)
    trace: dict[str, Any] = {
        "nodes": [
            "validate_consent",
            "filter_events",
            "create_decision_candidates",
            "rank_decisions",
            "sanitize_decisions",
            "build_response",
        ],
        "configured_provider": settings.llm_provider,
        "provider": provider.provider_name,
        "input_count": len(request.mental_load_items),
        "privacy_filtered_count": len(blocked_items),
        "allowed_item_count": len(allowed_items),
    }

    if not allowed_items:
        trace["fallbackReason"] = "privacy_filtered"
        trace["decision_count"] = 0
        return DecisionPlanResponse(decisions=[], trace=trace)

    candidate_decisions: list[DecisionCard] = []
    provider_meta: dict[str, Any] = {}
    if request.privacy_settings.ai_enabled and runtime_flags.get("decision_plan"):
        try:
            provider_result = await provider.complete_json(
                system_prompt=DECISION_PLAN_SYSTEM_PROMPT,
                user_payload={
                    "intent": "decision_plan",
                    "user_id": request.user_id,
                    "locale": request.locale,
                    "allowed_domains": request.privacy_settings.allowed_domains,
                    "mental_load_items": [
                        item.model_dump(mode="json") for item in allowed_items
                    ],
                    "max_decisions": max_decisions,
                },
                response_schema=DecisionPlanResponse.model_json_schema(),
                temperature=0.0,
            )
            candidate_decisions = _normalize_provider_decisions(
                provider_result,
                request=request,
                allowed_items=allowed_items,
            )
            if isinstance(provider_result, dict):
                provider_meta = dict(provider_result.get("_provider_meta", {}) or {})
        except Exception as exc:
            trace["provider_error"] = type(exc).__name__

    if not candidate_decisions:
        candidate_decisions = _build_local_decisions(
            request=request,
            allowed_items=allowed_items,
            max_decisions=max_decisions,
            fallback_reason=trace.get("provider_error", "local_decision_fallback"),
        )
        trace["clientFallback"] = True

    decisions, rejected = sanitize_decision_cards(
        candidate_decisions,
        max_items=max_decisions,
    )
    if not decisions:
        decisions, _ = sanitize_decision_cards(
            _build_local_decisions(
                request=request,
                allowed_items=allowed_items,
                max_decisions=max_decisions,
                fallback_reason="guardrail_recovery",
            ),
            max_items=max_decisions,
        )
        trace["clientFallback"] = True
        trace["fallbackReason"] = "guardrail_recovery"

    trace["provider_meta"] = provider_meta
    trace["guardrail_review"] = {"rejected": rejected}
    trace["decision_count"] = len(decisions)
    if "fallbackReason" not in trace and trace.get("clientFallback") is True:
        trace["fallbackReason"] = "local_decision_fallback"
    return DecisionPlanResponse(decisions=decisions, trace=trace)


def _normalize_provider_mindflow_items(
    provider_result: object,
    *,
    request: MindFlowParseRequest,
) -> list[MentalLoadItem]:
    if not isinstance(provider_result, dict):
        return []
    raw_items = provider_result.get("items")
    if not isinstance(raw_items, list):
        return []

    now_iso = _utcnow_iso()
    items: list[MentalLoadItem] = []
    for index, raw in enumerate(raw_items):
        if not isinstance(raw, dict):
            continue
        domain = str(raw.get("domain") or "task")
        title = str(raw.get("title") or raw.get("text") or "").strip()
        summary = str(raw.get("summary") or raw.get("rationale") or "").strip()
        if not title or not summary:
            continue
        items.append(
            MentalLoadItem(
                item_id=str(raw.get("item_id") or f"mindflow-{uuid4()}"),
                user_id=request.user_id,
                source_event_id=(
                    str(raw.get("source_event_id"))
                    if raw.get("source_event_id") is not None
                    else None
                ),
                type=str(raw.get("type") or _mental_load_type_for_domain(domain)),
                domain=domain,  # type: ignore[arg-type]
                title=title,
                summary=summary,
                urgency_score=_score(raw.get("urgency_score"), fallback=0.58),
                effort_score=_score(raw.get("effort_score"), fallback=0.52),
                confidence=_score(raw.get("confidence"), fallback=0.7),
                state=str(raw.get("state") or "needs_confirmation"),
                due_hint=_maybe_text(raw.get("due_hint")),
                amount_hint=_maybe_float(raw.get("amount_hint")),
                currency_hint=_maybe_text(raw.get("currency_hint")),
                evidence_refs=_string_list(raw.get("evidence_refs")),
                privacy_level=(
                    "ai_allowed"
                    if request.privacy_settings.ai_enabled
                    else "local_only"
                ),
                requires_confirmation=raw.get("requires_confirmation") is not False,
                created_at_iso=_maybe_text(raw.get("created_at_iso")) or now_iso,
                updated_at_iso=_maybe_text(raw.get("updated_at_iso")) or now_iso,
                trace={"semantic": True, "item_index": index},
            )
        )
    return items


def _mental_load_from_parsed_item(
    *,
    request: MindFlowParseRequest,
    raw_item: Any,
    index: int,
) -> MentalLoadItem:
    now_iso = _utcnow_iso()
    domain = raw_item.domain
    allowed_domains = set(request.privacy_settings.allowed_domains)
    privacy_level = (
        "ai_allowed"
        if request.privacy_settings.ai_enabled
        and (not allowed_domains or domain in allowed_domains)
        else "local_only"
    )
    due_hint = (
        raw_item.hints.get("time_hint")
        or raw_item.hints.get("expiry_hint")
        or None
    )
    return MentalLoadItem(
        item_id=f"mindflow-{index}-{uuid4()}",
        user_id=request.user_id,
        source_event_id=None,
        type=_mental_load_type_for_domain(domain),
        domain=domain,  # type: ignore[arg-type]
        title=raw_item.text.strip(),
        summary=raw_item.rationale,
        urgency_score=_urgency_for_domain(domain, due_hint=due_hint),
        effort_score=_effort_for_domain(domain),
        confidence=_score(raw_item.confidence, fallback=0.66),
        state="needs_confirmation",
        due_hint=due_hint,
        amount_hint=_maybe_float(raw_item.hints.get("amount")),
        currency_hint=_maybe_text(raw_item.hints.get("currency")),
        evidence_refs=[raw_item.event_type],
        privacy_level=privacy_level,  # type: ignore[arg-type]
        requires_confirmation=True,
        created_at_iso=now_iso,
        updated_at_iso=now_iso,
        trace={
            "event_type": raw_item.event_type,
            "matched_hints": sorted(raw_item.hints.keys()),
            "local_only_collections": _REMOTE_ONLY_COLLECTIONS,
        },
    )


def _filter_ai_allowed_items(
    items: list[MentalLoadItem],
    request: DecisionPlanRequest,
) -> tuple[list[MentalLoadItem], list[dict[str, str]]]:
    allowed_domains = set(request.privacy_settings.allowed_domains)
    allowed: list[MentalLoadItem] = []
    blocked: list[dict[str, str]] = []
    for item in items:
        if item.privacy_level != "ai_allowed":
            blocked.append(
                {
                    "item_id": item.item_id,
                    "domain": item.domain,
                    "reason": "privacy_level",
                }
            )
            continue
        if allowed_domains and item.domain not in allowed_domains:
            blocked.append(
                {
                    "item_id": item.item_id,
                    "domain": item.domain,
                    "reason": "domain_not_allowed",
                }
            )
            continue
        allowed.append(item)
    return allowed, blocked


def _normalize_provider_decisions(
    provider_result: object,
    *,
    request: DecisionPlanRequest,
    allowed_items: list[MentalLoadItem],
) -> list[DecisionCard]:
    if not isinstance(provider_result, dict):
        return []
    raw_decisions = provider_result.get("decisions")
    if not isinstance(raw_decisions, list):
        return []
    by_item_id = {item.item_id: item for item in allowed_items}
    now_iso = _utcnow_iso()
    decisions: list[DecisionCard] = []
    for index, raw in enumerate(raw_decisions):
        if not isinstance(raw, dict):
            continue
        source_items = _string_list(raw.get("source_items"))
        primary_item = by_item_id.get(source_items[0]) if source_items else None
        title = str(raw.get("title") or "").strip()
        recommended_action = str(raw.get("recommended_action") or "").strip()
        uncertainty = str(raw.get("uncertainty") or "").strip()
        if not title or not recommended_action or not uncertainty:
            continue
        domain_targets = _string_list(raw.get("domain_targets"))
        evidence = _normalize_evidence(
            raw.get("evidence"),
            fallback_domain=primary_item.domain if primary_item else "task",
        )
        ranking_score = _score(
            raw.get("ranking_score"),
            fallback=primary_item.urgency_score if primary_item else 0.54,
        )
        decisions.append(
            DecisionCard(
                decision_id=str(raw.get("decision_id") or f"decision-{uuid4()}"),
                user_id=request.user_id,
                title=title,
                recommended_action=recommended_action,
                alternatives=_string_list(raw.get("alternatives")),
                domain_targets=domain_targets,  # type: ignore[arg-type]
                source_items=source_items,
                evidence=evidence,
                confidence=_score(raw.get("confidence"), fallback=0.7),
                uncertainty=uncertainty,
                privacy_summary=_privacy_summary_for_request(
                    request=request,
                    sent_event_count=len(allowed_items),
                    blocked_event_count=max(0, len(request.mental_load_items) - len(allowed_items)),
                ),
                confirmation_required=raw.get("confirmation_required") is not False,
                action_contract=ActionContract(
                    action_type=str(
                        (raw.get("action_contract") or {}).get("action_type")
                        or "review_and_confirm"
                    ),
                    requires_confirmation=True,
                    destructive=(raw.get("action_contract") or {}).get("destructive")
                    is True,
                    external=(raw.get("action_contract") or {}).get("external")
                    is True,
                    payload_preview=dict(
                        (raw.get("action_contract") or {}).get("payload_preview") or {}
                    ),
                    forbidden_actions=_string_list(
                        (raw.get("action_contract") or {}).get("forbidden_actions")
                    ),
                ),
                status=str(raw.get("status") or "shown"),
                evidence_status=str(
                    raw.get("evidence_status")
                    or ("local_only" if evidence else "insufficient_verified_data")
                ),
                ranking_score=ranking_score,
                created_at_iso=_maybe_text(raw.get("created_at_iso")) or now_iso,
                updated_at_iso=_maybe_text(raw.get("updated_at_iso")) or now_iso,
                trace={
                    "semantic": True,
                    "rank_decisions": {
                        "ranking_reason": (
                            str(raw.get("ranking_reason") or "").strip()
                            or _ranking_reason(primary_item, ranking_score)
                        ),
                    },
                    "decision_index": index,
                },
            )
        )
    return decisions


def _build_local_decisions(
    *,
    request: DecisionPlanRequest,
    allowed_items: list[MentalLoadItem],
    max_decisions: int,
    fallback_reason: str,
) -> list[DecisionCard]:
    now_iso = _utcnow_iso()
    ranked_items = sorted(
        allowed_items,
        key=lambda item: (
            round(item.urgency_score - (item.effort_score * 0.35), 4),
            round(item.confidence, 4),
        ),
        reverse=True,
    )[:max_decisions]

    decisions: list[DecisionCard] = []
    for item in ranked_items:
        ranking_score = max(
            0.0,
            min(1.0, item.urgency_score * 0.7 + item.confidence * 0.2 + (1.0 - item.effort_score) * 0.1),
        )
        ranking_reason = _ranking_reason(item, ranking_score)
        decisions.append(
            DecisionCard(
                decision_id=f"decision-{item.item_id}",
                user_id=request.user_id,
                title=item.title,
                recommended_action=_recommended_action_for_item(item),
                alternatives=_local_alternatives(item),
                domain_targets=[item.domain],  # type: ignore[list-item]
                source_items=[item.item_id],
                evidence=[
                    SuggestionEvidence(
                        source_domain=item.domain,  # type: ignore[arg-type]
                        entity_id=item.source_event_id,
                        claim=item.summary,
                        confidence=item.confidence,
                    )
                ],
                confidence=max(0.45, item.confidence),
                uncertainty="Generated from privacy-safe deterministic fallback rules.",
                privacy_summary=_privacy_summary_for_request(
                    request=request,
                    sent_event_count=len(allowed_items),
                    blocked_event_count=max(0, len(request.mental_load_items) - len(allowed_items)),
                ),
                confirmation_required=True,
                action_contract=ActionContract(
                    action_type="review_and_confirm",
                    requires_confirmation=True,
                    destructive=False,
                    external=False,
                    payload_preview={"mental_load_item_id": item.item_id},
                    forbidden_actions=["external_action_without_confirmation"],
                ),
                status="shown",
                evidence_status=(
                    "local_only" if item.evidence_refs else "insufficient_verified_data"
                ),
                ranking_score=ranking_score,
                created_at_iso=now_iso,
                updated_at_iso=now_iso,
                trace={
                    "clientFallback": True,
                    "fallbackReason": fallback_reason,
                    "rank_decisions": {
                        "ranking_reason": ranking_reason,
                        "final_score": round(ranking_score, 4),
                    },
                },
            )
        )
    return decisions


def _privacy_summary_for_request(
    *,
    request: DecisionPlanRequest,
    sent_event_count: int,
    blocked_event_count: int,
) -> PrivacySummary:
    allowed_domains = list(dict.fromkeys(request.privacy_settings.allowed_domains))
    known_domains = {
        "task",
        "habit",
        "week",
        "finance",
        "pantry",
        "wardrobe",
        "calendar",
        "journal",
        "recipe",
        "homememory",
        "shopping",
        "decision",
        "mission",
        "system",
    }
    blocked_domains = sorted(known_domains - set(allowed_domains))
    return PrivacySummary(
        ai_enabled=request.privacy_settings.ai_enabled,
        sent_event_count=sent_event_count,
        blocked_event_count=blocked_event_count,
        allowed_domains=allowed_domains,  # type: ignore[arg-type]
        blocked_domains=blocked_domains,  # type: ignore[arg-type]
        local_only_collections=list(_REMOTE_ONLY_COLLECTIONS),
        trace={"privacy_filtered": blocked_event_count},
    )


def _normalize_evidence(
    raw_items: object,
    *,
    fallback_domain: str,
) -> list[SuggestionEvidence]:
    if not isinstance(raw_items, list):
        return []
    evidence: list[SuggestionEvidence] = []
    for raw in raw_items:
        if not isinstance(raw, dict):
            continue
        claim = str(raw.get("claim") or raw.get("summary") or "").strip()
        if not claim:
            continue
        evidence.append(
            SuggestionEvidence(
                source_domain=str(
                    raw.get("source_domain") or fallback_domain
                ),  # type: ignore[arg-type]
                entity_id=_maybe_text(raw.get("entity_id")),
                claim=claim,
                confidence=_score(raw.get("confidence"), fallback=0.62),
            )
        )
    return evidence


def _mental_load_type_for_domain(domain: str) -> str:
    return {
        "task": "task",
        "finance": "money",
        "pantry": "shopping",
        "wardrobe": "shopping",
        "week": "calendar",
        "habit": "reminder",
        "calendar": "calendar",
        "journal": "note",
        "recipe": "meal",
        "homememory": "home_memory",
        "shopping": "shopping",
        "decision": "decision",
    }.get(domain, "note")


def _recommended_action_for_item(item: MentalLoadItem) -> str:
    mapping = {
        "task": "Complete the smallest visible next step.",
        "finance": "Review the spend and confirm whether action is needed today.",
        "pantry": "Use what already exists before adding a purchase.",
        "wardrobe": "Compare the purchase against existing items first.",
        "week": "Block time or postpone intentionally.",
        "calendar": "Create or confirm a reminder before this slips.",
        "shopping": "Confirm the need and check local context first.",
        "homememory": "Review the item, warranty, or maintenance status before acting.",
        "decision": "Choose one safe next action and confirm it manually.",
    }
    return mapping.get(item.domain, "Review the next safe action and confirm it manually.")


def _local_alternatives(item: MentalLoadItem) -> list[str]:
    alternatives = ["Postpone and create a reminder", "Keep this local-only for now"]
    if item.domain in {"pantry", "shopping", "wardrobe"}:
        alternatives.insert(0, "Use an existing item first")
    return alternatives


def _ranking_reason(item: MentalLoadItem | None, score: float) -> str:
    if item is None:
        return f"Ranked with fallback score {score:.2f}."
    if item.due_hint:
        return f"Ranked high because it has a due hint ({item.due_hint}) and visible urgency."
    if item.domain in {"pantry", "shopping"}:
        return "Ranked for reducing waste or avoiding unnecessary purchases."
    if item.domain == "finance":
        return "Ranked to reduce money friction before it escalates."
    return f"Ranked for urgency {item.urgency_score:.2f} with manageable effort {item.effort_score:.2f}."


def _urgency_for_domain(domain: str, *, due_hint: str | None) -> float:
    base = {
        "finance": 0.78,
        "pantry": 0.72,
        "task": 0.7,
        "week": 0.62,
        "habit": 0.54,
        "wardrobe": 0.5,
    }.get(domain, 0.56)
    if due_hint:
        return min(0.94, base + 0.12)
    return base


def _effort_for_domain(domain: str) -> float:
    return {
        "task": 0.58,
        "finance": 0.42,
        "pantry": 0.34,
        "week": 0.46,
        "habit": 0.28,
        "wardrobe": 0.4,
        "shopping": 0.4,
        "homememory": 0.52,
    }.get(domain, 0.48)


def _score(value: object, *, fallback: float) -> float:
    if isinstance(value, (int, float)):
        return max(0.0, min(1.0, float(value)))
    if isinstance(value, str):
        try:
            return max(0.0, min(1.0, float(value)))
        except ValueError:
            return fallback
    return fallback


def _maybe_float(value: object) -> float | None:
    if isinstance(value, (int, float)):
        return float(value)
    if isinstance(value, str):
        try:
            return float(value.replace(",", "."))
        except ValueError:
            return None
    return None


def _maybe_text(value: object) -> str | None:
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def _string_list(value: object) -> list[str]:
    if isinstance(value, list):
        return [str(item) for item in value if str(item).strip()]
    return []
