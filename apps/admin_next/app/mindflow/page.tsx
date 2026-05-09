import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { RiskBanner } from "@/components/premium/risk-banner";
import { StatusPill } from "@/components/status-pill";
import {
  getMindFlowDecisionQuality,
  getMindFlowOpenLoops,
  getMindFlowSummary,
} from "@/lib/api";
import { formatNumber, formatPercent } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function MindFlowPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.mindflow;
  const [summaryResult, qualityResult, openLoopsResult] = await Promise.all([
    getMindFlowSummary(),
    getMindFlowDecisionQuality(),
    getMindFlowOpenLoops(),
  ]);

  const summary = summaryResult.data!;
  const quality = qualityResult.data!;
  const openLoops = openLoopsResult.data!;
  const error =
    [summaryResult.error, qualityResult.error, openLoopsResult.error]
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
      <RiskBanner
        title={t.disclaimerTitle}
        body={t.disclaimerBody}
        tone="info"
      />

      <KpiGrid className="xl:grid-cols-4">
        <MetricCard
          label={t.mentalLoadLabel}
          value={formatNumber(summary.mental_load_items_per_active_user, locale)}
          note={t.mentalLoadNote}
          tone="ink"
        />
        <MetricCard
          label={t.acceptanceLabel}
          value={formatPercent(summary.decision_acceptance_rate, locale)}
          note={t.acceptanceNote}
          tone="sage"
        />
        <MetricCard
          label={t.completionLabel}
          value={formatPercent(summary.decision_completion_rate, locale)}
          note={t.completionNote}
          tone="bronze"
        />
        <MetricCard
          label={t.privacyFilterLabel}
          value={formatPercent(summary.privacy_filtered_decision_rate, locale)}
          note={t.privacyFilterNote}
          tone="clay"
        />
      </KpiGrid>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.05fr)_minmax(0,0.95fr)]">
        <Panel
          eyebrow={t.openLoopsEyebrow}
          title={t.openLoopsTitle}
          note={t.openLoopsNote}
        >
          <div className="grid gap-4 md:grid-cols-2">
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">{t.mentalLoadQueueLabel}</p>
              <p className="mt-2 text-3xl font-semibold text-ink">
                {formatNumber(openLoops.mental_load_items, locale)}
              </p>
            </div>
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">{t.pendingDecisionsLabel}</p>
              <p className="mt-2 text-3xl font-semibold text-ink">
                {formatNumber(openLoops.pending_decisions, locale)}
              </p>
            </div>
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">{t.pendingShoppingLabel}</p>
              <p className="mt-2 text-3xl font-semibold text-ink">
                {formatNumber(openLoops.pending_shopping_needs, locale)}
              </p>
            </div>
            <div className="rounded-[20px] border border-[color:var(--line)] bg-white/45 p-4">
              <p className="text-sm font-semibold text-ink">{t.warrantyReviewLabel}</p>
              <p className="mt-2 text-3xl font-semibold text-ink">
                {formatNumber(openLoops.warranty_review_needs, locale)}
              </p>
            </div>
          </div>
          <div className="mt-4 flex flex-wrap gap-2">
            <StatusPill tone="warn">
              {t.openLoopsTitle}: {formatNumber(openLoops.total_open_loops, locale)}
            </StatusPill>
            <StatusPill tone="info">
              {t.fallbackTitle}: {formatPercent(summary.fallback_rate, locale)}
            </StatusPill>
            <StatusPill tone="neutral">
              Open loop rate: {formatPercent(summary.open_loop_rate, locale)}
            </StatusPill>
          </div>
        </Panel>

        <Panel
          eyebrow={t.decisionFlowEyebrow}
          title={t.decisionFlowTitle}
          note={t.decisionFlowNote}
        >
          <div className="grid gap-3 md:grid-cols-2">
            {[
              [t.generatedLabel, quality.generated_count],
              [t.acceptedLabel, quality.accepted_count],
              [t.completedLabel, quality.completed_count],
              [t.rejectedLabel, quality.rejected_count],
              [t.postponedLabel, quality.postponed_count],
              [t.repeatedLabel, quality.repeated_count],
            ].map(([label, value]) => (
              <div
                key={label}
                className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
              >
                <p className="text-sm font-semibold text-ink">{label}</p>
                <p className="mt-2 text-2xl font-semibold text-ink">
                  {formatNumber(Number(value), locale)}
                </p>
              </div>
            ))}
          </div>
          <div className="mt-4 flex flex-wrap gap-2">
            <StatusPill tone="good">
              {t.acceptanceLabel}: {formatPercent(quality.acceptance_rate, locale)}
            </StatusPill>
            <StatusPill tone="info">
              {t.completionLabel}: {formatPercent(quality.completion_rate, locale)}
            </StatusPill>
            <StatusPill tone="warn">
              {t.postponedLabel}: {formatPercent(quality.postpone_rate, locale)}
            </StatusPill>
            <StatusPill tone="danger">
              {t.rejectedLabel}: {formatPercent(quality.rejection_rate, locale)}
            </StatusPill>
          </div>
          <p className="mt-4 text-sm leading-6 text-[color:var(--ink-soft)]">
            {t.fallbackBody}
          </p>
        </Panel>
      </div>
    </>
  );
}
