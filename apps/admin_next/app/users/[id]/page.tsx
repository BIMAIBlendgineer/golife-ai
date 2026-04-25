import { notFound } from "next/navigation";

import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getFeedback, getMissions, getUsage, getUser } from "@/lib/api";
import { formatDateTime, formatFeedbackReason, formatPercent } from "@/lib/format";

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const [userResult, usageResult, missionResult, feedbackResult] =
    await Promise.all([
      getUser(id),
      getUsage(),
      getMissions(),
      getFeedback(),
    ]);

  const user = userResult.data;
  if (!user) {
    notFound();
  }

  const usage = (usageResult.data ?? []).find((item) => item.user_id === id) ?? null;
  const missions = (missionResult.data ?? []).filter((item) => item.user_id === id);
  const feedback = (feedbackResult.data ?? []).filter((item) => item.user_id === id);
  const error =
    [userResult.error, usageResult.error, missionResult.error, feedbackResult.error]
      .filter(Boolean)
      .join(" | ") || null;

  return (
    <>
      <PageHeader
        eyebrow="User File"
        title={user.email}
        description="This dossier combines current plan, live usage footprint, mission outcomes, and the feedback that should shape ranking next."
        badge={user.user_id}
      />
      <ErrorBanner error={error} />

      <div className="grid gap-4 md:grid-cols-4">
        <MetricCard
          label="Plan"
          value={user.plan}
          note="Commercial state of this account."
          tone="ink"
        />
        <MetricCard
          label="AI calls"
          value={user.ai_calls.toString()}
          note="Total operational gateway traffic so far."
          tone="bronze"
        />
        <MetricCard
          label="Useful missions"
          value={user.useful_missions_completed.toString()}
          note="Completed or accepted missions that mattered."
          tone="sage"
        />
        <MetricCard
          label="Fallback rate"
          value={usage ? formatPercent(usage.fallback_rate) : "0%"}
          note="How often this user needed deterministic fallback."
          tone="clay"
        />
      </div>

      <div className="grid gap-6 xl:grid-cols-[0.95fr_1.05fr]">
        <Panel
          eyebrow="Account"
          title="State and support"
          note="Support flags are early warning markers for trust, monetization, or product learning."
        >
          <div className="space-y-4 text-sm leading-6 text-[color:var(--ink-soft)]">
            <div className="flex flex-wrap gap-2">
              <StatusPill tone={user.status === "active" ? "good" : "warn"}>
                {user.status}
              </StatusPill>
              {user.weekly_active ? (
                <StatusPill tone="info">Weekly active</StatusPill>
              ) : (
                <StatusPill tone="warn">Dormant this week</StatusPill>
              )}
              {user.export_requested ? (
                <StatusPill tone="warn">Export requested</StatusPill>
              ) : null}
              {user.delete_requested ? (
                <StatusPill tone="danger">Delete requested</StatusPill>
              ) : null}
            </div>
            <div className="grid gap-3 md:grid-cols-2">
              <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  Created
                </p>
                <p className="mt-2 text-sm text-ink">{formatDateTime(user.created_at)}</p>
              </div>
              <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  Last seen
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatDateTime(user.last_seen_at)}
                </p>
              </div>
            </div>
            <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                Support flags
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                {user.support_flags.length > 0 ? (
                  user.support_flags.map((flag) => (
                    <StatusPill key={flag} tone="info">
                      {flag}
                    </StatusPill>
                  ))
                ) : (
                  <StatusPill tone="neutral">No manual flags</StatusPill>
                )}
              </div>
            </div>
          </div>
        </Panel>

        <Panel
          eyebrow="Behavior"
          title="Mission and feedback journal"
          note="Mission outcomes stay visible here. Private feedback notes are redacted before they reach admin."
        >
          <div className="space-y-3">
            {missions.map((mission) => (
              <div
                key={mission.mission_id}
                className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
              >
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="text-sm font-semibold text-ink">{mission.title}</p>
                    <p className="mt-1 text-sm text-[color:var(--ink-soft)]">
                      Domains: {mission.domains.join(", ")}. Risks:{" "}
                      {mission.matched_risks.join(", ") || "none"}.
                    </p>
                  </div>
                  <div className="flex flex-wrap gap-2">
                    <StatusPill
                      tone={
                        mission.status === "completed"
                          ? "good"
                          : mission.status === "rejected"
                            ? "danger"
                            : "info"
                      }
                    >
                      {mission.status}
                    </StatusPill>
                    <StatusPill tone="neutral">
                      score {mission.final_score.toFixed(2)}
                    </StatusPill>
                  </div>
                </div>
              </div>
            ))}
            {feedback.map((item) => (
              <div
                key={item.feedback_id}
                className="rounded-[18px] border border-[color:var(--line)] bg-[color:rgba(93,122,104,0.06)] p-4"
              >
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div>
                    <p className="text-sm font-semibold text-ink">{item.status}</p>
                    <p className="mt-1 text-sm text-[color:var(--ink-soft)]">
                      {formatFeedbackReason(item.reason)}
                    </p>
                  </div>
                  <p className="text-sm text-[color:var(--ink-muted)]">
                    {formatDateTime(item.created_at)}
                  </p>
                </div>
              </div>
            ))}
            {missions.length === 0 && feedback.length === 0 ? (
              <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
                No mission or feedback records found for this user yet.
              </p>
            ) : null}
          </div>
        </Panel>
      </div>
    </>
  );
}
