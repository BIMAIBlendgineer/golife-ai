import { cookies } from "next/headers";
import { redirect } from "next/navigation";

import { RiskBanner } from "@/components/premium/risk-banner";
import { PageHeader } from "@/components/page-header";
import { getAuthStatus } from "@/lib/api";
import { getAdminMessages } from "@/lib/i18n";

import { signInScaffold } from "./actions";

const adminOperatorCookieName = "golife_admin_operator";

export default async function LoginPage({
  searchParams,
}: {
  searchParams: Promise<{ error?: string }>;
}) {
  const { messages } = await getAdminMessages();
  const t = messages.pages.login;
  const authResult = await getAuthStatus();
  const auth = authResult.data;
  const params = await searchParams;
  const localOperatorSecretConfigured = Boolean(
    process.env.ADMIN_OPERATOR_SECRET?.trim() ??
      process.env.GOLIFE_ADMIN_OPERATOR_SECRET?.trim(),
  );
  const secretRequired =
    auth?.auth_mode === "token_plus_operator_secret" || localOperatorSecretConfigured;
  const cookieStore = await cookies();
  if (cookieStore.get(adminOperatorCookieName)?.value) {
    redirect("/dashboard");
  }

  return (
    <>
      <PageHeader
        eyebrow={t.eyebrow}
        title={t.title}
        description={t.description}
        badge={t.badge}
      />

      <div className="grid gap-6 xl:grid-cols-[minmax(0,1.1fr)_360px]">
        <form
          action={signInScaffold}
          className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-6"
        >
          <div className="space-y-4">
            <div>
              <p className="text-sm font-semibold text-ink">{t.modeTitle}</p>
              <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">
                {auth?.warning ?? t.modeBody}
              </p>
            </div>
            {params.error === "invalid_secret" ? (
              <p className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
                {t.invalidSecretBody}
              </p>
            ) : null}
            <label className="block space-y-2">
              <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                {t.operatorLabel}
              </span>
              <input
                name="operator"
                type="text"
                placeholder={t.operatorPlaceholder}
                className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
              />
            </label>
            {secretRequired ? (
              <label className="block space-y-2">
                <span className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                  {t.secretLabel}
                </span>
                <input
                  name="secret"
                  type="password"
                  autoComplete="current-password"
                  placeholder={t.secretPlaceholder}
                  className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-ink"
                />
              </label>
            ) : null}
            <button
              type="submit"
              className="rounded-lg border border-[color:var(--line-strong)] bg-[color:var(--surface-2)] px-4 py-2 text-sm font-medium text-ink transition-colors hover:bg-white"
            >
              {t.submitLabel}
            </button>
          </div>
        </form>

        <RiskBanner title={t.warningTitle} body={t.warningBody} tone="warn" />
      </div>
    </>
  );
}
