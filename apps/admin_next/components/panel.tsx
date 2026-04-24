import { cn } from "@/lib/cn";

export function Panel({
  eyebrow,
  title,
  note,
  className,
  children,
}: {
  eyebrow?: string;
  title?: string;
  note?: string;
  className?: string;
  children: React.ReactNode;
}) {
  return (
    <section
      className={cn(
        "rounded-[24px] border border-[color:var(--line)] bg-[color:var(--paper-soft)] p-5",
        className,
      )}
    >
      {(eyebrow || title || note) && (
        <header className="mb-4 flex flex-col gap-2 border-b border-[color:var(--line)] pb-4 md:flex-row md:items-end md:justify-between">
          <div className="space-y-1">
            {eyebrow ? (
              <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                {eyebrow}
              </p>
            ) : null}
            {title ? (
              <h2 className="text-lg font-semibold text-ink">{title}</h2>
            ) : null}
          </div>
          {note ? (
            <p className="max-w-md text-sm leading-6 text-[color:var(--ink-soft)]">
              {note}
            </p>
          ) : null}
        </header>
      )}
      {children}
    </section>
  );
}
