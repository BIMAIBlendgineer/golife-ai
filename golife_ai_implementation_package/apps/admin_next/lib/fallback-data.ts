import type {
  AICostSnapshot,
  AdminUser,
  DashboardMetrics,
  FeatureFlag,
  FeedbackAuditRecord,
  MissionAuditRecord,
  ModelSettingsSnapshot,
  SafetyAuditRecord,
  SupportRequest,
  UsageSnapshot,
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
    reason: "Pantry rescue prevented another spend.",
    domains: ["finance", "pantry"],
    created_at: "2026-04-24T06:00:00Z",
  },
  {
    feedback_id: "feedback-002",
    user_id: "local-user",
    suggestion_id: "mission-002",
    status: "accepted",
    reason: "Habit mission matched energy.",
    domains: ["task", "habit"],
    created_at: "2026-04-24T08:00:00Z",
  },
  {
    feedback_id: "feedback-003",
    user_id: "user-2",
    suggestion_id: "mission-003",
    status: "rejected",
    reason: "Already owned a similar jacket.",
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
