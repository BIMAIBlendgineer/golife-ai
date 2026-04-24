import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getMissions } from "@/lib/api";

export default async function MissionsPage() {
  const missionsResult = await getMissions();
  const missions = missionsResult.data ?? [];
  const completed = missions.filter((item) => item.status === "completed").length;
  const rejected = missions.filter((item) => item.status === "rejected").length;

  return (
    <>
      <PageHeader
        eyebrow="Mission Audit"
        title="Ranked outputs and linked risks"
        description="This table is the quality gate for whether the system is creating actions worth doing, not just cards worth rendering."
        badge="Quality review"
      />
      <ErrorBanner error={missionsResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Tracked missions"
          value={missions.length.toString()}
          note="Current audit slice from the operational backend."
          tone="ink"
        />
        <MetricCard
          label="Completed"
          value={completed.toString()}
          note="The strongest proof of practical utility."
          tone="sage"
        />
        <MetricCard
          label="Rejected"
          value={rejected.toString()}
          note="A direct signal for repetitive or low-context recommendations."
          tone="clay"
        />
      </div>

      <Panel
        eyebrow="Review"
        title="Mission records"
        note="Each row keeps domains, matched risks, usefulness, and final score in one place."
      >
        <div className="space-y-3">
          {missions.map((mission) => (
            <div
              key={mission.mission_id}
              className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
            >
              <div className="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
                <div className="space-y-2">
                  <p className="text-sm font-semibold text-ink">{mission.title}</p>
                  <p className="font-mono text-xs text-[color:var(--ink-muted)]">
                    {mission.mission_id} · {mission.user_id}
                  </p>
                  <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
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
                  {mission.usefulness ? (
                    <StatusPill tone="neutral">{mission.usefulness}</StatusPill>
                  ) : null}
                  <StatusPill tone="info">
                    score {mission.final_score.toFixed(2)}
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
