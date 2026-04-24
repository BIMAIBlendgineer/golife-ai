import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getFeatureFlags } from "@/lib/api";
import { formatDateTime, labelizeKey } from "@/lib/format";

import { toggleFeatureFlag } from "./actions";

export default async function FeatureFlagsPage({
  searchParams,
}: {
  searchParams: Promise<{ updated?: string; error?: string }>;
}) {
  const params = await searchParams;
  const flagsResult = await getFeatureFlags();
  const flags = flagsResult.data ?? [];

  return (
    <>
      <PageHeader
        eyebrow="Rollout"
        title="Feature flags"
        description="Flags keep mobile, AI gateway, and admin aligned on which behavior is live, which is in shadow mode, and which stays behind operator control."
        badge="Switchboard"
      />
      <ErrorBanner error={flagsResult.error ?? params.error ?? null} />
      {params.updated ? (
        <div className="rounded-[22px] border border-[color:rgba(93,122,104,0.24)] bg-[color:var(--sage-soft)] p-4">
          <p className="text-sm font-semibold text-moss">
            Updated flag: {labelizeKey(params.updated)}
          </p>
        </div>
      ) : null}

      <Panel
        eyebrow="Switches"
        title="Operational rollout control"
        note="Read fallback values if the backend is offline. When the admin API is live, each toggle sends a real PATCH request."
      >
        <div className="space-y-3">
          {flags.map((flag) => (
            <form
              key={flag.key}
              action={toggleFeatureFlag}
              className="flex flex-col gap-4 rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4 md:flex-row md:items-center md:justify-between"
            >
              <input type="hidden" name="key" value={flag.key} />
              <input
                type="hidden"
                name="enabled"
                value={flag.enabled ? "false" : "true"}
              />
              <div className="space-y-2">
                <div className="flex flex-wrap gap-2">
                  <StatusPill tone={flag.enabled ? "good" : "warn"}>
                    {flag.enabled ? "Enabled" : "Disabled"}
                  </StatusPill>
                  <StatusPill tone="neutral">
                    updated {formatDateTime(flag.updated_at)}
                  </StatusPill>
                </div>
                <div>
                  <p className="text-sm font-semibold text-ink">
                    {labelizeKey(flag.key)}
                  </p>
                  <p className="mt-1 text-sm leading-6 text-[color:var(--ink-soft)]">
                    {flag.description}
                  </p>
                </div>
              </div>
              <button
                type="submit"
                className="rounded-full border border-[color:var(--line-strong)] bg-white px-4 py-2 text-sm font-semibold text-ink transition-colors hover:border-moss hover:text-moss"
              >
                Turn {flag.enabled ? "off" : "on"}
              </button>
            </form>
          ))}
        </div>
      </Panel>
    </>
  );
}
