import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getModelCatalog } from "@/lib/api";
import { formatCurrency, formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function ModelCatalogPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.modelCatalog;
  const catalogResult = await getModelCatalog();
  const catalog = catalogResult.data ?? [];

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={catalogResult.error} />

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="space-y-4">
          {catalog.length === 0 ? (
            <p className="text-sm text-[color:var(--ink-soft)]">{t.empty}</p>
          ) : null}
          {catalog.map((model) => (
            <div
              key={model.model_id}
              className="rounded-[20px] border border-[color:var(--line)] bg-white/48 p-5"
            >
              <div className="flex flex-wrap items-center justify-between gap-3">
                <div>
                  <p className="font-semibold text-ink">{model.name}</p>
                  <p className="mt-1 font-mono text-sm text-[color:var(--ink-muted)]">
                    {model.model_id}
                  </p>
                </div>
                <div className="flex flex-wrap gap-2">
                  {model.output_modalities.map((modality) => (
                    <StatusPill key={modality} tone="good">
                      {modality}
                    </StatusPill>
                  ))}
                </div>
              </div>

              <div className="mt-4 grid gap-4 md:grid-cols-2 xl:grid-cols-4">
                <p className="text-sm text-[color:var(--ink-soft)]">
                  {t.contextLabel}{" "}
                  <span className="font-mono text-ink">
                    {formatNumber(model.context_length, locale)}
                  </span>
                </p>
                <p className="text-sm text-[color:var(--ink-soft)]">
                  {t.promptLabel}{" "}
                  <span className="font-mono text-ink">
                    {formatCurrency(model.prompt_price_usd_per_million, locale)}
                  </span>
                </p>
                <p className="text-sm text-[color:var(--ink-soft)]">
                  {t.completionLabel}{" "}
                  <span className="font-mono text-ink">
                    {formatCurrency(model.completion_price_usd_per_million, locale)}
                  </span>
                </p>
                <p className="text-sm text-[color:var(--ink-soft)]">
                  {t.refreshedLabel}{" "}
                  <span className="font-medium text-ink">
                    {formatDateTime(model.refreshed_at, locale)}
                  </span>
                </p>
              </div>

              <div className="mt-4 flex flex-wrap gap-2">
                {model.supported_parameters.map((parameter) => (
                  <StatusPill key={parameter} tone="info">
                    {parameter}
                  </StatusPill>
                ))}
              </div>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
