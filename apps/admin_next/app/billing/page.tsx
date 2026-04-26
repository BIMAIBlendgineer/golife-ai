import { CostCard } from "@/components/premium/cost-card";
import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getBillingAccounts, getBillingPlans } from "@/lib/api";
import { formatCurrency, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { BillingAccountRow } from "@/lib/types";

export default async function BillingPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.billing;
  const [accountsResult, plansResult] = await Promise.all([
    getBillingAccounts(),
    getBillingPlans(),
  ]);
  const accounts = accountsResult.data ?? [];
  const plans = plansResult.data ?? [];

  const columns: Array<DataColumn<BillingAccountRow>> = [
    {
      id: "org",
      header: t.tableOrganization,
      cell: (account) => (
        <div>
          <p className="text-sm font-semibold text-ink">{account.organization_name}</p>
          <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
            {account.organization_id}
          </p>
        </div>
      ),
    },
    {
      id: "plan",
      header: t.tablePlan,
      cell: (account) => <StatusPill tone="info">{account.plan}</StatusPill>,
    },
    {
      id: "status",
      header: t.tableStatus,
      cell: (account) => (
        <StatusPill tone={account.subscription_status === "active" ? "good" : "warn"}>
          {account.subscription_status}
        </StatusPill>
      ),
    },
    {
      id: "storage",
      header: t.tableStorageCharge,
      cell: (account) => (
        <span className="text-sm text-ink">
          {formatCurrency(account.storage_charge_usd, locale)}
        </span>
      ),
    },
    {
      id: "ai",
      header: t.tableAiCharge,
      cell: (account) => (
        <span className="text-sm text-ink">
          {formatCurrency(account.xinsight_charge_usd, locale)}
        </span>
      ),
    },
    {
      id: "byok",
      header: t.tableByokKeys,
      cell: (account) => (
        <span className="text-sm text-ink">{formatNumber(account.byok_key_count, locale)}</span>
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
          title={t.accountsLabel}
          amount={accounts.length.toString()}
          note={t.accountsNote}
        />
        <CostCard
          title={t.storageRevenueLabel}
          amount={formatCurrency(
            accounts.reduce((sum, account) => sum + account.storage_charge_usd, 0),
            locale,
          )}
          note={t.storageRevenueNote}
        />
        <CostCard
          title={t.aiRevenueLabel}
          amount={formatCurrency(
            accounts.reduce((sum, account) => sum + account.xinsight_charge_usd, 0),
            locale,
          )}
          note={t.aiRevenueNote}
        />
        <CostCard
          title={t.planCountLabel}
          amount={plans.length.toString()}
          note={t.planCountNote}
        />
      </KpiGrid>

      <div className="grid gap-4 lg:grid-cols-2 xl:grid-cols-3">
        {plans.map((plan) => (
          <CostCard
            key={plan.plan_id}
            title={plan.name}
            amount={plan.price_label}
            note={`${plan.storage_limit_gb} GB | ${plan.ai_credit_policy}`}
          />
        ))}
      </div>

      <DataTable columns={columns} rows={accounts} rowKey={(account) => account.organization_id} />
    </>
  );
}
