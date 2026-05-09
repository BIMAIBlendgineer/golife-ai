import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { RiskBanner } from "@/components/premium/risk-banner";
import { StatusPill } from "@/components/status-pill";
import {
  getShoppingClaimsSummary,
  getShoppingEvidenceQuality,
  getShoppingSummary,
} from "@/lib/api";
import { formatNumber, formatPercent } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function ShoppingPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.shopping;
  const [summaryResult, evidenceResult, claimsResult] = await Promise.all([
    getShoppingSummary(),
    getShoppingEvidenceQuality(),
    getShoppingClaimsSummary(),
  ]);

  const summary = summaryResult.data!;
  const evidence = evidenceResult.data!;
  const claims = claimsResult.data!;
  const error =
    [summaryResult.error, evidenceResult.error, claimsResult.error]
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
          label={t.needsLabel}
          value={formatNumber(summary.needs_detected, locale)}
          note={t.needsNote}
          tone="ink"
        />
        <MetricCard
          label={t.plansLabel}
          value={formatNumber(summary.plans_generated, locale)}
          note={t.plansNote}
          tone="sage"
        />
        <MetricCard
          label={t.claimsCoverageLabel}
          value={formatPercent(summary.shopping_claims_with_evidence_rate, locale)}
          note={t.claimsCoverageNote}
          tone="bronze"
        />
        <MetricCard
          label={t.insufficientLabel}
          value={formatPercent(summary.insufficient_sustainability_data_rate, locale)}
          note={t.insufficientNote}
          tone="clay"
        />
      </KpiGrid>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.05fr)_minmax(0,0.95fr)]">
        <Panel
          eyebrow={t.evidenceEyebrow}
          title={t.evidenceTitle}
          note={t.evidenceNote}
        >
          <div className="grid gap-4 md:grid-cols-2">
            {[
              [t.verifiedLabel, evidence.verified_count],
              [t.partialLabel, evidence.partial_count],
              [t.insufficientEvidenceLabel, evidence.insufficient_count],
              [t.notCheckedLabel, evidence.not_checked_count],
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
              {t.claimsCoverageLabel}: {formatPercent(evidence.verified_rate, locale)}
            </StatusPill>
            <StatusPill tone="warn">
              {t.insufficientLabel}: {formatPercent(evidence.insufficient_rate, locale)}
            </StatusPill>
            <StatusPill tone={summary.product_evidence_enabled ? "good" : "warn"}>
              {t.productEvidenceLabel}:{" "}
              {summary.product_evidence_enabled
                ? messages.shared.enabled
                : messages.shared.disabled}
            </StatusPill>
          </div>
        </Panel>

        <Panel
          eyebrow={t.claimsEyebrow}
          title={t.claimsTitle}
          note={t.claimsNote}
        >
          <div className="grid gap-3">
            <div className="flex flex-wrap gap-2">
              <StatusPill tone={summary.external_sources_enabled ? "good" : "warn"}>
                {t.externalSourcesLabel}:{" "}
                {summary.external_sources_enabled
                  ? messages.shared.enabled
                  : messages.shared.disabled}
              </StatusPill>
              <StatusPill tone={claims.blocked_external_sources ? "warn" : "good"}>
                External source blocks:{" "}
                {claims.blocked_external_sources
                  ? messages.shared.enabled
                  : messages.shared.disabled}
              </StatusPill>
            </div>
            <div className="grid gap-3 md:grid-cols-3">
              {[
                [t.priceClaimsBlockedLabel, claims.unverified_price_attempts, "danger"],
                [
                  t.sustainabilityClaimsBlockedLabel,
                  claims.unverified_sustainability_attempts,
                  "warn",
                ],
                [t.availabilityClaimsBlockedLabel, claims.no_availability_claim_count, "info"],
              ].map(([label, value, tone]) => (
                <div
                  key={String(label)}
                  className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4"
                >
                  <p className="text-sm font-semibold text-ink">{label}</p>
                  <div className="mt-3">
                    <StatusPill tone={tone as "danger" | "warn" | "info"}>
                      {formatNumber(Number(value), locale)}
                    </StatusPill>
                  </div>
                </div>
              ))}
            </div>
            <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
              {t.claimsNote}
            </p>
          </div>
        </Panel>
      </div>
    </>
  );
}
