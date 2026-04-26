import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { StatusPill } from "@/components/status-pill";
import { getSafety } from "@/lib/api";
import { formatDateTime, labelizeKey } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import { withSearchParams } from "@/lib/url";

export default async function SafetyPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.safety;
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
  const safetyResult = await getSafety({ limit, offset });
  const page = safetyResult.data;
  const safety = page?.items ?? [];
  const highSeverity = safety.filter((item) => item.severity === "high").length;
  const financeIncidents = safety.filter((item) => item.category === "finance").length;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={safetyResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.eventsLabel}
          value={safety.length.toString()}
          note={t.eventsNote}
          tone="ink"
        />
        <MetricCard
          label={t.highSeverityLabel}
          value={highSeverity.toString()}
          note={t.highSeverityNote}
          tone="clay"
        />
        <MetricCard
          label={t.financeIncidentsLabel}
          value={financeIncidents.toString()}
          note={t.financeIncidentsNote}
          tone="bronze"
        />
      </div>

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="space-y-3">
          {safety.map((item) => (
            <div
              key={item.event_id}
              className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
            >
              <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                <div className="space-y-2">
                  <div className="flex flex-wrap gap-2">
                    <StatusPill
                      tone={
                        item.severity === "high"
                          ? "danger"
                          : item.severity === "medium"
                            ? "warn"
                            : "info"
                      }
                    >
                      {item.severity}
                    </StatusPill>
                    <StatusPill tone="neutral">{labelizeKey(item.category)}</StatusPill>
                  </div>
                  <p className="text-sm font-semibold text-ink">{item.rule}</p>
                  <p className="font-mono text-xs text-[color:var(--ink-muted)]">
                    {item.user_id} | {item.event_id}
                  </p>
                </div>
                <p className="text-sm text-[color:var(--ink-muted)]">
                  {formatDateTime(item.created_at, locale)}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Panel>
      <PaginationFooter
        summary={`${messages.shared.pageSummaryPrefix} ${safety.length} ${messages.shared.pageSummaryMiddle} ${page?.total ?? safety.length}`}
        previousHref={offset > 0 ? withSearchParams({ limit, offset: Math.max(0, offset - limit) }) : null}
        nextHref={page?.next_offset != null ? withSearchParams({ limit, offset: page.next_offset }) : null}
        previousLabel={messages.shared.previousPage}
        nextLabel={messages.shared.nextPage}
      />
    </>
  );
}
