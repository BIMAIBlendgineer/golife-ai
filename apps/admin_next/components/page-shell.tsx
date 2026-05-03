import { NavSidebar } from "@/components/nav-sidebar";
import { PremiumShell } from "@/components/premium/premium-shell";
import { PremiumTopbar } from "@/components/premium/premium-topbar";
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
  const source =
    healthResult.source === "offline"
      ? "offline"
      : health?.mode === "seeded"
        ? "fallback"
        : "live";
  const lastIngestion = health?.last_ingestion_at
    ? `${messages.shell.lastIngestionPrefix} ${formatDateTime(health.last_ingestion_at, locale)}`
    : messages.shell.lastIngestionEmpty;

  return (
    <PremiumShell
      sidebar={
        <NavSidebar
          locale={locale}
          nav={messages.nav}
          localeSwitcher={messages.localeSwitcher}
        />
      }
      topbar={
        <PremiumTopbar
          locale={locale}
          shell={messages.shell}
          nav={messages.nav}
          globalState={globalState}
          source={source}
          apiBaseUrl={runtime.baseUrl}
          tokenConfigured={runtime.tokenConfigured}
          lastIngestion={lastIngestion}
        />
      }
    >
      {children}
    </PremiumShell>
  );
}
