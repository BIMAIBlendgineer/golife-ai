from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field

UserPlan = Literal["free", "plus", "internal"]
UserStatus = Literal["active", "paused", "trial"]
FeedbackStatus = Literal["useful", "accepted", "completed", "rejected", "edited"]
SafetySeverity = Literal["low", "medium", "high"]
RequestType = Literal["export", "delete"]


class DashboardMetrics(BaseModel):
    dau: int = Field(ge=0)
    wau: int = Field(ge=0)
    new_users_7d: int = Field(ge=0)
    useful_missions_per_active_user_week: float = Field(ge=0.0)
    mission_completion_rate: float = Field(ge=0.0, le=1.0)
    recommendation_usefulness_rate: float = Field(ge=0.0, le=1.0)
    rejection_rate: float = Field(ge=0.0, le=1.0)
    capture_events_per_active_user: float = Field(ge=0.0)
    fallback_rate: float = Field(ge=0.0, le=1.0)
    ai_latency_ms_avg: float = Field(ge=0.0)
    ai_cost_total_usd: float = Field(ge=0.0)
    ai_cost_per_active_user_usd: float = Field(ge=0.0)
    safety_intervention_rate: float = Field(ge=0.0, le=1.0)
    privacy_concern_rate: float = Field(ge=0.0, le=1.0)


class AdminUser(BaseModel):
    user_id: str = Field(min_length=1)
    email: str = Field(min_length=3)
    plan: UserPlan
    status: UserStatus
    created_at: datetime
    last_seen_at: datetime
    weekly_active: bool = True
    ai_calls: int = Field(ge=0)
    useful_missions_completed: int = Field(ge=0)
    support_flags: list[str] = Field(default_factory=list)
    export_requested: bool = False
    delete_requested: bool = False


class UsageSnapshot(BaseModel):
    user_id: str = Field(min_length=1)
    capture_events: int = Field(ge=0)
    missions_generated: int = Field(ge=0)
    missions_completed: int = Field(ge=0)
    fallback_rate: float = Field(ge=0.0, le=1.0)
    latency_ms_avg: float = Field(ge=0.0)
    last_active_at: datetime


class AICostSnapshot(BaseModel):
    endpoint: str = Field(min_length=1)
    provider: str = Field(min_length=1)
    requests: int = Field(ge=0)
    estimated_cost_usd: float = Field(ge=0.0)
    avg_latency_ms: float = Field(ge=0.0)
    fallback_rate: float = Field(ge=0.0, le=1.0)


class MissionAuditRecord(BaseModel):
    mission_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    title: str = Field(min_length=1)
    status: Literal["generated", "accepted", "completed", "rejected"]
    usefulness: FeedbackStatus | None = None
    domains: list[str] = Field(default_factory=list)
    matched_risks: list[str] = Field(default_factory=list)
    final_score: float = Field(ge=0.0)


class FeedbackAuditRecord(BaseModel):
    feedback_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    suggestion_id: str = Field(min_length=1)
    status: FeedbackStatus
    reason: str | None = None
    domains: list[str] = Field(default_factory=list)
    created_at: datetime


class SafetyAuditRecord(BaseModel):
    event_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    category: str = Field(min_length=1)
    rule: str = Field(min_length=1)
    severity: SafetySeverity
    created_at: datetime


class FeatureFlag(BaseModel):
    key: str = Field(min_length=1)
    enabled: bool = False
    description: str = Field(min_length=1)
    updated_at: datetime


class FeatureFlagPatch(BaseModel):
    enabled: bool


class ModelSettingsSnapshot(BaseModel):
    active_provider: str = Field(min_length=1)
    primary_model: str = Field(min_length=1)
    fallback_model: str = Field(min_length=1)
    classification_model: str = Field(min_length=1)
    weekly_summary_model: str = Field(min_length=1)


class SupportRequest(BaseModel):
    request_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    request_type: RequestType
    status: Literal["open", "done"]
    requested_at: datetime

