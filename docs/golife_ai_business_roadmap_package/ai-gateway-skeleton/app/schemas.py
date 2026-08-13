from __future__ import annotations

from datetime import datetime
from enum import Enum
from typing import Any

from pydantic import BaseModel, ConfigDict, Field, model_validator


class Domain(str, Enum):
    TASK = "task"
    HABIT = "habit"
    MONEY = "money"
    PANTRY = "pantry"
    WARDROBE = "wardrobe"
    PLANNING = "planning"
    SYSTEM = "system"


class EventSource(str, Enum):
    MANUAL = "manual"
    AI = "ai"
    IMPORT = "import"
    INTEGRATION = "integration"


class PrivacyLevel(str, Enum):
    NORMAL = "normal"
    SENSITIVE = "sensitive"
    HIGHLY_SENSITIVE = "highly_sensitive"


class RiskLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"


class RecommendationType(str, Enum):
    DAILY_MISSION = "daily_mission"
    TASK_FIX = "task_fix"
    SPENDING_INSIGHT = "spending_insight"
    PANTRY_PLAN = "pantry_plan"
    NO_BUY = "no_buy"


class PrivacySettings(BaseModel):
    model_config = ConfigDict(use_enum_values=True)

    ai_enabled: bool = True
    allowed_domains: list[Domain] = Field(
        default_factory=lambda: [
            Domain.TASK,
            Domain.HABIT,
            Domain.MONEY,
            Domain.PANTRY,
            Domain.WARDROBE,
            Domain.PLANNING,
        ]
    )


class LifeEvent(BaseModel):
    model_config = ConfigDict(use_enum_values=True)

    id: str
    user_id: str
    domain: Domain
    event_type: str
    occurred_at: datetime
    payload: dict[str, Any] = Field(default_factory=dict)
    source: EventSource = EventSource.MANUAL
    confidence: float | None = Field(default=None, ge=0, le=1)
    privacy_level: PrivacyLevel = PrivacyLevel.NORMAL


class BaseAIRequest(BaseModel):
    model_config = ConfigDict(use_enum_values=True)

    user_id: str
    privacy: PrivacySettings = Field(default_factory=PrivacySettings)
    events: list[LifeEvent] = Field(default_factory=list)
    constraints: dict[str, Any] = Field(default_factory=dict)


class DailyPlanRequest(BaseAIRequest):
    goals: list[str] = Field(default_factory=list)
    date: str | None = None


class TaskDiagnosisRequest(BaseAIRequest):
    task_text: str
    blockers: list[str] = Field(default_factory=list)


class SpendingInsightRequest(BaseAIRequest):
    period: str = "week"
    budget_limit: float | None = None


class PantryPlanRequest(BaseAIRequest):
    available_minutes: int = 20


class WardrobeNoBuyRequest(BaseAIRequest):
    purchase_intent: str


class ClassifyEventRequest(BaseModel):
    text: str
    hints: dict[str, Any] = Field(default_factory=dict)


class SafetySummary(BaseModel):
    allowed: bool = True
    reasons: list[str] = Field(default_factory=list)
    requires_confirmation: bool = False


class TraceStep(BaseModel):
    node: str
    detail: str
    at: datetime


class AITrace(BaseModel):
    model_config = ConfigDict(use_enum_values=True)

    trace_id: str
    operation: str
    domain: str
    agent: str
    provider: str
    used_fallback: bool = False
    safety: SafetySummary = Field(default_factory=SafetySummary)
    life_context: list[str] = Field(default_factory=list)
    steps: list[TraceStep] = Field(default_factory=list)


class AIRecommendation(BaseModel):
    model_config = ConfigDict(use_enum_values=True)

    id: str
    type: RecommendationType
    title: str
    summary: str
    evidence: list[str] = Field(default_factory=list)
    uncertainty: list[str] = Field(default_factory=list)
    action_minimum: str
    explanation: str | None = None
    risk_level: RiskLevel = RiskLevel.LOW
    domain_links: list[Domain | str] = Field(default_factory=list)
    requires_user_confirmation: bool = False


class BaseAIResponse(BaseModel):
    recommendations: list[AIRecommendation] = Field(default_factory=list)
    risks: list[str] = Field(default_factory=list)
    blocked_items: list[str] = Field(default_factory=list)
    estimated_effort_minutes: int | None = None
    trace: AITrace
    mock: bool = False


class DayPlanResponse(BaseAIResponse):
    date: str
    missions: list[AIRecommendation] = Field(default_factory=list)
    plan_realism_score: float = Field(ge=0, le=1)

    @model_validator(mode="after")
    def sync_missions(self) -> "DayPlanResponse":
        if not self.missions and self.recommendations:
            self.missions = list(self.recommendations)
        if not self.recommendations and self.missions:
            self.recommendations = list(self.missions)
        return self


class TaskDiagnosisResponse(BaseAIResponse):
    task: str
    diagnosis: str


class SpendingInsightResponse(BaseAIResponse):
    period: str


class PantryPlanResponse(BaseAIResponse):
    servings: int | None = None


class WardrobeNoBuyResponse(BaseAIResponse):
    purchase_intent: str


class ClassifyEventResponse(BaseModel):
    model_config = ConfigDict(use_enum_values=True)

    domain: Domain
    event_type: str
    confidence: float = Field(ge=0, le=1)
    rationale: str


class FeedbackRequest(BaseModel):
    user_id: str
    recommendation_id: str
    useful: bool
    notes: str | None = None


class FeedbackResponse(BaseModel):
    status: str
    stored: bool


class HealthResponse(BaseModel):
    status: str
    service: str
    providers: list[str]
