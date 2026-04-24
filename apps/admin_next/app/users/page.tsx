import Link from "next/link";

import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getUsers } from "@/lib/api";
import { formatDateTime } from "@/lib/format";

export default async function UsersPage() {
  const usersResult = await getUsers();
  const users = usersResult.data ?? [];
  const weeklyActive = users.filter((user) => user.weekly_active).length;
  const supportQueue = users.filter(
    (user) => user.export_requested || user.delete_requested,
  ).length;

  return (
    <>
      <PageHeader
        eyebrow="Operators"
        title="User state and support signals"
        description="A compact list for account health, current plan mix, and who may need export, delete, or trust follow-up."
        badge="Accounts"
      />
      <ErrorBanner error={usersResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label="Total users"
          value={users.length.toString()}
          note="Seeded operational scope for now."
          tone="ink"
        />
        <MetricCard
          label="Weekly active"
          value={weeklyActive.toString()}
          note="Users who are still inside the weekly mission loop."
          tone="sage"
        />
        <MetricCard
          label="Support queue"
          value={supportQueue.toString()}
          note="Export or delete requests that need manual action."
          tone="clay"
        />
      </div>

      <Panel
        eyebrow="Roster"
        title="Users"
        note="The detail page combines account profile, usage footprint, mission history, and feedback journal."
      >
        <div className="overflow-x-auto">
          <table className="min-w-full border-separate border-spacing-y-3">
            <thead>
              <tr className="text-left text-[11px] font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                <th className="px-3">User</th>
                <th className="px-3">Plan</th>
                <th className="px-3">Status</th>
                <th className="px-3">AI calls</th>
                <th className="px-3">Useful missions</th>
                <th className="px-3">Last seen</th>
                <th className="px-3">Support</th>
              </tr>
            </thead>
            <tbody>
              {users.map((user) => (
                <tr key={user.user_id} className="rounded-[18px] bg-white/45">
                  <td className="rounded-l-[18px] px-3 py-4">
                    <Link
                      href={`/users/${user.user_id}`}
                      className="block text-sm font-semibold text-ink"
                    >
                      {user.email}
                    </Link>
                    <p className="mt-1 font-mono text-xs text-[color:var(--ink-muted)]">
                      {user.user_id}
                    </p>
                  </td>
                  <td className="px-3 py-4">
                    <StatusPill tone={user.plan === "plus" ? "good" : "neutral"}>
                      {user.plan}
                    </StatusPill>
                  </td>
                  <td className="px-3 py-4">
                    <StatusPill tone={user.status === "active" ? "good" : "warn"}>
                      {user.status}
                    </StatusPill>
                  </td>
                  <td className="px-3 py-4 text-sm text-ink">{user.ai_calls}</td>
                  <td className="px-3 py-4 text-sm text-ink">
                    {user.useful_missions_completed}
                  </td>
                  <td className="px-3 py-4 text-sm text-[color:var(--ink-soft)]">
                    {formatDateTime(user.last_seen_at)}
                  </td>
                  <td className="rounded-r-[18px] px-3 py-4">
                    <div className="flex flex-wrap gap-2">
                      {user.export_requested ? (
                        <StatusPill tone="warn">Export</StatusPill>
                      ) : null}
                      {user.delete_requested ? (
                        <StatusPill tone="danger">Delete</StatusPill>
                      ) : null}
                      {user.support_flags.map((flag) => (
                        <StatusPill key={flag} tone="info">
                          {flag}
                        </StatusPill>
                      ))}
                      {!user.export_requested &&
                      !user.delete_requested &&
                      user.support_flags.length === 0 ? (
                        <StatusPill tone="neutral">None</StatusPill>
                      ) : null}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </Panel>
    </>
  );
}
