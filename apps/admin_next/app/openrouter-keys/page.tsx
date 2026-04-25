import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getDashboard, getOpenRouterKeyEvents, getOpenRouterKeys } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

function keyStatusLabel(
  status: string,
  t: {
    statusHealthy: string;
    statusDegraded: string;
    statusDisabled: string;
  },
): string {
  switch (status) {
    case "healthy":
      return t.statusHealthy;
    case "degraded":
      return t.statusDegraded;
    case "disabled":
      return t.statusDisabled;
    default:
      return status;
  }
}

function eventTypeLabel(
  eventType: string,
  t: {
    eventSuccess: string;
    eventFailure: string;
    eventDisabled: string;
  },
): string {
  switch (eventType) {
    case "success":
      return t.eventSuccess;
    case "failure":
      return t.eventFailure;
    case "disabled":
      return t.eventDisabled;
    default:
      return eventType;
  }
}

export default async function OpenRouterKeysPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.openrouterKeys;
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
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.activeKeysLabel}
          value={formatNumber(dashboard.active_key_count, locale)}
          note={t.activeKeysNote}
          tone="sage"
        />
        <MetricCard
          label={t.disabledKeysLabel}
          value={formatNumber(dashboard.disabled_key_count, locale)}
          note={t.disabledKeysNote}
          tone="clay"
        />
        <MetricCard
          label={t.recentEventsLabel}
          value={formatNumber(events.length, locale)}
          note={t.recentEventsNote}
          tone="bronze"
        />
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <Panel
          eyebrow={t.keyPoolEyebrow}
          title={t.keyPoolTitle}
          note={t.keyPoolNote}
        >
          <div className="space-y-3">
            {keys.length === 0 ? (
              <p className="text-sm text-[color:var(--ink-soft)]">{t.emptyKeys}</p>
            ) : null}
            {keys.map((key) => (
              <div
                key={key.key_id}
                className="rounded-[20px] border border-[color:var(--line)] bg-white/50 p-4"
              >
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="font-semibold text-ink">{key.label}</p>
                    <p className="mt-1 font-mono text-sm text-[color:var(--ink-muted)]">
                      {key.key_id} | ****{key.secret_last4}
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <StatusPill tone={key.enabled ? "good" : "danger"}>
                      {key.enabled ? messages.shared.enabled : messages.shared.disabled}
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
                      {keyStatusLabel(key.status, t)}
                    </StatusPill>
                    <StatusPill tone="info">{t.priorityLabel} {key.priority}</StatusPill>
                  </div>
                </div>
                <div className="mt-4 grid gap-3 md:grid-cols-3">
                  <p className="text-sm text-[color:var(--ink-soft)]">
                    {t.lastOkLabel}{" "}
                    <span className="font-medium text-ink">
                      {key.last_ok_at ? formatDateTime(key.last_ok_at, locale) : t.never}
                    </span>
                  </p>
                  <p className="text-sm text-[color:var(--ink-soft)]">
                    {t.lastErrorLabel}{" "}
                    <span className="font-medium text-ink">
                      {key.last_error_at ? formatDateTime(key.last_error_at, locale) : t.none}
                    </span>
                  </p>
                  <p className="text-sm text-[color:var(--ink-soft)]">
                    {t.consecutiveFailuresLabel}{" "}
                    <span className="font-medium text-ink">
                      {formatNumber(key.consecutive_failures, locale)}
                    </span>
                  </p>
                </div>
              </div>
            ))}
          </div>
        </Panel>

        <Panel
          eyebrow={t.rotationLogEyebrow}
          title={t.rotationLogTitle}
          note={t.rotationLogNote}
        >
          <div className="space-y-3">
            {events.length === 0 ? (
              <p className="text-sm text-[color:var(--ink-soft)]">{t.emptyEvents}</p>
            ) : null}
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
                    {eventTypeLabel(event.event_type, t)}
                  </StatusPill>
                </div>
                <p className="mt-2 text-sm text-[color:var(--ink-soft)]">
                  {event.endpoint ?? t.noEndpoint} | {event.model ?? t.noModel}
                </p>
                <p className="mt-2 text-sm text-[color:var(--ink-soft)]">
                  {event.notes ?? t.noNotes}
                </p>
                <p className="mt-2 font-mono text-xs text-[color:var(--ink-muted)]">
                  {formatDateTime(event.created_at, locale)}
                  {event.error_code ? ` | ${event.error_code}` : ""}
                </p>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </>
  );
}
