import { NavSidebar } from "@/components/nav-sidebar";
import { StatusPill } from "@/components/status-pill";
import { getAdminRuntime, getBackendHealth } from "@/lib/api";
import { formatDateTime } from "@/lib/format";
import { getAdminMessages } from "@/lib/i18n";

export async function PageShell({ children }: { children: React.ReactNode }) {
  const { locale, messages } = await getAdminMessages();
  const runtime = getAdminRuntime();
  const healthResult = await getBackendHealth();
  const health = healthResult.data;
  const globalState =
    healthResult.source === "offline"
      ? messages.shell.stateBackendOffline
      : health?.mode !== "seeded" && !health?.last_ingestion_at
        ? messages.shell.stateLiveNoIngestion
        : health?.mode === "seeded"
          ? messages.shell.stateFallbackSnapshot
          : messages.shell.stateLiveData;
  const globalTone =
    globalState === messages.shell.stateLiveData
      ? "good"
      : globalState === messages.shell.stateLiveNoIngestion
        ? "warn"
        : globalState === messages.shell.stateFallbackSnapshot
          ? "warn"
          : "danger";

  return (
    <div className="mx-auto flex min-h-screen w-full max-w-[1600px] flex-col gap-6 px-4 py-4 lg:grid lg:grid-cols-[290px_minmax(0,1fr)] lg:px-6">
      <div className="lg:sticky lg:top-4 lg:h-[calc(100vh-2rem)]">
        <NavSidebar
          locale={locale}
          nav={messages.nav}
          localeSwitcher={messages.localeSwitcher}
        />
      </div>
      <div className="space-y-6">
        <div className="rounded-[24px] border border-[color:var(--line)] bg-[color:rgba(255,248,242,0.82)] p-4">
          <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <div className="space-y-1">
              <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                {messages.shell.eyebrow}
              </p>
              <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
                {messages.shell.summary}
              </p>
              <p className="text-sm leading-6 text-[color:var(--ink-muted)]">
                {health?.last_ingestion_at
                  ? `${messages.shell.lastIngestionPrefix} ${formatDateTime(health.last_ingestion_at, locale)}`
                  : messages.shell.lastIngestionEmpty}
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <StatusPill tone={globalTone}>{globalState}</StatusPill>
              <StatusPill tone="good">
                {messages.shell.apiLabel} {runtime.baseUrl}
              </StatusPill>
              <StatusPill tone={runtime.tokenConfigured ? "info" : "warn"}>
                {runtime.tokenConfigured
                  ? messages.shell.tokenSet
                  : messages.shell.tokenMissing}
              </StatusPill>
            </div>
          </div>
        </div>
        <main className="space-y-6">{children}</main>
      </div>
    </div>
  );
}
