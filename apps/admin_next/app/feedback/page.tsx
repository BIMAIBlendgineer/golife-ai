import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getFeedback } from "@/lib/api";
import { formatDateTime, formatFeedbackReason } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function FeedbackPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.feedback;
  const feedbackResult = await getFeedback();
  const feedback = feedbackResult.data ?? [];
  const usefulCount = feedback.filter((item) =>
    ["useful", "accepted", "completed"].includes(item.status),
  ).length;
  const rejectedCount = feedback.filter((item) => item.status === "rejected").length;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={feedbackResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.eventsLabel}
          value={feedback.length.toString()}
          note={t.eventsNote}
          tone="ink"
        />
        <MetricCard
          label={t.positiveLabel}
          value={usefulCount.toString()}
          note={t.positiveNote}
          tone="sage"
        />
        <MetricCard
          label={t.rejectedLabel}
          value={rejectedCount.toString()}
          note={t.rejectedNote}
          tone="clay"
        />
      </div>

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="space-y-3">
          {feedback.map((item) => (
            <div
              key={item.feedback_id}
              className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
            >
              <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
                <div className="space-y-2">
                  <div className="flex flex-wrap gap-2">
                    <StatusPill
                      tone={
                        item.status === "rejected"
                          ? "danger"
                          : item.status === "completed"
                            ? "good"
                            : "info"
                      }
                    >
                      {item.status}
                    </StatusPill>
                    <StatusPill tone="neutral">{item.suggestion_id}</StatusPill>
                  </div>
                  <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
                    {formatFeedbackReason(item.reason, messages)}
                  </p>
                  <p className="text-sm text-[color:var(--ink-muted)]">
                    {t.domainsPrefix}: {item.domains.join(", ")}
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
