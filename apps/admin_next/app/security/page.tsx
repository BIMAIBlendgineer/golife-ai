import Link from "next/link";

import { KpiGrid } from "@/components/premium/kpi-grid";
import { RiskBanner } from "@/components/premium/risk-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getAuthStatus, getSecuritySummary } from "@/lib/api";
import { formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function SecurityPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.security;
  const [securityResult, authResult] = await Promise.all([
    getSecuritySummary(),
    getAuthStatus(),
  ]);
  const security = securityResult.data;
  const auth = authResult.data;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />

      <RiskBanner
        title={t.productionTitle}
        body={auth?.warning ?? t.productionBody}
        tone={security?.production_ready ? "info" : "warn"}
      />

      <KpiGrid className="xl:grid-cols-4">
        <MetricCard
          label={t.guardrailLabel}
          value={security?.production_ready ? messages.shared.enabled : messages.shared.disabled}
          note={t.guardrailNote}
          tone={security?.production_ready ? "sage" : "clay"}
        />
        <MetricCard
          label={t.keyCountLabel}
          value={formatNumber(security?.openrouter_key_count ?? 0, locale)}
          note={t.keyCountNote}
          tone="ink"
        />
        <MetricCard
          label={t.byokLabel}
          value={formatNumber(security?.byok_key_count ?? 0, locale)}
          note={t.byokNote}
          tone="bronze"
        />
        <MetricCard
          label={t.auditLabel}
          value={
            security?.latest_audit_at
              ? formatDateTime(security.latest_audit_at, locale)
              : messages.shared.never
          }
          note={t.auditNote}
          tone="sage"
        />
      </KpiGrid>

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.25fr)_360px]">
        <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-5">
          <div className="grid gap-4 md:grid-cols-2">
            <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.tableCheck}
              </p>
              <p className="mt-3 text-sm font-semibold text-ink">{t.adminTokenCheck}</p>
              <p className="mt-1 text-sm text-[color:var(--ink-soft)]">{t.tokenDetail}</p>
            </div>
            <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.tableState}
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                <StatusPill tone={security?.admin_token_configured ? "good" : "warn"}>
                  admin
                </StatusPill>
                <StatusPill tone={security?.ingestion_token_configured ? "good" : "warn"}>
                  ingestion
                </StatusPill>
                <StatusPill
                  tone={security?.internal_service_token_configured ? "good" : "warn"}
                >
                  internal
                </StatusPill>
              </div>
            </div>
            <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.tableDetail}
              </p>
              <p className="mt-3 text-sm text-[color:var(--ink-soft)]">
                {security?.dependency_scan_status ?? messages.shared.notAvailable}
              </p>
            </div>
            <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
              <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.failedAuthLabel}
              </p>
              <p className="mt-3 text-sm text-[color:var(--ink-soft)]">
                {formatNumber(security?.failed_auth_placeholder ?? 0, locale)}
              </p>
            </div>
          </div>
        </div>

        <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-5">
          <div className="space-y-4">
            <p className="text-sm font-semibold text-ink">{t.settingsCardTitle}</p>
            <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
              {t.settingsCardBody}
            </p>
            <Link
              href="/settings/security"
              className="inline-flex rounded-lg border border-[color:var(--line-strong)] bg-[color:var(--surface-2)] px-3 py-2 text-sm font-medium text-ink transition-colors hover:bg-white"
            >
              {t.settingsLink}
            </Link>
          </div>
        </div>
      </div>
    </>
  );
}
