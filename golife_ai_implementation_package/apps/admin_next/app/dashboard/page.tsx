import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import {
  getDashboard,
  getFeatureFlags,
  getSafety,
  getSupportRequests,
} from "@/lib/api";
import {
  formatCurrency,
  formatNumber,
  formatPercent,
  labelizeKey,
} from "@/lib/format";

export default async function DashboardPage() {
  const [dashboardResult, flagsResult, safetyResult, supportResult] =
    await Promise.all([
      getDashboard(),
      getFeatureFlags(),
      getSafety(),
      getSupportRequests(),
    ]);

  const dashboard = dashboardResult.data!;
  const flags = flagsResult.data ?? [];
  const safety = safetyResult.data ?? [];
  const supportRequests = supportResult.data ?? [];
  const error =
    [
      dashboardResult.error,
      flagsResult.error,
      safetyResult.error,
      supportResult.error,
    ]
      .filter(Boolean)
      .join(" | ") || null;

  return (
    <>
      <PageHeader
        eyebrow="Decision Desk"
        title="Operational pulse for the personal OS"
        description="Watch whether GoLife is generating useful missions, staying inside trust boundaries, and keeping AI cost under control."
        badge="Mission ops"
      />
      <ErrorBanner error={error} />

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          label="Useful missions / active user / week"
          value={formatNumber(dashboard.useful_missions_per_active_user_week)}
          note="North star of real product utility."
          tone="sage"
        />
        <MetricCard
          label="Mission completion rate"
          value={formatPercent(dashboard.mission_completion_rate)}
          note="Checks whether recommendations become action."
          tone="ink"
        />
        <MetricCard
          label="AI cost / active user"
          value={formatCurrency(dashboard.ai_cost_per_active_user_usd)}
          note="Keep the margin visible while usage grows."
          tone="bronze"
        />
        <MetricCard
          label="Safety intervention rate"
          value={formatPercent(dashboard.safety_intervention_rate)}
          note="Signals whether prompts are drifting into regulated or unsafe territory."
          tone="clay"
        />
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.35fr_0.95fr]">
        <Panel
          eyebrow="Briefing"
          title="What to watch today"
          note="The board is organized around the same three questions product asks every morning: are missions useful, are risks clear, and is trust intact?"
        >
          <div className="grid gap-4 md:grid-cols-3">
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">Mission quality</p>
              <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                Usefulness is at{" "}
                <span className="font-semibold text-ink">
                  {formatPercent(dashboard.recommendation_usefulness_rate)}
                </span>
                . Rejections are{" "}
                <span className="font-semibold text-ink">
                  {formatPercent(dashboard.rejection_rate)}
                </span>
                .
              </p>
            </div>
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">Operational load</p>
              <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                WAU is <span className="font-semibold text-ink">{dashboard.wau}</span>
                , DAU is <span className="font-semibold text-ink">{dashboard.dau}</span>,
                and capture volume is{" "}
                <span className="font-semibold text-ink">
                  {formatNumber(dashboard.capture_events_per_active_user)}
                </span>{" "}
                events per active user.
              </p>
            </div>
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">Trust queue</p>
              <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                There are{" "}
                <span className="font-semibold text-ink">{supportRequests.length}</span>{" "}
                export/delete requests and{" "}
                <span className="font-semibold text-ink">{safety.length}</span>{" "}
                recent safety incidents to review.
              </p>
            </div>
          </div>
        </Panel>

        <Panel
          eyebrow="Release Surface"
          title="Feature flags"
          note="Operational rollouts stay visible here so mobile, gateway, and admin work from the same switchboard."
        >
          <div className="space-y-3">
            {flags.map((flag) => (
              <div
                key={flag.key}
                className="flex flex-col gap-3 rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4 md:flex-row md:items-center md:justify-between"
              >
                <div>
                  <p className="text-sm font-semibold text-ink">
                    {labelizeKey(flag.key)}
                  </p>
                  <p className="mt-1 text-sm leading-6 text-[color:var(--ink-soft)]">
                    {flag.description}
                  </p>
                </div>
                <StatusPill tone={flag.enabled ? "good" : "warn"}>
                  {flag.enabled ? "Enabled" : "Disabled"}
                </StatusPill>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </>
  );
}
