"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";

import { LocaleSwitcher } from "@/components/locale-switcher";
import { StatusPill } from "@/components/status-pill";
import { cn } from "@/lib/cn";
import type { AdminLocale, AdminMessages } from "@/lib/i18n";

type NavSidebarProps = {
  locale: AdminLocale;
  nav: AdminMessages["nav"];
  localeSwitcher: AdminMessages["localeSwitcher"];
};

export function NavSidebar({ locale, nav, localeSwitcher }: NavSidebarProps) {
  const pathname = usePathname();

  return (
    <aside className="flex h-full flex-col gap-8 rounded-[28px] border border-[color:var(--line)] bg-[color:rgba(255,248,242,0.72)] p-5">
      <div className="space-y-3">
        <StatusPill tone="info">{nav.badge}</StatusPill>
        <div className="space-y-2">
          <h1 className="text-xl font-semibold tracking-[-0.04em] text-ink">{nav.title}</h1>
          <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
            {nav.subtitle}
          </p>
        </div>
        <LocaleSwitcher currentLocale={locale} labels={localeSwitcher} />
      </div>

      <nav className="space-y-6">
        {nav.sections.map((section) => (
          <div key={section.label} className="space-y-3">
            <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
              {section.label}
            </p>
            <div className="space-y-2">
              {section.items.map((item) => {
                const selected =
                  pathname === item.href || pathname.startsWith(`${item.href}/`);

                return (
                  <Link
                    key={item.href}
                    href={item.href}
                    className={cn(
                      "block rounded-[20px] border px-4 py-3 transition-colors",
                      selected
                        ? "border-[color:rgba(93,122,104,0.25)] bg-[color:rgba(93,122,104,0.1)]"
                        : "border-transparent bg-white/35 hover:border-[color:var(--line)] hover:bg-white/65",
                    )}
                  >
                    <p className="text-sm font-semibold text-ink">{item.title}</p>
                    <p className="mt-1 text-sm leading-6 text-[color:var(--ink-soft)]">
                      {item.note}
                    </p>
                  </Link>
                );
              })}
            </div>
          </div>
        ))}
      </nav>
    </aside>
  );
}
