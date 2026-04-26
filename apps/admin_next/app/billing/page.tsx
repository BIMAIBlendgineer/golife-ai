import { CostCard } from "@/components/premium/cost-card";
import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { PaginationFooter } from "@/components/premium/pagination-footer";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getBillingAccounts, getBillingPlans } from "@/lib/api";
import { formatCurrency, formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { BillingAccountRow } from "@/lib/types";
import { withSearchParams } from "@/lib/url";

export default async function BillingPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}) {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.billing;
  const params = await searchParams;
  const limit = Math.min(
    100,
    Math.max(
      10,
      Number.parseInt(typeof params.limit === "string" ? params.limit : "25", 10) || 25,
    ),
  );
  const offset = Math.max(
    0,
    Number.parseInt(typeof params.offset === "string" ? params.offset : "0", 10) || 0,
  );
  const [accountsResult, plansResult] = await Promise.all([
    getBillingAccounts({ limit, offset }),
    getBillingPlans(),
  ]);
  const page = accountsResult.data;
  const accounts = page?.items ?? [];
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

      <div className="space-y-4">
        <DataTable columns={columns} rows={accounts} rowKey={(account) => account.organization_id} />
        <PaginationFooter
          summary={`${messages.shared.pageSummaryPrefix} ${accounts.length} ${messages.shared.pageSummaryMiddle} ${page?.total ?? accounts.length}`}
          previousHref={offset > 0 ? withSearchParams({ limit, offset: Math.max(0, offset - limit) }) : null}
          nextHref={page?.next_offset != null ? withSearchParams({ limit, offset: page.next_offset }) : null}
          previousLabel={messages.shared.previousPage}
          nextLabel={messages.shared.nextPage}
        />
      </div>
    </>
  );
}
