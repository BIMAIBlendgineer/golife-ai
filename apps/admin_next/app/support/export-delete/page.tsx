import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getSupportRequests } from "@/lib/api";
import { formatDateTime } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function SupportExportDeletePage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.supportQueue;
  const supportResult = await getSupportRequests();
  const requests = supportResult.data ?? [];
  const exportCount = requests.filter((item) => item.request_type === "export").length;
  const deleteCount = requests.filter((item) => item.request_type === "delete").length;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={supportResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.openRequestsLabel}
          value={requests.length.toString()}
          note={t.openRequestsNote}
          tone="ink"
        />
        <MetricCard
          label={t.exportLabel}
          value={exportCount.toString()}
          note={t.exportNote}
          tone="bronze"
        />
        <MetricCard
          label={t.deleteLabel}
          value={deleteCount.toString()}
          note={t.deleteNote}
          tone="clay"
        />
      </div>

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="space-y-3">
          {requests.length === 0 ? (
            <p className="text-sm text-[color:var(--ink-soft)]">{t.empty}</p>
          ) : null}
          {requests.map((item) => (
            <div
              key={item.request_id}
              className="flex flex-col gap-3 rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4 md:flex-row md:items-center md:justify-between"
            >
              <div className="space-y-2">
                <div className="flex flex-wrap gap-2">
                  <StatusPill tone={item.request_type === "delete" ? "danger" : "warn"}>
                    {item.request_type === "delete" ? t.deleteLabel : t.exportLabel}
                  </StatusPill>
                  <StatusPill tone={item.status === "open" ? "info" : "good"}>
                    {item.status === "open" ? t.statusOpen : t.statusResolved}
                  </StatusPill>
                </div>
                <p className="font-mono text-xs text-[color:var(--ink-muted)]">
                  {item.request_id} | {item.user_id}
                </p>
              </div>
              <p className="text-sm text-[color:var(--ink-muted)]">
                {formatDateTime(item.requested_at, locale)}
              </p>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
