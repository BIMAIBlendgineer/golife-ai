import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getSupportRequests } from "@/lib/api";
import { formatDateTime } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

import {
  executeSupportDelete,
  markSupportRequestResolved,
} from "./actions";

export default async function SupportExportDeletePage({
  searchParams,
}: {
  searchParams: Promise<{ updated?: string; action?: string; error?: string }>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.supportQueue;
  const params = await searchParams;
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
      <ErrorBanner error={supportResult.error ?? params.error ?? null} />
      {params.updated ? (
        <div className="rounded-[22px] border border-[color:rgba(93,122,104,0.24)] bg-[color:var(--sage-soft)] p-4">
          <p className="text-sm font-semibold text-moss">
            {params.action === "deleted"
              ? `${t.deletedRequestPrefix}: ${params.updated}`
              : `${t.resolvedRequestPrefix}: ${params.updated}`}
          </p>
        </div>
      ) : null}

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
                <p className="text-sm text-[color:var(--ink-soft)]">{t.metadataOnlyNote}</p>
              </div>
              <div className="flex flex-col items-start gap-3 md:items-end">
                <p className="text-sm text-[color:var(--ink-muted)]">
                  {formatDateTime(item.requested_at, locale)}
                </p>
                {item.status === "open" ? (
                  <div className="flex flex-wrap gap-2">
                    {item.request_type === "export" ? (
                      <>
                        <a
                          href={`/support/export-delete/${item.request_id}/bundle`}
                          className="rounded-full border border-[color:var(--line-strong)] bg-white px-4 py-2 text-sm font-semibold text-ink transition-colors hover:border-moss hover:text-moss"
                        >
                          {t.downloadBundleLabel}
                        </a>
                        <form action={markSupportRequestResolved}>
                          <input type="hidden" name="requestId" value={item.request_id} />
                          <button
                            type="submit"
                            className="rounded-full border border-[color:var(--line-strong)] bg-white px-4 py-2 text-sm font-semibold text-ink transition-colors hover:border-moss hover:text-moss"
                          >
                            {t.markResolvedLabel}
                          </button>
                        </form>
                      </>
                    ) : (
                      <form action={executeSupportDelete}>
                        <input type="hidden" name="requestId" value={item.request_id} />
                        <button
                          type="submit"
                          className="rounded-full border border-[color:rgba(173,81,53,0.32)] bg-[color:var(--danger-soft)] px-4 py-2 text-sm font-semibold text-[color:var(--copper)] transition-colors hover:border-[color:rgba(173,81,53,0.48)]"
                        >
                          {t.runDeleteLabel}
                        </button>
                      </form>
                    )}
                  </div>
                ) : null}
              </div>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
