import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getSupportRequests } from "@/lib/api";
import { formatDateTime } from "@/lib/format";

export default async function SupportExportDeletePage() {
  const supportResult = await getSupportRequests();
  const requests = supportResult.data ?? [];
  const exportCount = requests.filter((item) => item.request_type === "export").length;
  const deleteCount = requests.filter((item) => item.request_type === "delete").length;

  return (
    <>
      <PageHeader
        eyebrow="Support Queue"
        title="Export and delete operations"
        description="Privacy trust is operational, not theoretical. This queue keeps export and delete requests visible and actionable."
        badge="Privacy ops"
      />
      <ErrorBanner error={supportResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Open requests"
          value={requests.length.toString()}
          note="All current privacy-related support work."
          tone="ink"
        />
        <MetricCard
          label="Export"
          value={exportCount.toString()}
          note="Users asking for their portable data bundle."
          tone="bronze"
        />
        <MetricCard
          label="Delete"
          value={deleteCount.toString()}
          note="Users requesting full account or data removal."
          tone="clay"
        />
      </div>

      <Panel
        eyebrow="Queue"
        title="Support requests"
        note="The web backend currently exposes a seeded queue. Replace this with persistent operational data in the next backend block."
      >
        <div className="space-y-3">
          {requests.map((item) => (
            <div
              key={item.request_id}
              className="flex flex-col gap-3 rounded-[18px] border border-[color:var(--line)] bg-white/45 p-4 md:flex-row md:items-center md:justify-between"
            >
              <div className="space-y-2">
                <div className="flex flex-wrap gap-2">
                  <StatusPill tone={item.request_type === "delete" ? "danger" : "warn"}>
                    {item.request_type}
                  </StatusPill>
                  <StatusPill tone={item.status === "open" ? "info" : "good"}>
                    {item.status}
                  </StatusPill>
                </div>
                <p className="font-mono text-xs text-[color:var(--ink-muted)]">
                  {item.request_id} · {item.user_id}
                </p>
              </div>
              <p className="text-sm text-[color:var(--ink-muted)]">
                {formatDateTime(item.requested_at)}
              </p>
            </div>
          ))}
        </div>
      </Panel>
    </>
  );
}
