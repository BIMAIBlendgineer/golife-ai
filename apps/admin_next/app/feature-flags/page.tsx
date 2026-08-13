import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getFeatureFlags } from "@/lib/api";
import { formatDateTime } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import { labelFeatureFlagDescription, labelFeatureFlagKey } from "@/lib/labels";

import { toggleFeatureFlag } from "./actions";

export default async function FeatureFlagsPage({
  searchParams,
}: {
  searchParams: Promise<{ updated?: string; error?: string }>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.featureFlags;
  const params = await searchParams;
  const flagsResult = await getFeatureFlags();
  const flags = flagsResult.data ?? [];

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={flagsResult.error ?? params.error ?? null} />
      {params.updated ? (
        <div className="rounded-[22px] border border-[color:rgba(93,122,104,0.24)] bg-[color:var(--sage-soft)] p-4">
          <p className="text-sm font-semibold text-moss">
            {t.updatedFlagPrefix}: {labelFeatureFlagKey(params.updated, messages)}
          </p>
        </div>
      ) : null}

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="space-y-3">
          {flags.map((flag) => (
            <form
              key={flag.key}
              action={toggleFeatureFlag}
              className="flex flex-col gap-4 rounded-[18px] border border-[color:var(--line)] bg-[color:var(--surface-frost)] p-4 md:flex-row md:items-center md:justify-between"
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
                    {flag.enabled ? messages.shared.enabled : messages.shared.disabled}
                  </StatusPill>
                  <StatusPill tone="neutral">
                    {t.updatedAtPrefix} {formatDateTime(flag.updated_at, locale)}
                  </StatusPill>
                </div>
                <div>
                  <p className="text-sm font-semibold text-ink">
                    {labelFeatureFlagKey(flag.key, messages)}
                  </p>
                  <p className="mt-1 text-sm leading-6 text-[color:var(--ink-soft)]">
                    {labelFeatureFlagDescription(flag.key, flag.description, messages)}
                  </p>
                </div>
              </div>
              <button
                type="submit"
                className="rounded-full border border-[color:var(--line-strong)] bg-[color:var(--surface-2)] px-4 py-2 text-sm font-semibold text-ink transition-colors hover:border-moss hover:bg-[color:var(--surface-hover)] hover:text-moss"
              >
                {flag.enabled ? t.turnOff : t.turnOn}
              </button>
            </form>
          ))}
        </div>
      </Panel>
    </>
  );
}
