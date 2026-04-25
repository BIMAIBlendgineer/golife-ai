"use client";

import { usePathname } from "next/navigation";

import { setAdminLocale } from "@/app/actions";
import type { AdminLocale, AdminMessages } from "@/lib/i18n";

type LocaleSwitcherProps = {
  currentLocale: AdminLocale;
  labels: AdminMessages["localeSwitcher"];
};

const localeOptions: AdminLocale[] = ["en", "es", "pt-BR", "ja", "zh-Hans"];

export function LocaleSwitcher({
  currentLocale,
  labels,
}: LocaleSwitcherProps) {
  const pathname = usePathname();

  return (
    <div className="flex flex-wrap items-center gap-2">
      <span className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
        {labels.label}
      </span>
      {localeOptions.map((locale) => (
        <form action={setAdminLocale} key={locale}>
          <input type="hidden" name="locale" value={locale} />
          <input type="hidden" name="redirectPath" value={pathname || "/dashboard"} />
          <button
            type="submit"
            className={[
              "rounded-full border px-3 py-1.5 text-xs font-semibold transition-colors",
              currentLocale === locale
                ? "border-[color:rgba(93,122,104,0.28)] bg-[color:rgba(93,122,104,0.16)] text-ink"
                : "border-[color:var(--line)] bg-white/60 text-[color:var(--ink-soft)] hover:bg-white",
            ].join(" ")}
          >
            {labels.options[locale]}
          </button>
        </form>
      ))}
    </div>
  );
}
