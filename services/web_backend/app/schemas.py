from datetime import datetime
from typing import Any, Generic, Literal, TypeVar

from pydantic import BaseModel, Field

UserPlan = Literal["free", "plus", "internal"]
UserStatus = Literal["active", "paused", "trial"]
FeedbackStatus = Literal["useful", "accepted", "completed", "rejected", "edited"]
SafetySeverity = Literal["low", "medium", "high"]
RequestType = Literal["export", "delete"]
DataMode = Literal["live", "seeded"]
InvocationStatus = Literal["success", "error"]
PrivacyRequestStatus = Literal[
    "none",
    "export_open",
    "delete_open",
    "mixed_open",
    "completed",
]
RoutingCapability = Literal[
    "daily_plan",
    "task_rewrite",
    "semantic_classify",
    "weekly_summary",
    "mindflow_parse",
    "decision_plan",
    "shopping_plan",
    "product_evidence",
]
RoutingConfigSource = Literal["live", "cached", "fallback"]
OpenRouterKeyStatus = Literal["healthy", "degraded", "disabled", "unknown"]
OpenRouterKeyEventType = Literal["success", "failure", "disabled", "enabled", "created"]
AdminLocale = Literal["en", "es", "pt-BR", "ja", "zh-Hans"]
MobileBillingMode = Literal["disabled", "google_play_sandbox", "google_play_live"]
MobileBillingProvider = Literal["disabled", "google_play"]
T = TypeVar("T")


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
    mental_load_items_per_active_user: float = Field(ge=0.0)
    decision_acceptance_rate: float = Field(ge=0.0, le=1.0)
    decision_completion_rate: float = Field(ge=0.0, le=1.0)
    decision_postpone_rate: float = Field(ge=0.0, le=1.0)
    shopping_need_conversion_rate: float = Field(ge=0.0, le=1.0)
    shopping_claims_with_evidence_rate: float = Field(ge=0.0, le=1.0)
    insufficient_sustainability_data_rate: float = Field(ge=0.0, le=1.0)
    privacy_filtered_decision_rate: float = Field(ge=0.0, le=1.0)
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


class UserManagementRow(BaseModel):
    user_id: str = Field(min_length=1)
    display_name: str = Field(min_length=1)
    email_masked: str = Field(min_length=3)
    plan: UserPlan
    status: UserStatus
    locale: AdminLocale = "en"
    last_seen_at: datetime
    ai_calls_count: int = Field(ge=0)
    useful_missions_count: int = Field(ge=0)
    fallback_rate: float = Field(ge=0.0, le=1.0)
    support_flags: list[str] = Field(default_factory=list)
    privacy_request_status: PrivacyRequestStatus = "none"


class UserSummary(BaseModel):
    user_id: str = Field(min_length=1)
    display_name: str = Field(min_length=1)
    email_masked: str = Field(min_length=3)
    plan: UserPlan
    status: UserStatus
    locale: AdminLocale = "en"
    created_at: datetime
    last_seen_at: datetime
    organization_id: str | None = None
    support_flags: list[str] = Field(default_factory=list)
    privacy_request_status: PrivacyRequestStatus = "none"


class UserUsageSummary(BaseModel):
    user_id: str = Field(min_length=1)
    capture_events: int = Field(ge=0)
    missions_generated: int = Field(ge=0)
    missions_completed: int = Field(ge=0)
    ai_calls_count: int = Field(ge=0)
    fallback_rate: float = Field(ge=0.0, le=1.0)
    latency_ms_avg: float = Field(ge=0.0)


class UserPrivacySummary(BaseModel):
    user_id: str = Field(min_length=1)
    privacy_request_status: PrivacyRequestStatus = "none"
    open_requests: list[RequestType] = Field(default_factory=list)
    encrypted_collections: list[str] = Field(default_factory=list)
    sensitive_data_excluded: bool = True


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


class UserSupportSummary(BaseModel):
    user_id: str = Field(min_length=1)
    support_flags: list[str] = Field(default_factory=list)
    open_request_count: int = Field(ge=0)
    requests: list[SupportRequest] = Field(default_factory=list)


class OrganizationRow(BaseModel):
    organization_id: str = Field(min_length=1)
    name: str = Field(min_length=1)
    status: Literal["active", "trial", "paused"]
    plan: str = Field(min_length=1)
    user_count: int = Field(ge=0)
    storage_used_gb: float = Field(ge=0.0)
    ai_mode_default: Literal["xinsightai", "byok", "hybrid"]
    created_at: datetime


class OrganizationDetail(OrganizationRow):
    members: list[UserSummary] = Field(default_factory=list)


class PlanRow(BaseModel):
    plan_id: str = Field(min_length=1)
    name: str = Field(min_length=1)
    price_label: str = Field(min_length=1)
    user_limit: int = Field(ge=1)
    storage_limit_gb: float = Field(ge=0.0)
    ai_credit_policy: str = Field(min_length=1)
    byok_allowed: bool = False
    support_level: str = Field(min_length=1)


class OpenRouterByokKeyRecord(BaseModel):
    key_id: str = Field(min_length=1)
    organization_id: str = Field(min_length=1)
    project_id: str | None = None
    label: str = Field(min_length=1)
    secret_last4: str = Field(min_length=4, max_length=4)
    status: OpenRouterKeyStatus = "unknown"
    created_at: datetime
    last_used_at: datetime | None = None
    disabled_at: datetime | None = None
    scopes: list[str] = Field(default_factory=list)


class OpenRouterByokKeyCreate(BaseModel):
    organization_id: str = Field(min_length=1)
    project_id: str | None = None
    label: str = Field(min_length=1)
    secret: str = Field(min_length=16)
    scopes: list[str] = Field(default_factory=list)


class OpenRouterByokKeyPatch(BaseModel):
    label: str | None = Field(default=None, min_length=1)
    secret: str | None = Field(default=None, min_length=16)
    project_id: str | None = None
    scopes: list[str] | None = None


class AiUsageLedgerRow(BaseModel):
    id: str = Field(min_length=1)
    organization_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    ai_mode: Literal["xinsightai", "byok", "hybrid"]
    provider: str = Field(min_length=1)
    model: str | None = None
    endpoint: str = Field(min_length=1)
    input_tokens: int = Field(ge=0)
    output_tokens: int = Field(ge=0)
    platform_cost_usd: float = Field(ge=0.0)
    customer_charge_usd: float = Field(ge=0.0)
    xinsight_credits_debited: int = Field(ge=0)
    byok_external_billing: bool = False
    created_at: datetime


class XInsightCreditSummary(BaseModel):
    total_credits_debited: int = Field(ge=0)
    total_customer_charge_usd: float = Field(ge=0.0)
    total_platform_cost_usd: float = Field(ge=0.0)
    byok_request_count: int = Field(ge=0)


class BillingAccountRow(BaseModel):
    organization_id: str = Field(min_length=1)
    organization_name: str = Field(min_length=1)
    plan: str = Field(min_length=1)
    subscription_status: Literal["active", "trial", "paused"]
    storage_charge_usd: float = Field(ge=0.0)
    xinsight_charge_usd: float = Field(ge=0.0)
    byok_key_count: int = Field(ge=0)
    invoice_placeholder: str = Field(min_length=1)


class StorageSummary(BaseModel):
    total_gb: float = Field(ge=0.0)
    billable_gb: float = Field(ge=0.0)
    local_only_gb: float = Field(ge=0.0)
    cloud_gb: float = Field(ge=0.0)
    export_bundle_gb: float = Field(ge=0.0)
    homememory_metadata_count: int = Field(ge=0)
    retention_risk_count: int = Field(ge=0)


class StorageUsageRow(BaseModel):
    organization_id: str = Field(min_length=1)
    organization_name: str = Field(min_length=1)
    plan: str = Field(min_length=1)
    storage_used_gb: float = Field(ge=0.0)
    encrypted_collections: list[str] = Field(default_factory=list)
    retention_risk: bool = False


class PrivacyRequestRow(BaseModel):
    request_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    request_type: RequestType
    status: Literal["open", "done"]
    requested_at: datetime


class PrivacyDataMap(BaseModel):
    encrypted_collections: list[str] = Field(default_factory=list)
    sensitive_data_excluded: bool = True
    retention_notes: list[str] = Field(default_factory=list)


class SecuritySummary(BaseModel):
    environment: str = Field(min_length=1)
    admin_token_configured: bool
    ingestion_token_configured: bool
    internal_service_token_configured: bool
    production_ready: bool
    openrouter_key_count: int = Field(ge=0)
    byok_key_count: int = Field(ge=0)
    latest_audit_at: datetime | None = None
    dependency_scan_status: str = Field(min_length=1)
    failed_auth_placeholder: int = Field(ge=0)


class AuditLogRow(BaseModel):
    audit_id: str = Field(min_length=1)
    actor_id: str = Field(min_length=1)
    action: str = Field(min_length=1)
    target_type: str = Field(min_length=1)
    target_id: str = Field(min_length=1)
    safe_diff: dict[str, Any] = Field(default_factory=dict)
    correlation_id: str = Field(min_length=1)
    created_at: datetime


class HomeMemorySummary(BaseModel):
    proof_parse_count: int = Field(ge=0)
    warranty_reminder_count: int = Field(ge=0)
    claim_draft_count: int = Field(ge=0)
    evidence_attachment_count: int = Field(ge=0)
    parser_success_rate: float = Field(ge=0.0, le=1.0)
    fallback_rate: float = Field(ge=0.0, le=1.0)
    locale_distribution: dict[str, int] = Field(default_factory=dict)
    encrypted_collections: list[str] = Field(default_factory=list)
    storage_impact_estimate: float = Field(ge=0.0)
    sensitive_data_excluded: bool = True


class HomeMemoryParserUsageRow(BaseModel):
    locale: str = Field(min_length=1)
    parser: Literal["deterministic", "semantic", "fallback"]
    requests: int = Field(ge=0)
    success_rate: float = Field(ge=0.0, le=1.0)
    fallback_rate: float = Field(ge=0.0, le=1.0)


class QualitySummary(BaseModel):
    mission_usefulness_rate: float = Field(ge=0.0, le=1.0)
    mission_completion_rate: float = Field(ge=0.0, le=1.0)
    rejection_rate: float = Field(ge=0.0, le=1.0)
    fallback_rate: float = Field(ge=0.0, le=1.0)
    proof_parser_success_rate: float = Field(ge=0.0, le=1.0)
    safety_interventions: int = Field(ge=0)
    high_cost_anomalies: int = Field(ge=0)
    support_escalations: int = Field(ge=0)


class MindFlowSummary(BaseModel):
    mental_load_items_per_active_user: float = Field(ge=0.0)
    decision_acceptance_rate: float = Field(ge=0.0, le=1.0)
    decision_completion_rate: float = Field(ge=0.0, le=1.0)
    decision_postpone_rate: float = Field(ge=0.0, le=1.0)
    privacy_filtered_decision_rate: float = Field(ge=0.0, le=1.0)
    open_loop_count: int = Field(ge=0)
    open_loop_rate: float = Field(ge=0.0, le=1.0)
    fallback_rate: float = Field(ge=0.0, le=1.0)


class MindFlowDecisionQuality(BaseModel):
    generated_count: int = Field(ge=0)
    accepted_count: int = Field(ge=0)
    completed_count: int = Field(ge=0)
    rejected_count: int = Field(ge=0)
    postponed_count: int = Field(ge=0)
    repeated_count: int = Field(ge=0)
    acceptance_rate: float = Field(ge=0.0, le=1.0)
    completion_rate: float = Field(ge=0.0, le=1.0)
    rejection_rate: float = Field(ge=0.0, le=1.0)
    postpone_rate: float = Field(ge=0.0, le=1.0)


class MindFlowOpenLoops(BaseModel):
    total_open_loops: int = Field(ge=0)
    mental_load_items: int = Field(ge=0)
    pending_decisions: int = Field(ge=0)
    pending_shopping_needs: int = Field(ge=0)
    warranty_review_needs: int = Field(ge=0)


class ShoppingSummary(BaseModel):
    shopping_need_conversion_rate: float = Field(ge=0.0, le=1.0)
    shopping_claims_with_evidence_rate: float = Field(ge=0.0, le=1.0)
    insufficient_sustainability_data_rate: float = Field(ge=0.0, le=1.0)
    needs_detected: int = Field(ge=0)
    plans_generated: int = Field(ge=0)
    external_sources_enabled: bool
    product_evidence_enabled: bool


class ShoppingEvidenceQuality(BaseModel):
    verified_count: int = Field(ge=0)
    partial_count: int = Field(ge=0)
    insufficient_count: int = Field(ge=0)
    not_checked_count: int = Field(ge=0)
    verified_rate: float = Field(ge=0.0, le=1.0)
    insufficient_rate: float = Field(ge=0.0, le=1.0)


class ShoppingClaimsSummary(BaseModel):
    unverified_price_attempts: int = Field(ge=0)
    unverified_sustainability_attempts: int = Field(ge=0)
    no_availability_claim_count: int = Field(ge=0)
    blocked_external_sources: bool


class QualityBreakdownRow(BaseModel):
    dimension: str = Field(min_length=1)
    label: str = Field(min_length=1)
    value: float = Field(ge=0.0)
    unit: Literal["ratio", "count", "usd", "ms"]
    source: Literal["live", "fallback", "derived"]


class IncidentRow(BaseModel):
    incident_id: str = Field(min_length=1)
    type: str = Field(min_length=1)
    severity: Literal["low", "medium", "high"]
    source: str = Field(min_length=1)
    status: Literal["open", "resolved", "monitoring"]
    created_at: datetime
    resolved_at: datetime | None = None
    safe_summary: str = Field(min_length=1)


class AdminAuthStatus(BaseModel):
    auth_mode: Literal["token_only_scaffold", "token_plus_operator_secret"]
    environment: str = Field(min_length=1)
    admin_token_configured: bool
    production_ready: bool
    enterprise_ready: bool = False
    warning: str = Field(min_length=1)


class AdminHealth(BaseModel):
    status: Literal["ok"]
    data_source: str = Field(min_length=1)
    mode: DataMode
    storage_path: str = Field(min_length=1)
    last_ingestion_at: datetime | None = None


class PaginatedResponse(BaseModel, Generic[T]):
    items: list[T] = Field(default_factory=list)
    total: int = Field(ge=0)
    limit: int = Field(ge=1)
    offset: int = Field(ge=0)
    next_offset: int | None = Field(default=None, ge=0)
    fetched_at: datetime


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


class SupportRequestExecutionResult(BaseModel):
    request_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    request_type: RequestType
    action: Literal["resolved", "deleted_operational_records"]
    status: Literal["done"]
    processed_at: datetime
    record_counts: dict[str, int] = Field(default_factory=dict)
    metadata_only: bool = True


class OperationalExportBundle(BaseModel):
    request_id: str = Field(min_length=1)
    user_id: str = Field(min_length=1)
    generated_at: datetime
    scope: Literal["web_backend_operational_records"] = "web_backend_operational_records"
    metadata_only: bool = True
    checksum_sha256: str = Field(min_length=64, max_length=64)
    record_counts: dict[str, int] = Field(default_factory=dict)
    user_summary: UserSummary | None = None
    usage_events: list[UsageEventRecord] = Field(default_factory=list)
    ai_invocations: list[AIInvocationRecord] = Field(default_factory=list)
    ai_usage_ledger: list[AiUsageLedgerRow] = Field(default_factory=list)
    mission_records: list[MissionAuditRecord] = Field(default_factory=list)
    feedback_records: list[FeedbackAuditRecord] = Field(default_factory=list)
    safety_events: list[SafetyAuditRecord] = Field(default_factory=list)
    support_requests: list[SupportRequest] = Field(default_factory=list)


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
    schema_version: int = Field(default=2, ge=1)
    ttl_seconds: int = Field(default=21600, ge=300)
    gateway_base_url: str = Field(min_length=1)
    feature_flags: dict[str, bool] = Field(default_factory=dict)
    friendly_copy: dict[str, str] = Field(default_factory=dict)
    ai_status: dict[str, Any] = Field(default_factory=dict)
    billing: "MobileBillingConfig" = Field(default_factory=lambda: MobileBillingConfig())
    generated_at: datetime


class MobileBillingCatalogEntry(BaseModel):
    product_id: str = Field(min_length=1)
    plan: Literal["premium", "pro"]
    title: str = Field(min_length=1)
    description: str = Field(min_length=1)


class MobileBillingConfig(BaseModel):
    enabled: bool = False
    provider: MobileBillingProvider = "disabled"
    mode: MobileBillingMode = "disabled"
    sandbox_only: bool = False
    production_purchases_enabled: bool = False
    restore_purchases: bool = False
    package_name: str | None = None
    validation_path: str = Field(
        default="/public/mobile/billing/google-play/validate",
        min_length=1,
    )
    decision_document_url: str = Field(min_length=1)
    public_message: str = Field(min_length=1)
    catalog: list[MobileBillingCatalogEntry] = Field(default_factory=list)


class MobileBillingValidationRequest(BaseModel):
    provider: MobileBillingProvider = "google_play"
    mode: MobileBillingMode = "google_play_sandbox"
    package_name: str = Field(min_length=1)
    product_id: str = Field(min_length=1)
    purchase_token: str = Field(min_length=1)
    purchase_id: str | None = None
    transaction_date_iso: str | None = None
    restored: bool = False
    purchase_status: str = Field(min_length=1)
    trace: dict[str, Any] = Field(default_factory=dict)


class MobileBillingValidationResponse(BaseModel):
    verified: bool
    plan: Literal["free", "premium", "pro"] = "free"
    quota: dict[str, int] = Field(default_factory=dict)
    billing_provider: MobileBillingProvider = "disabled"
    renewal_state: str = Field(min_length=1)
    sandbox: bool = False
    status_code: str = Field(min_length=1)
    message: str = Field(min_length=1)
    validated_at_iso: datetime
    trace: dict[str, Any] = Field(default_factory=dict)
