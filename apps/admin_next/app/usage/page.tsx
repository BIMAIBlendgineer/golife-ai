import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { getUsage } from "@/lib/api";
import { formatDateTime, formatLatency, formatPercent } from "@/lib/format";

export default async function UsagePage() {
  const usageResult = await getUsage();
  const usage = usageResult.data ?? [];

  const totalCaptureEvents = usage.reduce((sum, item) => sum + item.capture_events, 0);
  const totalGenerated = usage.reduce((sum, item) => sum + item.missions_generated, 0);
  const avgLatency =
    usage.length > 0
      ? usage.reduce((sum, item) => sum + item.latency_ms_avg, 0) / usage.length
      : 0;

  return (
    <>
      <PageHeader
        eyebrow="Usage"
        title="Capture and mission throughput"
        description="A per-user view of how often the product is used, how often fallback is needed, and where latency is drifting."
        badge="Telemetry"
      />
      <ErrorBanner error={usageResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Capture events"
          value={totalCaptureEvents.toString()}
          note="Signals whether capture is frictionless enough to become habit."
          tone="ink"
        />
        <MetricCard
          label="Missions generated"
          value={totalGenerated.toString()}
          note="How many ranked plans the system has emitted."
          tone="sage"
        />
        <MetricCard
          label="Average latency"
          value={formatLatency(avgLatency)}
          note="A direct operator check on AI responsiveness."
          tone="bronze"
        />
      </div>

      <Panel
        eyebrow="Per user"
        title="Usage ledger"
        note="This is the operational view to compare capture depth, fallback, and mission execution user by user."
      >
        <div className="overflow-x-auto">
          <table className="min-w-full border-separate border-spacing-y-3">
            <thead>
              <tr className="text-left text-[11px] font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                <th className="px-3">User</th>
                <th className="px-3">Capture events</th>
                <th className="px-3">Missions generated</th>
                <th className="px-3">Completed</th>
                <th className="px-3">Fallback</th>
                <th className="px-3">Latency</th>
                <th className="px-3">Last active</th>
              </tr>
            </thead>
            <tbody>
              {usage.map((item) => (
                <tr key={item.user_id} className="bg-white/45">
                  <td className="rounded-l-[18px] px-3 py-4 font-mono text-xs text-ink">
                    {item.user_id}
                  </td>
                  <td className="px-3 py-4 text-sm text-ink">{item.capture_events}</td>
                  <td className="px-3 py-4 text-sm text-ink">
                    {item.missions_generated}
                  </td>
                  <td className="px-3 py-4 text-sm text-ink">
                    {item.missions_completed}
                  </td>
                  <td className="px-3 py-4 text-sm text-[color:var(--ink-soft)]">
                    {formatPercent(item.fallback_rate)}
                  </td>
                  <td className="px-3 py-4 text-sm text-[color:var(--ink-soft)]">
                    {formatLatency(item.latency_ms_avg)}
                  </td>
                  <td className="rounded-r-[18px] px-3 py-4 text-sm text-[color:var(--ink-soft)]">
                    {formatDateTime(item.last_active_at)}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Panel>
    </>
  );
}
