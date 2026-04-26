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

export type RoutingProfile = {
  capability:
    | "daily_plan"
    | "task_rewrite"
    | "semantic_classify"
    | "weekly_summary";
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
  capability:
    | "daily_plan"
    | "task_rewrite"
    | "semantic_classify"
    | "weekly_summary";
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
