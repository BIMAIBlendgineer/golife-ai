import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getDashboard, getModelSelections } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";

export default async function RoutingSnapshotsPage() {
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
        eyebrow="Snapshot"
        title="Current top-3 model selections"
        description="This page shows the ranked output of the control plane after catalog filtering, telemetry weighting, and policy checks."
        badge="Execution input"
      />
      <ErrorBanner
        error={[dashboardResult.error, selectionsResult.error].filter(Boolean).join(" | ") || null}
      />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Capabilities with snapshots"
          value={formatNumber(byCapability.size)}
          note="Each enabled capability should expose exactly three candidates."
          tone="sage"
        />
        <MetricCard
          label="Snapshot age"
          value={
            dashboard.routing_snapshot_age_seconds == null
              ? "N/A"
              : `${dashboard.routing_snapshot_age_seconds}s`
          }
          note="Older snapshots increase the chance of routing stale models."
          tone="bronze"
        />
        <MetricCard
          label="Selected rows"
          value={formatNumber(selections.length)}
          note="Total ranked rows stored across all capabilities."
          tone="ink"
        />
      </div>

      <div className="space-y-6">
        {Array.from(byCapability.entries()).map(([capability, rows]) => (
          <Panel
            key={capability}
            eyebrow="Capability"
            title={capability}
            note="The gateway asks OpenRouter for these three models in this order, with provider fallback enabled."
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
                        Rank {snapshot.rank_index + 1}
                      </p>
                      <StatusPill tone={snapshot.rank_index === 0 ? "good" : "info"}>
                        Score {snapshot.score}
                      </StatusPill>
                    </div>
                    <p className="mt-3 font-mono text-sm text-[color:var(--ink-muted)]">
                      {snapshot.model_id}
                    </p>
                    <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                      {(snapshot.selection_reason["model_name"] as string | undefined) ??
                        "No model name"}
                    </p>
                    <div className="mt-4 space-y-2 text-sm text-[color:var(--ink-soft)]">
                      <p>
                        Generated{" "}
                        <span className="font-medium text-ink">
                          {formatDateTime(snapshot.generated_at)}
                        </span>
                      </p>
                      <p>
                        Expires{" "}
                        <span className="font-medium text-ink">
                          {formatDateTime(snapshot.expires_at)}
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
