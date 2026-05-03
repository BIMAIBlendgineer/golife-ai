import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { ModelCard } from "@/components/premium/model-card";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getPlans } from "@/lib/api";
import { formatNumber } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { PlanRow } from "@/lib/types";

export default async function PlansPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.plans;
  const plansResult = await getPlans();
  const plans = plansResult.data ?? [];
  const byokEnabled = plans.filter((plan) => plan.byok_allowed).length;
  const highestStorage = Math.max(0, ...plans.map((plan) => plan.storage_limit_gb));

  const columns: Array<DataColumn<PlanRow>> = [
    {
      id: "plan",
      header: t.tablePlan,
      cell: (plan) => (
        <div>
          <p className="text-sm font-semibold text-ink">{plan.name}</p>
          <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
            {plan.plan_id}
          </p>
        </div>
      ),
    },
    {
      id: "price",
      header: t.tablePrice,
      cell: (plan) => <span className="text-sm text-ink">{plan.price_label}</span>,
    },
    {
      id: "userLimit",
      header: t.tableUsers,
      cell: (plan) => (
        <span className="text-sm text-ink">
          {formatNumber(plan.user_limit, locale)}
        </span>
      ),
    },
    {
      id: "storage",
      header: t.tableStorage,
      cell: (plan) => (
        <span className="text-sm text-ink">
          {formatNumber(plan.storage_limit_gb, locale)} GB
        </span>
      ),
    },
    {
      id: "byok",
      header: t.tableByok,
      cell: (plan) => (
        <StatusPill tone={plan.byok_allowed ? "good" : "neutral"}>
          {plan.byok_allowed ? messages.shared.enabled : messages.shared.disabled}
        </StatusPill>
      ),
    },
    {
      id: "support",
      header: t.tableSupport,
      cell: (plan) => <span className="text-sm text-ink">{plan.support_level}</span>,
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

      <KpiGrid className="xl:grid-cols-3">
        <MetricCard
          label={t.totalPlansLabel}
          value={plans.length.toString()}
          note={t.totalPlansNote}
          tone="ink"
        />
        <MetricCard
          label={t.byokPlansLabel}
          value={byokEnabled.toString()}
          note={t.byokPlansNote}
          tone="sage"
        />
        <MetricCard
          label={t.maxStorageLabel}
          value={`${formatNumber(highestStorage, locale)} GB`}
          note={t.maxStorageNote}
          tone="bronze"
        />
      </KpiGrid>

      <div className="grid gap-4 lg:grid-cols-2 xl:grid-cols-3">
        {plans.map((plan) => (
          <ModelCard
            key={plan.plan_id}
            title={plan.name}
            subtitle={plan.ai_credit_policy}
            stats={[
              { label: t.tablePrice, value: plan.price_label },
              { label: t.tableUsers, value: String(plan.user_limit) },
              { label: t.tableStorage, value: `${plan.storage_limit_gb} GB` },
              {
                label: t.tableByok,
                value: plan.byok_allowed
                  ? messages.shared.enabled
                  : messages.shared.disabled,
              },
            ]}
          />
        ))}
      </div>

      <DataTable columns={columns} rows={plans} rowKey={(plan) => plan.plan_id} />
    </>
  );
}
