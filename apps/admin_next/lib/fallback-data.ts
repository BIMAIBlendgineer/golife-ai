import type {
  AICostSnapshot,
  AdminUser,
  AdminAuthStatus,
  AuditLogRow,
  DashboardMetrics,
  FeatureFlag,
  FeedbackAuditRecord,
  HomeMemoryParserUsageRow,
  HomeMemorySummary,
  IncidentRow,
  MissionAuditRecord,
  ModelCatalogEntry,
  ModelSettingsSnapshot,
  ModelSelectionSnapshot,
  BillingAccountRow,
  OpenRouterByokKeyRecord,
  OrganizationDetail,
  OrganizationRow,
  OpenRouterApiKeyRecord,
  OpenRouterKeyEventRecord,
  PaginatedResponse,
  PlanRow,
  PrivacyDataMap,
  PrivacyRequestRow,
  QualityBreakdownRow,
  QualitySummary,
  RoutingProfile,
  SafetyAuditRecord,
  SecuritySummary,
  StorageSummary,
  StorageUsageRow,
  SupportRequest,
  AiUsageLedgerRow,
  UserManagementRow,
  UserPrivacySummary,
  UserSummary,
  UserSupportSummary,
  UserUsageSummary,
  UsageSnapshot,
  XInsightCreditSummary,
} from "@/lib/types";

export const fallbackDashboard: DashboardMetrics = {
  dau: 2,
  wau: 2,
  new_users_7d: 2,
  useful_missions_per_active_user_week: 6,
  mission_completion_rate: 0.48,
  recommendation_usefulness_rate: 0.67,
  rejection_rate: 0.33,
  capture_events_per_active_user: 21,
  fallback_rate: 0.1,
  ai_latency_ms_avg: 381.67,
  ai_cost_total_usd: 5.2,
  ai_cost_per_active_user_usd: 2.6,
  safety_intervention_rate: 0.11,
  privacy_concern_rate: 1,
  active_key_count: 2,
  disabled_key_count: 1,
  routing_snapshot_age_seconds: 480,
};

export const fallbackUsers: AdminUser[] = [
  {
    user_id: "local-user",
    email: "local-user@golife.ai",
    plan: "plus",
    status: "active",
    created_at: "2026-04-10T09:00:00Z",
    last_seen_at: "2026-04-24T11:10:00Z",
    weekly_active: true,
    ai_calls: 42,
    useful_missions_completed: 9,
    support_flags: ["high_value_feedback"],
    export_requested: false,
    delete_requested: false,
  },
  {
    user_id: "user-2",
    email: "user-2@golife.ai",
    plan: "free",
    status: "active",
    created_at: "2026-04-20T08:20:00Z",
    last_seen_at: "2026-04-23T18:00:00Z",
    weekly_active: true,
    ai_calls: 16,
    useful_missions_completed: 3,
    support_flags: [],
    export_requested: true,
    delete_requested: false,
  },
  {
    user_id: "user-3",
    email: "user-3@golife.ai",
    plan: "internal",
    status: "trial",
    created_at: "2026-04-22T13:00:00Z",
    last_seen_at: "2026-04-23T09:30:00Z",
    weekly_active: false,
    ai_calls: 7,
    useful_missions_completed: 1,
    support_flags: ["safety_review"],
    export_requested: false,
    delete_requested: true,
  },
];

export const fallbackUserManagement: PaginatedResponse<UserManagementRow> = {
  items: [
    {
      user_id: "local-user",
      display_name: "Local User",
      email_masked: "lo***@golife.ai",
      plan: "plus",
      status: "active",
      locale: "en",
      last_seen_at: "2026-04-24T11:10:00Z",
      ai_calls_count: 42,
      useful_missions_count: 9,
      fallback_rate: 0.08,
      support_flags: ["high_value_feedback"],
      privacy_request_status: "none",
    },
    {
      user_id: "user-2",
      display_name: "Marta L",
      email_masked: "us***@golife.ai",
      plan: "free",
      status: "active",
      locale: "es",
      last_seen_at: "2026-04-23T18:00:00Z",
      ai_calls_count: 16,
      useful_missions_count: 3,
      fallback_rate: 0.18,
      support_flags: [],
      privacy_request_status: "export_open",
    },
    {
      user_id: "user-3",
      display_name: "Ops Internal",
      email_masked: "us***@golife.ai",
      plan: "internal",
      status: "trial",
      locale: "ja",
      last_seen_at: "2026-04-23T09:30:00Z",
      ai_calls_count: 7,
      useful_missions_count: 1,
      fallback_rate: 0.04,
      support_flags: ["safety_review"],
      privacy_request_status: "delete_open",
    },
  ],
  total: 3,
  limit: 25,
  offset: 0,
  next_offset: null,
  fetched_at: "2026-04-24T11:30:00Z",
};

export const fallbackUserSummaryById: Record<string, UserSummary> = {
  "local-user": {
    user_id: "local-user",
    display_name: "Local User",
    email_masked: "lo***@golife.ai",
    plan: "plus",
    status: "active",
    locale: "en",
    created_at: "2026-04-10T09:00:00Z",
    last_seen_at: "2026-04-24T11:10:00Z",
    organization_id: "org-household",
    support_flags: ["high_value_feedback"],
    privacy_request_status: "none",
  },
  "user-2": {
    user_id: "user-2",
    display_name: "Marta L",
    email_masked: "us***@golife.ai",
    plan: "free",
    status: "active",
    locale: "es",
    created_at: "2026-04-20T08:20:00Z",
    last_seen_at: "2026-04-23T18:00:00Z",
    organization_id: "org-household",
    support_flags: [],
    privacy_request_status: "export_open",
  },
  "user-3": {
    user_id: "user-3",
    display_name: "Ops Internal",
    email_masked: "us***@golife.ai",
    plan: "internal",
    status: "trial",
    locale: "ja",
    created_at: "2026-04-22T13:00:00Z",
    last_seen_at: "2026-04-23T09:30:00Z",
    organization_id: "org-internal",
    support_flags: ["safety_review"],
    privacy_request_status: "delete_open",
  },
};

export const fallbackUserUsageById: Record<string, UserUsageSummary> = {
  "local-user": {
    user_id: "local-user",
    capture_events: 28,
    missions_generated: 18,
    missions_completed: 9,
    ai_calls_count: 42,
    fallback_rate: 0.08,
    latency_ms_avg: 840,
  },
  "user-2": {
    user_id: "user-2",
    capture_events: 10,
    missions_generated: 8,
    missions_completed: 3,
    ai_calls_count: 16,
    fallback_rate: 0.18,
    latency_ms_avg: 950,
  },
  "user-3": {
    user_id: "user-3",
    capture_events: 4,
    missions_generated: 4,
    missions_completed: 1,
    ai_calls_count: 7,
    fallback_rate: 0.04,
    latency_ms_avg: 720,
  },
};

export const fallbackUserPrivacyById: Record<string, UserPrivacySummary> = {
  "local-user": {
    user_id: "local-user",
    privacy_request_status: "none",
    open_requests: [],
    encrypted_collections: ["expenses", "journal_entries", "quick_notes"],
    sensitive_data_excluded: true,
  },
  "user-2": {
    user_id: "user-2",
    privacy_request_status: "export_open",
    open_requests: ["export"],
    encrypted_collections: ["expenses", "journal_entries", "quick_notes"],
    sensitive_data_excluded: true,
  },
  "user-3": {
    user_id: "user-3",
    privacy_request_status: "delete_open",
    open_requests: ["delete"],
    encrypted_collections: ["expenses", "journal_entries", "quick_notes"],
    sensitive_data_excluded: true,
  },
};

export const fallbackUserSupportById: Record<string, UserSupportSummary> = {
  "local-user": {
    user_id: "local-user",
    support_flags: ["high_value_feedback"],
    open_request_count: 0,
    requests: [],
  },
  "user-2": {
    user_id: "user-2",
    support_flags: [],
    open_request_count: 1,
    requests: [
      {
        request_id: "support-001",
        user_id: "user-2",
        request_type: "export",
        status: "open",
        requested_at: "2026-04-24T02:00:00Z",
      },
    ],
  },
  "user-3": {
    user_id: "user-3",
    support_flags: ["safety_review"],
    open_request_count: 1,
    requests: [
      {
        request_id: "support-002",
        user_id: "user-3",
        request_type: "delete",
        status: "open",
        requested_at: "2026-04-24T05:00:00Z",
      },
    ],
  },
};

export const fallbackUsage: UsageSnapshot[] = [
  {
    user_id: "local-user",
    capture_events: 28,
    missions_generated: 18,
    missions_completed: 9,
    fallback_rate: 0.08,
    latency_ms_avg: 840,
    last_active_at: "2026-04-24T11:10:00Z",
  },
  {
    user_id: "user-2",
    capture_events: 10,
    missions_generated: 8,
    missions_completed: 3,
    fallback_rate: 0.18,
    latency_ms_avg: 950,
    last_active_at: "2026-04-23T18:00:00Z",
  },
  {
    user_id: "user-3",
    capture_events: 4,
    missions_generated: 4,
    missions_completed: 1,
    fallback_rate: 0.04,
    latency_ms_avg: 720,
    last_active_at: "2026-04-23T09:30:00Z",
  },
];

export const fallbackAICosts: AICostSnapshot[] = [
  {
    endpoint: "/v1/missions/daily",
    provider: "openrouter",
    requests: 26,
    estimated_cost_usd: 4.78,
    avg_latency_ms: 910,
    fallback_rate: 0.11,
  },
  {
    endpoint: "/v1/events/classify",
    provider: "mock_or_small_model",
    requests: 22,
    estimated_cost_usd: 0.42,
    avg_latency_ms: 180,
    fallback_rate: 0.03,
  },
  {
    endpoint: "/v1/feedback",
    provider: "system",
    requests: 13,
    estimated_cost_usd: 0,
    avg_latency_ms: 55,
    fallback_rate: 0,
  },
];

export const fallbackMissions: MissionAuditRecord[] = [
  {
    mission_id: "mission-001",
    user_id: "local-user",
    title: "Use pantry before buying lunch",
    status: "completed",
    usefulness: "completed",
    domains: ["finance", "pantry"],
    matched_risks: ["food_spend_overlap"],
    final_score: 0.82,
  },
  {
    mission_id: "mission-002",
    user_id: "local-user",
    title: "Protect one recovery habit",
    status: "accepted",
    usefulness: "accepted",
    domains: ["task", "habit"],
    matched_risks: ["task_habit_tradeoff"],
    final_score: 0.77,
  },
  {
    mission_id: "mission-003",
    user_id: "user-2",
    title: "Pause a wardrobe buy for 24 hours",
    status: "rejected",
    usefulness: "rejected",
    domains: ["wardrobe"],
    matched_risks: ["purchase_intention_active"],
    final_score: 0.69,
  },
];

export const fallbackFeedback: FeedbackAuditRecord[] = [
  {
    feedback_id: "feedback-001",
    user_id: "local-user",
    suggestion_id: "mission-001",
    status: "completed",
    reason: "private_note_redacted",
    domains: ["finance", "pantry"],
    created_at: "2026-04-24T06:00:00Z",
  },
  {
    feedback_id: "feedback-002",
    user_id: "local-user",
    suggestion_id: "mission-002",
    status: "accepted",
    reason: null,
    domains: ["task", "habit"],
    created_at: "2026-04-24T08:00:00Z",
  },
  {
    feedback_id: "feedback-003",
    user_id: "user-2",
    suggestion_id: "mission-003",
    status: "rejected",
    reason: "private_note_redacted",
    domains: ["wardrobe"],
    created_at: "2026-04-24T09:00:00Z",
  },
];

export const fallbackSafety: SafetyAuditRecord[] = [
  {
    event_id: "safety-001",
    user_id: "user-2",
    category: "finance",
    rule: "regulated_advice",
    severity: "medium",
    created_at: "2026-04-24T00:30:00Z",
  },
  {
    event_id: "safety-002",
    user_id: "user-3",
    category: "external_action",
    rule: "external_action_without_confirmation",
    severity: "low",
    created_at: "2026-04-24T03:00:00Z",
  },
];

export const fallbackFeatureFlags: FeatureFlag[] = [
  {
    key: "daily_risk_engine",
    enabled: true,
    description: "Expose risks in Home Today and admin trace.",
    updated_at: "2026-04-23T10:00:00Z",
  },
  {
    key: "sqlite_domain_entities",
    enabled: true,
    description: "Persist entities and missions locally in mobile.",
    updated_at: "2026-04-24T07:00:00Z",
  },
  {
    key: "multi_event_capture",
    enabled: false,
    description: "Split one capture into multiple entities and events.",
    updated_at: "2026-04-24T10:00:00Z",
  },
];

export const fallbackModelSettings: ModelSettingsSnapshot = {
  active_provider: "openrouter",
  primary_model: "openai/gpt-4.1-mini",
  fallback_model: "mock",
  classification_model: "deterministic_capture_router",
  weekly_summary_model: "openai/gpt-4.1-mini",
};

export const fallbackSupportRequests: SupportRequest[] = [
  {
    request_id: "support-001",
    user_id: "user-2",
    request_type: "export",
    status: "open",
    requested_at: "2026-04-24T02:00:00Z",
  },
  {
    request_id: "support-002",
    user_id: "user-3",
    request_type: "delete",
    status: "open",
    requested_at: "2026-04-24T05:00:00Z",
  },
];

export const fallbackOrganizations: OrganizationRow[] = [
  {
    organization_id: "org-household",
    name: "Household Alpha",
    status: "active",
    plan: "family",
    user_count: 2,
    storage_used_gb: 12.4,
    ai_mode_default: "hybrid",
    created_at: "2026-02-25T10:00:00Z",
  },
  {
    organization_id: "org-internal",
    name: "GoLife Internal Ops",
    status: "active",
    plan: "enterprise",
    user_count: 1,
    storage_used_gb: 48.9,
    ai_mode_default: "xinsightai",
    created_at: "2025-12-08T08:30:00Z",
  },
];

export const fallbackOrganizationDetails: Record<string, OrganizationDetail> = {
  "org-household": {
    ...fallbackOrganizations[0],
    members: [
      fallbackUserSummaryById["local-user"],
      fallbackUserSummaryById["user-2"],
    ],
  },
  "org-internal": {
    ...fallbackOrganizations[1],
    members: [fallbackUserSummaryById["user-3"]],
  },
};

export const fallbackPlans: PlanRow[] = [
  {
    plan_id: "free",
    name: "Free",
    price_label: "$0",
    user_limit: 1,
    storage_limit_gb: 1,
    ai_credit_policy: "No bundled credits",
    byok_allowed: false,
    support_level: "community",
  },
  {
    plan_id: "pro",
    name: "Pro",
    price_label: "$19 / month",
    user_limit: 1,
    storage_limit_gb: 20,
    ai_credit_policy: "Bundled xInsightAI credits",
    byok_allowed: true,
    support_level: "standard",
  },
  {
    plan_id: "family",
    name: "Family",
    price_label: "$29 / month",
    user_limit: 5,
    storage_limit_gb: 50,
    ai_credit_policy: "Shared household credits",
    byok_allowed: true,
    support_level: "priority",
  },
  {
    plan_id: "team",
    name: "Team",
    price_label: "$79 / month",
    user_limit: 25,
    storage_limit_gb: 250,
    ai_credit_policy: "Seat pool + org ledger",
    byok_allowed: true,
    support_level: "priority",
  },
  {
    plan_id: "enterprise",
    name: "Enterprise",
    price_label: "Custom",
    user_limit: 500,
    storage_limit_gb: 5000,
    ai_credit_policy: "Contracted credit policy",
    byok_allowed: true,
    support_level: "dedicated",
  },
];

export const fallbackOpenRouterByokKeys: OpenRouterByokKeyRecord[] = [
  {
    key_id: "byok-001",
    organization_id: "org-household",
    project_id: null,
    label: "Household receipts parser",
    secret_last4: "9xyz",
    status: "healthy",
    created_at: "2026-04-04T09:00:00Z",
    last_used_at: "2026-04-24T02:00:00Z",
    disabled_at: null,
    scopes: ["missions", "parse", "routing"],
  },
];

export const fallbackXInsightUsage: AiUsageLedgerRow[] = [
  {
    id: "ledger-001",
    organization_id: "org-household",
    user_id: "local-user",
    ai_mode: "xinsightai",
    provider: "openrouter",
    model: "openai/gpt-4.1-mini",
    endpoint: "/v1/missions/daily",
    input_tokens: 1640,
    output_tokens: 910,
    platform_cost_usd: 0.82,
    customer_charge_usd: 1.45,
    xinsight_credits_debited: 24,
    byok_external_billing: false,
    created_at: "2026-04-24T04:00:00Z",
  },
  {
    id: "ledger-002",
    organization_id: "org-household",
    user_id: "user-2",
    ai_mode: "byok",
    provider: "openrouter",
    model: "anthropic/claude-sonnet-4",
    endpoint: "/v1/missions/daily",
    input_tokens: 1820,
    output_tokens: 1030,
    platform_cost_usd: 0,
    customer_charge_usd: 0.22,
    xinsight_credits_debited: 0,
    byok_external_billing: true,
    created_at: "2026-04-24T06:00:00Z",
  },
  {
    id: "ledger-003",
    organization_id: "org-internal",
    user_id: "user-3",
    ai_mode: "xinsightai",
    provider: "openrouter",
    model: "google/gemini-2.5-flash",
    endpoint: "/v1/events/classify",
    input_tokens: 420,
    output_tokens: 120,
    platform_cost_usd: 0.09,
    customer_charge_usd: 0.31,
    xinsight_credits_debited: 3,
    byok_external_billing: false,
    created_at: "2026-04-24T10:00:00Z",
  },
];

export const fallbackXInsightCredits: XInsightCreditSummary = {
  total_credits_debited: 27,
  total_customer_charge_usd: 1.76,
  total_platform_cost_usd: 0.91,
  byok_request_count: 1,
};

export const fallbackBillingAccounts: BillingAccountRow[] = [
  {
    organization_id: "org-household",
    organization_name: "Household Alpha",
    plan: "family",
    subscription_status: "active",
    storage_charge_usd: 2.23,
    xinsight_charge_usd: 1.45,
    byok_key_count: 1,
    invoice_placeholder: "placeholder-org-household",
  },
  {
    organization_id: "org-internal",
    organization_name: "GoLife Internal Ops",
    plan: "enterprise",
    subscription_status: "active",
    storage_charge_usd: 8.8,
    xinsight_charge_usd: 0.31,
    byok_key_count: 0,
    invoice_placeholder: "placeholder-org-internal",
  },
];

export const fallbackStorageSummary: StorageSummary = {
  total_gb: 61.3,
  billable_gb: 61.3,
  local_only_gb: 25.75,
  cloud_gb: 35.55,
  export_bundle_gb: 3.68,
  homememory_metadata_count: 0,
  retention_risk_count: 1,
};

export const fallbackStorageUsage: StorageUsageRow[] = [
  {
    organization_id: "org-household",
    organization_name: "Household Alpha",
    plan: "family",
    storage_used_gb: 12.4,
    encrypted_collections: ["expenses", "journal_entries", "quick_notes"],
    retention_risk: false,
  },
  {
    organization_id: "org-internal",
    organization_name: "GoLife Internal Ops",
    plan: "enterprise",
    storage_used_gb: 48.9,
    encrypted_collections: ["expenses", "journal_entries", "quick_notes"],
    retention_risk: true,
  },
];

export const fallbackOpenRouterKeys: OpenRouterApiKeyRecord[] = [
  {
    key_id: "or-key-1",
    label: "Primary production key",
    secret_last4: "8f2a",
    enabled: true,
    priority: 0,
    status: "healthy",
    last_ok_at: "2026-04-24T11:55:00Z",
    last_error_at: null,
    consecutive_failures: 0,
    created_at: "2026-04-20T10:00:00Z",
    updated_at: "2026-04-24T11:55:00Z",
  },
  {
    key_id: "or-key-2",
    label: "Secondary production key",
    secret_last4: "1cd9",
    enabled: true,
    priority: 1,
    status: "degraded",
    last_ok_at: "2026-04-24T11:48:00Z",
    last_error_at: "2026-04-24T11:53:00Z",
    consecutive_failures: 2,
    created_at: "2026-04-20T10:10:00Z",
    updated_at: "2026-04-24T11:53:00Z",
  },
  {
    key_id: "or-key-3",
    label: "Paused backup key",
    secret_last4: "44aa",
    enabled: false,
    priority: 2,
    status: "disabled",
    last_ok_at: null,
    last_error_at: null,
    consecutive_failures: 0,
    created_at: "2026-04-20T10:20:00Z",
    updated_at: "2026-04-22T08:10:00Z",
  },
];

export const fallbackRoutingProfiles: RoutingProfile[] = [
  {
    capability: "daily_plan",
    strategy: "quality_first",
    min_context_length: 32000,
    required_parameters: ["response_format", "temperature", "max_tokens"],
    preferred_max_latency_seconds: 6,
    preferred_min_throughput_tokens_per_second: 20,
    max_prompt_price_usd_per_million: null,
    max_completion_price_usd_per_million: null,
    retry_policy: { key_retries: 2, parse_retries: 1 },
    enabled: true,
    updated_at: "2026-04-24T11:00:00Z",
  },
  {
    capability: "task_rewrite",
    strategy: "quality_first",
    min_context_length: 16000,
    required_parameters: ["response_format", "temperature", "max_tokens"],
    preferred_max_latency_seconds: 4,
    preferred_min_throughput_tokens_per_second: 30,
    max_prompt_price_usd_per_million: null,
    max_completion_price_usd_per_million: null,
    retry_policy: { key_retries: 2, parse_retries: 1 },
    enabled: true,
    updated_at: "2026-04-24T11:00:00Z",
  },
];

export const fallbackModelCatalog: ModelCatalogEntry[] = [
  {
    model_id: "anthropic/claude-sonnet-4",
    canonical_slug: "anthropic/claude-sonnet-4",
    name: "Claude Sonnet 4",
    description: "High quality general planning model.",
    context_length: 200000,
    output_modalities: ["text"],
    supported_parameters: ["response_format", "temperature", "max_tokens"],
    prompt_price_usd_per_million: 3,
    completion_price_usd_per_million: 15,
    request_price_usd: 0,
    top_provider_json: { max_completion_tokens: 8192 },
    architecture_json: { output_modalities: ["text"] },
    expiration_date: null,
    refreshed_at: "2026-04-24T11:45:00Z",
  },
  {
    model_id: "openai/gpt-4.1-mini",
    canonical_slug: "openai/gpt-4.1-mini",
    name: "GPT-4.1 mini",
    description: "Reliable fast structured output model.",
    context_length: 128000,
    output_modalities: ["text"],
    supported_parameters: ["response_format", "temperature", "max_tokens"],
    prompt_price_usd_per_million: 0.8,
    completion_price_usd_per_million: 3.2,
    request_price_usd: 0,
    top_provider_json: { max_completion_tokens: 8192 },
    architecture_json: { output_modalities: ["text"] },
    expiration_date: null,
    refreshed_at: "2026-04-24T11:45:00Z",
  },
];

export const fallbackModelSelections: ModelSelectionSnapshot[] = [
  {
    capability: "daily_plan",
    rank_index: 0,
    model_id: "anthropic/claude-sonnet-4",
    score: 0.963,
    selection_reason: { model_name: "Claude Sonnet 4", quality_prior: 0.97 },
    generated_at: "2026-04-24T11:50:00Z",
    expires_at: "2026-04-24T17:50:00Z",
  },
  {
    capability: "daily_plan",
    rank_index: 1,
    model_id: "openai/gpt-4.1-mini",
    score: 0.952,
    selection_reason: { model_name: "GPT-4.1 mini", quality_prior: 0.965 },
    generated_at: "2026-04-24T11:50:00Z",
    expires_at: "2026-04-24T17:50:00Z",
  },
  {
    capability: "task_rewrite",
    rank_index: 0,
    model_id: "openai/gpt-4.1-mini",
    score: 0.948,
    selection_reason: { model_name: "GPT-4.1 mini", quality_prior: 0.965 },
    generated_at: "2026-04-24T11:50:00Z",
    expires_at: "2026-04-24T17:50:00Z",
  },
];

export const fallbackOpenRouterKeyEvents: OpenRouterKeyEventRecord[] = [
  {
    event_id: "key-event-1",
    key_id: "or-key-2",
    key_label: "Secondary production key",
    event_type: "failure",
    endpoint: "/v1/missions/daily",
    model: "anthropic/claude-sonnet-4",
    error_code: "429",
    notes: "Rate limited, rotated to next key.",
    created_at: "2026-04-24T11:53:00Z",
  },
  {
    event_id: "key-event-2",
    key_id: "or-key-1",
    key_label: "Primary production key",
    event_type: "success",
    endpoint: "/v1/missions/daily",
    model: "openai/gpt-4.1-mini",
    error_code: null,
    notes: "Model fallback resolved on second candidate.",
    created_at: "2026-04-24T11:55:00Z",
  },
];

export const fallbackPrivacyRequests: PaginatedResponse<PrivacyRequestRow> = {
  items: [
    {
      request_id: "support-1",
      user_id: "user-2",
      request_type: "export",
      status: "open",
      requested_at: "2026-04-24T08:00:00Z",
    },
    {
      request_id: "support-2",
      user_id: "user-3",
      request_type: "delete",
      status: "done",
      requested_at: "2026-04-21T10:00:00Z",
    },
  ],
  total: 2,
  limit: 25,
  offset: 0,
  next_offset: null,
  fetched_at: "2026-04-26T09:00:00Z",
};

export const fallbackPrivacyDataMap: PrivacyDataMap = {
  encrypted_collections: ["expenses", "journal_entries", "quick_notes"],
  sensitive_data_excluded: true,
  retention_notes: [
    "Support exports generate temporary bundles.",
    "HomeMemory personal objects stay excluded until aggregate-only admin telemetry is available.",
  ],
};

export const fallbackSecuritySummary: SecuritySummary = {
  environment: "dev",
  admin_token_configured: false,
  ingestion_token_configured: false,
  internal_service_token_configured: false,
  production_ready: false,
  openrouter_key_count: 3,
  byok_key_count: 1,
  latest_audit_at: "2026-04-26T08:40:00Z",
  dependency_scan_status: "ci_required",
  failed_auth_placeholder: 0,
};

export const fallbackAuditLog: PaginatedResponse<AuditLogRow> = {
  items: [
    {
      audit_id: "audit-1",
      actor_id: "admin-operator",
      action: "patch_feature_flag",
      target_type: "feature_flag",
      target_id: "proof_parser",
      safe_diff: { enabled: true },
      correlation_id: "corr-1",
      created_at: "2026-04-26T08:40:00Z",
    },
    {
      audit_id: "audit-2",
      actor_id: "admin-operator",
      action: "disable_openrouter_key",
      target_type: "openrouter_key",
      target_id: "or-key-3",
      safe_diff: { enabled: false, status: "disabled" },
      correlation_id: "corr-2",
      created_at: "2026-04-25T17:20:00Z",
    },
  ],
  total: 2,
  limit: 25,
  offset: 0,
  next_offset: null,
  fetched_at: "2026-04-26T09:00:00Z",
};

export const fallbackHomeMemorySummary: HomeMemorySummary = {
  proof_parse_count: 0,
  warranty_reminder_count: 0,
  claim_draft_count: 0,
  evidence_attachment_count: 0,
  parser_success_rate: 0,
  fallback_rate: 0,
  locale_distribution: {},
  encrypted_collections: [],
  storage_impact_estimate: 0,
  sensitive_data_excluded: true,
};

export const fallbackHomeMemoryParserUsage: PaginatedResponse<HomeMemoryParserUsageRow> = {
  items: [],
  total: 0,
  limit: 25,
  offset: 0,
  next_offset: null,
  fetched_at: "2026-04-26T09:00:00Z",
};

export const fallbackQualitySummary: QualitySummary = {
  mission_usefulness_rate: 0.67,
  mission_completion_rate: 0.48,
  rejection_rate: 0.33,
  fallback_rate: 0.1,
  proof_parser_success_rate: 0,
  safety_interventions: 3,
  high_cost_anomalies: 1,
  support_escalations: 1,
};

export const fallbackQualityBreakdown: QualityBreakdownRow[] = [
  {
    dimension: "missions",
    label: "Mission usefulness",
    value: 0.67,
    unit: "ratio",
    source: "live",
  },
  {
    dimension: "cost",
    label: "AI cost per active user",
    value: 2.6,
    unit: "usd",
    source: "live",
  },
  {
    dimension: "homememory",
    label: "Proof parser success",
    value: 0,
    unit: "ratio",
    source: "derived",
  },
];

export const fallbackIncidents: PaginatedResponse<IncidentRow> = {
  items: [
    {
      incident_id: "routing-key-event-1",
      type: "routing_key_issue",
      severity: "medium",
      source: "web_backend",
      status: "monitoring",
      created_at: "2026-04-24T11:53:00Z",
      resolved_at: null,
      safe_summary: "Routing key event failure affected endpoint /v1/missions/daily.",
    },
    {
      incident_id: "privacy-support-1",
      type: "privacy_request_backlog",
      severity: "medium",
      source: "support",
      status: "open",
      created_at: "2026-04-24T08:00:00Z",
      resolved_at: null,
      safe_summary: "Export request waiting for operator action.",
    },
  ],
  total: 2,
  limit: 25,
  offset: 0,
  next_offset: null,
  fetched_at: "2026-04-26T09:00:00Z",
};

export const fallbackAuthStatus: AdminAuthStatus = {
  auth_mode: "token_only_scaffold",
  environment: "dev",
  admin_token_configured: false,
  production_ready: false,
  enterprise_ready: false,
  warning:
    "Token-only admin access is a scaffold. Use SSO or managed identity before enterprise production.",
};
