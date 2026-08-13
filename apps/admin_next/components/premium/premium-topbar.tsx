import { CommandPalette } from "@/components/premium/command-palette";
import { SourceStateBadge } from "@/components/premium/source-state-badge";
import type { AdminLocale, AdminMessages } from "@/lib/i18n";

export function PremiumTopbar({
  shell,
  nav,
  globalState,
  source,
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
  const compactState =
    source === "live"
      ? shell.compactStateLive
      : source === "fallback"
        ? shell.compactStateFallback
        : shell.compactStateOffline;

  return (
    <div className="flex items-center justify-end gap-2 border-b border-[color:var(--line)] pb-4">
      <div className="mr-auto" />
      <div className="flex flex-wrap items-center gap-2">
        <CommandPalette
          sections={nav.sections}
          triggerLabel={shell.commandPaletteLabel}
          searchPlaceholder={shell.commandPalettePlaceholder}
          compact
        />
        <div title={globalState}>
          <SourceStateBadge source={source} label={compactState} />
        </div>
      </div>
    </div>
  );
}
