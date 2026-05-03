import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { EmptyState } from "@/components/premium/empty-state";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { RiskBanner } from "@/components/premium/risk-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getHomeMemoryParserUsage, getHomeMemorySummary } from "@/lib/api";
import { formatNumber, formatPercent } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { HomeMemoryParserUsageRow } from "@/lib/types";
import { withSearchParams } from "@/lib/url";

export default async function HomeMemoryPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.homememory;
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

  const [summaryResult, parserUsageResult] = await Promise.all([
    getHomeMemorySummary(),
    getHomeMemoryParserUsage({ limit, offset }),
  ]);
  const summary = summaryResult.data;
  const page = parserUsageResult.data;
  const rows = page?.items ?? [];
  const nextHref =
    page?.next_offset != null ? withSearchParams({ limit, offset: page.next_offset }) : null;
  const previousHref =
    offset > 0 ? withSearchParams({ limit, offset: Math.max(0, offset - limit) }) : null;

  const columns: Array<DataColumn<HomeMemoryParserUsageRow>> = [
    {
      id: "locale",
      header: t.tableLocale,
      cell: (row) => <StatusPill tone="neutral">{row.locale}</StatusPill>,
    },
    {
      id: "parser",
      header: t.tableParser,
      cell: (row) => <StatusPill tone="info">{row.parser}</StatusPill>,
    },
    {
      id: "requests",
      header: t.tableRequests,
      cell: (row) => <span className="text-sm text-ink">{formatNumber(row.requests, locale)}</span>,
    },
    {
      id: "success",
      header: t.tableSuccess,
      cell: (row) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatPercent(row.success_rate, locale)}
        </span>
      ),
    },
    {
      id: "fallback",
      header: t.tableFallback,
      cell: (row) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatPercent(row.fallback_rate, locale)}
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

      <RiskBanner title={t.disclaimerTitle} body={t.disclaimerBody} tone="info" />

      <KpiGrid className="xl:grid-cols-4">
        <MetricCard
          label={t.proofParsesLabel}
          value={formatNumber(summary?.proof_parse_count ?? 0, locale)}
          note={t.proofParsesNote}
          tone="ink"
        />
        <MetricCard
          label={t.warrantyLabel}
          value={formatNumber(summary?.warranty_reminder_count ?? 0, locale)}
          note={t.warrantyNote}
          tone="sage"
        />
        <MetricCard
          label={t.claimsLabel}
          value={formatNumber(summary?.claim_draft_count ?? 0, locale)}
          note={t.claimsNote}
          tone="bronze"
        />
        <MetricCard
          label={t.fallbackLabel}
          value={formatPercent(summary?.fallback_rate ?? 0, locale)}
          note={t.fallbackNote}
          tone="clay"
        />
      </KpiGrid>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.35fr)_360px]">
        <div className="space-y-4">
          <DataTable
            columns={columns}
            rows={rows}
            rowKey={(row) => `${row.locale}-${row.parser}`}
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

        <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-5">
          <div className="space-y-5">
            <div>
              <p className="text-sm font-semibold text-ink">{t.localeTitle}</p>
              <div className="mt-3 flex flex-wrap gap-2">
                {Object.entries(summary?.locale_distribution ?? {}).map(([localeCode, count]) => (
                  <StatusPill key={localeCode} tone="neutral">
                    {localeCode}: {count}
                  </StatusPill>
                ))}
                {Object.keys(summary?.locale_distribution ?? {}).length === 0 ? (
                  <StatusPill tone="neutral">{messages.shared.none}</StatusPill>
                ) : null}
              </div>
            </div>
            <div>
              <p className="text-sm font-semibold text-ink">{t.encryptionTitle}</p>
              <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">
                {t.encryptionBody}
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                {(summary?.encrypted_collections ?? []).map((collection) => (
                  <StatusPill key={collection} tone="neutral">
                    {collection}
                  </StatusPill>
                ))}
                {(summary?.encrypted_collections.length ?? 0) === 0 ? (
                  <StatusPill tone="neutral">{messages.shared.notAvailable}</StatusPill>
                ) : null}
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
