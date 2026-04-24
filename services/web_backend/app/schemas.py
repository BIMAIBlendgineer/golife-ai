from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, Field

UserPlan = Literal["free", "plus", "internal"]
UserStatus = Literal["active", "paused", "trial"]
FeedbackStatus = Literal["useful", "accepted", "completed", "rejected", "edited"]
SafetySeverity = Literal["low", "medium", "high"]
RequestType = Literal["export", "delete"]
DataMode = Literal["live", "seeded"]
InvocationStatus = Literal["success", "error"]
RoutingCapability = Literal[
    "daily_plan",
    "task_rewrite",
    "semantic_classify",
    "weekly_summary",
]
RoutingConfigSource = Literal["live", "cached", "fallback"]
OpenRouterKeyStatus = Literal["healthy", "degraded", "disabled", "unknown"]
OpenRouterKeyEventType = Literal["success", "failure", "disabled", "enabled", "created"]


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
    active_key_count: int = Field(default=0, ge=0)
    disabled_key_count: int = Field(default=0, ge=0)
    routing_snapshot_age_seconds: int | None = Field(default=None, ge=0)


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


class AdminHealth(BaseModel):
    status: Literal["ok"]
    data_source: str = Field(min_length=1)
    mode: DataMode
    storage_path: str = Field(min_length=1)
    last_ingestion_at: datetime | None = None


class UsageEventRecord(BaseModel):
    event_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    event_type: str = Field(min_length=1)
    endpoint: str | None = None
    domain: str | None = None
    quantity: int = Field(default=1, ge=1)
    created_at: datetime
    metadata: dict[str, Any] = Field(default_factory=dict)


class AIInvocationRecord(BaseModel):
    invocation_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    endpoint: str = Field(min_length=1)
    provider: str = Field(min_length=1)
    model: str | None = None
    latency_ms: float = Field(ge=0.0)
    fallback: bool = False
    suggestions_count: int = Field(default=0, ge=0)
    estimated_cost_usd: float = Field(default=0.0, ge=0.0)
    schema_valid: bool = True
    status: InvocationStatus = "success"
    created_at: datetime
    metadata: dict[str, Any] = Field(default_factory=dict)


class MissionAuditUpsert(BaseModel):
    mission_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    title: str = Field(min_length=1)
    status: Literal["generated", "accepted", "completed", "rejected"]
    usefulness: FeedbackStatus | None = None
    domains: list[str] = Field(default_factory=list)
    matched_risks: list[str] = Field(default_factory=list)
    final_score: float = Field(ge=0.0)
    created_at: datetime


class FeedbackAuditUpsert(BaseModel):
    feedback_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    suggestion_id: str = Field(min_length=1)
    status: FeedbackStatus
    reason: str | None = None
    domains: list[str] = Field(default_factory=list)
    created_at: datetime


class SafetyAuditUpsert(BaseModel):
    event_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    category: str = Field(min_length=1)
    rule: str = Field(min_length=1)
    severity: SafetySeverity
    endpoint: str | None = None
    created_at: datetime


class ModelSettingsUpsert(BaseModel):
    active_provider: str = Field(min_length=1)
    primary_model: str = Field(min_length=1)
    fallback_model: str = Field(min_length=1)
    classification_model: str = Field(min_length=1)
    weekly_summary_model: str = Field(min_length=1)


class OpenRouterApiKeyRecord(BaseModel):
    key_id: str = Field(min_length=1)
    label: str = Field(min_length=1)
    secret_last4: str = Field(min_length=4, max_length=4)
    enabled: bool = True
    priority: int = Field(ge=0)
    status: OpenRouterKeyStatus = "unknown"
    last_ok_at: datetime | None = None
    last_error_at: datetime | None = None
    consecutive_failures: int = Field(default=0, ge=0)
    created_at: datetime
    updated_at: datetime


class OpenRouterApiKeyCreate(BaseModel):
    label: str = Field(min_length=1)
    secret: str = Field(min_length=16)
    enabled: bool = True
    priority: int = Field(default=0, ge=0)


class OpenRouterApiKeyPatch(BaseModel):
    label: str | None = Field(default=None, min_length=1)
    secret: str | None = Field(default=None, min_length=16)
    enabled: bool | None = None
    priority: int | None = Field(default=None, ge=0)


class RoutingProfile(BaseModel):
    capability: RoutingCapability
    strategy: Literal["quality_first"]
    min_context_length: int = Field(ge=1)
    required_parameters: list[str] = Field(default_factory=list)
    preferred_max_latency_seconds: float = Field(ge=0.0)
    preferred_min_throughput_tokens_per_second: float = Field(ge=0.0)
    max_prompt_price_usd_per_million: float | None = Field(default=None, ge=0.0)
    max_completion_price_usd_per_million: float | None = Field(default=None, ge=0.0)
    retry_policy: dict[str, int] = Field(default_factory=dict)
    enabled: bool = True
    updated_at: datetime


class RoutingProfilePatch(BaseModel):
    strategy: Literal["quality_first"] | None = None
    min_context_length: int | None = Field(default=None, ge=1)
    required_parameters: list[str] | None = None
    preferred_max_latency_seconds: float | None = Field(default=None, ge=0.0)
    preferred_min_throughput_tokens_per_second: float | None = Field(default=None, ge=0.0)
    max_prompt_price_usd_per_million: float | None = Field(default=None, ge=0.0)
    max_completion_price_usd_per_million: float | None = Field(default=None, ge=0.0)
    retry_policy: dict[str, int] | None = None
    enabled: bool | None = None


class ModelCatalogEntry(BaseModel):
    model_id: str = Field(min_length=1)
    canonical_slug: str | None = None
    name: str = Field(min_length=1)
    description: str | None = None
    context_length: int = Field(ge=1)
    output_modalities: list[str] = Field(default_factory=list)
    supported_parameters: list[str] = Field(default_factory=list)
    prompt_price_usd_per_million: float = Field(ge=0.0)
    completion_price_usd_per_million: float = Field(ge=0.0)
    request_price_usd: float = Field(default=0.0, ge=0.0)
    top_provider_json: dict[str, Any] = Field(default_factory=dict)
    architecture_json: dict[str, Any] = Field(default_factory=dict)
    expiration_date: datetime | None = None
    refreshed_at: datetime


class ModelSelectionSnapshot(BaseModel):
    capability: RoutingCapability
    rank_index: int = Field(ge=0, le=2)
    model_id: str = Field(min_length=1)
    score: float = Field(ge=0.0)
    selection_reason: dict[str, Any] = Field(default_factory=dict)
    generated_at: datetime
    expires_at: datetime


class OpenRouterKeyEventRecord(BaseModel):
    event_id: str = Field(min_length=1)
    key_id: str = Field(min_length=1)
    key_label: str = Field(min_length=1)
    event_type: OpenRouterKeyEventType
    endpoint: str | None = None
    model: str | None = None
    error_code: str | None = None
    notes: str | None = None
    created_at: datetime


class OpenRouterKeyEventUpsert(BaseModel):
    event_id: str = Field(min_length=1)
    key_id: str = Field(min_length=1)
    key_label: str = Field(min_length=1)
    event_type: OpenRouterKeyEventType
    endpoint: str | None = None
    model: str | None = None
    error_code: str | None = None
    notes: str | None = None
    created_at: datetime


class GatewayRoutingKey(BaseModel):
    key_id: str = Field(min_length=1)
    label: str = Field(min_length=1)
    secret: str = Field(min_length=16)
    priority: int = Field(ge=0)
    status: OpenRouterKeyStatus


class InternalRoutingConfig(BaseModel):
    config_source: RoutingConfigSource = "live"
    generated_at: datetime
    openrouter_keys: list[GatewayRoutingKey] = Field(default_factory=list)
    routing_profiles: list[RoutingProfile] = Field(default_factory=list)
    selection_snapshots: list[ModelSelectionSnapshot] = Field(default_factory=list)
    feature_flags: dict[str, bool] = Field(default_factory=dict)


class MobileRuntimeConfig(BaseModel):
    schema_version: int = Field(default=1, ge=1)
    ttl_seconds: int = Field(default=21600, ge=300)
    gateway_base_url: str = Field(min_length=1)
    feature_flags: dict[str, bool] = Field(default_factory=dict)
    friendly_copy: dict[str, str] = Field(default_factory=dict)
    ai_status: dict[str, Any] = Field(default_factory=dict)
    generated_at: datetime

