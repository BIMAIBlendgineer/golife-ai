import { cookies } from "next/headers";

import { PageHeader } from "@/components/page-header";
import { RiskBanner } from "@/components/premium/risk-banner";
import { StatusPill } from "@/components/status-pill";
import { getAuthStatus, getSecuritySummary } from "@/lib/api";
import { getAdminMessages } from "@/lib/i18n";

const adminOperatorCookieName = "golife_admin_operator";

export default async function SettingsSecurityPage() {
  const { messages } = await getAdminMessages();
  const t = messages.pages.settingsSecurity;
  const [authResult, securityResult, cookieStore] = await Promise.all([
    getAuthStatus(),
    getSecuritySummary(),
    cookies(),
  ]);
  const auth = authResult.data;
  const security = securityResult.data;
  const operator = cookieStore.get(adminOperatorCookieName)?.value ?? null;

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />

      <RiskBanner
        title={t.warningTitle}
        body={auth?.warning ?? t.warningBody}
        tone={security?.production_ready ? "info" : "warn"}
      />

      <div className="grid gap-6 md:grid-cols-2 xl:grid-cols-3">
        <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-5">
          <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.authModeLabel}
          </p>
          <p className="mt-3 text-sm font-semibold text-ink">{auth?.auth_mode ?? "token_only_scaffold"}</p>
          <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">
            {t.authModeNote}
          </p>
        </div>
        <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-5">
          <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.operatorLabel}
          </p>
          <p className="mt-3 text-sm font-semibold text-ink">{operator ?? messages.shared.none}</p>
          <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">{t.operatorNote}</p>
        </div>
        <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-5">
          <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {t.tokensLabel}
          </p>
          <div className="mt-3 flex flex-wrap gap-2">
            <StatusPill tone={security?.admin_token_configured ? "good" : "warn"}>
              admin
            </StatusPill>
            <StatusPill tone={security?.ingestion_token_configured ? "good" : "warn"}>
              ingestion
            </StatusPill>
            <StatusPill tone={security?.internal_service_token_configured ? "good" : "warn"}>
              internal
            </StatusPill>
          </div>
        </div>
      </div>
    </>
  );
}
