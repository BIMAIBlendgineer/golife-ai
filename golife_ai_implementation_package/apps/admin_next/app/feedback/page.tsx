import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getFeedback } from "@/lib/api";
import { formatDateTime } from "@/lib/format";

export default async function FeedbackPage() {
  const feedbackResult = await getFeedback();
  const feedback = feedbackResult.data ?? [];
  const usefulCount = feedback.filter((item) =>
    ["useful", "accepted", "completed"].includes(item.status),
  ).length;
  const rejectedCount = feedback.filter((item) => item.status === "rejected").length;

  return (
    <>
      <PageHeader
        eyebrow="Learning Loop"
        title="Feedback journal"
        description="Accepted, completed, and rejected missions are the live teaching signal for the ranking layer."
        badge="Ranking input"
      />
      <ErrorBanner error={feedbackResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Feedback events"
          value={feedback.length.toString()}
          note="Stored signals available to improve future ranking."
          tone="ink"
        />
        <MetricCard
          label="Useful or accepted"
          value={usefulCount.toString()}
          note="Positive signals that should reinforce similar mission patterns."
          tone="sage"
        />
        <MetricCard
          label="Rejected"
          value={rejectedCount.toString()}
          note="The clearest early warning for repetition or poor context."
          tone="clay"
        />
      </div>

      <Panel
        eyebrow="Journal"
        title="Feedback records"
        note="Capture the reason whenever possible. Bare status is weaker than an explicit explanation."
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
                    {item.reason ?? "No explicit reason recorded."}
                  </p>
                  <p className="text-sm text-[color:var(--ink-muted)]">
                    Domains: {item.domains.join(", ")}
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
