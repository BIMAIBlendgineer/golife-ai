from __future__ import annotations

from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

from app.guardrails import sanitize_product_evidence_cards
from app.providers.base import LLMProvider
from app.schemas import (
    ActionContract,
    DecisionCard,
    PrivacySummary,
    ProductEvidenceCard,
    ProductEvidenceRequest,
    ShoppingNeed,
    ShoppingPlanRequest,
    ShoppingPlanResponse,
    SuggestionEvidence,
)
from app.settings import Settings

SHOPPING_OPTIMIZATION_SYSTEM_PROMPT = """
Return JSON only.
Create a shopping decision plan from pantry, finance, recipes,
wardrobe and homememory context.
Prefer using existing items before recommending purchases.
Do not claim best price, availability, or sustainability unless
source evidence is present.
If evidence is missing, set sustainability_status='insufficient_verified_data'.
Every purchase recommendation requires human confirmation.
"""


def _utcnow_iso() -> str:
    return datetime.now(UTC).isoformat()


async def run_shopping_plan_graph(
    request: ShoppingPlanRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> ShoppingPlanResponse:
    runtime_flags = await provider.runtime_flags()
    allowed_needs, blocked_needs = _filter_allowed_needs(request.shopping_needs, request)
    if not allowed_needs:
        return ShoppingPlanResponse(
            needs=[],
            product_evidence=[],
            decisions=[],
            trace={
                "nodes": [
                    "validate_consent",
                    "collect_local_context",
                    "extract_shopping_needs",
                    "build_response",
                ],
                "configured_provider": settings.llm_provider,
                "provider": provider.provider_name,
                "privacy_filtered_count": len(blocked_needs),
                "shopping_need_count": 0,
                "fallbackReason": "privacy_filtered",
            },
        )

    response: ShoppingPlanResponse | None = None
    provider_meta: dict[str, Any] = {}
    if request.privacy_settings.ai_enabled and runtime_flags.get("shopping_plan"):
        try:
            provider_result = await provider.complete_json(
                system_prompt=SHOPPING_OPTIMIZATION_SYSTEM_PROMPT,
                user_payload={
                    "intent": "shopping_plan",
                    "user_id": request.user_id,
                    "locale": request.locale,
                    "allowed_domains": request.privacy_settings.allowed_domains,
                    "shopping_needs": [item.model_dump(mode="json") for item in allowed_needs],
                    "pantry_context": request.pantry_context,
                    "finance_context": request.finance_context,
                    "wardrobe_context": request.wardrobe_context,
                    "homememory_context": request.homememory_context,
                },
                response_schema=ShoppingPlanResponse.model_json_schema(),
                temperature=0.0,
            )
            response = _normalize_provider_shopping_response(
                provider_result,
                request=request,
                allowed_needs=allowed_needs,
            )
            if isinstance(provider_result, dict):
                provider_meta = dict(provider_result.get("_provider_meta", {}) or {})
        except Exception:
            response = None

    if response is None:
        response = _build_local_shopping_response(request=request, allowed_needs=allowed_needs)
        response = response.model_copy(
            update={
                "trace": {
                    **response.trace,
                    "clientFallback": True,
                }
            }
        )

    sanitized_evidence, guardrail_events = sanitize_product_evidence_cards(
        response.product_evidence
    )
    normalized_response = response.model_copy(
        update={
            "product_evidence": sanitized_evidence,
            "trace": {
                **response.trace,
                "configured_provider": settings.llm_provider,
                "provider": provider.provider_name,
                "provider_meta": provider_meta,
                "privacy_filtered_count": len(blocked_needs),
                "shopping_need_count": len(response.needs),
                "guardrail_review": {"rejected": guardrail_events},
            },
        }
    )
    return normalized_response


async def run_extract_shopping_needs_graph(
    request: ShoppingPlanRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> ShoppingPlanResponse:
    response = await run_shopping_plan_graph(
        request,
        settings=settings,
        provider=provider,
    )
    return response.model_copy(update={"decisions": [], "product_evidence": []})


async def run_product_evidence_graph(
    request: ProductEvidenceRequest,
    *,
    settings: Settings,
    provider: LLMProvider,
) -> ProductEvidenceCard:
    runtime_flags = await provider.runtime_flags()
    provider_card: ProductEvidenceCard | None = None
    if request.privacy_settings.ai_enabled and runtime_flags.get("product_evidence"):
        try:
            provider_result = await provider.complete_json(
                system_prompt=SHOPPING_OPTIMIZATION_SYSTEM_PROMPT,
                user_payload={
                    "intent": "product_evidence",
                    "user_id": request.user_id,
                    "locale": request.locale,
                    "product_name": request.product_name,
                    "merchant_name": request.merchant_name,
                    "allowed_domains": request.privacy_settings.allowed_domains,
                },
                response_schema=ProductEvidenceCard.model_json_schema(),
                temperature=0.0,
            )
            provider_card = _normalize_provider_product_evidence(
                provider_result,
                request=request,
            )
        except Exception:
            provider_card = None

    fallback_card = provider_card or _build_local_product_evidence_card(request)
    cards, _ = sanitize_product_evidence_cards([fallback_card])
    return cards[0]


def _filter_allowed_needs(
    needs: list[ShoppingNeed],
    request: ShoppingPlanRequest,
) -> tuple[list[ShoppingNeed], list[dict[str, str]]]:
    allowed_domains = set(request.privacy_settings.allowed_domains)
    allowed: list[ShoppingNeed] = []
    blocked: list[dict[str, str]] = []
    for need in needs:
        if allowed_domains and need.source_domain not in allowed_domains:
            blocked.append(
                {
                    "need_id": need.need_id,
                    "domain": need.source_domain,
                    "reason": "domain_not_allowed",
                }
            )
            continue
        allowed.append(need)
    return allowed, blocked


def _normalize_provider_shopping_response(
    provider_result: object,
    *,
    request: ShoppingPlanRequest,
    allowed_needs: list[ShoppingNeed],
) -> ShoppingPlanResponse | None:
    if not isinstance(provider_result, dict):
        return None
    raw_needs = provider_result.get("needs")
    raw_evidence = provider_result.get("product_evidence")
    raw_decisions = provider_result.get("decisions")
    if not isinstance(raw_needs, list) or not isinstance(raw_evidence, list) or not isinstance(raw_decisions, list):
        return None

    normalized_needs = [
        _normalize_shopping_need(raw, request=request, fallback=allowed_needs[min(index, len(allowed_needs) - 1)])
        for index, raw in enumerate(raw_needs)
        if isinstance(raw, dict) and allowed_needs
    ]
    normalized_evidence = [
        _normalize_product_evidence_from_dict(raw, request_user_id=request.user_id)
        for raw in raw_evidence
        if isinstance(raw, dict)
    ]
    normalized_decisions = [
        _normalize_shopping_decision(
            raw,
            request=request,
            allowed_needs=normalized_needs or allowed_needs,
        )
        for raw in raw_decisions
        if isinstance(raw, dict)
    ]
    return ShoppingPlanResponse(
        needs=normalized_needs,
        product_evidence=normalized_evidence,
        decisions=[item for item in normalized_decisions if item is not None],
        trace={
            "nodes": [
                "validate_consent",
                "collect_local_context",
                "extract_shopping_needs",
                "prefer_existing_items",
                "sanitize_purchase_claims",
                "build_response",
            ],
            "semantic": True,
        },
    )


def _normalize_provider_product_evidence(
    provider_result: object,
    *,
    request: ProductEvidenceRequest,
) -> ProductEvidenceCard | None:
    if not isinstance(provider_result, dict):
        return None
    return _normalize_product_evidence_from_dict(
        provider_result,
        request_user_id=request.user_id,
        fallback_product_name=request.product_name,
        fallback_merchant=request.merchant_name,
    )


def _normalize_shopping_need(
    raw: dict[str, Any],
    *,
    request: ShoppingPlanRequest,
    fallback: ShoppingNeed,
) -> ShoppingNeed:
    now_iso = _utcnow_iso()
    return ShoppingNeed(
        need_id=str(raw.get("need_id") or raw.get("id") or fallback.need_id),
        user_id=request.user_id,
        need_type=str(raw.get("need_type") or fallback.need_type),
        title=str(raw.get("title") or fallback.title),
        source_domain=str(raw.get("source_domain") or fallback.source_domain),  # type: ignore[arg-type]
        source_event_ids=_string_list(raw.get("source_event_ids")) or fallback.source_event_ids,
        urgency_score=_score(raw.get("urgency_score"), fallback=fallback.urgency_score),
        budget_hint=_maybe_float(raw.get("budget_hint")) if raw.get("budget_hint") is not None else fallback.budget_hint,
        currency=_maybe_text(raw.get("currency")) or fallback.currency,
        sustainability_preference=_maybe_text(raw.get("sustainability_preference")) or fallback.sustainability_preference,
        state=str(raw.get("state") or fallback.state),
        created_at_iso=_maybe_text(raw.get("created_at_iso")) or fallback.created_at_iso or now_iso,
        updated_at_iso=_maybe_text(raw.get("updated_at_iso")) or fallback.updated_at_iso or now_iso,
        trace={"semantic": True},
    )


def _normalize_product_evidence_from_dict(
    raw: dict[str, Any],
    *,
    request_user_id: str,
    fallback_product_name: str | None = None,
    fallback_merchant: str | None = None,
) -> ProductEvidenceCard:
    now_iso = _utcnow_iso()
    return ProductEvidenceCard(
        id=str(raw.get("id") or f"evidence-{uuid4()}"),
        user_id=request_user_id,
        product_name=str(raw.get("product_name") or fallback_product_name or "Unknown product"),
        brand=_maybe_text(raw.get("brand")),
        merchant_name=_maybe_text(raw.get("merchant_name")) or fallback_merchant,
        price=_maybe_float(raw.get("price")),
        currency=_maybe_text(raw.get("currency")),
        source=_maybe_text(raw.get("source")),
        checked_at_iso=_maybe_text(raw.get("checked_at_iso")) or _maybe_text(raw.get("checked_at")) or now_iso,
        review_summary=_maybe_text(raw.get("review_summary")),
        sustainability_status=str(raw.get("sustainability_status") or "not_checked"),  # type: ignore[arg-type]
        confidence=_score(raw.get("confidence"), fallback=0.54),
        disclaimer=str(
            raw.get("disclaimer")
            or "No price, availability, or sustainability claim is shown without verified evidence."
        ),
        trace={"semantic": True},
    )


def _normalize_shopping_decision(
    raw: dict[str, Any],
    *,
    request: ShoppingPlanRequest,
    allowed_needs: list[ShoppingNeed],
) -> DecisionCard | None:
    title = str(raw.get("title") or "").strip()
    action = str(raw.get("recommended_action") or "").strip()
    uncertainty = str(raw.get("uncertainty") or "").strip()
    if not title or not action or not uncertainty:
        return None
    source_items = _string_list(raw.get("source_items"))
    source_need = None
    if source_items:
        source_need = next((item for item in allowed_needs if item.need_id == source_items[0]), None)
    source_need = source_need or (allowed_needs[0] if allowed_needs else None)
    evidence_claim = (
        f"Existing-item-first context was considered for {source_need.title}."
        if source_need is not None
        else "Existing-item-first context was considered."
    )
    return DecisionCard(
        decision_id=str(raw.get("decision_id") or f"shopping-decision-{uuid4()}"),
        user_id=request.user_id,
        title=title,
        recommended_action=action,
        alternatives=_string_list(raw.get("alternatives")),
        domain_targets=_string_list(raw.get("domain_targets")) or ["shopping"],  # type: ignore[arg-type]
        source_items=source_items or ([source_need.need_id] if source_need else []),
        evidence=[
            SuggestionEvidence(
                source_domain=(source_need.source_domain if source_need else "shopping"),  # type: ignore[arg-type]
                entity_id=(source_need.need_id if source_need else None),
                claim=evidence_claim,
                confidence=0.62,
            )
        ],
        confidence=_score(raw.get("confidence"), fallback=0.6),
        uncertainty=uncertainty,
        privacy_summary=_shopping_privacy_summary(request=request, sent_count=len(allowed_needs)),
        confirmation_required=True,
        action_contract=ActionContract(
            action_type=str((raw.get("action_contract") or {}).get("action_type") or "confirm_shopping_need"),
            requires_confirmation=True,
            destructive=False,
            external=(raw.get("action_contract") or {}).get("external") is True,
            payload_preview=dict((raw.get("action_contract") or {}).get("payload_preview") or {}),
            forbidden_actions=_string_list((raw.get("action_contract") or {}).get("forbidden_actions")),
        ),
        status=str(raw.get("status") or "shown"),
        evidence_status=str(raw.get("evidence_status") or "insufficient_verified_data"),
        ranking_score=_score(raw.get("ranking_score"), fallback=source_need.urgency_score if source_need else 0.5),
        created_at_iso=_utcnow_iso(),
        updated_at_iso=_utcnow_iso(),
        trace={"semantic": True},
    )


def _build_local_shopping_response(
    *,
    request: ShoppingPlanRequest,
    allowed_needs: list[ShoppingNeed],
) -> ShoppingPlanResponse:
    pantry_names = _context_names(request.pantry_context)
    needs = allowed_needs
    evidence_cards = [
        _local_evidence_for_need(need, pantry_names=pantry_names)
        for need in needs
    ]
    decisions = [
        _local_decision_for_need(
            request=request,
            need=need,
            pantry_names=pantry_names,
        )
        for need in needs[:3]
    ]
    return ShoppingPlanResponse(
        needs=needs,
        product_evidence=evidence_cards,
        decisions=decisions,
        trace={
            "nodes": [
                "validate_consent",
                "collect_local_context",
                "extract_shopping_needs",
                "prefer_existing_items",
                "generate_list_candidates",
                "attach_evidence_status",
                "sanitize_purchase_claims",
                "build_response",
            ],
            "pantry_context_count": len(request.pantry_context),
            "finance_context_count": len(request.finance_context),
            "wardrobe_context_count": len(request.wardrobe_context),
            "homememory_context_count": len(request.homememory_context),
        },
    )


def _build_local_product_evidence_card(request: ProductEvidenceRequest) -> ProductEvidenceCard:
    return ProductEvidenceCard(
        id=f"evidence-{uuid4()}",
        user_id=request.user_id,
        product_name=request.product_name,
        brand=None,
        merchant_name=request.merchant_name,
        price=None,
        currency=None,
        source=None,
        checked_at_iso=None,
        review_summary="Local-first product evidence only. External shopping claims stay blocked.",
        sustainability_status="insufficient_verified_data",
        confidence=0.42,
        disclaimer="No price, availability, or sustainability claim is shown without verified evidence.",
        trace={"clientFallback": True},
    )


def _local_evidence_for_need(
    need: ShoppingNeed,
    *,
    pantry_names: set[str],
) -> ProductEvidenceCard:
    review_summary = (
        "An existing pantry item may already cover this need."
        if _matches_existing_item(need.title, pantry_names)
        else "Local context did not verify price, availability, or sustainability."
    )
    return ProductEvidenceCard(
        id=f"evidence-{need.need_id}",
        user_id=need.user_id,
        product_name=need.title,
        brand=None,
        merchant_name=None,
        price=None,
        currency=need.currency,
        source=None,
        checked_at_iso=None,
        review_summary=review_summary,
        sustainability_status="insufficient_verified_data",
        confidence=0.46,
        disclaimer="No price, availability, or sustainability claim is shown without verified evidence.",
        trace={"clientFallback": True},
    )


def _local_decision_for_need(
    *,
    request: ShoppingPlanRequest,
    need: ShoppingNeed,
    pantry_names: set[str],
) -> DecisionCard:
    use_existing_first = _matches_existing_item(need.title, pantry_names)
    title = f"Review {need.title} before adding a purchase"
    recommended_action = (
        "Use an existing pantry item first, then confirm whether a purchase is still needed."
        if use_existing_first
        else "Check local pantry, budget, and home context before confirming this purchase."
    )
    return DecisionCard(
        decision_id=f"shopping-decision-{need.need_id}",
        user_id=request.user_id,
        title=title,
        recommended_action=recommended_action,
        alternatives=[
            "Postpone and create a reminder",
            "Keep the need local-only for now",
        ],
        domain_targets=[need.source_domain, "shopping"],  # type: ignore[list-item]
        source_items=[need.need_id],
        evidence=[
            SuggestionEvidence(
                source_domain=need.source_domain,  # type: ignore[arg-type]
                entity_id=need.need_id,
                claim=(
                    "Existing pantry context can satisfy part of the need."
                    if use_existing_first
                    else "No verified external evidence is available, so the plan stays local-first."
                ),
                confidence=0.62,
            )
        ],
        confidence=0.58,
        uncertainty="External source claims are blocked until verified evidence exists.",
        privacy_summary=_shopping_privacy_summary(request=request, sent_count=len(request.shopping_needs)),
        confirmation_required=True,
        action_contract=ActionContract(
            action_type="confirm_shopping_need",
            requires_confirmation=True,
            destructive=False,
            external=False,
            payload_preview={"need_id": need.need_id},
            forbidden_actions=["external_action_without_confirmation"],
        ),
        status="shown",
        evidence_status="insufficient_verified_data",
        ranking_score=need.urgency_score,
        created_at_iso=_utcnow_iso(),
        updated_at_iso=_utcnow_iso(),
        trace={
            "clientFallback": True,
            "preferred_existing_items": use_existing_first,
        },
    )


def _shopping_privacy_summary(
    *,
    request: ShoppingPlanRequest,
    sent_count: int,
) -> PrivacySummary:
    allowed_domains = list(dict.fromkeys(request.privacy_settings.allowed_domains))
    return PrivacySummary(
        ai_enabled=request.privacy_settings.ai_enabled,
        sent_event_count=sent_count,
        blocked_event_count=0,
        allowed_domains=allowed_domains,  # type: ignore[arg-type]
        blocked_domains=[],  # type: ignore[arg-type]
        local_only_collections=["pantry", "homememory", "journal_entries"],
        trace={
            "pantry_context_count": len(request.pantry_context),
            "finance_context_count": len(request.finance_context),
            "wardrobe_context_count": len(request.wardrobe_context),
            "homememory_context_count": len(request.homememory_context),
        },
    )


def _context_names(items: list[dict[str, Any]]) -> set[str]:
    names: set[str] = set()
    for item in items:
        for key in ("name", "title", "label", "product_name"):
            value = item.get(key)
            if value is None:
                continue
            normalized = str(value).strip().lower()
            if normalized:
                names.add(normalized)
    return names


def _matches_existing_item(title: str, pantry_names: set[str]) -> bool:
    normalized = title.lower()
    return any(name in normalized or normalized in name for name in pantry_names)


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
