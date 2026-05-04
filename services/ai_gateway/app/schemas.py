from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, Field, model_validator

PrivacyLevel = Literal["local_only", "sync_allowed", "ai_allowed"]
Domain = Literal["task", "habit", "week", "finance", "pantry", "wardrobe", "mission", "system"]
RecommendationType = Literal["mission", "plan_adjustment", "task_rewrite", "warning", "reflection"]
SuggestionStatus = Literal["draft", "shown", "accepted", "rejected", "edited", "expired"]
DayState = Literal["overloaded", "steady", "recovery", "unstructured", "unknown"]
FeedbackStatus = Literal["useful", "rejected", "accepted", "completed", "edited"]
ReflectionSafetyCategory = Literal["supportive", "clinical", "crisis"]
FeedbackRejectionCategory = Literal[
    "too_hard",
    "not_relevant",
    "not_now",
    "privacy",
    "too_generic",
    "already_done",
    "unknown",
]
EffortFeedback = Literal["low", "balanced", "high", "unknown"]


class PrivacySettings(BaseModel):
    ai_enabled: bool = True
    allowed_domains: list[Domain] = Field(default_factory=list)
    allow_cross_domain_patterns: bool = True


class DomainSummary(BaseModel):
    domain: Domain
    summary: str = Field(min_length=1)
    evidence_count: int = Field(default=0, ge=0)
    ai_allowed: bool = True


class LifeEvent(BaseModel):
    event_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    domain: Domain
    event_type: str = Field(min_length=1)
    timestamp: datetime
    payload: dict[str, Any] = Field(default_factory=dict)
    source: Literal["manual", "import", "ai", "system"]
    privacy_level: PrivacyLevel
    evidence_hash: str | None = None


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


class AISuggestion(BaseModel):
    suggestion_id: str = Field(min_length=1)
    title: str = Field(min_length=1)
    domain_targets: list[Domain] = Field(default_factory=list)
    recommendation_type: RecommendationType
    body: str = Field(min_length=1)
    evidence: list[SuggestionEvidence] = Field(default_factory=list)
    confidence: float = Field(ge=0.0, le=1.0)
    uncertainty: str = Field(min_length=1)
    requires_confirmation: bool = True
    forbidden_actions: list[str] = Field(default_factory=list)
    status: SuggestionStatus = "draft"
    ranking: MissionRanking | None = None


class SuggestionRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    scope: Literal["daily", "weekly", "domain"] = "daily"
    allowed_domains: list[Domain] = Field(default_factory=list)
    life_events: list[LifeEvent] = Field(default_factory=list)
    privacy_settings: PrivacySettings = Field(default_factory=PrivacySettings)
    domain_summaries: list[DomainSummary] = Field(default_factory=list)
    constraints: dict[str, Any] = Field(default_factory=dict)
    max_suggestions: int = Field(default=3, ge=1, le=3)

    @model_validator(mode="after")
    def merge_allowed_domains(self) -> "SuggestionRequest":
        if self.allowed_domains and not self.privacy_settings.allowed_domains:
            self.privacy_settings.allowed_domains = list(dict.fromkeys(self.allowed_domains))
        return self


class SuggestionResponse(BaseModel):
    suggestions: list[AISuggestion] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)


class EventClassificationRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    text: str = Field(min_length=1)
    privacy_settings: PrivacySettings = Field(default_factory=PrivacySettings)


class EventClassificationResponse(BaseModel):
    domain: Domain
    event_type: str = Field(min_length=1)
    confidence: float = Field(ge=0.0, le=1.0)
    rationale: str = Field(min_length=1)
    trace: dict[str, Any] = Field(default_factory=dict)


class ParsedEventItem(BaseModel):
    text: str = Field(min_length=1)
    domain: Domain
    event_type: str = Field(min_length=1)
    confidence: float = Field(ge=0.0, le=1.0)
    rationale: str = Field(min_length=1)
    hints: dict[str, Any] = Field(default_factory=dict)


class EventParseRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    text: str = Field(min_length=1)
    privacy_settings: PrivacySettings = Field(default_factory=PrivacySettings)


class EventParseResponse(BaseModel):
    items: list[ParsedEventItem] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)


class ProofParseRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    region: str | None = None
    text: str = Field(min_length=1)
    privacy_settings: PrivacySettings = Field(default_factory=PrivacySettings)


class ProofParseResponse(BaseModel):
    product_name: str | None = None
    brand: str | None = None
    model: str | None = None
    merchant_name: str | None = None
    purchase_date: str | None = None
    total_amount: float | None = None
    currency: str | None = None
    warranty_months: int | None = None
    confidence: float = Field(ge=0.0, le=1.0)
    rationale: str = Field(min_length=1)
    disclaimer: str = Field(min_length=1)
    trace: dict[str, Any] = Field(default_factory=dict)


class TaskRewriteRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    task_title: str = Field(min_length=1)
    task_description: str | None = None
    privacy_level: PrivacyLevel = "local_only"
    constraints: dict[str, Any] = Field(default_factory=dict)


class TaskRewriteStep(BaseModel):
    title: str = Field(min_length=1)
    reason: str = Field(min_length=1)
    estimated_minutes: int = Field(ge=1, le=240)
    evidence: list[SuggestionEvidence] = Field(default_factory=list)
    confidence: float = Field(ge=0.0, le=1.0)


class TaskRewriteResponse(BaseModel):
    rewrites: list[TaskRewriteStep] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)


class MissionFeedbackRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    suggestion_id: str = Field(min_length=1)
    status: FeedbackStatus
    notes: str | None = None
    domain_targets: list[Domain] = Field(default_factory=list)
    recommendation_type: RecommendationType | None = None
    rejection_reason_category: FeedbackRejectionCategory | None = None
    effort_feedback: EffortFeedback | None = None
    repeated_flag: bool = False
    timestamp: datetime | None = None
    trace: dict[str, Any] = Field(default_factory=dict)


class MissionFeedbackResponse(BaseModel):
    stored: bool = True
    feedback_id: str = Field(min_length=1)
    trace: dict[str, Any] = Field(default_factory=dict)


class ReflectionSafetyRequest(BaseModel):
    user_id: str = Field(min_length=1)
    locale: str = "en"
    text: str = Field(min_length=1)
    privacy_level: PrivacyLevel = "local_only"


class ReflectionSupportResource(BaseModel):
    label: str = Field(min_length=1)
    contact: str = Field(min_length=1)
    description: str = Field(min_length=1)
    region: str = Field(min_length=1)


class ReflectionSafetyResponse(BaseModel):
    safe: bool = True
    category: ReflectionSafetyCategory
    message: str = Field(min_length=1)
    resources: list[ReflectionSupportResource] = Field(default_factory=list)
    trace: dict[str, Any] = Field(default_factory=dict)
