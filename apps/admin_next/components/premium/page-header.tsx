import type { StatusBadgeTone } from "@/components/premium/status-badge";

export function PremiumPageHeader({
  eyebrow,
  title,
  description,
  badge,
  badgeTone = "info",
  actions,
}: {
  eyebrow: string;
  title: string;
  description: string;
  badge?: string;
  badgeTone?: StatusBadgeTone;
  actions?: React.ReactNode;
}) {
  void badgeTone;
  const helpText = [eyebrow, badge, description].filter(Boolean).join(" • ");

  return (
    <header className="border-b border-[color:var(--line)] pb-4">
      <div className="flex flex-col gap-3 xl:flex-row xl:items-center xl:justify-between">
        <div className="flex min-w-0 items-center gap-3">
          <h1 className="truncate text-2xl font-semibold text-ink md:text-[28px]">
            {title}
          </h1>
          {helpText ? (
            <span
              className="inline-flex h-7 w-7 shrink-0 items-center justify-center rounded-full border border-[color:var(--line)] bg-[color:var(--surface-2)] text-[color:var(--ink-muted)]"
              title={helpText}
              aria-label={helpText}
            >
              i
            </span>
          ) : null}
        </div>
        {actions ? <div className="flex flex-wrap gap-2">{actions}</div> : null}
      </div>
    </header>
  );
}
