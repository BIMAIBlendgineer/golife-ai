import "server-only";

import {
  fallbackAICosts,
  fallbackDashboard,
  fallbackFeatureFlags,
  fallbackFeedback,
  fallbackModelCatalog,
  fallbackModelSelections,
  fallbackMissions,
  fallbackModelSettings,
  fallbackOpenRouterKeyEvents,
  fallbackOpenRouterKeys,
  fallbackRoutingProfiles,
  fallbackSafety,
  fallbackSupportRequests,
  fallbackUserManagement,
  fallbackUserPrivacyById,
  fallbackUserSummaryById,
  fallbackUserSupportById,
  fallbackUserUsageById,
  fallbackUsage,
} from "@/lib/fallback-data";
import type {
  AICostSnapshot,
  AdminBackendHealth,
  AdminDataState,
  AdminFetchResult,
  DashboardMetrics,
  FeatureFlag,
  FeedbackAuditRecord,
  ModelCatalogEntry,
  MissionAuditRecord,
  ModelSettingsSnapshot,
  ModelSelectionSnapshot,
  OpenRouterApiKeyRecord,
  OpenRouterKeyEventRecord,
  PaginatedResponse,
  RoutingProfile,
  SafetyAuditRecord,
  SupportRequest,
  UserManagementRow,
  UserPrivacySummary,
  UserSummary,
  UserSupportSummary,
  UserUsageSummary,
  UsageSnapshot,
} from "@/lib/types";

const ADMIN_API_BASE_URL =
  process.env.GOLIFE_ADMIN_API_BASE_URL ?? "http://127.0.0.1:8010";
const ADMIN_API_TOKEN =
  process.env.GOLIFE_ADMIN_API_TOKEN ??
  (process.env.NODE_ENV === "production" ? "" : "golife-admin-dev");

type RequestOptions = {
  method?: "GET" | "PATCH";
  body?: string;
  fallbackData: unknown;
  fallbackSource?: Extract<AdminDataState, "fallback" | "offline">;
};

function fallbackMessage(path: string, cause: string): string {
  return `Using fallback snapshot for ${path}: ${cause}`;
}

async function adminRequest<T>(
  path: string,
  {
    method = "GET",
    body,
    fallbackData,
    fallbackSource = "fallback",
  }: RequestOptions,
): Promise<AdminFetchResult<T>> {
  const fetchedAt = new Date().toISOString();
  try {
    const response = await fetch(`${ADMIN_API_BASE_URL}${path}`, {
      method,
      cache: "no-store",
      headers: {
        "content-type": "application/json",
        "x-admin-token": ADMIN_API_TOKEN,
      },
      body,
      signal: AbortSignal.timeout(3000),
    });

    if (!response.ok) {
      return {
        data: fallbackData as T,
        error: fallbackMessage(path, `${response.status} ${response.statusText}`),
        source: fallbackSource,
        fetchedAt,
      };
    }

    const data = (await response.json()) as T;
    return { data, error: null, source: "live", fetchedAt };
  } catch (error) {
    return {
      data: fallbackData as T,
      error: fallbackMessage(
        path,
        error instanceof Error ? error.message : "unknown error",
      ),
      source: fallbackSource,
      fetchedAt,
    };
  }
}

async function adminWrite<T>(
  path: string,
  body: Record<string, unknown>,
): Promise<AdminFetchResult<T>> {
  const fetchedAt = new Date().toISOString();
  try {
    const response = await fetch(`${ADMIN_API_BASE_URL}${path}`, {
      method: "PATCH",
      cache: "no-store",
      headers: {
        "content-type": "application/json",
        "x-admin-token": ADMIN_API_TOKEN,
      },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(3000),
    });

    if (!response.ok) {
      return {
        data: null,
        error: `${response.status} ${response.statusText}`,
        source: "offline",
        fetchedAt,
      };
    }

    return {
      data: (await response.json()) as T,
      error: null,
      source: "live",
      fetchedAt,
    };
  } catch (error) {
    return {
      data: null,
      error: error instanceof Error ? error.message : "unknown error",
      source: "offline",
      fetchedAt,
    };
  }
}

export function getAdminRuntime(): {
  baseUrl: string;
  tokenConfigured: boolean;
} {
  return {
    baseUrl: ADMIN_API_BASE_URL,
    tokenConfigured: ADMIN_API_TOKEN.length > 0,
  };
}

export async function getBackendHealth(): Promise<
  AdminFetchResult<AdminBackendHealth>
> {
  return adminRequest("/health", {
    fallbackData: {
      status: "ok",
      data_source: "unreachable_backend",
      mode: "seeded",
      storage_path: ADMIN_API_BASE_URL,
      last_ingestion_at: null,
    } satisfies AdminBackendHealth,
    fallbackSource: "offline",
  });
}

export async function getDashboard(): Promise<AdminFetchResult<DashboardMetrics>> {
  return adminRequest("/admin/dashboard", {
    fallbackData: fallbackDashboard,
  });
}

export async function getUsers(params?: {
  limit?: number;
  offset?: number;
  query?: string;
  status?: string;
  plan?: string;
  locale?: string;
}): Promise<AdminFetchResult<PaginatedResponse<UserManagementRow>>> {
  const searchParams = new URLSearchParams();
  if (params?.limit != null) searchParams.set("limit", String(params.limit));
  if (params?.offset != null) searchParams.set("offset", String(params.offset));
  if (params?.query) searchParams.set("query", params.query);
  if (params?.status) searchParams.set("status", params.status);
  if (params?.plan) searchParams.set("plan", params.plan);
  if (params?.locale) searchParams.set("locale", params.locale);
  const suffix = searchParams.toString() ? `?${searchParams.toString()}` : "";
  return adminRequest(`/admin/users${suffix}`, {
    fallbackData: fallbackUserManagement,
  });
}

export async function getUser(
  userId: string,
): Promise<AdminFetchResult<UserSummary | null>> {
  const result = await adminRequest<UserSummary | null>(`/admin/users/${userId}`, {
    fallbackData: fallbackUserSummaryById[userId] ?? null,
  });
  return result;
}

export async function getUserSummary(
  userId: string,
): Promise<AdminFetchResult<UserSummary | null>> {
  return adminRequest<UserSummary | null>(`/admin/users/${userId}/summary`, {
    fallbackData: fallbackUserSummaryById[userId] ?? null,
  });
}

export async function getUserUsageSummary(
  userId: string,
): Promise<AdminFetchResult<UserUsageSummary | null>> {
  return adminRequest<UserUsageSummary | null>(`/admin/users/${userId}/usage`, {
    fallbackData: fallbackUserUsageById[userId] ?? null,
  });
}

export async function getUserPrivacySummary(
  userId: string,
): Promise<AdminFetchResult<UserPrivacySummary | null>> {
  return adminRequest<UserPrivacySummary | null>(`/admin/users/${userId}/privacy`, {
    fallbackData: fallbackUserPrivacyById[userId] ?? null,
  });
}

export async function getUserSupportSummary(
  userId: string,
): Promise<AdminFetchResult<UserSupportSummary | null>> {
  return adminRequest<UserSupportSummary | null>(`/admin/users/${userId}/support`, {
    fallbackData: fallbackUserSupportById[userId] ?? null,
  });
}

export async function getUsage(): Promise<AdminFetchResult<UsageSnapshot[]>> {
  return adminRequest("/admin/usage", {
    fallbackData: fallbackUsage,
  });
}

export async function getAICosts(): Promise<AdminFetchResult<AICostSnapshot[]>> {
  return adminRequest("/admin/ai-costs", {
    fallbackData: fallbackAICosts,
  });
}

export async function getMissions(): Promise<AdminFetchResult<MissionAuditRecord[]>> {
  return adminRequest("/admin/missions", {
    fallbackData: fallbackMissions,
  });
}

export async function getFeedback(): Promise<AdminFetchResult<FeedbackAuditRecord[]>> {
  return adminRequest("/admin/feedback", {
    fallbackData: fallbackFeedback,
  });
}

export async function getSafety(): Promise<AdminFetchResult<SafetyAuditRecord[]>> {
  return adminRequest("/admin/safety", {
    fallbackData: fallbackSafety,
  });
}

export async function getFeatureFlags(): Promise<AdminFetchResult<FeatureFlag[]>> {
  return adminRequest("/admin/feature-flags", {
    fallbackData: fallbackFeatureFlags,
  });
}

export async function updateFeatureFlag(
  key: string,
  enabled: boolean,
): Promise<AdminFetchResult<FeatureFlag>> {
  return adminWrite(`/admin/feature-flags/${key}`, { enabled });
}

export async function getModelSettings(): Promise<
  AdminFetchResult<ModelSettingsSnapshot>
> {
  return adminRequest("/admin/models", {
    fallbackData: fallbackModelSettings,
  });
}

export async function getSupportRequests(): Promise<
  AdminFetchResult<SupportRequest[]>
> {
  return adminRequest("/admin/support/export-delete", {
    fallbackData: fallbackSupportRequests,
  });
}

export async function getOpenRouterKeys(): Promise<
  AdminFetchResult<OpenRouterApiKeyRecord[]>
> {
  return adminRequest("/admin/openrouter/keys", {
    fallbackData: fallbackOpenRouterKeys,
  });
}

export async function getOpenRouterKeyEvents(): Promise<
  AdminFetchResult<OpenRouterKeyEventRecord[]>
> {
  return adminRequest("/admin/openrouter/key-events", {
    fallbackData: fallbackOpenRouterKeyEvents,
  });
}

export async function getRoutingProfiles(): Promise<
  AdminFetchResult<RoutingProfile[]>
> {
  return adminRequest("/admin/routing-profiles", {
    fallbackData: fallbackRoutingProfiles,
  });
}

export async function getModelCatalog(): Promise<
  AdminFetchResult<ModelCatalogEntry[]>
> {
  return adminRequest("/admin/model-catalog", {
    fallbackData: fallbackModelCatalog,
  });
}

export async function getModelSelections(): Promise<
  AdminFetchResult<ModelSelectionSnapshot[]>
> {
  return adminRequest("/admin/model-selections", {
    fallbackData: fallbackModelSelections,
  });
}
