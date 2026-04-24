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

export type SupportRequest = {
  request_id: string;
  user_id: string;
  request_type: "export" | "delete";
  status: "open" | "done";
  requested_at: string;
};

export type AdminFetchResult<T> = {
  data: T | null;
  error: string | null;
};
