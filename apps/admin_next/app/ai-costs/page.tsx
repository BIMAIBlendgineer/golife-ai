import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { getAICosts } from "@/lib/api";
import {
  formatCurrency,
  formatLatency,
  formatPercent,
} from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function AICostsPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.aiCosts;
  const costsResult = await getAICosts();
  const costs = costsResult.data ?? [];
  const totalCost = costs.reduce((sum, item) => sum + item.estimated_cost_usd, 0);
  const avgFallback =
    costs.length > 0
      ? costs.reduce((sum, item) => sum + item.fallback_rate, 0) / costs.length
      : 0;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={costsResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.totalCostLabel}
          value={formatCurrency(totalCost, locale)}
          note={t.totalCostNote}
          tone="bronze"
        />
        <MetricCard
          label={t.trackedEndpointsLabel}
          value={costs.length.toString()}
          note={t.trackedEndpointsNote}
          tone="ink"
        />
        <MetricCard
          label={t.averageFallbackLabel}
          value={formatPercent(avgFallback, locale)}
          note={t.averageFallbackNote}
          tone="clay"
        />
      </div>

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="space-y-3">
          {costs.map((item) => (
            <div
              key={item.endpoint}
              className="grid gap-3 rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4 md:grid-cols-[1.15fr_0.85fr_0.85fr_0.85fr]"
            >
              <div>
                <p className="font-mono text-sm font-semibold text-ink">
                  {item.endpoint}
                </p>
                <p className="mt-1 text-sm text-[color:var(--ink-soft)]">
                  {messages.shared.providerLabel}: {item.provider}
                </p>
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  {messages.shared.requestsLabel}
                </p>
                <p className="mt-2 text-sm text-ink">{item.requests}</p>
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  {messages.shared.latencyLabel}
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatLatency(item.avg_latency_ms, locale, messages.shared.msUnit)}
                </p>
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  {messages.shared.costFallbackLabel}
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatCurrency(item.estimated_cost_usd, locale)} /{" "}
                  {formatPercent(item.fallback_rate, locale)}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
