import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { RiskBanner } from "@/components/premium/risk-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getStorageSummary, getStorageUsage } from "@/lib/api";
import { formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { StorageUsageRow } from "@/lib/types";

export default async function StoragePage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.storage;
  const [summaryResult, usageResult] = await Promise.all([
    getStorageSummary(),
    getStorageUsage(),
  ]);
  const summary = summaryResult.data;
  const usage = usageResult.data ?? [];

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

      <DataTable columns={columns} rows={usage} rowKey={(row) => row.organization_id} />
    </>
  );
}
