import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { EmptyState } from "@/components/premium/empty-state";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { RiskBanner } from "@/components/premium/risk-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getPrivacyDataMap, getPrivacyRequests } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { PrivacyRequestRow } from "@/lib/types";
import { withSearchParams } from "@/lib/url";

export default async function PrivacyPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.privacy;
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

  const [requestsResult, dataMapResult] = await Promise.all([
    getPrivacyRequests({ limit, offset }),
    getPrivacyDataMap(),
  ]);
  const page = requestsResult.data;
  const requests = page?.items ?? [];
  const dataMap = dataMapResult.data;
  const openCount = requests.filter((item) => item.status === "open").length;
  const exportCount = requests.filter((item) => item.request_type === "export").length;
  const nextHref =
    page?.next_offset != null
      ? withSearchParams({ limit, offset: page.next_offset })
      : null;
  const previousHref =
    offset > 0 ? withSearchParams({ limit, offset: Math.max(0, offset - limit) }) : null;

  const columns: Array<DataColumn<PrivacyRequestRow>> = [
    {
      id: "request",
      header: t.tableRequest,
      cell: (row) => (
        <p className="font-mono text-xs text-ink">{row.request_id}</p>
      ),
    },
    {
      id: "user",
      header: t.tableUser,
      cell: (row) => (
        <p className="font-mono text-xs text-[color:var(--ink-soft)]">{row.user_id}</p>
      ),
    },
    {
      id: "type",
      header: t.tableType,
      cell: (row) => <StatusPill tone="info">{row.request_type}</StatusPill>,
    },
    {
      id: "status",
      header: t.tableStatus,
      cell: (row) => (
        <StatusPill tone={row.status === "open" ? "warn" : "good"}>{row.status}</StatusPill>
      ),
    },
    {
      id: "requested",
      header: t.tableRequestedAt,
      cell: (row) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatDateTime(row.requested_at, locale)}
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

      <RiskBanner title={t.dataMapTitle} body={t.dataMapBody} tone="info" />

      <KpiGrid className="xl:grid-cols-3">
        <MetricCard
          label={t.openRequestsLabel}
          value={formatNumber(openCount, locale)}
          note={t.openRequestsNote}
          tone="clay"
        />
        <MetricCard
          label={t.encryptedLabel}
          value={formatNumber(dataMap?.encrypted_collections.length ?? 0, locale)}
          note={t.encryptedNote}
          tone="sage"
        />
        <MetricCard
          label={t.retentionLabel}
          value={formatNumber(dataMap?.retention_notes.length ?? 0, locale)}
          note={t.retentionNote}
          tone="bronze"
        />
      </KpiGrid>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.45fr)_360px]">
        <div className="space-y-4">
          <DataTable
            columns={columns}
            rows={requests}
            rowKey={(row) => row.request_id}
            emptyState={<EmptyState title={t.emptyTitle} body={t.emptyBody} />}
          />
          <PaginationFooter
            summary={`${messages.shared.pageSummaryPrefix} ${requests.length} ${messages.shared.pageSummaryMiddle} ${page?.total ?? requests.length}`}
            previousHref={previousHref}
            nextHref={nextHref}
            previousLabel={messages.shared.previousPage}
            nextLabel={messages.shared.nextPage}
          />
        </div>

        <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-5">
          <div className="space-y-5">
            <div>
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.encryptedCollectionsLabel}
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                {dataMap?.encrypted_collections.map((collection) => (
                  <StatusPill key={collection} tone="neutral">
                    {collection}
                  </StatusPill>
                )) ?? <StatusPill tone="neutral">{messages.shared.none}</StatusPill>}
              </div>
            </div>
            <div>
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.retentionNotesLabel}
              </p>
              <ul className="mt-3 space-y-2 text-sm leading-6 text-[color:var(--ink-soft)]">
                {dataMap?.retention_notes.map((note) => <li key={note}>• {note}</li>)}
              </ul>
            </div>
            <div>
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.exportCountLabel}
              </p>
              <p className="mt-3 text-sm text-[color:var(--ink-soft)]">
                {formatNumber(exportCount, locale)}
              </p>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
