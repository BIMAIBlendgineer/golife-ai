from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from app.schemas import (
    EventClassificationRequest,
    EventClassificationResponse,
    MissionFeedbackRequest,
    SuggestionRequest,
    SuggestionResponse,
    TaskRewriteRequest,
    TaskRewriteResponse,
)
from app.settings import Settings


def _utcnow_iso() -> str:
    return datetime.now(UTC).isoformat()


def estimate_cost_usd(
    *,
    endpoint: str,
    provider: str,
    suggestions_count: int = 0,
) -> float:
    if provider == "mock" or endpoint == "/v1/feedback":
        return 0.0

    base_costs = {
        "/v1/missions/daily": 0.018,
        "/v1/suggestions/generate": 0.016,
        "/v1/finance/reflect": 0.011,
        "/v1/pantry/rescue": 0.011,
        "/v1/closet/decision": 0.01,
        "/v1/tasks/rewrite": 0.012,
        "/v1/events/classify": 0.001,
    }
    base = base_costs.get(endpoint, 0.008)
    multiplier = 1.0 + max(0, suggestions_count - 1) * 0.2
    return round(base * multiplier, 4)


def build_model_settings_payload(settings: Settings, provider_name: str) -> dict[str, Any]:
    return {
        "active_provider": provider_name,
        "primary_model": settings.openrouter_default_model,
        "fallback_model": settings.openrouter_fallback_model or "mock",
        "classification_model": "deterministic_capture_router",
        "weekly_summary_model": settings.openrouter_default_model,
    }


def build_suggestion_operation_payloads(
    *,
    endpoint: str,
    request: SuggestionRequest,
    response: SuggestionResponse,
    latency_ms: float,
) -> dict[str, Any]:
    provider_meta = response.trace.get("provider_meta", {}) or {}
    provider_name = str(response.trace.get("active_provider", provider_meta.get("provider", "unknown")))
    model_name = provider_meta.get("model")
    created_at = _utcnow_iso()
    invocation_id = f"invoke-{uuid4()}"

    score_breakdown = {
        item["suggestion_id"]: item
        for item in response.trace.get("rank", {}).get("score_breakdown", [])
        if isinstance(item, dict) and "suggestion_id" in item
    }

    mission_audits = []
    for suggestion in response.suggestions:
        breakdown = score_breakdown.get(suggestion.suggestion_id, {})
        mission_audits.append(
            {
                "mission_id": suggestion.suggestion_id,
                "user_id": request.user_id,
                "title": suggestion.title,
                "status": "generated",
                "usefulness": None,
                "domains": suggestion.domain_targets,
                "matched_risks": breakdown.get("matched_risks", []),
                "final_score": breakdown.get("final_score", round(suggestion.confidence, 4)),
                "created_at": created_at,
            }
        )

    safety_events = []
    for rejected in response.trace.get("guardrail_review", {}).get("rejected", []):
        if not isinstance(rejected, dict):
            continue
        reason = str(rejected.get("reason", "guardrail_rejection"))
        safety_events.append(
            {
                "event_id": f"safety-{uuid4()}",
                "user_id": request.user_id,
                "category": "ai_output",
                "rule": reason,
                "severity": "medium" if "regulated" in reason or "medical" in reason else "low",
                "endpoint": endpoint,
                "created_at": created_at,
            }
        )

    return {
        "usage_event": {
            "event_id": f"usage-{uuid4()}",
            "user_id": request.user_id,
            "event_type": "daily_plan_requested",
            "endpoint": endpoint,
            "domain": None,
            "quantity": 1,
            "created_at": created_at,
            "metadata": {
                "scope": request.scope,
                "suggestions_count": len(response.suggestions),
            },
        },
        "ai_invocation": {
            "invocation_id": invocation_id,
            "user_id": request.user_id,
            "endpoint": endpoint,
            "provider": provider_name,
            "model": model_name,
            "latency_ms": round(latency_ms, 2),
            "fallback": bool(response.trace.get("mock_mode") or provider_name == "mock"),
            "suggestions_count": len(response.suggestions),
            "estimated_cost_usd": estimate_cost_usd(
                endpoint=endpoint,
                provider=provider_name,
                suggestions_count=len(response.suggestions),
            ),
            "schema_valid": True,
            "status": "success",
            "created_at": created_at,
            "metadata": {
                "intent": endpoint,
                "filtered_events_count": response.trace.get("validate_consent", {}).get(
                    "filtered_events_count",
                    0,
                ),
            },
        },
        "mission_audits": mission_audits,
        "safety_events": safety_events,
    }


def build_classification_operation_payloads(
    *,
    request: EventClassificationRequest,
    response: EventClassificationResponse,
    latency_ms: float,
) -> dict[str, Any]:
    created_at = _utcnow_iso()
    return {
        "usage_event": {
            "event_id": f"usage-{uuid4()}",
            "user_id": request.user_id,
            "event_type": "capture_classification_requested",
            "endpoint": "/v1/events/classify",
            "domain": response.domain,
            "quantity": 1,
            "created_at": created_at,
            "metadata": {
                "event_type": response.event_type,
                "classifier": response.trace.get("classifier"),
            },
        },
        "ai_invocation": {
            "invocation_id": f"invoke-{uuid4()}",
            "user_id": request.user_id,
            "endpoint": "/v1/events/classify",
            "provider": "deterministic_classifier",
            "model": "deterministic_capture_router",
            "latency_ms": round(latency_ms, 2),
            "fallback": False,
            "suggestions_count": 1,
            "estimated_cost_usd": estimate_cost_usd(
                endpoint="/v1/events/classify",
                provider="deterministic_classifier",
                suggestions_count=1,
            ),
            "schema_valid": True,
            "status": "success",
            "created_at": created_at,
            "metadata": {
                "domain": response.domain,
                "confidence": response.confidence,
            },
        },
    }


def build_feedback_operation_payloads(
    *,
    request: MissionFeedbackRequest,
    feedback_id: str,
) -> dict[str, Any]:
    created_at = _utcnow_iso()
    return {
        "usage_event": {
            "event_id": f"usage-{uuid4()}",
            "user_id": request.user_id,
            "event_type": "mission_feedback_recorded",
            "endpoint": "/v1/feedback",
            "domain": request.domain_targets[0] if request.domain_targets else None,
            "quantity": 1,
            "created_at": created_at,
            "metadata": {
                "status": request.status,
                "suggestion_id": request.suggestion_id,
            },
        },
        "feedback_audit": {
            "feedback_id": feedback_id,
            "user_id": request.user_id,
            "suggestion_id": request.suggestion_id,
            "status": request.status,
            "reason": request.notes,
            "domains": request.domain_targets,
            "created_at": created_at,
        },
    }


def build_task_rewrite_operation_payloads(
    *,
    request: TaskRewriteRequest,
    response: TaskRewriteResponse | None,
    latency_ms: float,
    status: str,
    error_detail: str | None = None,
) -> dict[str, Any]:
    created_at = _utcnow_iso()
    rewrite_count = len(response.rewrites) if response else 0
    provider_name = (
        str(response.trace.get("provider", "unknown"))
        if response
        else "guardrail"
    )
    return {
        "usage_event": {
            "event_id": f"usage-{uuid4()}",
            "user_id": request.user_id,
            "event_type": "task_rewrite_requested",
            "endpoint": "/v1/tasks/rewrite",
            "domain": "task",
            "quantity": 1,
            "created_at": created_at,
            "metadata": {
                "rewrite_count": rewrite_count,
                "status": status,
            },
        },
        "ai_invocation": {
            "invocation_id": f"invoke-{uuid4()}",
            "user_id": request.user_id,
            "endpoint": "/v1/tasks/rewrite",
            "provider": provider_name,
            "model": None,
            "latency_ms": round(latency_ms, 2),
            "fallback": bool(response.trace.get("mock_mode", False)) if response else False,
            "suggestions_count": rewrite_count,
            "estimated_cost_usd": estimate_cost_usd(
                endpoint="/v1/tasks/rewrite",
                provider=provider_name,
                suggestions_count=rewrite_count,
            ),
            "schema_valid": response is not None,
            "status": status,
            "created_at": created_at,
            "metadata": {
                "error": error_detail,
            },
        },
        "safety_events": (
            [
                {
                    "event_id": f"safety-{uuid4()}",
                    "user_id": request.user_id,
                    "category": "privacy",
                    "rule": "task_rewrite_requires_ai_allowed",
                    "severity": "medium",
                    "endpoint": "/v1/tasks/rewrite",
                    "created_at": created_at,
                }
            ]
            if error_detail
            else []
        ),
    }
