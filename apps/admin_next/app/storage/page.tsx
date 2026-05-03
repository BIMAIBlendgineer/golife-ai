import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { RiskBanner } from "@/components/premium/risk-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getStorageSummary, getStorageUsage } from "@/lib/api";
import { formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { StorageUsageRow } from "@/lib/types";
import { withSearchParams } from "@/lib/url";

export default async function StoragePage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.storage;
  const params = await searchParams;
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
  const [summaryResult, usageResult] = await Promise.all([
    getStorageSummary(),
    getStorageUsage({ limit, offset }),
  ]);
  const summary = summaryResult.data;
  const page = usageResult.data;
  const usage = page?.items ?? [];

  const columns: Array<DataColumn<StorageUsageRow>> = [
    {
      id: "organization",
      header: t.tableOrganization,
      cell: (row) => (
        <div>
          <p className="text-sm font-semibold text-ink">{row.organization_name}</p>
          <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
            {row.organization_id}
          </p>
        </div>
      ),
    },
    {
      id: "plan",
      header: t.tablePlan,
      cell: (row) => <StatusPill tone="info">{row.plan}</StatusPill>,
    },
    {
      id: "usage",
      header: t.tableUsage,
      cell: (row) => (
        <span className="text-sm text-ink">{formatNumber(row.storage_used_gb, locale)} GB</span>
      ),
    },
    {
      id: "encrypted",
      header: t.tableEncrypted,
      cell: (row) => (
        <div className="flex min-w-[200px] flex-wrap gap-2">
          {row.encrypted_collections.map((collection) => (
            <StatusPill key={collection} tone="neutral">
              {collection}
            </StatusPill>
          ))}
        </div>
      ),
    },
    {
      id: "risk",
      header: t.tableRetentionRisk,
      cell: (row) => (
        <StatusPill tone={row.retention_risk ? "warn" : "good"}>
          {row.retention_risk ? t.riskOpen : t.riskClear}
        </StatusPill>
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

      <RiskBanner title={t.disclaimerTitle} body={t.disclaimerBody} tone="info" />

      <KpiGrid className="xl:grid-cols-4">
        <MetricCard
          label={t.totalStorageLabel}
          value={`${formatNumber(summary?.total_gb ?? 0, locale)} GB`}
          note={t.totalStorageNote}
          tone="ink"
        />
        <MetricCard
          label={t.cloudStorageLabel}
          value={`${formatNumber(summary?.cloud_gb ?? 0, locale)} GB`}
          note={t.cloudStorageNote}
          tone="sage"
        />
        <MetricCard
          label={t.exportBundlesLabel}
          value={`${formatNumber(summary?.export_bundle_gb ?? 0, locale)} GB`}
          note={t.exportBundlesNote}
          tone="bronze"
        />
        <MetricCard
          label={t.retentionRiskLabel}
          value={formatNumber(summary?.retention_risk_count ?? 0, locale)}
          note={t.retentionRiskNote}
          tone="clay"
        />
      </KpiGrid>

      <div className="space-y-4">
        <DataTable columns={columns} rows={usage} rowKey={(row) => row.organization_id} />
        <PaginationFooter
          summary={`${messages.shared.pageSummaryPrefix} ${usage.length} ${messages.shared.pageSummaryMiddle} ${page?.total ?? usage.length}`}
          previousHref={offset > 0 ? withSearchParams({ limit, offset: Math.max(0, offset - limit) }) : null}
          nextHref={page?.next_offset != null ? withSearchParams({ limit, offset: page.next_offset }) : null}
          previousLabel={messages.shared.previousPage}
          nextLabel={messages.shared.nextPage}
        />
      </div>
    </>
  );
}
