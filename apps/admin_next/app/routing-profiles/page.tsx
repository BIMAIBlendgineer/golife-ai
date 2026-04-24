import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getRoutingProfiles } from "@/lib/api";
import { formatNumber, labelizeKey } from "@/lib/format";

export default async function RoutingProfilesPage() {
  const profilesResult = await getRoutingProfiles();
  const profiles = profilesResult.data ?? [];

  return (
    <>
      <PageHeader
        eyebrow="Routing Policy"
        title="Capability profiles"
        description="Each capability keeps its own latency, throughput, parameter, and context rules so the gateway does not route everything with one blunt policy."
        badge="Per capability"
      />
      <ErrorBanner error={profilesResult.error} />

      <Panel
        eyebrow="Profiles"
        title="Quality-first routing rules"
        note="These rules gate the whole OpenRouter catalog before ranking. Keep them strict enough to protect structured outputs."
      >
        <div className="space-y-4">
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
                    Strategy {labelizeKey(profile.strategy)}
                  </p>
                </div>
                <StatusPill tone={profile.enabled ? "good" : "warn"}>
                  {profile.enabled ? "Enabled" : "Disabled"}
                </StatusPill>
              </div>

              <div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    Min context
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {formatNumber(profile.min_context_length)}
                  </p>
                </div>
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    Max latency
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {profile.preferred_max_latency_seconds}s
                  </p>
                </div>
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    Min throughput
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {profile.preferred_min_throughput_tokens_per_second} tok/s
                  </p>
                </div>
                <div>
                  <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                    Retry policy
                  </p>
                  <p className="mt-2 font-mono text-xl text-ink">
                    {profile.retry_policy.key_retries ?? 0}/
                    {profile.retry_policy.parse_retries ?? 0}
                  </p>
                </div>
              </div>

              <div className="mt-4">
                <p className="text-sm font-semibold text-ink">
                  Required parameters
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
