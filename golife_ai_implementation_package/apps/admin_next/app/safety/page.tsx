import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getSafety } from "@/lib/api";
import { formatDateTime, labelizeKey } from "@/lib/format";

export default async function SafetyPage() {
  const safetyResult = await getSafety();
  const safety = safetyResult.data ?? [];
  const highSeverity = safety.filter((item) => item.severity === "high").length;
  const financeIncidents = safety.filter((item) => item.category === "finance").length;

  return (
    <>
      <PageHeader
        eyebrow="Trust Desk"
        title="Safety incidents and blocked behavior"
        description="Operators need a compact trace of blocked outputs, regulated advice attempts, and actions that required stronger confirmation."
        badge="Trust"
      />
      <ErrorBanner error={safetyResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Safety events"
          value={safety.length.toString()}
          note="Recent trust and policy interventions."
          tone="ink"
        />
        <MetricCard
          label="High severity"
          value={highSeverity.toString()}
          note="Anything high needs immediate operator review."
          tone="clay"
        />
        <MetricCard
          label="Finance incidents"
          value={financeIncidents.toString()}
          note="Financial advice pressure remains the most sensitive regulated area."
          tone="bronze"
        />
      </div>

      <Panel
        eyebrow="Incident Log"
        title="Safety records"
        note="Each event preserves who triggered it, which rule fired, and the domain that needs closer prompt or policy work."
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
                    {item.user_id} · {item.event_id}
                  </p>
                </div>
                <p className="text-sm text-[color:var(--ink-muted)]">
                  {formatDateTime(item.created_at)}
                </p>
              </div>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
