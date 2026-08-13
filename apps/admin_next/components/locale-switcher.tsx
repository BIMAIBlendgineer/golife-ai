"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useSearchParams } from "next/navigation";

import type { AdminLocale, AdminMessages } from "@/lib/i18n";

type LocaleSwitcherProps = {
  currentLocale: AdminLocale;
  labels: AdminMessages["localeSwitcher"];
  hideLabel?: boolean;
};

const localeOptions: AdminLocale[] = ["en", "es"];

export function LocaleSwitcher({
  currentLocale,
  labels,
  hideLabel = false,
}: LocaleSwitcherProps) {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const redirectPath = `${pathname || "/dashboard"}${
    searchParams?.toString() ? `?${searchParams.toString()}` : ""
  }`;

  return (
    <div className="flex flex-wrap items-center gap-2">
      {!hideLabel ? (
        <span className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
          {labels.label}
        </span>
      ) : null}
      {localeOptions.map((locale) => (
        <Link
          key={locale}
          href={`/locale?locale=${locale}&redirectPath=${encodeURIComponent(redirectPath)}`}
          prefetch={false}
          className={[
            "rounded-full border px-3 py-1.5 text-xs font-semibold uppercase tracking-[0.12em] transition-colors",
            currentLocale === locale
              ? "border-[color:rgba(93,122,104,0.28)] bg-[color:rgba(93,122,104,0.16)] text-ink"
              : "border-[color:var(--line)] bg-[color:var(--surface-frost)] text-[color:var(--ink-soft)] hover:bg-[color:var(--surface-hover)]",
          ].join(" ")}
        >
            {labels.options[locale]}
        </Link>
      ))}
    </div>
  );
}
