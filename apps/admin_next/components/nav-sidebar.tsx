"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

import { LocaleSwitcher } from "@/components/locale-switcher";
import { cn } from "@/lib/cn";
import type { AdminLocale, AdminMessages } from "@/lib/i18n";

type NavSidebarProps = {
  locale: AdminLocale;
  nav: AdminMessages["nav"];
  localeSwitcher: AdminMessages["localeSwitcher"];
};

export function NavSidebar({ locale, nav, localeSwitcher }: NavSidebarProps) {
  const pathname = usePathname();
  const activeSectionLabel = useMemo(
    () =>
      nav.sections.find((section) =>
        section.items.some(
          (item) => pathname === item.href || pathname.startsWith(`${item.href}/`),
        ),
      )?.label ?? nav.sections[0]?.label,
    [nav.sections, pathname],
  );
  const [openSection, setOpenSection] = useState<string | null>(activeSectionLabel);

  useEffect(() => {
    setOpenSection(activeSectionLabel);
  }, [activeSectionLabel]);

  return (
    <aside className="flex flex-col gap-5 border-r border-[color:var(--line)] pr-4 lg:pr-6">
      <div className="flex items-center justify-between gap-3 pb-2">
        <div className="min-w-0">
          <h1 className="text-xl font-semibold text-ink">{nav.title}</h1>
        </div>
        <LocaleSwitcher
          currentLocale={locale}
          labels={localeSwitcher}
          hideLabel
        />
      </div>

      <nav className="space-y-2">
        {nav.sections.map((section) => (
          <section key={section.label} className="space-y-1">
            <button
              type="button"
              aria-expanded={openSection === section.label}
              onClick={() =>
                setOpenSection((current) =>
                  current === section.label ? null : section.label,
                )
              }
              className={cn(
                "flex w-full items-center justify-between gap-3 rounded-lg px-2 py-2 text-left transition-colors",
                openSection === section.label
                  ? "text-ink"
                  : "text-[color:var(--ink-soft)] hover:text-ink",
              )}
            >
              <div className="min-w-0">
                <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                  {section.label}
                </p>
              </div>
              <span
                className={cn(
                  "inline-flex h-7 w-7 items-center justify-center rounded-full text-[color:var(--ink-muted)] transition-transform",
                  openSection === section.label && "rotate-180",
                )}
              >
                <svg
                  aria-hidden="true"
                  viewBox="0 0 12 12"
                  className="h-3.5 w-3.5"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="1.75"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="M2.25 4.5 6 8.25 9.75 4.5" />
                </svg>
              </span>
            </button>

            {openSection === section.label ? (
              <div className="space-y-1 pb-2 pl-2">
                {section.items.map((item) => {
                  const selected =
                    pathname === item.href || pathname.startsWith(`${item.href}/`);

                  return (
                    <Link
                      key={item.href}
                      href={item.href}
                      className={cn(
                        "block rounded-lg px-3 py-2.5 transition-colors",
                        selected
                          ? "bg-[color:rgba(124,196,161,0.1)] text-ink"
                          : "text-[color:var(--ink-soft)] hover:bg-[color:var(--surface-2)] hover:text-ink",
                      )}
                    >
                      <p className="text-sm font-semibold">{item.title}</p>
                    </Link>
                  );
                })}
              </div>
            ) : null}
          </section>
        ))}
      </nav>
    </aside>
  );
}
