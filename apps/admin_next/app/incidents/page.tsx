import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { EmptyState } from "@/components/premium/empty-state";
import { FilterBar } from "@/components/premium/filter-bar";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getIncidents } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { IncidentRow } from "@/lib/types";
import { withSearchParams } from "@/lib/url";

function severityTone(severity: IncidentRow["severity"]) {
  switch (severity) {
    case "high":
      return "danger" as const;
    case "medium":
      return "warn" as const;
    case "low":
    default:
      return "info" as const;
  }
}

export default async function IncidentsPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.incidents;
  const params = await searchParams;
  const severity = typeof params.severity === "string" ? params.severity : "";
  const status = typeof params.status === "string" ? params.status : "";
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

  const incidentsResult = await getIncidents({
    severity: severity || undefined,
    status: status || undefined,
    limit,
    offset,
  });
  const page = incidentsResult.data;
  const rows = page?.items ?? [];
  const openCount = rows.filter((row) => row.status === "open").length;
  const monitoringCount = rows.filter((row) => row.status === "monitoring").length;
  const highCount = rows.filter((row) => row.severity === "high").length;
  const nextHref =
    page?.next_offset != null
      ? withSearchParams({ severity: severity || undefined, status: status || undefined, limit, offset: page.next_offset })
      : null;
  const previousHref =
    offset > 0
      ? withSearchParams({ severity: severity || undefined, status: status || undefined, limit, offset: Math.max(0, offset - limit) })
      : null;

  const columns: Array<DataColumn<IncidentRow>> = [
    {
      id: "type",
      header: t.tableType,
      cell: (row) => <span className="text-sm font-semibold text-ink">{row.type}</span>,
    },
    {
      id: "severity",
      header: t.tableSeverity,
      cell: (row) => <StatusPill tone={severityTone(row.severity)}>{row.severity}</StatusPill>,
    },
    {
      id: "source",
      header: t.tableSource,
      cell: (row) => <StatusPill tone="neutral">{row.source}</StatusPill>,
    },
    {
      id: "status",
      header: t.tableStatus,
      cell: (row) => <StatusPill tone={row.status === "open" ? "warn" : "info"}>{row.status}</StatusPill>,
    },
    {
      id: "created",
      header: t.tableCreated,
      cell: (row) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatDateTime(row.created_at, locale)}
        </span>
      ),
    },
    {
      id: "summary",
      header: t.tableSummary,
      cell: (row) => <p className="text-sm leading-6 text-[color:var(--ink-soft)]">{row.safe_summary}</p>,
      className: "min-w-[320px]",
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

      <KpiGrid className="xl:grid-cols-3">
        <MetricCard
          label={t.openLabel}
          value={formatNumber(openCount, locale)}
          note={t.openNote}
          tone="clay"
        />
        <MetricCard
          label={t.monitoringLabel}
          value={formatNumber(monitoringCount, locale)}
          note={t.monitoringNote}
          tone="bronze"
        />
        <MetricCard
          label={t.highSeverityLabel}
          value={formatNumber(highCount, locale)}
          note={t.highSeverityNote}
          tone="ink"
        />
      </KpiGrid>

      <FilterBar>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterSeverity}
          </span>
          <select
            name="severity"
            defaultValue={severity}
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          >
            <option value="">{messages.shared.none}</option>
            <option value="low">low</option>
            <option value="medium">medium</option>
            <option value="high">high</option>
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
            <option value="open">open</option>
            <option value="monitoring">monitoring</option>
            <option value="resolved">resolved</option>
          </select>
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

      <div className="space-y-4">
        <DataTable
          columns={columns}
          rows={rows}
          rowKey={(row) => row.incident_id}
          emptyState={<EmptyState title={t.emptyTitle} body={t.emptyBody} />}
        />
        <PaginationFooter
          summary={`${messages.shared.pageSummaryPrefix} ${rows.length} ${messages.shared.pageSummaryMiddle} ${page?.total ?? rows.length}`}
          previousHref={previousHref}
          nextHref={nextHref}
          previousLabel={messages.shared.previousPage}
          nextLabel={messages.shared.nextPage}
        />
      </div>
    </>
  );
}
