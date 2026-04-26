import { ErrorBanner } from "@/components/error-banner";
import { DetailDrawer } from "@/components/premium/detail-drawer";
import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { EmptyState } from "@/components/premium/empty-state";
import { FilterBar } from "@/components/premium/filter-bar";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getOrganization, getOrganizations } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { OrganizationRow } from "@/lib/types";
import { withSearchParams } from "@/lib/url";

export default async function OrganizationsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.organizations;
  const params = await searchParams;
  const query = typeof params.query === "string" ? params.query.toLowerCase() : "";
  const status = typeof params.status === "string" ? params.status : "";
  const plan = typeof params.plan === "string" ? params.plan : "";
  const limit = Math.min(
    100,
    Math.max(
      10,
      Number.parseInt(typeof params.limit === "string" ? params.limit : "25", 10) || 25,
    ),
  );
  const offset = Math.max(
    0,
    Number.parseInt(typeof params.offset === "string" ? params.offset : "0", 10) || 0,
  );

  const organizationsResult = await getOrganizations({
    limit,
    offset,
    query: query || undefined,
    status: status || undefined,
    plan: plan || undefined,
  });
  const page = organizationsResult.data;
  const organizations = page?.items ?? [];
  const selectedOrganizationId =
    (typeof params.selected === "string" ? params.selected : null) ??
    organizations[0]?.organization_id ??
    null;
  const detailResult =
    selectedOrganizationId == null
      ? null
      : await getOrganization(selectedOrganizationId);

  const totalUsers = organizations.reduce(
    (sum, organization) => sum + organization.user_count,
    0,
  );
  const totalStorage = organizations.reduce(
    (sum, organization) => sum + organization.storage_used_gb,
    0,
  );

  const columns: Array<DataColumn<OrganizationRow>> = [
    {
      id: "organization",
      header: t.tableOrganization,
      cell: (organization) => (
        <div>
          <p className="text-sm font-semibold text-ink">{organization.name}</p>
          <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
            {organization.organization_id}
          </p>
        </div>
      ),
    },
    {
      id: "status",
      header: t.tableStatus,
      cell: (organization) => (
        <StatusPill tone={organization.status === "active" ? "good" : "warn"}>
          {organization.status}
        </StatusPill>
      ),
    },
    {
      id: "plan",
      header: t.tablePlan,
      cell: (organization) => <StatusPill tone="info">{organization.plan}</StatusPill>,
    },
    {
      id: "users",
      header: t.tableUsers,
      cell: (organization) => (
        <span className="text-sm text-ink">
          {formatNumber(organization.user_count, locale)}
        </span>
      ),
    },
    {
      id: "storage",
      header: t.tableStorage,
      cell: (organization) => (
        <span className="text-sm text-ink">
          {formatNumber(organization.storage_used_gb, locale)} GB
        </span>
      ),
    },
    {
      id: "aiMode",
      header: t.tableAiMode,
      cell: (organization) => (
        <StatusPill tone="neutral">{organization.ai_mode_default}</StatusPill>
      ),
    },
    {
      id: "created",
      header: t.tableCreated,
      cell: (organization) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatDateTime(organization.created_at, locale)}
        </span>
      ),
    },
  ];

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={organizationsResult.error ?? detailResult?.error ?? null} />

      <KpiGrid className="xl:grid-cols-3">
        <MetricCard
          label={t.totalOrganizationsLabel}
          value={(page?.total ?? organizations.length).toString()}
          note={t.totalOrganizationsNote}
          tone="ink"
        />
        <MetricCard
          label={t.totalUsersLabel}
          value={formatNumber(totalUsers, locale)}
          note={t.totalUsersNote}
          tone="sage"
        />
        <MetricCard
          label={t.totalStorageLabel}
          value={`${formatNumber(totalStorage, locale)} GB`}
          note={t.totalStorageNote}
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
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          />
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
            <option value="trial">trial</option>
            <option value="paused">paused</option>
          </select>
        </label>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterPlan}
          </span>
          <input
            type="text"
            name="plan"
            defaultValue={plan}
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          />
        </label>
        <div className="flex items-end">
          <button
            type="submit"
            className="rounded-lg border border-[color:var(--line-strong)] bg-[color:var(--surface)] px-3 py-2 text-sm font-medium text-ink"
          >
            {t.applyFilters}
          </button>
        </div>
      </FilterBar>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.4fr)_360px]">
        <div className="space-y-4">
          <DataTable
            columns={columns}
            rows={organizations}
            rowKey={(organization) => organization.organization_id}
            emptyState={<EmptyState title={t.emptyTitle} body={t.emptyBody} />}
          />
          <PaginationFooter
            summary={`${messages.shared.pageSummaryPrefix} ${organizations.length} ${messages.shared.pageSummaryMiddle} ${page?.total ?? organizations.length}`}
            previousHref={
              offset > 0
                ? withSearchParams({
                    query: query || undefined,
                    status: status || undefined,
                    plan: plan || undefined,
                    limit,
                    offset: Math.max(0, offset - limit),
                    selected: selectedOrganizationId ?? undefined,
                  })
                : null
            }
            nextHref={
              page?.next_offset != null
                ? withSearchParams({
                    query: query || undefined,
                    status: status || undefined,
                    plan: plan || undefined,
                    limit,
                    offset: page.next_offset,
                    selected: selectedOrganizationId ?? undefined,
                  })
                : null
            }
            previousLabel={messages.shared.previousPage}
            nextLabel={messages.shared.nextPage}
          />
        </div>
        <DetailDrawer
          title={detailResult?.data?.name ?? t.detailEmptyTitle}
          description={detailResult?.data?.organization_id ?? t.detailEmptyBody}
        >
          {detailResult?.data ? (
            <div className="space-y-4 text-sm leading-6 text-[color:var(--ink-soft)]">
              <div className="flex flex-wrap gap-2">
                <StatusPill tone="good">{detailResult.data.status}</StatusPill>
                <StatusPill tone="info">{detailResult.data.plan}</StatusPill>
                <StatusPill tone="neutral">{detailResult.data.ai_mode_default}</StatusPill>
              </div>
              <p>
                {detailResult.data.user_count} {t.detailUsersLabel},{" "}
                {formatNumber(detailResult.data.storage_used_gb, locale)} GB.
              </p>
              <div className="space-y-2">
                <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.detailMembers}
                </p>
                {detailResult.data.members.map((member) => (
                  <div
                    key={member.user_id}
                    className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-3"
                  >
                    <p className="text-sm font-semibold text-ink">{member.display_name}</p>
                    <p className="mt-1 text-sm text-[color:var(--ink-soft)]">
                      {member.email_masked} | {member.locale}
                    </p>
                  </div>
                ))}
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
