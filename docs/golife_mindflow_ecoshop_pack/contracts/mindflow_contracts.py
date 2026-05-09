from __future__ import annotations

from typing import Any, Literal

from pydantic import BaseModel, Field

PrivacyLevel = Literal["local_only", "sync_allowed", "ai_allowed"]

Domain = Literal[
    "task",
    "habit",
    "week",
    "finance",
    "pantry",
    "wardrobe",
    "mission",
    "system",
    "calendar",
    "journal",
    "recipe",
    "homememory",
    "shopping",
    "decision",
]

MentalLoadItemType = Literal[
    "task",
    "reminder",
    "decision",
    "shopping",
    "document",
    "calendar",
    "money",
    "home_memory",
    "meal",
    "note",
]

MentalLoadState = Literal[
    "inbox",
    "parsed",
    "needs_confirmation",
    "scheduled",
    "accepted",
    "done",
    "dismissed",
]

DecisionStatus = Literal[
    "draft",
    "shown",
    "accepted",
    "done",
    "postponed",
    "rejected",
]

EvidenceStatus = Literal[
    "verified",
    "partial",
    "local_only",
    "insufficient_verified_data",
    "not_checked",
]

ShoppingNeedType = Literal[
    "pantry_restock",
    "meal_gap",
    "replacement",
    "wardrobe_intention",
    "home_item",
    "maintenance_supply",
]


class PrivacySettings(BaseModel):
    ai_enabled: bool = True
    allowed_domains: list[Domain] = Field(default_factory=list)
    allow_cross_domain_patterns: bool = True


class SuggestionEvidence(BaseModel):
    source_domain: Domain
    entity_id: str | None = None
    claim: str = Field(min_length=1)
    confidence: float = Field(ge=0.0, le=1.0)


class MissionRanking(BaseModel):
    impact_score: float = Field(ge=0.0, le=1.0)
    urgency_score: float = Field(ge=0.0, le=1.0)
    effort_score: float = Field(ge=0.0, le=1.0)
    confidence_score: float = Field(ge=0.0, le=1.0)
    privacy_score: float = Field(ge=0.0, le=1.0)
    feedback_score: float = Field(ge=0.0, le=1.0)
    novelty_score: float = Field(ge=0.0, le=1.0)
    final_score: float = Field(ge=0.0, le=1.0)
    ranking_reason: str = Field(min_length=1)
    evidence_refs: list[str] = Field(default_factory=list)


class PrivacySummary(BaseModel):
    ai_enabled: bool
    sent_event_count: int = Field(ge=0)
    blocked_event_count: int = Field(ge=0)
    allowed_domains: list[Domain] = Field(default_factory=list)
    blocked_domains: list[Domain] = Field(default_factory=list)
    local_only_collections: list[str] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)


class ActionContract(BaseModel):
    action_type: str
    requires_confirmation: bool = True
    destructive: bool = False
    external: bool = False
    payload_preview: dict[str, Any] = Field(default_factory=dict)
    forbidden_actions: list[str] = Field(
        default_factory=lambda: ["external_action_without_confirmation"]
    )


class MentalLoadItem(BaseModel):
    item_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    source_event_id: str | None = None
    type: MentalLoadItemType
    domain: Domain
    title: str = Field(min_length=1)
    summary: str = Field(min_length=1)
    urgency_score: float = Field(ge=0.0, le=1.0)
    effort_score: float = Field(ge=0.0, le=1.0)
    confidence: float = Field(ge=0.0, le=1.0)
    state: MentalLoadState = "inbox"
    due_hint: str | None = None
    amount_hint: float | None = None
    currency_hint: str | None = None
    evidence_refs: list[str] = Field(default_factory=list)
    privacy_level: PrivacyLevel
    requires_confirmation: bool = True
    trace: dict[str, Any] = Field(default_factory=dict)


class DecisionCard(BaseModel):
    decision_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    title: str = Field(min_length=1)
    recommended_action: str = Field(min_length=1)
    alternatives: list[str] = Field(default_factory=list)
    domain_targets: list[Domain] = Field(default_factory=list)
    source_items: list[str] = Field(default_factory=list)
    evidence: list[SuggestionEvidence] = Field(default_factory=list)
    ranking: MissionRanking | None = None
    confidence: float = Field(ge=0.0, le=1.0)
    uncertainty: str = Field(min_length=1)
    privacy_summary: PrivacySummary
    confirmation_required: bool = True
    action_contract: ActionContract
    status: DecisionStatus = "draft"


class MindFlowParseRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    text: str = Field(min_length=1)
    privacy_settings: PrivacySettings = Field(default_factory=PrivacySettings)


class MindFlowParseResponse(BaseModel):
    items: list[MentalLoadItem] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)


class DecisionPlanRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    mental_load_items: list[MentalLoadItem] = Field(default_factory=list)
    privacy_settings: PrivacySettings = Field(default_factory=PrivacySettings)
    constraints: dict[str, Any] = Field(default_factory=dict)
    max_decisions: int = Field(default=3, ge=1, le=3)


class DecisionPlanResponse(BaseModel):
    decisions: list[DecisionCard] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)


class ShoppingNeed(BaseModel):
    need_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    need_type: ShoppingNeedType
    title: str = Field(min_length=1)
    source_domain: Domain
    source_event_ids: list[str] = Field(default_factory=list)
    urgency_score: float = Field(ge=0.0, le=1.0)
    budget_hint: float | None = None
    currency: str | None = None
    sustainability_preference: str | None = None
    state: Literal["draft", "confirmed", "shopping_list", "dismissed"] = "draft"


class ProductEvidenceCard(BaseModel):
    product_name: str = Field(min_length=1)
    brand: str | None = None
    merchant_name: str | None = None
    price: float | None = None
    currency: str | None = None
    source: str | None = None
    checked_at: str | None = None
    review_summary: str | None = None
    sustainability_status: EvidenceStatus = "not_checked"
    confidence: float = Field(ge=0.0, le=1.0)
    disclaimer: str = Field(min_length=1)
    trace: dict[str, Any] = Field(default_factory=dict)


class ShoppingPlanRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    shopping_needs: list[ShoppingNeed] = Field(default_factory=list)
    pantry_context: list[dict[str, Any]] = Field(default_factory=list)
    finance_context: list[dict[str, Any]] = Field(default_factory=list)
    wardrobe_context: list[dict[str, Any]] = Field(default_factory=list)
    homememory_context: list[dict[str, Any]] = Field(default_factory=list)
    privacy_settings: PrivacySettings = Field(default_factory=PrivacySettings)


class ShoppingPlanResponse(BaseModel):
    needs: list[ShoppingNeed] = Field(default_factory=list)
    product_evidence: list[ProductEvidenceCard] = Field(default_factory=list)
    decisions: list[DecisionCard] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)
