from collections.abc import Iterable

from fastapi import HTTPException

from app.policy_engine import POLICY_VERSION, policy_engine
from app.schemas import (
    AISuggestion,
    EventClassificationRequest,
    EventParseRequest,
    LifeEvent,
    ProofParseRequest,
    ReflectionSafetyRequest,
    ReflectionSafetyResponse,
    SuggestionRequest,
    TaskRewriteRequest,
)


def _raise_unsafe_input(
    *,
    code: str,
    input_surface: str,
    category: str,
    message: str,
    safe: bool,
    resources: list[dict],
    trace: dict,
) -> None:
    raise HTTPException(
        status_code=422,
        detail={
            "code": code,
            "input_surface": input_surface,
            "message": message,
            "category": category,
            "safe": safe,
            "resources": resources,
            "redirect_endpoint": "/v1/reflection/check",
            "trace": trace,
        },
    )


def filter_ai_events(request: SuggestionRequest) -> tuple[list[LifeEvent], list[dict[str, str]]]:
    if not request.privacy_settings.ai_enabled:
        return [], [
            {"event_id": event.event_id, "domain": event.domain, "reason": "ai_disabled"}
            for event in request.life_events
        ]

    allowed_domains = set(request.privacy_settings.allowed_domains or request.allowed_domains)
    allowed_events: list[LifeEvent] = []
    filtered: list[dict[str, str]] = []

    for event in request.life_events:
        if event.privacy_level != "ai_allowed":
            filtered.append(
                {
                    "event_id": event.event_id,
                    "domain": event.domain,
                    "reason": "privacy_level",
                }
            )
            continue
        if allowed_domains and event.domain not in allowed_domains:
            filtered.append(
                {
                    "event_id": event.event_id,
                    "domain": event.domain,
                    "reason": "domain_not_allowed",
                }
            )
            continue
        allowed_events.append(event)

    return allowed_events, filtered


def enforce_task_rewrite_privacy(request: TaskRewriteRequest) -> None:
    if request.privacy_level != "ai_allowed":
        raise HTTPException(
            status_code=403,
            detail="Task rewrite requires privacy_level=ai_allowed.",
        )


def _enforce_safe_text(
    *,
    text: str,
    locale: str,
    input_surface: str,
    code: str,
    region: str = "global",
    catalog_path: str | None = None,
) -> None:
    decision = policy_engine.evaluate_input_text(
        text,
        locale=locale,
        input_surface=input_surface,
        region=region,
        catalog_path=catalog_path,
    )
    if decision.action != "allow":
        _raise_unsafe_input(
            code=code,
            input_surface=input_surface,
            category=decision.category,
            message=decision.message,
            safe=decision.safe,
            resources=decision.resources,
            trace=decision.trace(locale=locale, region=region),
        )


def enforce_safe_capture_input(
    request: EventClassificationRequest | EventParseRequest,
    *,
    region: str = "global",
    catalog_path: str | None = None,
) -> None:
    _enforce_safe_text(
        text=request.text,
        locale=request.locale,
        input_surface="capture",
        code="unsafe_capture_text",
        region=region,
        catalog_path=catalog_path,
    )


def enforce_safe_proof_input(
    request: ProofParseRequest,
    *,
    region: str = "global",
    catalog_path: str | None = None,
) -> None:
    _enforce_safe_text(
        text=request.text,
        locale=request.locale,
        input_surface="proof_parse",
        code="unsafe_proof_text",
        region=region,
        catalog_path=catalog_path,
    )


def enforce_safe_task_rewrite_content(
    request: TaskRewriteRequest,
    *,
    region: str = "global",
    catalog_path: str | None = None,
) -> None:
    combined_text = " ".join(
        part.strip()
        for part in (request.task_title, request.task_description or "")
        if part and part.strip()
    )
    _enforce_safe_text(
        text=combined_text,
        locale=request.locale,
        input_surface="task_rewrite",
        code="unsafe_task_rewrite_text",
        region=region,
        catalog_path=catalog_path,
    )


def sanitize_suggestions(
    suggestions: Iterable[AISuggestion],
    *,
    max_items: int,
) -> tuple[list[AISuggestion], list[dict[str, str]]]:
    accepted: list[AISuggestion] = []
    rejected: list[dict[str, str]] = []

    for suggestion in suggestions:
        decision = policy_engine.evaluate_suggestion(suggestion)
        if not decision.safe:
            rejected.append(
                {
                    "suggestion_id": suggestion.suggestion_id,
                    "reason": decision.reason,
                    "policy_id": decision.policy_id,
                    "policy_version": decision.policy_version,
                }
            )
            continue

        merged_actions = list(
            dict.fromkeys(
                [
                    *suggestion.forbidden_actions,
                    "external_action_without_confirmation",
                ]
            )
        )
        accepted.append(
            suggestion.model_copy(
                update={
                    "requires_confirmation": True,
                    "forbidden_actions": merged_actions,
                }
            )
        )
        if len(accepted) >= max_items:
            break

    return accepted, rejected


def assess_reflection_safety(
    request: ReflectionSafetyRequest,
    *,
    region: str = "global",
    catalog_path: str | None = None,
) -> ReflectionSafetyResponse:
    response = policy_engine.evaluate_reflection_text(
        request.text,
        locale=request.locale,
        region=region,
        catalog_path=catalog_path,
    )
    response.trace.setdefault("policy_version", POLICY_VERSION)
    return response
