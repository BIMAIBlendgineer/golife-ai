import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getDashboard, getModelSelections } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function RoutingSnapshotsPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.routingSnapshots;
  const [dashboardResult, selectionsResult] = await Promise.all([
    getDashboard(),
    getModelSelections(),
  ]);

  const dashboard = dashboardResult.data!;
  const selections = selectionsResult.data ?? [];
  const byCapability = new Map<string, typeof selections>();
  for (const item of selections) {
    const current = byCapability.get(item.capability) ?? [];
    current.push(item);
    byCapability.set(item.capability, current);
  }

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner
        error={[dashboardResult.error, selectionsResult.error].filter(Boolean).join(" | ") || null}
      />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.capabilitiesLabel}
          value={formatNumber(byCapability.size, locale)}
          note={t.capabilitiesNote}
          tone="sage"
        />
        <MetricCard
          label={t.snapshotAgeLabel}
          value={
            dashboard.routing_snapshot_age_seconds == null
              ? messages.shared.notAvailable
              : `${dashboard.routing_snapshot_age_seconds}s`
          }
          note={t.snapshotAgeNote}
          tone="bronze"
        />
        <MetricCard
          label={t.selectedRowsLabel}
          value={formatNumber(selections.length, locale)}
          note={t.selectedRowsNote}
          tone="ink"
        />
      </div>

      <div className="space-y-6">
        {byCapability.size === 0 ? (
          <Panel
            eyebrow={t.panelEyebrow}
            title={t.emptyTitle}
            note={t.empty}
          >
            <div />
          </Panel>
        ) : null}
        {Array.from(byCapability.entries()).map(([capability, rows]) => (
          <Panel
            key={capability}
            eyebrow={t.panelEyebrow}
            title={capability}
            note={t.panelNote}
          >
            <div className="grid gap-4 xl:grid-cols-3">
              {rows
                .sort((left, right) => left.rank_index - right.rank_index)
                .map((snapshot) => (
                  <div
                    key={`${snapshot.capability}-${snapshot.rank_index}`}
                    className="rounded-[20px] border border-[color:var(--line)] bg-white/50 p-5"
                  >
                    <div className="flex items-center justify-between gap-3">
                      <p className="font-semibold text-ink">
                        {t.rankLabel} {snapshot.rank_index + 1}
                      </p>
                      <StatusPill tone={snapshot.rank_index === 0 ? "good" : "info"}>
                        {t.scoreLabel} {snapshot.score}
                      </StatusPill>
                    </div>
                    <p className="mt-3 font-mono text-sm text-[color:var(--ink-muted)]">
                      {snapshot.model_id}
                    </p>
                    <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                      {(snapshot.selection_reason["model_name"] as string | undefined) ??
                        messages.shared.noModelName}
                    </p>
                    <div className="mt-4 space-y-2 text-sm text-[color:var(--ink-soft)]">
                      <p>
                        {messages.shared.generatedLabel}{" "}
                        <span className="font-medium text-ink">
                          {formatDateTime(snapshot.generated_at, locale)}
                        </span>
                      </p>
                      <p>
                        {messages.shared.expiresLabel}{" "}
                        <span className="font-medium text-ink">
                          {formatDateTime(snapshot.expires_at, locale)}
                        </span>
                      </p>
                    </div>
                  </div>
                ))}
            </div>
          </Panel>
        ))}
      </div>
    </>
  );
}
