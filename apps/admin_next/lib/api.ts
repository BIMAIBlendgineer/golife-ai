import "server-only";

import {
  fallbackAICosts,
  fallbackAuditLog,
  fallbackAuthStatus,
  fallbackDashboard,
  fallbackFeatureFlags,
  fallbackFeedback,
  fallbackBillingAccounts,
  fallbackHomeMemoryParserUsage,
  fallbackHomeMemorySummary,
  fallbackIncidents,
  fallbackModelCatalog,
  fallbackModelSelections,
  fallbackMissions,
  fallbackModelSettings,
  fallbackOpenRouterByokKeys,
  fallbackOrganizationDetails,
  fallbackOrganizations,
  fallbackOpenRouterKeyEvents,
  fallbackOpenRouterKeys,
  fallbackPlans,
  fallbackPrivacyDataMap,
  fallbackPrivacyRequests,
  fallbackQualityBreakdown,
  fallbackQualitySummary,
  fallbackRoutingProfiles,
  fallbackSafety,
  fallbackSecuritySummary,
  fallbackSupportRequests,
  fallbackUserManagement,
  fallbackUserPrivacyById,
  fallbackUserSummaryById,
  fallbackUserSupportById,
  fallbackUserUsageById,
  fallbackUsage,
  fallbackStorageSummary,
  fallbackStorageUsage,
  fallbackXInsightCredits,
  fallbackXInsightUsage,
} from "@/lib/fallback-data";
import type {
  AICostSnapshot,
  AdminBackendHealth,
  AdminDataState,
  AdminAuthStatus,
  AdminFetchResult,
  AiUsageLedgerRow,
  AuditLogRow,
  BillingAccountRow,
  DashboardMetrics,
  FeatureFlag,
  FeedbackAuditRecord,
  HomeMemoryParserUsageRow,
  HomeMemorySummary,
  IncidentRow,
  ModelCatalogEntry,
  MissionAuditRecord,
  ModelSettingsSnapshot,
  ModelSelectionSnapshot,
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
  SupportRequestExecutionResult,
  UserManagementRow,
  UserPrivacySummary,
  UserSummary,
  UserSupportSummary,
  UserUsageSummary,
  UsageSnapshot,
  XInsightCreditSummary,
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

function asPage<T>(
  items: T[],
  options?: {
    limit?: number;
    offset?: number;
  },
): PaginatedResponse<T> {
  const limit = options?.limit ?? 25;
  const offset = options?.offset ?? 0;
  const nextOffset = offset + limit < items.length ? offset + limit : null;
  return {
    items: items.slice(offset, offset + limit),
    total: items.length,
    limit,
    offset,
    next_offset: nextOffset,
    fetched_at: new Date().toISOString(),
  };
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
  body: Record<string, unknown> = {},
  method: "PATCH" | "POST" = "PATCH",
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

export async function getUsage(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<UsageSnapshot>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  const suffix = `?limit=${limit}&offset=${offset}`;
  return adminRequest(`/admin/usage${suffix}`, {
    fallbackData: asPage(fallbackUsage, { limit, offset }),
  });
}

export async function getOrganizations(params?: {
  limit?: number;
  offset?: number;
  query?: string;
  status?: string;
  plan?: string;
}): Promise<AdminFetchResult<PaginatedResponse<OrganizationRow>>> {
  const searchParams = new URLSearchParams();
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  searchParams.set("limit", String(limit));
  searchParams.set("offset", String(offset));
  if (params?.query) searchParams.set("query", params.query);
  if (params?.status) searchParams.set("status", params.status);
  if (params?.plan) searchParams.set("plan", params.plan);
  return adminRequest(`/admin/organizations?${searchParams.toString()}`, {
    fallbackData: asPage(fallbackOrganizations, { limit, offset }),
  });
}

export async function getOrganization(
  organizationId: string,
): Promise<AdminFetchResult<OrganizationDetail | null>> {
  return adminRequest(`/admin/organizations/${organizationId}`, {
    fallbackData: fallbackOrganizationDetails[organizationId] ?? null,
  });
}

export async function getPlans(): Promise<AdminFetchResult<PlanRow[]>> {
  return adminRequest("/admin/plans", {
    fallbackData: fallbackPlans,
  });
}

export async function getOpenRouterByokKeys(): Promise<
  AdminFetchResult<OpenRouterByokKeyRecord[]>
> {
  return adminRequest("/admin/openrouter-byok", {
    fallbackData: fallbackOpenRouterByokKeys,
  });
}

export async function getXInsightUsage(): Promise<
  AdminFetchResult<AiUsageLedgerRow[]>
> {
  return adminRequest("/admin/xinsightai/usage", {
    fallbackData: fallbackXInsightUsage,
  });
}

export async function getXInsightCredits(): Promise<
  AdminFetchResult<XInsightCreditSummary>
> {
  return adminRequest("/admin/xinsightai/credits", {
    fallbackData: fallbackXInsightCredits,
  });
}

export async function getXInsightPlans(): Promise<AdminFetchResult<PlanRow[]>> {
  return adminRequest("/admin/xinsightai/plans", {
    fallbackData: fallbackPlans.filter((plan) => plan.ai_credit_policy !== "No bundled credits"),
  });
}

export async function getBillingAccounts(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<BillingAccountRow>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  return adminRequest(`/admin/billing/accounts?limit=${limit}&offset=${offset}`, {
    fallbackData: asPage(fallbackBillingAccounts, { limit, offset }),
  });
}

export async function getBillingPlans(): Promise<AdminFetchResult<PlanRow[]>> {
  return adminRequest("/admin/billing/plans", {
    fallbackData: fallbackPlans,
  });
}

export async function getStorageSummary(): Promise<
  AdminFetchResult<StorageSummary>
> {
  return adminRequest("/admin/storage/summary", {
    fallbackData: fallbackStorageSummary,
  });
}

export async function getStorageUsage(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<StorageUsageRow>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  return adminRequest(`/admin/storage/usage?limit=${limit}&offset=${offset}`, {
    fallbackData: asPage(fallbackStorageUsage, { limit, offset }),
  });
}

export async function getAICosts(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<AICostSnapshot>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  return adminRequest(`/admin/ai-costs?limit=${limit}&offset=${offset}`, {
    fallbackData: asPage(fallbackAICosts, { limit, offset }),
  });
}

export async function getMissions(): Promise<AdminFetchResult<MissionAuditRecord[]>> {
  return adminRequest("/admin/missions", {
    fallbackData: fallbackMissions,
  });
}

export async function getFeedback(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<FeedbackAuditRecord>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  return adminRequest(`/admin/feedback?limit=${limit}&offset=${offset}`, {
    fallbackData: asPage(fallbackFeedback, { limit, offset }),
  });
}

export async function getSafety(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<SafetyAuditRecord>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  return adminRequest(`/admin/safety?limit=${limit}&offset=${offset}`, {
    fallbackData: asPage(fallbackSafety, { limit, offset }),
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

export async function resolveSupportRequest(
  requestId: string,
): Promise<AdminFetchResult<SupportRequestExecutionResult>> {
  return adminWrite(`/admin/support/export-delete/${requestId}/resolve`, {}, "POST");
}

export async function executeDeleteSupportRequest(
  requestId: string,
): Promise<AdminFetchResult<SupportRequestExecutionResult>> {
  return adminWrite(
    `/admin/support/export-delete/${requestId}/execute-delete`,
    {},
    "POST",
  );
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

export async function getPrivacyRequests(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<PrivacyRequestRow>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  return adminRequest(`/admin/privacy/requests?limit=${limit}&offset=${offset}`, {
    fallbackData: {
      ...fallbackPrivacyRequests,
      limit,
      offset,
      items: fallbackPrivacyRequests.items.slice(offset, offset + limit),
      next_offset:
        offset + limit < fallbackPrivacyRequests.items.length ? offset + limit : null,
    },
  });
}

export async function getPrivacyDataMap(): Promise<AdminFetchResult<PrivacyDataMap>> {
  return adminRequest("/admin/privacy/data-map", {
    fallbackData: fallbackPrivacyDataMap,
  });
}

export async function getSecuritySummary(): Promise<AdminFetchResult<SecuritySummary>> {
  return adminRequest("/admin/security/summary", {
    fallbackData: fallbackSecuritySummary,
  });
}

export async function getAuditLog(params?: {
  limit?: number;
  offset?: number;
  actor?: string;
  action?: string;
}): Promise<AdminFetchResult<PaginatedResponse<AuditLogRow>>> {
  const searchParams = new URLSearchParams();
  searchParams.set("limit", String(params?.limit ?? 25));
  searchParams.set("offset", String(params?.offset ?? 0));
  if (params?.actor) searchParams.set("actor", params.actor);
  if (params?.action) searchParams.set("action", params.action);
  return adminRequest(`/admin/audit?${searchParams.toString()}`, {
    fallbackData: fallbackAuditLog,
  });
}

export async function getHomeMemorySummary(): Promise<AdminFetchResult<HomeMemorySummary>> {
  return adminRequest("/admin/homememory/summary", {
    fallbackData: fallbackHomeMemorySummary,
  });
}

export async function getHomeMemoryParserUsage(params?: {
  limit?: number;
  offset?: number;
}): Promise<AdminFetchResult<PaginatedResponse<HomeMemoryParserUsageRow>>> {
  const limit = params?.limit ?? 25;
  const offset = params?.offset ?? 0;
  return adminRequest(`/admin/homememory/parser-usage?limit=${limit}&offset=${offset}`, {
    fallbackData: {
      ...fallbackHomeMemoryParserUsage,
      limit,
      offset,
      items: fallbackHomeMemoryParserUsage.items.slice(offset, offset + limit),
      next_offset:
        offset + limit < fallbackHomeMemoryParserUsage.items.length ? offset + limit : null,
    },
  });
}

export async function getQualitySummary(): Promise<AdminFetchResult<QualitySummary>> {
  return adminRequest("/admin/quality/summary", {
    fallbackData: fallbackQualitySummary,
  });
}

export async function getQualityBreakdown(): Promise<
  AdminFetchResult<QualityBreakdownRow[]>
> {
  return adminRequest("/admin/quality/breakdown", {
    fallbackData: fallbackQualityBreakdown,
  });
}

export async function getIncidents(params?: {
  limit?: number;
  offset?: number;
  severity?: string;
  status?: string;
}): Promise<AdminFetchResult<PaginatedResponse<IncidentRow>>> {
  const searchParams = new URLSearchParams();
  searchParams.set("limit", String(params?.limit ?? 25));
  searchParams.set("offset", String(params?.offset ?? 0));
  if (params?.severity) searchParams.set("severity", params.severity);
  if (params?.status) searchParams.set("status", params.status);
  return adminRequest(`/admin/incidents?${searchParams.toString()}`, {
    fallbackData: fallbackIncidents,
  });
}

export async function getAuthStatus(): Promise<AdminFetchResult<AdminAuthStatus>> {
  return adminRequest("/admin/auth/status", {
    fallbackData: fallbackAuthStatus,
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
