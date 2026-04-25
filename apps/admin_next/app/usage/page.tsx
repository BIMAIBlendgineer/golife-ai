import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { getUsage } from "@/lib/api";
import { formatDateTime, formatLatency, formatPercent } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function UsagePage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.usage;
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
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={usageResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.captureEventsLabel}
          value={totalCaptureEvents.toString()}
          note={t.captureEventsNote}
          tone="ink"
        />
        <MetricCard
          label={t.missionsGeneratedLabel}
          value={totalGenerated.toString()}
          note={t.missionsGeneratedNote}
          tone="sage"
        />
        <MetricCard
          label={t.averageLatencyLabel}
          value={formatLatency(avgLatency, locale, messages.shared.msUnit)}
          note={t.averageLatencyNote}
          tone="bronze"
        />
      </div>

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="overflow-x-auto">
          <table className="min-w-full border-separate border-spacing-y-3">
            <thead>
              <tr className="text-left text-[11px] font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                <th className="px-3">{t.tableUser}</th>
                <th className="px-3">{t.tableCaptureEvents}</th>
                <th className="px-3">{t.tableMissionsGenerated}</th>
                <th className="px-3">{t.tableCompleted}</th>
                <th className="px-3">{t.tableFallback}</th>
                <th className="px-3">{t.tableLatency}</th>
                <th className="px-3">{t.tableLastActive}</th>
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
                    {formatPercent(item.fallback_rate, locale)}
                  </td>
                  <td className="px-3 py-4 text-sm text-[color:var(--ink-soft)]">
                    {formatLatency(item.latency_ms_avg, locale, messages.shared.msUnit)}
                  </td>
                  <td className="rounded-r-[18px] px-3 py-4 text-sm text-[color:var(--ink-soft)]">
                    {formatDateTime(item.last_active_at, locale)}
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
