from collections.abc import Iterable

from fastapi import HTTPException

from app.crisis_resources import resolve_crisis_resources
from app.schemas import (
    AISuggestion,
    LifeEvent,
    ReflectionSafetyRequest,
    ReflectionSafetyResponse,
    SuggestionRequest,
    TaskRewriteRequest,
)

REGULATED_FINANCE_TERMS = (
    "invest",
    "stock",
    "shares",
    "crypto",
    "etf",
    "portfolio",
    "mutual fund",
)
MEDICAL_TERMS = (
    "diagnose",
    "diagnosis",
    "medication",
    "therapy",
    "treatment plan",
    "disorder",
)
EMOTIONAL_CLINICAL_TERMS = (
    "depressed",
    "depression",
    "anxiety disorder",
    "panic disorder",
    "diagnostico",
    "diagnosis",
    "terapia",
    "therapy",
    "tratamiento",
    "treatment",
)
CRISIS_TERMS = (
    "suicide",
    "suicidal",
    "kill myself",
    "self harm",
    "harm myself",
    "quiero morir",
    "suicid",
    "hacerme daño",
    "lastimarme",
)


def filter_ai_events(request: SuggestionRequest) -> tuple[list[LifeEvent], list[dict[str, str]]]:
    if not request.privacy_settings.ai_enabled:
        return [], [
            {"event_id": event.event_id, "reason": "ai_disabled"}
            for event in request.life_events
        ]

    allowed_domains = set(request.privacy_settings.allowed_domains or request.allowed_domains)
    allowed_events: list[LifeEvent] = []
    filtered: list[dict[str, str]] = []

    for event in request.life_events:
        if event.privacy_level != "ai_allowed":
            filtered.append({"event_id": event.event_id, "reason": "privacy_level"})
            continue
        if allowed_domains and event.domain not in allowed_domains:
            filtered.append({"event_id": event.event_id, "reason": "domain_not_allowed"})
            continue
        allowed_events.append(event)

    return allowed_events, filtered


def enforce_task_rewrite_privacy(request: TaskRewriteRequest) -> None:
    if request.privacy_level != "ai_allowed":
        raise HTTPException(
            status_code=403,
            detail="Task rewrite requires privacy_level=ai_allowed.",
        )


def sanitize_suggestions(
    suggestions: Iterable[AISuggestion],
    *,
    max_items: int,
) -> tuple[list[AISuggestion], list[dict[str, str]]]:
    accepted: list[AISuggestion] = []
    rejected: list[dict[str, str]] = []

    for suggestion in suggestions:
        text = f"{suggestion.title} {suggestion.body}".lower()
        if not suggestion.evidence:
            rejected.append(
                {"suggestion_id": suggestion.suggestion_id, "reason": "missing_evidence"}
            )
            continue
        if any(term in text for term in REGULATED_FINANCE_TERMS):
            rejected.append(
                {"suggestion_id": suggestion.suggestion_id, "reason": "regulated_advice"}
            )
            continue
        if any(term in text for term in MEDICAL_TERMS):
            rejected.append(
                {"suggestion_id": suggestion.suggestion_id, "reason": "medical_content"}
            )
            continue

        merged_actions = list(dict.fromkeys(
            [*suggestion.forbidden_actions, "external_action_without_confirmation"]
        ))
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
    lowered = request.text.lower()

    matched_crisis = [term for term in CRISIS_TERMS if term in lowered]
    if matched_crisis:
        resources = resolve_crisis_resources(
            region=region,
            catalog_path=catalog_path,
        )
        return ReflectionSafetyResponse(
            safe=False,
            category="crisis",
            message=(
                "GoLife can help you organize what feels heavy, but it is not crisis care. "
                "If you might act on self-harm or feel in immediate danger, use the immediate support options below "
                "and reach out to someone nearby right now."
            ),
            resources=resources,
            trace={
                "policy": "reflection_safety",
                "matched_terms": matched_crisis,
                "reason": "crisis_language",
                "region": region,
            },
        )

    matched_clinical = [term for term in EMOTIONAL_CLINICAL_TERMS if term in lowered]
    if matched_clinical:
        return ReflectionSafetyResponse(
            safe=False,
            category="clinical",
            message=(
                "GoLife can support reflection and daily organization, but it cannot diagnose, treat, "
                "or replace a licensed mental health professional. Keep the reflection practical and non-clinical."
            ),
            trace={
                "policy": "reflection_safety",
                "matched_terms": matched_clinical,
                "reason": "clinical_language",
                "region": region,
            },
        )

    return ReflectionSafetyResponse(
        safe=True,
        category="supportive",
        message=(
            "GoLife can help you reflect on routines, energy, and daily friction. "
            "It stays in coaching and organization mode, not diagnosis or treatment."
        ),
        trace={
            "policy": "reflection_safety",
            "matched_terms": [],
            "reason": "supportive_reflection",
            "region": region,
        },
    )
