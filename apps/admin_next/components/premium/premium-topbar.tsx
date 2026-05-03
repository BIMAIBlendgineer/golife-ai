import { CommandPalette } from "@/components/premium/command-palette";
import { EnvironmentBadge } from "@/components/premium/environment-badge";
import { SourceStateBadge } from "@/components/premium/source-state-badge";
import { StatusBadge } from "@/components/premium/status-badge";
import type { AdminLocale, AdminMessages } from "@/lib/i18n";

export function PremiumTopbar({
  locale,
  shell,
  nav,
  globalState,
  source,
  apiBaseUrl,
  tokenConfigured,
  lastIngestion,
}: {
  locale: AdminLocale;
  shell: AdminMessages["shell"];
  nav: AdminMessages["nav"];
  globalState: string;
  source: "live" | "fallback" | "offline";
  apiBaseUrl: string;
  tokenConfigured: boolean;
  lastIngestion?: string;
}) {
  return (
    <div className="flex flex-col gap-4 border-b border-[color:var(--line)] pb-5 xl:flex-row xl:items-center xl:justify-between">
      <div className="space-y-1">
        <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
          {shell.eyebrow}
        </p>
        <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
          {shell.summary}
        </p>
        {lastIngestion ? (
          <p className="text-sm leading-6 text-[color:var(--ink-muted)]">
            {lastIngestion}
          </p>
        ) : null}
      </div>
      <div className="flex flex-wrap items-center gap-2">
        <CommandPalette
          sections={nav.sections}
          triggerLabel={shell.commandPaletteLabel}
          searchPlaceholder={shell.commandPalettePlaceholder}
        />
        <SourceStateBadge source={source} label={globalState} />
        <EnvironmentBadge environment={process.env.NODE_ENV ?? "development"} />
        <StatusBadge tone="info">
          {shell.apiLabel} {apiBaseUrl}
        </StatusBadge>
        <StatusBadge tone={tokenConfigured ? "good" : "warn"}>
          {tokenConfigured ? shell.tokenSet : shell.tokenMissing}
        </StatusBadge>
        <StatusBadge tone="neutral">{locale}</StatusBadge>
      </div>
    </div>
  );
}
