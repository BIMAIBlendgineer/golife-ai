import { StatusBadge, type StatusBadgeTone } from "@/components/premium/status-badge";

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
  return (
    <header className="space-y-4 border-b border-[color:var(--line)] pb-5">
      <div className="flex flex-col gap-4 xl:flex-row xl:items-end xl:justify-between">
        <div className="max-w-4xl space-y-2">
          <div className="flex flex-wrap items-center gap-3">
            <p className="text-[11px] font-semibold uppercase tracking-[0.18em] text-[color:var(--ink-muted)]">
              {eyebrow}
            </p>
            {badge ? <StatusBadge tone={badgeTone}>{badge}</StatusBadge> : null}
          </div>
          <h1 className="text-2xl font-semibold text-ink md:text-3xl">{title}</h1>
          <p className="max-w-3xl text-sm leading-6 text-[color:var(--ink-soft)] md:text-[15px]">
            {description}
          </p>
        </div>
        {actions ? <div className="flex flex-wrap gap-2">{actions}</div> : null}
      </div>
    </header>
  );
}
