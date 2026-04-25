import Link from "next/link";

import { ErrorBanner } from "@/components/error-banner";
import { MetricCard } from "@/components/metric-card";
import { PageHeader } from "@/components/page-header";
import { Panel } from "@/components/panel";
import { StatusPill } from "@/components/status-pill";
import { getUsers } from "@/lib/api";
import { formatDateTime } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export default async function UsersPage() {
  const { locale, messages } = await getAdminMessages();
  const t = messages.pages.users;
  const usersResult = await getUsers();
  const users = usersResult.data ?? [];
  const weeklyActive = users.filter((user) => user.weekly_active).length;
  const supportQueue = users.filter(
    (user) => user.export_requested || user.delete_requested,
  ).length;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />
      <ErrorBanner error={usersResult.error} />

      <div className="grid gap-4 md:grid-cols-3">
        <MetricCard
          label={t.totalUsersLabel}
          value={users.length.toString()}
          note={t.totalUsersNote}
          tone="ink"
        />
        <MetricCard
          label={t.weeklyActiveLabel}
          value={weeklyActive.toString()}
          note={t.weeklyActiveNote}
          tone="sage"
        />
        <MetricCard
          label={t.supportQueueLabel}
          value={supportQueue.toString()}
          note={t.supportQueueNote}
          tone="clay"
        />
      </div>

      <Panel
        eyebrow={t.panelEyebrow}
        title={t.panelTitle}
        note={t.panelNote}
      >
        <div className="overflow-x-auto">
          <table className="min-w-full border-separate border-spacing-y-3">
            <thead>
              <tr className="text-left text-[11px] font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
                <th className="px-3">{t.tableUser}</th>
                <th className="px-3">{t.tablePlan}</th>
                <th className="px-3">{t.tableStatus}</th>
                <th className="px-3">{t.tableAiCalls}</th>
                <th className="px-3">{t.tableUsefulMissions}</th>
                <th className="px-3">{t.tableLastSeen}</th>
                <th className="px-3">{t.tableSupport}</th>
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
                    {formatDateTime(user.last_seen_at, locale)}
                  </td>
                  <td className="rounded-r-[18px] px-3 py-4">
                    <div className="flex flex-wrap gap-2">
                      {user.export_requested ? (
                        <StatusPill tone="warn">{messages.shared.export}</StatusPill>
                      ) : null}
                      {user.delete_requested ? (
                        <StatusPill tone="danger">{messages.shared.delete}</StatusPill>
                      ) : null}
                      {user.support_flags.map((flag) => (
                        <StatusPill key={flag} tone="info">
                          {flag}
                        </StatusPill>
                      ))}
                      {!user.export_requested &&
                      !user.delete_requested &&
                      user.support_flags.length === 0 ? (
                        <StatusPill tone="neutral">{messages.shared.none}</StatusPill>
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
