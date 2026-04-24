import { ErrorBanner } from "@/components/error-banner";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getModelCatalog } from "@/lib/api";
import { formatCurrency, formatDateTime, formatNumber } from "@/lib/format";

export default async function ModelCatalogPage() {
  const catalogResult = await getModelCatalog();
  const catalog = catalogResult.data ?? [];

  return (
    <>
      <PageHeader
        eyebrow="Catalog Cache"
        title="OpenRouter model catalog"
        description="This cache is the raw material for routing decisions. Operators should check freshness, context windows, and structured-output capability before trusting a snapshot."
        badge="Eligibility layer"
      />
      <ErrorBanner error={catalogResult.error} />

      <Panel
        eyebrow="Catalog"
        title="Current cached models"
        note="The control plane filters these models before ranking them per capability."
      >
        <div className="space-y-4">
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
                  Context{" "}
                  <span className="font-mono text-ink">
                    {formatNumber(model.context_length)}
                  </span>
                </p>
                <p className="text-sm text-[color:var(--ink-soft)]">
                  Prompt{" "}
                  <span className="font-mono text-ink">
                    {formatCurrency(model.prompt_price_usd_per_million)}
                  </span>
                </p>
                <p className="text-sm text-[color:var(--ink-soft)]">
                  Completion{" "}
                  <span className="font-mono text-ink">
                    {formatCurrency(model.completion_price_usd_per_million)}
                  </span>
                </p>
                <p className="text-sm text-[color:var(--ink-soft)]">
                  Refreshed{" "}
                  <span className="font-medium text-ink">
                    {formatDateTime(model.refreshed_at)}
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
