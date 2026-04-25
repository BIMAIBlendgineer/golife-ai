import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getRoutingProfiles } from "@/lib/api";
import { formatNumber, labelizeKey } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function RoutingProfilesPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.routingProfiles;
  const profilesResult = await getRoutingProfiles();
  const profiles = profilesResult.data ?? [];

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={profilesResult.error} />

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="space-y-4">
          {profiles.length === 0 ? (
            <p className="text-sm text-[color:var(--ink-soft)]">{t.empty}</p>
          ) : null}
          {profiles.map((profile) => (
            <div
              key={profile.capability}
              className="rounded-[20px] border border-[color:var(--line)] bg-white/48 p-5"
            >
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <p className="font-semibold text-ink">
                    {labelizeKey(profile.capability)}
                  </p>
                  <p className="mt-1 text-sm text-[color:var(--ink-soft)]">
                    {t.strategyLabel} {labelizeKey(profile.strategy)}
                  </p>
                </div>
                <StatusPill tone={profile.enabled ? "good" : "warn"}>
                  {profile.enabled ? messages.shared.enabled : messages.shared.disabled}
                </StatusPill>
              </div>

              <div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    {t.minContextLabel}
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {formatNumber(profile.min_context_length, locale)}
                  </p>
                </div>
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    {t.maxLatencyLabel}
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {profile.preferred_max_latency_seconds}s
                  </p>
                </div>
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    {t.minThroughputLabel}
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {profile.preferred_min_throughput_tokens_per_second} tok/s
                  </p>
                </div>
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    {t.retryPolicyLabel}
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {profile.retry_policy.key_retries ?? 0}/
                    {profile.retry_policy.parse_retries ?? 0}
                  </p>
                </div>
              </div>

              <div className="mt-4">
                <p className="text-sm font-semibold text-ink">
                  {t.requiredParametersLabel}
                </p>
                <div className="mt-2 flex flex-wrap gap-2">
                  {profile.required_parameters.map((parameter) => (
                    <StatusPill key={parameter} tone="info">
                      {parameter}
                    </StatusPill>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
