from __future__ import annotations

from datetime import UTC, datetime, timedelta
from typing import Any

from app.schemas import (
    AIInvocationRecord,
    MobileRuntimeConfig,
    ModelCatalogEntry,
    ModelSelectionSnapshot,
    RoutingCapability,
    RoutingProfile,
)

CAPABILITY_DEFAULTS: dict[RoutingCapability, dict[str, Any]] = {
    "daily_plan": {
        "min_context_length": 32000,
        "required_parameters": ["response_format", "temperature", "max_tokens"],
        "preferred_max_latency_seconds": 6.0,
        "preferred_min_throughput_tokens_per_second": 20.0,
        "retry_policy": {"key_retries": 2, "parse_retries": 1},
    },
    "task_rewrite": {
        "min_context_length": 16000,
        "required_parameters": ["response_format", "temperature", "max_tokens"],
        "preferred_max_latency_seconds": 4.0,
        "preferred_min_throughput_tokens_per_second": 30.0,
        "retry_policy": {"key_retries": 2, "parse_retries": 1},
    },
    "semantic_classify": {
        "min_context_length": 8000,
        "required_parameters": ["response_format"],
        "preferred_max_latency_seconds": 2.0,
        "preferred_min_throughput_tokens_per_second": 50.0,
        "retry_policy": {"key_retries": 2, "parse_retries": 1},
    },
    "weekly_summary": {
        "min_context_length": 64000,
        "required_parameters": ["response_format"],
        "preferred_max_latency_seconds": 10.0,
        "preferred_min_throughput_tokens_per_second": 10.0,
        "retry_policy": {"key_retries": 2, "parse_retries": 1},
    },
}

CAPABILITY_ENDPOINTS: dict[RoutingCapability, tuple[str, ...]] = {
    "daily_plan": (
        "/v1/missions/daily",
        "/v1/suggestions/generate",
        "/v1/finance/reflect",
        "/v1/pantry/rescue",
        "/v1/closet/decision",
    ),
    "task_rewrite": ("/v1/tasks/rewrite",),
    "semantic_classify": ("/v1/events/classify",),
    "weekly_summary": (),
}

VENDOR_PRIORS: tuple[tuple[str, float], ...] = (
    ("anthropic/", 0.97),
    ("openai/", 0.965),
    ("google/", 0.955),
    ("x-ai/", 0.94),
    ("deepseek/", 0.935),
    ("mistralai/", 0.925),
    ("qwen/", 0.915),
    ("meta-llama/", 0.905),
    ("nousresearch/", 0.89),
)


def utcnow() -> datetime:
    return datetime.now(UTC)


def build_default_routing_profiles(now: datetime | None = None) -> list[RoutingProfile]:
    current = now or utcnow()
    profiles: list[RoutingProfile] = []
    for capability, defaults in CAPABILITY_DEFAULTS.items():
        profiles.append(
            RoutingProfile(
                capability=capability,
                strategy="quality_first",
                min_context_length=defaults["min_context_length"],
                required_parameters=list(defaults["required_parameters"]),
                preferred_max_latency_seconds=defaults["preferred_max_latency_seconds"],
                preferred_min_throughput_tokens_per_second=defaults[
                    "preferred_min_throughput_tokens_per_second"
                ],
                retry_policy=dict(defaults["retry_policy"]),
                enabled=(capability != "semantic_classify"),
                updated_at=current,
            )
        )
    return profiles


def capability_for_endpoint(endpoint: str) -> RoutingCapability | None:
    for capability, endpoints in CAPABILITY_ENDPOINTS.items():
        if endpoint in endpoints:
            return capability
    return None


def vendor_prior(model_id: str) -> float:
    lowered = model_id.lower()
    for prefix, score in VENDOR_PRIORS:
        if lowered.startswith(prefix):
            return score
    return 0.86


def build_mobile_runtime_config(
    *,
    gateway_base_url: str,
    ttl_seconds: int,
    feature_flags: dict[str, bool],
    ai_status: dict[str, Any],
    now: datetime | None = None,
) -> MobileRuntimeConfig:
    generated_at = now or utcnow()
    return MobileRuntimeConfig(
        schema_version=1,
        ttl_seconds=ttl_seconds,
        gateway_base_url=gateway_base_url,
        feature_flags=feature_flags,
        friendly_copy={
            "offline": "You can keep using GoLife locally. Reconnect when you want fresh AI help.",
            "gateway_degraded": "GoLife AI is under heavy load. Local guidance is still available.",
            "ai_temporarily_unavailable": "GoLife AI is temporarily unavailable. Your local plan and data are still safe.",
            "runtime_config_stale": "Using the last trusted server configuration until a fresh one is available.",
        },
        ai_status=ai_status,
        generated_at=generated_at,
    )


def filter_models_for_capability(
    models: list[ModelCatalogEntry],
    profile: RoutingProfile,
) -> list[ModelCatalogEntry]:
    filtered: list[ModelCatalogEntry] = []
    required = set(profile.required_parameters)
    now = utcnow()
    for model in models:
        if "text" not in model.output_modalities:
            continue
        if model.expiration_date and model.expiration_date <= now:
            continue
        if model.context_length < profile.min_context_length:
            continue
        if required and not required.issubset(set(model.supported_parameters)):
            continue
        if (
            profile.max_prompt_price_usd_per_million is not None
            and model.prompt_price_usd_per_million > profile.max_prompt_price_usd_per_million
        ):
            continue
        if (
            profile.max_completion_price_usd_per_million is not None
            and model.completion_price_usd_per_million > profile.max_completion_price_usd_per_million
        ):
            continue
        filtered.append(model)
    return filtered


def build_model_history(invocations: list[AIInvocationRecord]) -> dict[str, dict[str, float]]:
    by_model: dict[str, list[AIInvocationRecord]] = {}
    for invocation in invocations:
        if not invocation.model:
            continue
        by_model.setdefault(invocation.model, []).append(invocation)

    history: dict[str, dict[str, float]] = {}
    for model_id, items in by_model.items():
        total = len(items)
        success_count = sum(1 for item in items if item.status == "success")
        fallback_count = sum(1 for item in items if item.fallback)
        latency_avg = sum(item.latency_ms for item in items) / total if total else 0.0
        cost_avg = (
            sum(item.estimated_cost_usd for item in items) / total if total else 0.0
        )
        history[model_id] = {
            "reliability": success_count / total if total else 0.0,
            "fallback_penalty": fallback_count / total if total else 0.0,
            "latency_ms_avg": latency_avg,
            "cost_avg": cost_avg,
            "sample_size": float(total),
        }
    return history


def rank_models_for_capability(
    *,
    capability: RoutingCapability,
    profile: RoutingProfile,
    models: list[ModelCatalogEntry],
    invocation_history: dict[str, dict[str, float]],
    now: datetime | None = None,
) -> list[ModelSelectionSnapshot]:
    current = now or utcnow()
    candidates = filter_models_for_capability(models, profile)
    scored: list[tuple[float, ModelCatalogEntry, dict[str, Any]]] = []

    for model in candidates:
        history = invocation_history.get(model.model_id, {})
        quality = vendor_prior(model.model_id)
        reliability = history.get("reliability", 0.84)
        latency_component = max(
            0.0,
            1.0
            - (
                history.get("latency_ms_avg", profile.preferred_max_latency_seconds * 1000.0)
                / max(profile.preferred_max_latency_seconds * 1000.0, 1.0)
            ),
        )
        cost_component = 1.0 / (
            1.0 + model.prompt_price_usd_per_million + model.completion_price_usd_per_million
        )
        fallback_penalty = history.get("fallback_penalty", 0.0)
        score = (
            quality * 0.5
            + reliability * 0.25
            + latency_component * 0.15
            + cost_component * 0.1
            - fallback_penalty * 0.1
        )
        scored.append(
            (
                score,
                model,
                {
                    "quality_prior": round(quality, 4),
                    "reliability": round(reliability, 4),
                    "latency_component": round(latency_component, 4),
                    "cost_component": round(cost_component, 4),
                    "fallback_penalty": round(fallback_penalty, 4),
                    "supported_parameters": model.supported_parameters,
                },
            )
        )

    scored.sort(key=lambda item: item[0], reverse=True)
    top_three = scored[:3]
    expires_at = current + timedelta(hours=6)
    snapshots: list[ModelSelectionSnapshot] = []
    for rank_index, (score, model, reason) in enumerate(top_three):
        snapshots.append(
            ModelSelectionSnapshot(
                capability=capability,
                rank_index=rank_index,
                model_id=model.model_id,
                score=round(score, 4),
                selection_reason={
                    **reason,
                    "model_name": model.name,
                    "context_length": model.context_length,
                },
                generated_at=current,
                expires_at=expires_at,
            )
        )
    return snapshots

