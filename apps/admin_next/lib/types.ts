export type AdminDataState = "live" | "fallback" | "offline" | "seeded";

export type DashboardMetrics = {
  dau: number;
  wau: number;
  new_users_7d: number;
  useful_missions_per_active_user_week: number;
  mission_completion_rate: number;
  recommendation_usefulness_rate: number;
  rejection_rate: number;
  capture_events_per_active_user: number;
  fallback_rate: number;
  ai_latency_ms_avg: number;
  ai_cost_total_usd: number;
  ai_cost_per_active_user_usd: number;
  safety_intervention_rate: number;
  privacy_concern_rate: number;
  mental_load_items_per_active_user: number;
  decision_acceptance_rate: number;
  decision_completion_rate: number;
  decision_postpone_rate: number;
  shopping_need_conversion_rate: number;
  shopping_claims_with_evidence_rate: number;
  insufficient_sustainability_data_rate: number;
  privacy_filtered_decision_rate: number;
  active_key_count: number;
  disabled_key_count: number;
  routing_snapshot_age_seconds: number | null;
};

export type AdminUser = {
  user_id: string;
  email: string;
  plan: "free" | "plus" | "internal";
  status: "active" | "paused" | "trial";
  created_at: string;
  last_seen_at: string;
  weekly_active: boolean;
  ai_calls: number;
  useful_missions_completed: number;
  support_flags: string[];
  export_requested: boolean;
  delete_requested: boolean;
};

export type PaginatedResponse<T> = {
  items: T[];
  total: number;
  limit: number;
  offset: number;
  next_offset: number | null;
  fetched_at: string;
};

export type UserManagementRow = {
  user_id: string;
  display_name: string;
  email_masked: string;
  plan: "free" | "plus" | "internal";
  status: "active" | "paused" | "trial";
  locale: "en" | "es" | "pt-BR" | "ja" | "zh-Hans";
  last_seen_at: string;
  ai_calls_count: number;
  useful_missions_count: number;
  fallback_rate: number;
  support_flags: string[];
  privacy_request_status:
    | "none"
    | "export_open"
    | "delete_open"
    | "mixed_open"
    | "completed";
};

export type UserSummary = {
  user_id: string;
  display_name: string;
  email_masked: string;
  plan: "free" | "plus" | "internal";
  status: "active" | "paused" | "trial";
  locale: "en" | "es" | "pt-BR" | "ja" | "zh-Hans";
  created_at: string;
  last_seen_at: string;
  organization_id: string | null;
  support_flags: string[];
  privacy_request_status:
    | "none"
    | "export_open"
    | "delete_open"
    | "mixed_open"
    | "completed";
};

export type UserUsageSummary = {
  user_id: string;
  capture_events: number;
  missions_generated: number;
  missions_completed: number;
  ai_calls_count: number;
  fallback_rate: number;
  latency_ms_avg: number;
};

export type UserPrivacySummary = {
  user_id: string;
  privacy_request_status:
    | "none"
    | "export_open"
    | "delete_open"
    | "mixed_open"
    | "completed";
  open_requests: Array<"export" | "delete">;
  encrypted_collections: string[];
  sensitive_data_excluded: boolean;
};

export type UserSupportSummary = {
  user_id: string;
  support_flags: string[];
  open_request_count: number;
  requests: SupportRequest[];
};

export type OrganizationRow = {
  organization_id: string;
  name: string;
  status: "active" | "trial" | "paused";
  plan: string;
  user_count: number;
  storage_used_gb: number;
  ai_mode_default: "xinsightai" | "byok" | "hybrid";
  created_at: string;
};

export type OrganizationDetail = OrganizationRow & {
  members: UserSummary[];
};

export type PlanRow = {
  plan_id: string;
  name: string;
  price_label: string;
  user_limit: number;
  storage_limit_gb: number;
  ai_credit_policy: string;
  byok_allowed: boolean;
  support_level: string;
};

export type OpenRouterByokKeyRecord = {
  key_id: string;
  organization_id: string;
  project_id: string | null;
  label: string;
  secret_last4: string;
  status: "healthy" | "degraded" | "disabled" | "unknown";
  created_at: string;
  last_used_at: string | null;
  disabled_at: string | null;
  scopes: string[];
};

export type AiUsageLedgerRow = {
  id: string;
  organization_id: string;
  user_id: string;
  ai_mode: "xinsightai" | "byok" | "hybrid";
  provider: string;
  model: string | null;
  endpoint: string;
  input_tokens: number;
  output_tokens: number;
  platform_cost_usd: number;
  customer_charge_usd: number;
  xinsight_credits_debited: number;
  byok_external_billing: boolean;
  created_at: string;
};

export type XInsightCreditSummary = {
  total_credits_debited: number;
  total_customer_charge_usd: number;
  total_platform_cost_usd: number;
  byok_request_count: number;
};

export type BillingAccountRow = {
  organization_id: string;
  organization_name: string;
  plan: string;
  subscription_status: "active" | "trial" | "paused";
  storage_charge_usd: number;
  xinsight_charge_usd: number;
  byok_key_count: number;
  invoice_placeholder: string;
};

export type StorageSummary = {
  total_gb: number;
  billable_gb: number;
  local_only_gb: number;
  cloud_gb: number;
  export_bundle_gb: number;
  homememory_metadata_count: number;
  retention_risk_count: number;
};

export type StorageUsageRow = {
  organization_id: string;
  organization_name: string;
  plan: string;
  storage_used_gb: number;
  encrypted_collections: string[];
  retention_risk: boolean;
};

export type PrivacyRequestRow = {
  request_id: string;
  user_id: string;
  request_type: "export" | "delete";
  status: "open" | "done";
  requested_at: string;
};

export type PrivacyDataMap = {
  encrypted_collections: string[];
  sensitive_data_excluded: boolean;
  retention_notes: string[];
};

export type SecuritySummary = {
  environment: string;
  admin_token_configured: boolean;
  ingestion_token_configured: boolean;
  internal_service_token_configured: boolean;
  production_ready: boolean;
  openrouter_key_count: number;
  byok_key_count: number;
  latest_audit_at: string | null;
  dependency_scan_status: string;
  failed_auth_placeholder: number;
};

export type AuditLogRow = {
  audit_id: string;
  actor_id: string;
  action: string;
  target_type: string;
  target_id: string;
  safe_diff: Record<string, unknown>;
  correlation_id: string;
  created_at: string;
};

export type HomeMemorySummary = {
  proof_parse_count: number;
  warranty_reminder_count: number;
  claim_draft_count: number;
  evidence_attachment_count: number;
  parser_success_rate: number;
  fallback_rate: number;
  locale_distribution: Record<string, number>;
  encrypted_collections: string[];
  storage_impact_estimate: number;
  sensitive_data_excluded: boolean;
};

export type HomeMemoryParserUsageRow = {
  locale: string;
  parser: "deterministic" | "semantic" | "fallback";
  requests: number;
  success_rate: number;
  fallback_rate: number;
};

export type QualitySummary = {
  mission_usefulness_rate: number;
  mission_completion_rate: number;
  rejection_rate: number;
  fallback_rate: number;
  proof_parser_success_rate: number;
  safety_interventions: number;
  high_cost_anomalies: number;
  support_escalations: number;
};

export type QualityBreakdownRow = {
  dimension: string;
  label: string;
  value: number;
  unit: "ratio" | "count" | "usd" | "ms";
  source: "live" | "fallback" | "derived";
};

export type IncidentRow = {
  incident_id: string;
  type: string;
  severity: "low" | "medium" | "high";
  source: string;
  status: "open" | "resolved" | "monitoring";
  created_at: string;
  resolved_at: string | null;
  safe_summary: string;
};

export type AdminAuthStatus = {
  auth_mode: "token_only_scaffold" | "token_plus_operator_secret";
  environment: string;
  admin_token_configured: boolean;
  production_ready: boolean;
  enterprise_ready: boolean;
  warning: string;
};

export type UsageSnapshot = {
  user_id: string;
  capture_events: number;
  missions_generated: number;
  missions_completed: number;
  fallback_rate: number;
  latency_ms_avg: number;
  last_active_at: string;
};

export type AICostSnapshot = {
  endpoint: string;
  provider: string;
  requests: number;
  estimated_cost_usd: number;
  avg_latency_ms: number;
  fallback_rate: number;
};

export type MissionAuditRecord = {
  mission_id: string;
  user_id: string;
  title: string;
  status: "generated" | "accepted" | "completed" | "rejected";
  usefulness: "useful" | "accepted" | "completed" | "rejected" | "edited" | null;
  domains: string[];
  matched_risks: string[];
  final_score: number;
};

export type FeedbackAuditRecord = {
  feedback_id: string;
  user_id: string;
  suggestion_id: string;
  status: "useful" | "accepted" | "completed" | "rejected" | "edited";
  reason: string | null;
  domains: string[];
  created_at: string;
};

export type SafetyAuditRecord = {
  event_id: string;
  user_id: string;
  category: string;
  rule: string;
  severity: "low" | "medium" | "high";
  created_at: string;
};

export type FeatureFlag = {
  key: string;
  enabled: boolean;
  description: string;
  updated_at: string;
};

export type MindFlowSummary = {
  mental_load_items_per_active_user: number;
  decision_acceptance_rate: number;
  decision_completion_rate: number;
  decision_postpone_rate: number;
  privacy_filtered_decision_rate: number;
  open_loop_count: number;
  open_loop_rate: number;
  fallback_rate: number;
};

export type MindFlowDecisionQuality = {
  generated_count: number;
  accepted_count: number;
  completed_count: number;
  rejected_count: number;
  postponed_count: number;
  repeated_count: number;
  acceptance_rate: number;
  completion_rate: number;
  rejection_rate: number;
  postpone_rate: number;
};

export type MindFlowOpenLoops = {
  total_open_loops: number;
  mental_load_items: number;
  pending_decisions: number;
  pending_shopping_needs: number;
  warranty_review_needs: number;
};

export type ShoppingSummary = {
  shopping_need_conversion_rate: number;
  shopping_claims_with_evidence_rate: number;
  insufficient_sustainability_data_rate: number;
  needs_detected: number;
  plans_generated: number;
  external_sources_enabled: boolean;
  product_evidence_enabled: boolean;
};

export type ShoppingEvidenceQuality = {
  verified_count: number;
  partial_count: number;
  insufficient_count: number;
  not_checked_count: number;
  verified_rate: number;
  insufficient_rate: number;
};

export type ShoppingClaimsSummary = {
  unverified_price_attempts: number;
  unverified_sustainability_attempts: number;
  no_availability_claim_count: number;
  blocked_external_sources: boolean;
};

export type ModelSettingsSnapshot = {
  active_provider: string;
  primary_model: string;
  fallback_model: string;
  classification_model: string;
  weekly_summary_model: string;
};

export type OpenRouterApiKeyRecord = {
  key_id: string;
  label: string;
  secret_last4: string;
  enabled: boolean;
  priority: number;
  status: "healthy" | "degraded" | "disabled" | "unknown";
  last_ok_at: string | null;
  last_error_at: string | null;
  consecutive_failures: number;
  created_at: string;
  updated_at: string;
};

export type RoutingCapability =
  | "daily_plan"
  | "task_rewrite"
  | "semantic_classify"
  | "weekly_summary"
  | "mindflow_parse"
  | "decision_plan"
  | "shopping_plan"
  | "product_evidence";

export type RoutingProfile = {
  capability: RoutingCapability;
  strategy: "quality_first";
  min_context_length: number;
  required_parameters: string[];
  preferred_max_latency_seconds: number;
  preferred_min_throughput_tokens_per_second: number;
  max_prompt_price_usd_per_million: number | null;
  max_completion_price_usd_per_million: number | null;
  retry_policy: Record<string, number>;
  enabled: boolean;
  updated_at: string;
};

export type ModelCatalogEntry = {
  model_id: string;
  canonical_slug: string | null;
  name: string;
  description: string | null;
  context_length: number;
  output_modalities: string[];
  supported_parameters: string[];
  prompt_price_usd_per_million: number;
  completion_price_usd_per_million: number;
  request_price_usd: number;
  top_provider_json: Record<string, unknown>;
  architecture_json: Record<string, unknown>;
  expiration_date: string | null;
  refreshed_at: string;
};

export type ModelSelectionSnapshot = {
  capability: RoutingCapability;
  rank_index: number;
  model_id: string;
  score: number;
  selection_reason: Record<string, unknown>;
  generated_at: string;
  expires_at: string;
};

export type OpenRouterKeyEventRecord = {
  event_id: string;
  key_id: string;
  key_label: string;
  event_type: "success" | "failure" | "disabled" | "enabled" | "created";
  endpoint: string | null;
  model: string | null;
  error_code: string | null;
  notes: string | null;
  created_at: string;
};

export type SupportRequest = {
  request_id: string;
  user_id: string;
  request_type: "export" | "delete";
  status: "open" | "done";
  requested_at: string;
};

export type SupportRequestExecutionResult = {
  request_id: string;
  user_id: string;
  request_type: "export" | "delete";
  action: "resolved" | "deleted_operational_records";
  status: "done";
  processed_at: string;
  record_counts: Record<string, number>;
  metadata_only: boolean;
};

export type AdminBackendHealth = {
  status: "ok";
  data_source: string;
  mode: "live" | "seeded";
  storage_path: string;
  last_ingestion_at: string | null;
};

export type AdminFetchResult<T> = {
  data: T | null;
  error: string | null;
  source: AdminDataState;
  fetchedAt: string;
};
