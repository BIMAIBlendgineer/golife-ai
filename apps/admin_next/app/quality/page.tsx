import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getQualityBreakdown, getQualitySummary } from "@/lib/api";
import { formatCurrency, formatNumber, formatPercent } from "@/lib/format";
import { getAdminMessages, type AdminLocale } from "@/lib/i18n";
import type { QualityBreakdownRow } from "@/lib/types";

function formatQualityValue(row: QualityBreakdownRow, locale: AdminLocale, msUnit: string) {
  switch (row.unit) {
    case "ratio":
      return formatPercent(row.value, locale);
    case "usd":
      return formatCurrency(row.value, locale);
    case "ms":
      return `${formatNumber(row.value, locale)} ${msUnit}`;
    case "count":
    default:
      return formatNumber(row.value, locale);
  }
}

export default async function QualityPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.quality;
  const [summaryResult, breakdownResult] = await Promise.all([
    getQualitySummary(),
    getQualityBreakdown(),
  ]);
  const summary = summaryResult.data;
  const rows = breakdownResult.data ?? [];

  const columns: Array<DataColumn<QualityBreakdownRow>> = [
    {
      id: "dimension",
      header: t.tableDimension,
      cell: (row) => <StatusPill tone="neutral">{row.dimension}</StatusPill>,
    },
    {
      id: "metric",
      header: t.tableMetric,
      cell: (row) => <span className="text-sm font-semibold text-ink">{row.label}</span>,
    },
    {
      id: "value",
      header: t.tableValue,
      cell: (row) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatQualityValue(row, locale, messages.shared.msUnit)}
        </span>
      ),
    },
    {
      id: "source",
      header: t.tableSource,
      cell: (row) => <StatusPill tone="info">{row.source}</StatusPill>,
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

      <KpiGrid className="xl:grid-cols-4">
        <MetricCard
          label={t.usefulnessLabel}
          value={formatPercent(summary?.mission_usefulness_rate ?? 0, locale)}
          note={t.usefulnessNote}
          tone="sage"
        />
        <MetricCard
          label={t.completionLabel}
          value={formatPercent(summary?.mission_completion_rate ?? 0, locale)}
          note={t.completionNote}
          tone="ink"
        />
        <MetricCard
          label={t.rejectionLabel}
          value={formatPercent(summary?.rejection_rate ?? 0, locale)}
          note={t.rejectionNote}
          tone="clay"
        />
        <MetricCard
          label={t.parserLabel}
          value={formatPercent(summary?.proof_parser_success_rate ?? 0, locale)}
          note={t.parserNote}
          tone="bronze"
        />
      </KpiGrid>

      <KpiGrid className="xl:grid-cols-4">
        <MetricCard
          label={t.fallbackLabel}
          value={formatPercent(summary?.fallback_rate ?? 0, locale)}
          note={t.fallbackNote}
          tone="clay"
        />
        <MetricCard
          label={t.safetyLabel}
          value={formatNumber(summary?.safety_interventions ?? 0, locale)}
          note={t.safetyNote}
          tone="bronze"
        />
        <MetricCard
          label={t.costLabel}
          value={formatNumber(summary?.high_cost_anomalies ?? 0, locale)}
          note={t.costNote}
          tone="ink"
        />
        <MetricCard
          label={t.supportLabel}
          value={formatNumber(summary?.support_escalations ?? 0, locale)}
          note={t.supportNote}
          tone="sage"
        />
      </KpiGrid>

      <DataTable columns={columns} rows={rows} rowKey={(row) => `${row.dimension}-${row.label}`} />
    </>
  );
}
