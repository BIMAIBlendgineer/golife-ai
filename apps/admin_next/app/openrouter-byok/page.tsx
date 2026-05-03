import { DataTable, type DataColumn } from "@/components/premium/data-table";
import { KpiGrid } from "@/components/premium/kpi-grid";
import { RiskBanner } from "@/components/premium/risk-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { StatusPill } from "@/components/status-pill";
import { getOpenRouterByokKeys } from "@/lib/api";
import { formatDateTime } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";
import type { OpenRouterByokKeyRecord } from "@/lib/types";

export default async function OpenRouterByokPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.openrouterByok;
  const keysResult = await getOpenRouterByokKeys();
  const keys = keysResult.data ?? [];

  const columns: Array<DataColumn<OpenRouterByokKeyRecord>> = [
    {
      id: "label",
      header: t.tableLabel,
      cell: (key) => (
        <div>
          <p className="text-sm font-semibold text-ink">{key.label}</p>
          <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
            {key.key_id}
          </p>
        </div>
      ),
    },
    {
      id: "org",
      header: t.tableOrganization,
      cell: (key) => <span className="text-sm text-ink">{key.organization_id}</span>,
    },
    {
      id: "last4",
      header: t.tableSecret,
      cell: (key) => <span className="font-mono text-sm text-ink">****{key.secret_last4}</span>,
    },
    {
      id: "status",
      header: t.tableStatus,
      cell: (key) => (
        <StatusPill
          tone={
            key.status === "healthy"
              ? "good"
              : key.status === "disabled"
                ? "danger"
                : key.status === "degraded"
                  ? "warn"
                  : "neutral"
          }
        >
          {key.status}
        </StatusPill>
      ),
    },
    {
      id: "lastUsed",
      header: t.tableLastUsed,
      cell: (key) => (
        <span className="text-sm text-[color:var(--ink-soft)]">
          {key.last_used_at ? formatDateTime(key.last_used_at, locale) : messages.shared.never}
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

      <RiskBanner title={t.disclaimerTitle} body={t.disclaimerBody} tone="info" />

      <KpiGrid className="xl:grid-cols-3">
        <MetricCard
          label={t.totalKeysLabel}
          value={keys.length.toString()}
          note={t.totalKeysNote}
          tone="ink"
        />
        <MetricCard
          label={t.healthyKeysLabel}
          value={keys.filter((key) => key.status === "healthy").length.toString()}
          note={t.healthyKeysNote}
          tone="sage"
        />
        <MetricCard
          label={t.disabledKeysLabel}
          value={keys.filter((key) => key.status === "disabled").length.toString()}
          note={t.disabledKeysNote}
          tone="clay"
        />
      </KpiGrid>

      <DataTable columns={columns} rows={keys} rowKey={(key) => key.key_id} />
    </>
  );
}
