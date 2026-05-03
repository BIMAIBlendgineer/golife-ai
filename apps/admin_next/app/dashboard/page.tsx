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
import { getAdminMessages } from "@/lib/i18n";

export default async function DashboardPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.dashboard;
  const [dashboardResult, flagsResult, safetyResult, supportResult] =
    await Promise.all([
      getDashboard(),
      getFeatureFlags(),
      getSafety(),
      getSupportRequests(),
    ]);

  const dashboard = dashboardResult.data!;
  const flags = flagsResult.data ?? [];
  const safety = safetyResult.data?.items ?? [];
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
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={error} />

      <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <MetricCard
          label={t.usefulMissionsLabel}
          value={formatNumber(dashboard.useful_missions_per_active_user_week, locale)}
          note={t.usefulMissionsNote}
          tone="sage"
        />
        <MetricCard
          label={t.completionRateLabel}
          value={formatPercent(dashboard.mission_completion_rate, locale)}
          note={t.completionRateNote}
          tone="ink"
        />
        <MetricCard
          label={t.aiCostLabel}
          value={formatCurrency(dashboard.ai_cost_per_active_user_usd, locale)}
          note={t.aiCostNote}
          tone="bronze"
        />
        <MetricCard
          label={t.safetyRateLabel}
          value={formatPercent(dashboard.safety_intervention_rate, locale)}
          note={t.safetyRateNote}
          tone="clay"
        />
      </div>

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.activeKeysLabel}
          value={formatNumber(dashboard.active_key_count, locale)}
          note={t.activeKeysNote}
          tone="sage"
        />
        <MetricCard
          label={t.disabledKeysLabel}
          value={formatNumber(dashboard.disabled_key_count, locale)}
          note={t.disabledKeysNote}
          tone="clay"
        />
        <MetricCard
          label={t.snapshotAgeLabel}
          value={
            dashboard.routing_snapshot_age_seconds == null
              ? messages.shared.notAvailable
              : `${dashboard.routing_snapshot_age_seconds}s`
          }
          note={t.snapshotAgeNote}
          tone="bronze"
        />
      </div>

      <div className="grid gap-6 xl:grid-cols-[1.35fr_0.95fr]">
        <Panel
          eyebrow={t.briefingEyebrow}
          title={t.briefingTitle}
          note={t.briefingNote}
        >
          <div className="grid gap-4 md:grid-cols-3">
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">{t.missionQualityTitle}</p>
              <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                {t.missionQualityBodyPrefix}{" "}
                <span className="font-semibold text-ink">
                  {formatPercent(dashboard.recommendation_usefulness_rate, locale)}
                </span>
                . {t.missionQualityBodyMiddle}{" "}
                <span className="font-semibold text-ink">
                  {formatPercent(dashboard.rejection_rate, locale)}
                </span>
                .
              </p>
            </div>
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">{t.operationalLoadTitle}</p>
              <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                {t.operationalLoadBodyPrefix}{" "}
                <span className="font-semibold text-ink">
                  {formatNumber(dashboard.wau, locale)}
                </span>
                , {t.operationalLoadBodyMiddle}{" "}
                <span className="font-semibold text-ink">
                  {formatNumber(dashboard.dau, locale)}
                </span>
                , {t.operationalLoadBodySuffix}{" "}
                <span className="font-semibold text-ink">
                  {formatNumber(dashboard.capture_events_per_active_user, locale)}
                </span>{" "}
                {t.operationalLoadBodyTail}
              </p>
            </div>
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">{t.trustQueueTitle}</p>
              <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
                {t.trustQueueBodyPrefix}{" "}
                <span className="font-semibold text-ink">
                  {formatNumber(supportRequests.length, locale)}
                </span>{" "}
                {t.trustQueueBodyMiddle}{" "}
                <span className="font-semibold text-ink">
                  {formatNumber(safety.length, locale)}
                </span>{" "}
                {t.trustQueueBodySuffix}
              </p>
            </div>
          </div>
        </Panel>

        <Panel
          eyebrow={t.flagsEyebrow}
          title={t.flagsTitle}
          note={t.flagsNote}
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
                  {flag.enabled ? messages.shared.enabled : messages.shared.disabled}
                </StatusPill>
              </div>
            ))}
          </div>
        </Panel>
      </div>
    </>
  );
}
