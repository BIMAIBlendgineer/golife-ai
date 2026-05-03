"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useMemo, useState } from "react";

type PaletteSection = {
  label: string;
  items: Array<{ href: string; title: string; note: string }>;
};

export function CommandPalette({
  sections,
  triggerLabel,
  searchPlaceholder,
}: {
  sections: PaletteSection[];
  triggerLabel: string;
  searchPlaceholder: string;
}) {
  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState("");

  useEffect(() => {
    function handleKeydown(event: KeyboardEvent) {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === "k") {
        event.preventDefault();
        setOpen((current) => !current);
      }
      if (event.key === "Escape") {
        setOpen(false);
      }
    }
    window.addEventListener("keydown", handleKeydown);
    return () => window.removeEventListener("keydown", handleKeydown);
  }, []);

  const items = useMemo(() => {
    const needle = query.trim().toLowerCase();
    const flattened = sections.flatMap((section) =>
      section.items.map((item) => ({
        section: section.label,
        ...item,
      })),
    );
    if (!needle) {
      return flattened;
    }
    return flattened.filter((item) =>
      [item.section, item.title, item.note, item.href]
        .join(" ")
        .toLowerCase()
        .includes(needle),
    );
  }, [query, sections]);

  return (
    <>
      <button
        type="button"
        onClick={() => setOpen(true)}
        className="inline-flex items-center gap-3 rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] px-3 py-2 text-sm text-[color:var(--ink-soft)]"
      >
        <span>{triggerLabel}</span>
        <span className="rounded border border-[color:var(--line)] bg-[color:var(--surface-2)] px-2 py-0.5 font-mono text-[11px] text-[color:var(--ink-muted)]">
          Ctrl K
        </span>
      </button>
      {open ? (
        <div className="fixed inset-0 z-50 flex items-start justify-center bg-[color:rgba(19,24,23,0.28)] p-4 pt-[12vh]">
          <div className="w-full max-w-2xl rounded-lg border border-[color:var(--line-strong)] bg-[color:var(--surface-raised)] shadow-2xl">
            <div className="border-b border-[color:var(--line)] p-3">
              <input
                autoFocus
                value={query}
                onChange={(event) => setQuery(event.target.value)}
                placeholder={searchPlaceholder}
                className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] px-3 py-2 text-sm text-ink outline-none"
              />
            </div>
            <div className="max-h-[60vh] overflow-y-auto p-2">
              {items.map((item) => {
                const selected =
                  pathname === item.href || pathname.startsWith(`${item.href}/`);
                return (
                  <Link
                    key={`${item.section}:${item.href}`}
                    href={item.href}
                    onClick={() => setOpen(false)}
                    className={`block rounded-lg px-3 py-3 ${
                      selected
                        ? "bg-[color:rgba(72,118,96,0.08)]"
                        : "hover:bg-[color:rgba(19,24,23,0.04)]"
                    }`}
                  >
                    <div className="flex flex-wrap items-center justify-between gap-3">
                      <p className="text-sm font-semibold text-ink">{item.title}</p>
                      <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
                        {item.section}
                      </p>
                    </div>
                    <p className="mt-1 text-sm leading-6 text-[color:var(--ink-soft)]">
                      {item.note}
                    </p>
                  </Link>
                );
              })}
            </div>
          </div>
        </div>
      ) : null}
    </>
  );
}
