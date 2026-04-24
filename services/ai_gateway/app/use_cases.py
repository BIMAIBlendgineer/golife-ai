from __future__ import annotations

from app.feedback_store import MissionFeedbackStore
from app.graphs.golife_graph import run_suggestion_graph
from app.guardrails import enforce_task_rewrite_privacy
from app.providers.base import LLMProvider
from app.schemas import (
    EventClassificationRequest,
    EventClassificationResponse,
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
"""


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
    )
    rewrites = [
        TaskRewriteStep.model_validate(item)
        for item in provider_result.get("rewrites", [])
    ]
    return TaskRewriteResponse(
        rewrites=rewrites,
        trace={
            "provider": provider.provider_name,
            "configured_provider": settings.llm_provider,
            "mock_mode": settings.resolved_mock_mode,
            "rewrite_count": len(rewrites),
            "mock": provider_result.get("mock", False),
        },
    )


def run_event_classification(
    request: EventClassificationRequest,
) -> EventClassificationResponse:
    text = request.text.lower()

    def _response(
        *,
        domain: str,
        event_type: str,
        confidence: float,
        rationale: str,
        matched_keywords: tuple[str, ...] = (),
    ) -> EventClassificationResponse:
        return EventClassificationResponse(
            domain=domain,
            event_type=event_type,
            confidence=confidence,
            rationale=rationale,
            trace={
                "classifier": "deterministic_capture_router",
                "ai_enabled": request.privacy_settings.ai_enabled,
                "matched_keywords": list(matched_keywords),
                "text_length": len(request.text),
            },
        )

    rules = [
        (
            "finance",
            "expense_logged",
            0.84,
            ("$", "eur", "gaste", "compre", "coffee", "pague", "paid", "bought"),
            "Detected money and purchase language.",
        ),
        (
            "pantry",
            "ingredient_flagged",
            0.82,
            (
                "vence",
                "expires",
                "fridge",
                "pantry",
                "spinach",
                "lechuga",
                "espinaca",
            ),
            "Detected pantry or expiry language.",
        ),
        (
            "wardrobe",
            "purchase_intention",
            0.8,
            ("jacket", "shirt", "ropa", "chaqueta", "closet", "armario", "outfit"),
            "Detected wardrobe or clothing intent.",
        ),
        (
            "habit",
            "habit_logged",
            0.77,
            ("habit", "streak", "meditate", "walked", "camine", "sleep", "water"),
            "Detected habit continuity language.",
        ),
        (
            "week",
            "week_note_captured",
            0.74,
            ("week", "semana", "monday", "martes", "viernes", "calendar"),
            "Detected planning or weekly framing.",
        ),
    ]

    for domain, event_type, confidence, keywords, rationale in rules:
        matched = tuple(keyword for keyword in keywords if keyword in text)
        if matched:
            return _response(
                domain=domain,
                event_type=event_type,
                confidence=confidence,
                rationale=rationale,
                matched_keywords=matched,
            )

    return _response(
        domain="task",
        event_type="task_captured",
        confidence=0.62,
        rationale="Defaulted to task because no stronger domain signal was found.",
    )
