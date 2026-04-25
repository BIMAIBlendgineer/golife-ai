import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getMissions } from "@/lib/api";
import { getAdminMessages } from "@/lib/i18n";

export default async function MissionsPage() {
  const { messages } = await getAdminMessages();
  const t = messages.pages.missions;
  const missionsResult = await getMissions();
  const missions = missionsResult.data ?? [];
  const completed = missions.filter((item) => item.status === "completed").length;
  const rejected = missions.filter((item) => item.status === "rejected").length;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={missionsResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.trackedLabel}
          value={missions.length.toString()}
          note={t.trackedNote}
          tone="ink"
        />
        <MetricCard
          label={t.completedLabel}
          value={completed.toString()}
          note={t.completedNote}
          tone="sage"
        />
        <MetricCard
          label={t.rejectedLabel}
          value={rejected.toString()}
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
          {missions.length === 0 ? (
            <p className="text-sm text-[color:var(--ink-soft)]">{t.empty}</p>
          ) : null}
          {missions.map((mission) => (
            <div
              key={mission.mission_id}
              className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
            >
              <div className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
                <div className="space-y-2">
                  <p className="text-sm font-semibold text-ink">{mission.title}</p>
                  <p className="font-mono text-xs text-[color:var(--ink-muted)]">
                    {mission.mission_id} | {mission.user_id}
                  </p>
                  <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
                    {t.domainsLabel}: {mission.domains.join(", ")}. {t.risksLabel}:{" "}
                    {mission.matched_risks.join(", ") || t.none}.
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
                    {mission.status === "completed"
                      ? t.statusCompleted
                      : mission.status === "rejected"
                        ? t.statusRejected
                        : t.statusShown}
                  </StatusPill>
                  {mission.usefulness ? (
                    <StatusPill tone="neutral">{mission.usefulness}</StatusPill>
                  ) : null}
                  <StatusPill tone="info">
                    {t.scoreLabel} {mission.final_score.toFixed(2)}
                  </StatusPill>
                </div>
              </div>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
