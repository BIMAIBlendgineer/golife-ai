from __future__ import annotations

from app.capture_parser import classify_capture_request, parse_capture_request
from app.feedback_store import MissionFeedbackStore
from app.graphs.golife_graph import run_suggestion_graph
from app.guardrails import enforce_task_rewrite_privacy
from app.providers.base import LLMProvider
from app.schemas import (
    EventClassificationRequest,
    EventClassificationResponse,
    EventParseRequest,
    EventParseResponse,
    ParsedEventItem,
    SuggestionEvidence,
    SuggestionRequest,
    SuggestionResponse,
    TaskRewriteRequest,
    TaskRewriteResponse,
    TaskRewriteStep,
)
from app.settings import Settings

TASK_REWRITE_SYSTEM_PROMPT = """
Return JSON only.
Rewrite the task into small, safe, actionable steps.
No external actions without confirmation.
Return an object with a single key `rewrites`, containing an array of step objects.
"""

SEMANTIC_CLASSIFICATION_SYSTEM_PROMPT = """
Return JSON only.
Classify the capture text into one GoLife domain and one event_type.
Allowed domains: task, habit, week, finance, pantry, wardrobe.
Return an object with keys: domain, event_type, confidence, rationale.
Do not add extra keys outside the requested JSON object.
"""

SEMANTIC_PARSE_SYSTEM_PROMPT = """
Return JSON only.
Split the capture text into one or more GoLife items.
Allowed domains: task, habit, week, finance, pantry, wardrobe.
Return an object with one key `items`.
Each item must contain: text, domain, event_type, confidence, rationale, hints.
`hints` must be an object and may include amount, currency, time_hint, expiry_hint, task_intent, purchase_pause_hours.
Do not add extra keys outside the requested JSON object.
"""


def _coerce_confidence(value: object, default: float) -> float:
    if isinstance(value, (int, float)):
        return max(0.0, min(1.0, float(value)))
    if isinstance(value, str):
        lowered = value.strip().lower()
        if lowered in {"low", "small"}:
            return 0.55
        if lowered in {"medium", "moderate"}:
            return 0.72
        if lowered in {"high", "strong"}:
            return 0.86
        try:
            return max(0.0, min(1.0, float(lowered)))
        except ValueError:
            return default
    return default


def _normalize_evidence(
    raw_items: object,
    *,
    fallback_domain: str = "task",
) -> list[SuggestionEvidence]:
    if not isinstance(raw_items, list):
        return []

    evidence_items: list[SuggestionEvidence] = []
    for raw in raw_items:
        if not isinstance(raw, dict):
            continue
        claim = (
            raw.get("claim")
            or raw.get("explanation")
            or raw.get("reason")
            or raw.get("description")
        )
        if not claim:
            continue
        evidence_items.append(
            SuggestionEvidence(
                source_domain=raw.get("source_domain", fallback_domain),
                entity_id=raw.get("entity_id") or raw.get("event_id"),
                claim=str(claim),
                confidence=_coerce_confidence(raw.get("confidence"), 0.65),
            )
        )
    return evidence_items


def _normalize_task_rewrite_steps(
    provider_result: object,
) -> list[TaskRewriteStep]:
    if isinstance(provider_result, list):
        raw_steps = provider_result
    elif isinstance(provider_result, dict):
        raw_steps = (
            provider_result.get("rewrites")
            or provider_result.get("steps")
            or provider_result.get("items")
            or []
        )
        if not raw_steps and "description" in provider_result:
            raw_steps = [provider_result]
    else:
        raw_steps = []

    normalized_steps: list[TaskRewriteStep] = []
    for index, raw in enumerate(raw_steps, start=1):
        if not isinstance(raw, dict):
            continue
        title = raw.get("title") or raw.get("description") or f"Step {index}"
        reason = (
            raw.get("reason")
            or raw.get("description")
            or raw.get("why")
            or "LLM-generated task breakdown."
        )
        estimated_minutes = raw.get("estimated_minutes") or raw.get("minutes") or 10
        try:
            estimated_minutes = max(1, min(240, int(estimated_minutes)))
        except (TypeError, ValueError):
            estimated_minutes = 10

        normalized_steps.append(
            TaskRewriteStep(
                title=str(title),
                reason=str(reason),
                estimated_minutes=estimated_minutes,
                evidence=_normalize_evidence(raw.get("evidence")),
                confidence=_coerce_confidence(
                    raw.get("confidence") or raw.get("certainty"),
                    0.72,
                ),
            )
        )
    return normalized_steps


async def run_suggestions(
    request: SuggestionRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
    feedback_store: MissionFeedbackStore,
    intent: str,
) -> SuggestionResponse:
    return await run_suggestion_graph(
        request,
        settings=settings,
        provider=provider,
        feedback_summary=feedback_store.summarize(request.user_id),
        intent=intent,
    )


async def run_domain_suggestions(
    request: SuggestionRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
    feedback_store: MissionFeedbackStore,
    required_domain: str,
    intent: str,
) -> SuggestionResponse:
    merged_domains = list(
        dict.fromkeys(
            [
                *request.allowed_domains,
                *request.privacy_settings.allowed_domains,
                required_domain,
            ]
        )
    )
    domain_request = request.model_copy(
        update={
            "scope": "domain",
            "allowed_domains": merged_domains,
            "privacy_settings": request.privacy_settings.model_copy(
                update={"allowed_domains": merged_domains}
            ),
        }
    )
    return await run_suggestions(
        domain_request,
        settings=settings,
        provider=provider,
        feedback_store=feedback_store,
        intent=intent,
    )


async def run_task_rewrite(
    request: TaskRewriteRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> TaskRewriteResponse:
    enforce_task_rewrite_privacy(request)
    provider_result = await provider.complete_json(
        system_prompt=TASK_REWRITE_SYSTEM_PROMPT,
        user_payload={
            "intent": "task_rewrite",
            "user_id": request.user_id,
            "task_title": request.task_title,
            "task_description": request.task_description,
            "constraints": request.constraints,
        },
        response_schema=TaskRewriteResponse.model_json_schema(),
        temperature=0.0,
    )
    rewrites = _normalize_task_rewrite_steps(provider_result)
    provider_trace = provider_result if isinstance(provider_result, dict) else {}
    return TaskRewriteResponse(
        rewrites=rewrites,
        trace={
            "provider": provider.provider_name,
            "configured_provider": settings.llm_provider,
            "mock_mode": settings.resolved_mock_mode,
            "rewrite_count": len(rewrites),
            "mock": provider_trace.get("mock", False),
            "provider_meta": provider_trace.get("_provider_meta", {}),
        },
    )


def run_event_classification(
    request: EventClassificationRequest,
) -> EventClassificationResponse:
    item = classify_capture_request(request)
    return EventClassificationResponse(
        domain=item.domain,  # type: ignore[arg-type]
        event_type=item.event_type,
        confidence=item.confidence,
        rationale=item.rationale,
        trace={
            "classifier": "deterministic_capture_router",
            "parser": "deterministic_capture_parser",
            "ai_enabled": request.privacy_settings.ai_enabled,
            "item_count": len(parse_capture_request(EventParseRequest.model_validate(request.model_dump()))),
            "text_length": len(request.text),
        },
    )


def run_event_parse(
    request: EventParseRequest,
) -> EventParseResponse:
    items = parse_capture_request(request)
    return EventParseResponse(
        items=[
            ParsedEventItem(
                text=item.text,
                domain=item.domain,  # type: ignore[arg-type]
                event_type=item.event_type,
                confidence=item.confidence,
                rationale=item.rationale,
                hints=item.hints,
            )
            for item in items
        ],
        trace={
            "parser": "deterministic_capture_parser",
            "ai_enabled": request.privacy_settings.ai_enabled,
            "item_count": len(items),
            "text_length": len(request.text),
        },
    )


async def run_event_classification_semantic(
    request: EventClassificationRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> EventClassificationResponse:
    provider_result = await provider.complete_json(
        system_prompt=SEMANTIC_CLASSIFICATION_SYSTEM_PROMPT,
        user_payload={
            "intent": "semantic_classify",
            "user_id": request.user_id,
            "text": request.text,
            "allowed_domains": request.privacy_settings.allowed_domains,
            "ai_enabled": request.privacy_settings.ai_enabled,
        },
        response_schema=EventClassificationResponse.model_json_schema(),
        temperature=0.0,
    )

    if not isinstance(provider_result, dict):
        raise ValueError("Semantic classifier did not return an object.")

    domain = provider_result.get("domain")
    if not isinstance(domain, str):
        raise ValueError("Semantic classifier did not return a valid domain.")

    event_type = provider_result.get("event_type")
    if not isinstance(event_type, str) or not event_type.strip():
        raise ValueError("Semantic classifier did not return a valid event type.")

    rationale = provider_result.get("rationale")
    if not isinstance(rationale, str) or not rationale.strip():
        rationale = "Semantic classifier returned a structured classification."

    confidence = _coerce_confidence(provider_result.get("confidence"), 0.72)
    provider_meta = provider_result.get("_provider_meta", {})

    return EventClassificationResponse(
        domain=domain,  # type: ignore[arg-type]
        event_type=event_type,
        confidence=confidence,
        rationale=rationale,
        trace={
            "classifier": "semantic_openrouter",
            "configured_provider": settings.llm_provider,
            "provider_meta": provider_meta,
        },
    )


async def run_event_parse_semantic(
    request: EventParseRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> EventParseResponse:
    provider_result = await provider.complete_json(
        system_prompt=SEMANTIC_PARSE_SYSTEM_PROMPT,
        user_payload={
            "intent": "semantic_classify",
            "user_id": request.user_id,
            "text": request.text,
            "allowed_domains": request.privacy_settings.allowed_domains,
            "ai_enabled": request.privacy_settings.ai_enabled,
            "multi_item": True,
        },
        response_schema=EventParseResponse.model_json_schema(),
        temperature=0.0,
    )

    if not isinstance(provider_result, dict):
        raise ValueError("Semantic parser did not return an object.")

    raw_items = provider_result.get("items")
    if not isinstance(raw_items, list) or not raw_items:
        raise ValueError("Semantic parser did not return any items.")

    items: list[ParsedEventItem] = []
    for raw in raw_items:
        if not isinstance(raw, dict):
            continue
        text = raw.get("text")
        domain = raw.get("domain")
        event_type = raw.get("event_type")
        if not isinstance(text, str) or not text.strip():
            continue
        if not isinstance(domain, str) or not domain.strip():
            continue
        if not isinstance(event_type, str) or not event_type.strip():
            continue
        items.append(
            ParsedEventItem(
                text=text.strip(),
                domain=domain,  # type: ignore[arg-type]
                event_type=event_type.strip(),
                confidence=_coerce_confidence(raw.get("confidence"), 0.72),
                rationale=str(
                    raw.get("rationale")
                    or "Semantic parser returned a structured item."
                ),
                hints=raw.get("hints") if isinstance(raw.get("hints"), dict) else {},
            )
        )

    if not items:
        raise ValueError("Semantic parser normalization produced no valid items.")

    return EventParseResponse(
        items=items,
        trace={
            "parser": "semantic_openrouter",
            "configured_provider": settings.llm_provider,
            "provider_meta": provider_result.get("_provider_meta", {}),
            "item_count": len(items),
        },
    )
