import { CostCard } from "@/components/premium/cost-card";
import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getXInsightCredits, getXInsightPlans, getXInsightUsage } from "@/lib/api";
import { formatCurrency, formatDateTime, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { AiUsageLedgerRow } from "@/lib/types";

export default async function XInsightAIPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.xinsightai;
  const [usageResult, creditsResult, plansResult] = await Promise.all([
    getXInsightUsage(),
    getXInsightCredits(),
    getXInsightPlans(),
  ]);
  const usage = usageResult.data ?? [];
  const credits = creditsResult.data;
  const plans = plansResult.data ?? [];

  const columns: Array<DataColumn<AiUsageLedgerRow>> = [
    {
      id: "mode",
      header: t.tableMode,
      cell: (row) => (
        <StatusPill tone={row.ai_mode === "byok" ? "warn" : "good"}>
          {row.ai_mode}
        </StatusPill>
      ),
    },
    {
      id: "endpoint",
      header: t.tableEndpoint,
      cell: (row) => (
        <div>
          <p className="text-sm font-semibold text-ink">{row.endpoint}</p>
          <p className="mt-1 text-sm text-[color:var(--ink-soft)]">
            {row.model ?? messages.shared.notAvailable}
          </p>
        </div>
      ),
    },
    {
      id: "tokens",
      header: t.tableTokens,
      cell: (row) => (
        <span className="text-sm text-ink">
          {formatNumber(row.input_tokens + row.output_tokens, locale)}
        </span>
      ),
    },
    {
      id: "customerCharge",
      header: t.tableCustomerCharge,
      cell: (row) => (
        <span className="text-sm text-ink">
          {formatCurrency(row.customer_charge_usd, locale)}
        </span>
      ),
    },
    {
      id: "credits",
      header: t.tableCredits,
      cell: (row) => (
        <span className="text-sm text-ink">
          {formatNumber(row.xinsight_credits_debited, locale)}
        </span>
      ),
    },
    {
      id: "createdAt",
      header: t.tableCreated,
      cell: (row) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {formatDateTime(row.created_at, locale)}
        </span>
      ),
    },
  ];

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />

      <KpiGrid className="xl:grid-cols-4">
        <CostCard
          title={t.totalCreditsLabel}
          amount={formatNumber(credits?.total_credits_debited ?? 0, locale)}
          note={t.totalCreditsNote}
        />
        <CostCard
          title={t.customerChargeLabel}
          amount={formatCurrency(credits?.total_customer_charge_usd ?? 0, locale)}
          note={t.customerChargeNote}
        />
        <CostCard
          title={t.platformCostLabel}
          amount={formatCurrency(credits?.total_platform_cost_usd ?? 0, locale)}
          note={t.platformCostNote}
        />
        <CostCard
          title={t.byokTrafficLabel}
          amount={formatNumber(credits?.byok_request_count ?? 0, locale)}
          note={t.byokTrafficNote}
        />
      </KpiGrid>

      <div className="grid gap-4 lg:grid-cols-2 xl:grid-cols-3">
        {plans.map((plan) => (
          <CostCard
            key={plan.plan_id}
            title={plan.name}
            amount={plan.price_label}
            note={plan.ai_credit_policy}
          />
        ))}
      </div>

      <DataTable columns={columns} rows={usage} rowKey={(row) => row.id} />
    </>
  );
}
