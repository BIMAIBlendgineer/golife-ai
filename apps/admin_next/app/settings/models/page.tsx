import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { getModelSettings } from "@/lib/api";
import { getAdminMessages } from "@/lib/i18n";

export default async function ModelSettingsPage() {
  const { messages } = await getAdminMessages();
  const t = messages.pages.modelSettings;
  const modelResult = await getModelSettings();
  const settings = modelResult.data!;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={modelResult.error} />

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <dl className="grid gap-4 md:grid-cols-2">
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              {t.activeProviderLabel}
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.active_provider}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              {t.primaryModelLabel}
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.primary_model}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              {t.fallbackModelLabel}
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.fallback_model}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              {t.classificationModelLabel}
            </dt>
            <dd className="mt-2 font-mono text-sm text-ink">
              {settings.classification_model}
            </dd>
          </div>
          <div className="rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4 md:col-span-2">
            <dt className="text-xs font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              {t.weeklySummaryModelLabel}
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
