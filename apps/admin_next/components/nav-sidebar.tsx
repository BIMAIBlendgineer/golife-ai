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
    <aside className="flex h-full flex-col gap-6 border-r border-[color:var(--line)] pr-4 lg:pr-6">
      <div className="space-y-3">
        <StatusPill tone="info">{nav.badge}</StatusPill>
        <div className="space-y-2">
          <h1 className="text-xl font-semibold text-ink">{nav.title}</h1>
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
                      "block rounded-lg border px-4 py-3 transition-colors",
                      selected
                        ? "border-[color:rgba(72,118,96,0.25)] bg-[color:rgba(72,118,96,0.08)]"
                        : "border-transparent bg-transparent hover:border-[color:var(--line)] hover:bg-[color:var(--surface)]",
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
