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

export default async function AICostsPage() {
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
        eyebrow="AI Spend"
        title="Provider cost and endpoint pressure"
        description="The fastest way to lose margin is to ignore which endpoint is expensive, slow, or frequently falling back. This board keeps that visible."
        badge="Cost control"
      />
      <ErrorBanner error={costsResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Total cost"
          value={formatCurrency(totalCost)}
          note="Estimated spend across ranked missions, classification, and support endpoints."
          tone="bronze"
        />
        <MetricCard
          label="Tracked endpoints"
          value={costs.length.toString()}
          note="Operational breakdown by endpoint rather than by provider alone."
          tone="ink"
        />
        <MetricCard
          label="Average fallback"
          value={formatPercent(avgFallback)}
          note="High fallback can mean prompt trouble, timeout pressure, or quota issues."
          tone="clay"
        />
      </div>

      <Panel
        eyebrow="Spend detail"
        title="Endpoint ledger"
        note="Classify cheaply, rank carefully, and keep feedback storage nearly free."
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
                  Provider: {item.provider}
                </p>
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  Requests
                </p>
                <p className="mt-2 text-sm text-ink">{item.requests}</p>
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  Latency
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatLatency(item.avg_latency_ms)}
                </p>
              </div>
              <div>
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  Cost / fallback
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatCurrency(item.estimated_cost_usd)} /{" "}
                  {formatPercent(item.fallback_rate)}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
