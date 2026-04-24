import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getDashboard, getOpenRouterKeyEvents, getOpenRouterKeys } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";

export default async function OpenRouterKeysPage() {
  const [dashboardResult, keysResult, eventsResult] = await Promise.all([
    getDashboard(),
    getOpenRouterKeys(),
    getOpenRouterKeyEvents(),
  ]);

  const dashboard = dashboardResult.data!;
  const keys = keysResult.data ?? [];
  const events = eventsResult.data ?? [];
  const error =
    [dashboardResult.error, keysResult.error, eventsResult.error]
      .filter(Boolean)
      .join(" | ") || null;

  return (
    <>
      <PageHeader
        eyebrow="Routing Control"
        title="OpenRouter keys and failover health"
        description="Track which keys are active, which ones are degraded, and whether GoLife is rotating safely when a route or quota fails."
        badge="Sequential failover"
      />
      <ErrorBanner error={error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Active keys"
          value={formatNumber(dashboard.active_key_count)}
          note="Healthy keys available to the gateway control plane."
          tone="sage"
        />
        <MetricCard
          label="Disabled keys"
          value={formatNumber(dashboard.disabled_key_count)}
          note="Keys excluded from routing because they are paused or unsafe."
          tone="clay"
        />
        <MetricCard
          label="Recent key events"
          value={formatNumber(events.length)}
          note="Latest success and failure records written by the gateway."
          tone="bronze"
        />
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <Panel
          eyebrow="Key pool"
          title="Masked server-side keys"
          note="Secrets never render here. Operators only see masked labels, health, and rotation order."
        >
          <div className="space-y-3">
            {keys.map((key) => (
              <div
                key={key.key_id}
                className="rounded-[20px] border border-[color:var(--line)] bg-white/50 p-4"
              >
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="font-semibold text-ink">{key.label}</p>
                    <p className="mt-1 font-mono text-sm text-[color:var(--ink-muted)]">
                      {key.key_id} · ****{key.secret_last4}
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <StatusPill tone={key.enabled ? "good" : "danger"}>
                      {key.enabled ? "Enabled" : "Disabled"}
                    </StatusPill>
                    <StatusPill
                      tone={
                        key.status === "healthy"
                          ? "good"
                          : key.status === "degraded"
                            ? "warn"
                            : key.status === "disabled"
                              ? "danger"
                              : "neutral"
                      }
                    >
                      {key.status}
                    </StatusPill>
                    <StatusPill tone="info">Priority {key.priority}</StatusPill>
                  </div>
                </div>
                <div className="mt-4 grid gap-3 md:grid-cols-3">
                  <p className="text-sm text-[color:var(--ink-soft)]">
                    Last ok:{" "}
                    <span className="font-medium text-ink">
                      {key.last_ok_at ? formatDateTime(key.last_ok_at) : "Never"}
                    </span>
                  </p>
                  <p className="text-sm text-[color:var(--ink-soft)]">
                    Last error:{" "}
                    <span className="font-medium text-ink">
                      {key.last_error_at
                        ? formatDateTime(key.last_error_at)
                        : "None"}
                    </span>
                  </p>
                  <p className="text-sm text-[color:var(--ink-soft)]">
                    Consecutive failures:{" "}
                    <span className="font-medium text-ink">
                      {key.consecutive_failures}
                    </span>
                  </p>
                </div>
              </div>
            ))}
          </div>
        </Panel>

        <Panel
          eyebrow="Rotation log"
          title="Latest key events"
          note="This is the first place to look when a capability starts falling back too often."
        >
          <div className="space-y-3">
            {events.map((event) => (
              <div
                key={event.event_id}
                className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
              >
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <p className="font-semibold text-ink">{event.key_label}</p>
                  <StatusPill
                    tone={
                      event.event_type === "success"
                        ? "good"
                        : event.event_type === "failure"
                          ? "warn"
                          : event.event_type === "disabled"
                            ? "danger"
                            : "info"
                    }
                  >
                    {event.event_type}
                  </StatusPill>
                </div>
                <p className="mt-2 text-sm text-[color:var(--ink-soft)]">
                  {event.endpoint ?? "No endpoint"} · {event.model ?? "no model"}
                </p>
                <p className="mt-2 text-sm text-[color:var(--ink-soft)]">
                  {event.notes ?? "No notes recorded."}
                </p>
                <p className="mt-2 font-mono text-xs text-[color:var(--ink-muted)]">
                  {formatDateTime(event.created_at)}
                  {event.error_code ? ` · ${event.error_code}` : ""}
                </p>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </>
  );
}
