import { StatusPill } from "@/components/status-pill";

export function PageHeader({
  eyebrow,
  title,
  description,
  badge,
}: {
  eyebrow: string;
  title: string;
  description: string;
  badge?: string;
}) {
  return (
    <header className="space-y-4">
      <div className="flex flex-wrap items-center gap-3">
        <p className="text-[11px] font-semibold uppercase tracking-[0.24em] text-[color:var(--ink-muted)]">
          {eyebrow}
        </p>
        {badge ? <StatusPill tone="info">{badge}</StatusPill> : null}
      </div>
      <div className="max-w-3xl space-y-3">
        <h1 className="text-3xl font-semibold tracking-[-0.04em] text-ink md:text-4xl">
          {title}
        </h1>
        <p className="text-base leading-7 text-[color:var(--ink-soft)]">
          {description}
        </p>
      </div>
    </header>
  );
}
