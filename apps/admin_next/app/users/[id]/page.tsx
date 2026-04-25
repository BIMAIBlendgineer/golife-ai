import { notFound } from "next/navigation";

import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getFeedback, getMissions, getUsage, getUser } from "@/lib/api";
import { formatDateTime, formatFeedbackReason, formatPercent } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.userDetail;
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
        eyebrow={t.eyebrow}
        title={user.email}
        description={t.description}
        badge={user.user_id}
      />
      <ErrorBanner error={error} />

      <div className="grid gap-4 md:grid-cols-4">
        <MetricCard
          label={t.planLabel}
          value={user.plan}
          note={t.planNote}
          tone="ink"
        />
        <MetricCard
          label={t.aiCallsLabel}
          value={user.ai_calls.toString()}
          note={t.aiCallsNote}
          tone="bronze"
        />
        <MetricCard
          label={t.usefulMissionsLabel}
          value={user.useful_missions_completed.toString()}
          note={t.usefulMissionsNote}
          tone="sage"
        />
        <MetricCard
          label={t.fallbackRateLabel}
          value={usage ? formatPercent(usage.fallback_rate, locale) : "0%"}
          note={t.fallbackRateNote}
          tone="clay"
        />
      </div>

      <div className="grid gap-6 xl:grid-cols-[0.95fr_1.05fr]">
        <Panel
          eyebrow={t.accountEyebrow}
          title={t.accountTitle}
          note={t.accountNote}
        >
          <div className="space-y-4 text-sm leading-6 text-[color:var(--ink-soft)]">
            <div className="flex flex-wrap gap-2">
              <StatusPill tone={user.status === "active" ? "good" : "warn"}>
                {user.status}
              </StatusPill>
              {user.weekly_active ? (
                <StatusPill tone="info">{messages.shared.weeklyActive}</StatusPill>
              ) : (
                <StatusPill tone="warn">{messages.shared.dormantThisWeek}</StatusPill>
              )}
              {user.export_requested ? (
                <StatusPill tone="warn">{messages.shared.exportRequested}</StatusPill>
              ) : null}
              {user.delete_requested ? (
                <StatusPill tone="danger">{messages.shared.deleteRequested}</StatusPill>
              ) : null}
            </div>
            <div className="grid gap-3 md:grid-cols-2">
              <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  {messages.shared.created}
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatDateTime(user.created_at, locale)}
                </p>
              </div>
              <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                  {messages.shared.lastSeen}
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatDateTime(user.last_seen_at, locale)}
                </p>
              </div>
            </div>
            <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                {messages.shared.supportFlags}
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                {user.support_flags.length > 0 ? (
                  user.support_flags.map((flag) => (
                    <StatusPill key={flag} tone="info">
                      {flag}
                    </StatusPill>
                  ))
                ) : (
                  <StatusPill tone="neutral">{messages.shared.noManualFlags}</StatusPill>
                )}
              </div>
            </div>
          </div>
        </Panel>

        <Panel
          eyebrow={t.behaviorEyebrow}
          title={t.behaviorTitle}
          note={t.behaviorNote}
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
                      {messages.shared.domains}: {mission.domains.join(", ")}.{" "}
                      {messages.shared.risks}:{" "}
                      {mission.matched_risks.join(", ") || messages.shared.none}.
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
                      {messages.shared.score} {mission.final_score.toFixed(2)}
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
                      {formatFeedbackReason(item.reason, messages)}
                    </p>
                  </div>
                  <p className="text-sm text-[color:var(--ink-muted)]">
                    {formatDateTime(item.created_at, locale)}
                  </p>
                </div>
              </div>
            ))}
            {missions.length === 0 && feedback.length === 0 ? (
              <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
                {t.emptyBehavior}
              </p>
            ) : null}
          </div>
        </Panel>
      </div>
    </>
  );
}
