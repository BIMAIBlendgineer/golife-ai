import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getSafety } from "@/lib/api";
import { formatDateTime, labelizeKey } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function SafetyPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.safety;
  const safetyResult = await getSafety();
  const safety = safetyResult.data ?? [];
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
    </>
  );
}
