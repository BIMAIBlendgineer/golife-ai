import Link from "next/link";

import { ErrorBanner } from "@/components/error-banner";
import { DetailDrawer } from "@/components/premium/detail-drawer";
import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { EmptyState } from "@/components/premium/empty-state";
import { FilterBar } from "@/components/premium/filter-bar";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import {
  getUserPrivacySummary,
  getUserSummary,
  getUserSupportSummary,
  getUserUsageSummary,
  getUsers,
} from "@/lib/api";
import { formatDateTime, formatLatency, formatPercent } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { UserManagementRow } from "@/lib/types";

function withSearchParams(
  entries: Record<string, string | number | null | undefined>,
): string {
  const searchParams = new URLSearchParams();
  Object.entries(entries).forEach(([key, value]) => {
    if (value == null || value === "") {
      return;
    }
    searchParams.set(key, String(value));
  });
  const query = searchParams.toString();
  return query ? `?${query}` : "";
}

function privacyTone(status: UserManagementRow["privacy_request_status"]) {
  switch (status) {
    case "export_open":
    case "delete_open":
      return "warn";
    case "mixed_open":
      return "danger";
    case "completed":
      return "good";
    case "none":
    default:
      return "neutral";
  }
}

export default async function UsersPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.users;
  const params = await searchParams;
  const query = typeof params.query === "string" ? params.query : "";
  const status = typeof params.status === "string" ? params.status : "";
  const plan = typeof params.plan === "string" ? params.plan : "";
  const localeFilter = typeof params.locale === "string" ? params.locale : "";
  const limit = Math.min(
    100,
    Math.max(
      10,
      Number.parseInt(
        typeof params.limit === "string" ? params.limit : "25",
        10,
      ) || 25,
    ),
  );
  const offset = Math.max(
    0,
    Number.parseInt(typeof params.offset === "string" ? params.offset : "0", 10) || 0,
  );

  const usersResult = await getUsers({
    limit,
    offset,
    query,
    status: status || undefined,
    plan: plan || undefined,
    locale: localeFilter || undefined,
  });
  const page = usersResult.data;
  const users = page?.items ?? [];
  const selectedUserId =
    (typeof params.selected === "string" ? params.selected : null) ??
    users[0]?.user_id ??
    null;

  const [summaryResult, usageResult, privacyResult, supportResult] =
    selectedUserId == null
      ? [null, null, null, null]
      : await Promise.all([
          getUserSummary(selectedUserId),
          getUserUsageSummary(selectedUserId),
          getUserPrivacySummary(selectedUserId),
          getUserSupportSummary(selectedUserId),
        ]);

  const error =
    [
      usersResult.error,
      summaryResult?.error,
      usageResult?.error,
      privacyResult?.error,
      supportResult?.error,
    ]
      .filter(Boolean)
      .join(" | ") || null;

  const activeUsers = users.filter((user) => user.status === "active").length;
  const supportQueue = users.filter((user) => user.support_flags.length > 0).length;
  const privacyRequests = users.filter(
    (user) => user.privacy_request_status !== "none",
  ).length;

  const columns: Array<DataColumn<UserManagementRow>> = [
    {
      id: "user",
      header: t.tableUser,
      cell: (user) => (
        <div className="min-w-[220px]">
          <Link
            href={`/users/${user.user_id}`}
            className="block text-sm font-semibold text-ink"
          >
            {user.display_name}
          </Link>
          <p className="mt-1 text-sm text-[color:var(--ink-soft)]">
            {user.email_masked}
          </p>
          <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
            {user.user_id}
          </p>
        </div>
      ),
    },
    {
      id: "locale",
      header: t.tableLocale,
      cell: (user) => <StatusPill tone="neutral">{user.locale}</StatusPill>,
    },
    {
      id: "plan",
      header: t.tablePlan,
      cell: (user) => (
        <StatusPill tone={user.plan === "plus" ? "good" : "neutral"}>
          {user.plan}
        </StatusPill>
      ),
    },
    {
      id: "status",
      header: t.tableStatus,
      cell: (user) => (
        <StatusPill tone={user.status === "active" ? "good" : "warn"}>
          {user.status}
        </StatusPill>
      ),
    },
    {
      id: "aiCalls",
      header: t.tableAiCalls,
      cell: (user) => <span className="text-sm text-ink">{user.ai_calls_count}</span>,
    },
    {
      id: "useful",
      header: t.tableUsefulMissions,
      cell: (user) => (
        <span className="text-sm text-ink">{user.useful_missions_count}</span>
      ),
    },
    {
      id: "fallback",
      header: t.tableFallback,
      cell: (user) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatPercent(user.fallback_rate, locale)}
        </span>
      ),
    },
    {
      id: "lastSeen",
      header: t.tableLastSeen,
      cell: (user) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatDateTime(user.last_seen_at, locale)}
        </span>
      ),
    },
    {
      id: "support",
      header: t.tableSupport,
      cell: (user) => (
        <div className="flex min-w-[180px] flex-wrap gap-2">
          {user.support_flags.length === 0 ? (
            <StatusPill tone="neutral">{messages.shared.none}</StatusPill>
          ) : (
            user.support_flags.map((flag) => (
              <StatusPill key={flag} tone="info">
                {flag}
              </StatusPill>
            ))
          )}
        </div>
      ),
    },
    {
      id: "privacy",
      header: t.tablePrivacy,
      cell: (user) => (
        <StatusPill tone={privacyTone(user.privacy_request_status)}>
          {user.privacy_request_status}
        </StatusPill>
      ),
    },
  ];

  const previousHref =
    offset > 0
      ? withSearchParams({
          query,
          status,
          plan,
          locale: localeFilter,
          limit,
          offset: Math.max(0, offset - limit),
          selected: selectedUserId ?? undefined,
        })
      : null;
  const nextHref =
    page?.next_offset != null
      ? withSearchParams({
          query,
          status,
          plan,
          locale: localeFilter,
          limit,
          offset: page.next_offset,
          selected: selectedUserId ?? undefined,
        })
      : null;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={error} />

      <KpiGrid className="xl:grid-cols-4">
        <MetricCard
          label={t.totalUsersLabel}
          value={(page?.total ?? users.length).toString()}
          note={t.totalUsersNote}
          tone="ink"
        />
        <MetricCard
          label={t.weeklyActiveLabel}
          value={activeUsers.toString()}
          note={t.weeklyActiveNote}
          tone="sage"
        />
        <MetricCard
          label={t.supportQueueLabel}
          value={supportQueue.toString()}
          note={t.supportQueueNote}
          tone="clay"
        />
        <MetricCard
          label={t.privacyRequestsLabel}
          value={privacyRequests.toString()}
          note={t.privacyRequestsNote}
          tone="bronze"
        />
      </KpiGrid>

      <FilterBar>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterQuery}
          </span>
          <input
            type="search"
            name="query"
            defaultValue={query}
            placeholder={t.filterQueryPlaceholder}
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          />
        </label>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterPlan}
          </span>
          <select
            name="plan"
            defaultValue={plan}
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          >
            <option value="">{messages.shared.none}</option>
            <option value="free">free</option>
            <option value="plus">plus</option>
            <option value="internal">internal</option>
          </select>
        </label>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterStatus}
          </span>
          <select
            name="status"
            defaultValue={status}
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          >
            <option value="">{messages.shared.none}</option>
            <option value="active">active</option>
            <option value="paused">paused</option>
            <option value="trial">trial</option>
          </select>
        </label>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterLocale}
          </span>
          <select
            name="locale"
            defaultValue={localeFilter}
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          >
            <option value="">{messages.shared.none}</option>
            <option value="en">en</option>
            <option value="es">es</option>
            <option value="pt-BR">pt-BR</option>
            <option value="ja">ja</option>
            <option value="zh-Hans">zh-Hans</option>
          </select>
        </label>
        <input type="hidden" name="limit" value={limit} />
        <div className="flex items-end gap-2">
          <button
            type="submit"
            className="rounded-lg border border-[color:var(--line-strong)] bg-[color:var(--surface)] px-3 py-2 text-sm font-medium text-ink"
          >
            {t.applyFilters}
          </button>
          <Link
            href="/users"
            className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm font-medium text-[color:var(--ink-soft)]"
          >
            {t.resetFilters}
          </Link>
        </div>
      </FilterBar>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.5fr)_380px]">
        <section className="space-y-4">
          <DataTable
            columns={columns}
            rows={users}
            rowKey={(user) => user.user_id}
            emptyState={
              <EmptyState title={t.emptyTitle} body={t.emptyBody} />
            }
          />
          <div className="flex flex-wrap items-center justify-between gap-3">
            <p className="text-sm text-[color:var(--ink-soft)]">
              {t.pageSummaryPrefix} {page?.offset ?? 0}
              {" - "}
              {(page?.offset ?? 0) + users.length} {t.pageSummaryMiddle}{" "}
              {page?.total ?? users.length}
            </p>
            <div className="flex gap-2">
              {previousHref ? (
                <Link
                  href={`/users${previousHref}`}
                  className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] px-3 py-2 text-sm text-ink"
                >
                  {t.previousPage}
                </Link>
              ) : null}
              {nextHref ? (
                <Link
                  href={`/users${nextHref}`}
                  className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] px-3 py-2 text-sm text-ink"
                >
                  {t.nextPage}
                </Link>
              ) : null}
            </div>
          </div>
        </section>

        <DetailDrawer
          title={summaryResult?.data?.display_name ?? t.detailEmptyTitle}
          description={summaryResult?.data?.email_masked ?? t.detailEmptyBody}
        >
          {summaryResult?.data && usageResult?.data && privacyResult?.data && supportResult?.data ? (
            <div className="space-y-4 text-sm leading-6 text-[color:var(--ink-soft)]">
              <div className="grid gap-3 sm:grid-cols-2">
                <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                    {t.drawerPlan}
                  </p>
                  <p className="mt-1 text-sm text-ink">{summaryResult.data.plan}</p>
                </div>
                <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                    {t.drawerLocale}
                  </p>
                  <p className="mt-1 text-sm text-ink">{summaryResult.data.locale}</p>
                </div>
                <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                    {t.drawerCreated}
                  </p>
                  <p className="mt-1 text-sm text-ink">
                    {formatDateTime(summaryResult.data.created_at, locale)}
                  </p>
                </div>
                <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-3">
                  <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                    {t.drawerLastSeen}
                  </p>
                  <p className="mt-1 text-sm text-ink">
                    {formatDateTime(summaryResult.data.last_seen_at, locale)}
                  </p>
                </div>
              </div>

              <div className="space-y-2">
                <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.drawerUsage}
                </p>
                <p>
                  {usageResult.data.ai_calls_count} AI calls,{" "}
                  {usageResult.data.capture_events} capture events,{" "}
                  {formatPercent(usageResult.data.fallback_rate, locale)} fallback,{" "}
                  {formatLatency(usageResult.data.latency_ms_avg, locale, messages.shared.msUnit)}
                  .
                </p>
              </div>

              <div className="space-y-2">
                <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.drawerPrivacy}
                </p>
                <p>
                  {privacyResult.data.privacy_request_status}.{" "}
                  {privacyResult.data.open_requests.length > 0
                    ? privacyResult.data.open_requests.join(", ")
                    : messages.shared.none}
                  .
                </p>
                <p>{t.drawerSensitiveExcluded}</p>
              </div>

              <div className="space-y-2">
                <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.drawerSupport}
                </p>
                <div className="flex flex-wrap gap-2">
                  {supportResult.data.support_flags.length > 0 ? (
                    supportResult.data.support_flags.map((flag) => (
                      <StatusPill key={flag} tone="info">
                        {flag}
                      </StatusPill>
                    ))
                  ) : (
                    <StatusPill tone="neutral">{messages.shared.none}</StatusPill>
                  )}
                </div>
                <p>
                  {supportResult.data.open_request_count} {t.drawerOpenRequests}
                </p>
              </div>
            </div>
          ) : (
            <EmptyState title={t.detailEmptyTitle} body={t.detailEmptyBody} />
          )}
        </DetailDrawer>
      </div>
    </>
  );
}
