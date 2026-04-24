import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { getModelSettings } from "@/lib/api";

export default async function ModelSettingsPage() {
  const modelResult = await getModelSettings();
  const settings = modelResult.data!;

  return (
    <>
      <PageHeader
        eyebrow="AI Routing"
        title="Provider and model settings"
        description="This page keeps the main operational model choices visible so cost, fallback, and classification strategy stay explicit."
        badge="Models"
      />
      <ErrorBanner error={modelResult.error} />

      <Panel
        eyebrow="Current stack"
        title="Model routing"
        note="Classification should stay cheap and deterministic when possible. Higher-cost reasoning belongs in ranked synthesis or weekly review."
      >
        <dl className="grid gap-4 md:grid-cols-2">
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              Active provider
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.active_provider}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              Primary model
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.primary_model}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              Fallback model
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.fallback_model}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              Classification model
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.classification_model}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4 md:col-span-2">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              Weekly summary model
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.weekly_summary_model}
            </dd>
          </div>
        </dl>
      </Panel>
    </>
  );
}
