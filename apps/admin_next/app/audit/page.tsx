import { AuditTimeline } from "@/components/premium/audit-timeline";
import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { DetailDrawer } from "@/components/premium/detail-drawer";
import { EmptyState } from "@/components/premium/empty-state";
import { FilterBar } from "@/components/premium/filter-bar";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getAuditLog } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { AuditLogRow } from "@/lib/types";
import { withSearchParams } from "@/lib/url";

function auditTone(action: string) {
  if (action.includes("disable")) return "warn" as const;
  if (action.includes("create") || action.includes("refresh")) return "good" as const;
  return "info" as const;
}

export default async function AuditPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.audit;
  const params = await searchParams;
  const actor = typeof params.actor === "string" ? params.actor : "";
  const action = typeof params.action === "string" ? params.action : "";
  const selected = typeof params.selected === "string" ? params.selected : "";
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

  const auditResult = await getAuditLog({
    actor: actor || undefined,
    action: action || undefined,
    limit,
    offset,
  });
  const page = auditResult.data;
  const rows = page?.items ?? [];
  const selectedRow = rows.find((row) => row.audit_id === selected) ?? rows[0] ?? null;
  const uniqueActors = new Set(rows.map((row) => row.actor_id)).size;
  const nextHref =
    page?.next_offset != null
      ? withSearchParams({
          actor: actor || undefined,
          action: action || undefined,
          limit,
          offset: page.next_offset,
          selected,
        })
      : null;
  const previousHref =
    offset > 0
      ? withSearchParams({
          actor: actor || undefined,
          action: action || undefined,
          limit,
          offset: Math.max(0, offset - limit),
          selected,
        })
      : null;

  const columns: Array<DataColumn<AuditLogRow>> = [
    {
      id: "time",
      header: t.tableTime,
      cell: (row) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatDateTime(row.created_at, locale)}
        </span>
      ),
    },
    {
      id: "actor",
      header: t.tableActor,
      cell: (row) => <StatusPill tone="neutral">{row.actor_id}</StatusPill>,
    },
    {
      id: "action",
      header: t.tableAction,
      cell: (row) => <StatusPill tone={auditTone(row.action)}>{row.action}</StatusPill>,
    },
    {
      id: "target",
      header: t.tableTarget,
      cell: (row) => (
        <div>
          <p className="text-sm font-semibold text-ink">{row.target_type}</p>
          <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
            {row.target_id}
          </p>
        </div>
      ),
    },
    {
      id: "correlation",
      header: t.tableCorrelation,
      cell: (row) => (
        <span className="font-mono text-xs text-[color:var(--ink-soft)]">
          {row.correlation_id}
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

      <KpiGrid className="xl:grid-cols-3">
        <MetricCard
          label={t.eventsLabel}
          value={formatNumber(page?.total ?? rows.length, locale)}
          note={t.eventsNote}
          tone="ink"
        />
        <MetricCard
          label={t.writesLabel}
          value={formatNumber(rows.length, locale)}
          note={t.writesNote}
          tone="sage"
        />
        <MetricCard
          label={t.actorsLabel}
          value={formatNumber(uniqueActors, locale)}
          note={t.actorsNote}
          tone="bronze"
        />
      </KpiGrid>

      <FilterBar>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterActor}
          </span>
          <input
            type="text"
            name="actor"
            defaultValue={actor}
            className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
          />
        </label>
        <label className="space-y-2">
          <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.filterAction}
          </span>
          <input
            type="text"
            name="action"
            defaultValue={action}
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

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.35fr)_360px]">
        <div className="space-y-4">
          <DataTable
            columns={columns}
            rows={rows}
            rowKey={(row) => row.audit_id}
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
        <DetailDrawer
          title={selectedRow?.action ?? t.detailTitle}
          description={selectedRow?.target_id ?? t.detailBody}
        >
          {selectedRow ? (
            <AuditTimeline
              items={[
                {
                  id: selectedRow.audit_id,
                  title: `${selectedRow.target_type} · ${selectedRow.target_id}`,
                  meta: formatDateTime(selectedRow.created_at, locale),
                  body: JSON.stringify(selectedRow.safe_diff, null, 2),
                  tone: auditTone(selectedRow.action),
                },
              ]}
            />
          ) : (
            <EmptyState title={t.detailTitle} body={t.detailBody} />
          )}
        </DetailDrawer>
      </div>
    </>
  );
}
