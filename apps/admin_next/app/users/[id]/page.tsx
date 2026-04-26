import { notFound } from "next/navigation";

import { ErrorBanner } from "@/components/error-banner";
import { DetailDrawer } from "@/components/premium/detail-drawer";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import {
  getUserPrivacySummary,
  getUserSummary,
  getUserSupportSummary,
  getUserUsageSummary,
} from "@/lib/api";
import { formatDateTime, formatLatency, formatPercent } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function UserDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.userDetail;
  const { id } = await params;

  const [summaryResult, usageResult, privacyResult, supportResult] =
    await Promise.all([
      getUserSummary(id),
      getUserUsageSummary(id),
      getUserPrivacySummary(id),
      getUserSupportSummary(id),
    ]);

  const summary = summaryResult.data;
  if (!summary) {
    notFound();
  }

  const error =
    [
      summaryResult.error,
      usageResult.data ? null : usageResult.error,
      privacyResult.data ? null : privacyResult.error,
      supportResult.data ? null : supportResult.error,
    ]
      .filter(Boolean)
      .join(" | ") || null;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={summary.display_name}
        description={t.description}
        badge={summary.user_id}
      />
      <ErrorBanner error={error} />

      <KpiGrid>
        <MetricCard
          label={t.planLabel}
          value={summary.plan}
          note={t.planNote}
          tone="ink"
        />
        <MetricCard
          label={t.aiCallsLabel}
          value={(usageResult.data?.ai_calls_count ?? 0).toString()}
          note={t.aiCallsNote}
          tone="bronze"
        />
        <MetricCard
          label={t.usefulMissionsLabel}
          value={(usageResult.data?.missions_completed ?? 0).toString()}
          note={t.usefulMissionsNote}
          tone="sage"
        />
        <MetricCard
          label={t.fallbackRateLabel}
          value={formatPercent(usageResult.data?.fallback_rate ?? 0, locale)}
          note={t.fallbackRateNote}
          tone="clay"
        />
      </KpiGrid>

      <div className="grid gap-6 xl:grid-cols-[1.1fr_0.9fr]">
        <DetailDrawer title={t.accountTitle} description={t.accountNote}>
          <div className="space-y-4 text-sm leading-6 text-[color:var(--ink-soft)]">
            <div className="flex flex-wrap gap-2">
              <StatusPill tone={summary.status === "active" ? "good" : "warn"}>
                {summary.status}
              </StatusPill>
              <StatusPill tone="neutral">{summary.locale}</StatusPill>
              <StatusPill tone="neutral">{summary.plan}</StatusPill>
            </div>
            <div className="grid gap-3 md:grid-cols-2">
              <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {messages.shared.created}
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatDateTime(summary.created_at, locale)}
                </p>
              </div>
              <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {messages.shared.lastSeen}
                </p>
                <p className="mt-2 text-sm text-ink">
                  {formatDateTime(summary.last_seen_at, locale)}
                </p>
              </div>
            </div>
            <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
              <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.emailLabel}
              </p>
              <p className="mt-2 text-sm text-ink">{summary.email_masked}</p>
            </div>
            <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
              <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {messages.shared.supportFlags}
              </p>
              <div className="mt-3 flex flex-wrap gap-2">
                {summary.support_flags.length > 0 ? (
                  summary.support_flags.map((flag) => (
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
        </DetailDrawer>

        <DetailDrawer title={t.behaviorTitle} description={t.behaviorNote}>
          <div className="space-y-4 text-sm leading-6 text-[color:var(--ink-soft)]">
            {usageResult.data ? (
              <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.usageSummaryLabel}
                </p>
                <p className="mt-2">
                  {usageResult.data.capture_events} capture events,{" "}
                  {usageResult.data.missions_generated} missions generated,{" "}
                  {usageResult.data.missions_completed} missions completed,{" "}
                  {formatPercent(usageResult.data.fallback_rate, locale)} fallback,{" "}
                  {formatLatency(
                    usageResult.data.latency_ms_avg,
                    locale,
                    messages.shared.msUnit,
                  )}
                  .
                </p>
              </div>
            ) : null}

            {privacyResult.data ? (
              <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.privacySummaryLabel}
                </p>
                <p className="mt-2">
                  {privacyResult.data.privacy_request_status}.{" "}
                  {privacyResult.data.open_requests.length > 0
                    ? privacyResult.data.open_requests.join(", ")
                    : messages.shared.none}
                  .
                </p>
                <p className="mt-2">{t.metadataOnlyLabel}</p>
              </div>
            ) : null}

            {supportResult.data ? (
              <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] p-4">
                <p className="text-xs font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.supportSummaryLabel}
                </p>
                <p className="mt-2">
                  {supportResult.data.open_request_count} {t.openRequestsLabel}
                </p>
              </div>
            ) : null}
          </div>
        </DetailDrawer>
      </div>
    </>
  );
}
