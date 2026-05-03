import { StatusBadge } from "@/components/premium/status-badge";

export function ModelCard({
  title,
  subtitle,
  stats,
}: {
  title: string;
  subtitle?: string;
  stats: Array<{ label: string; value: string }>;
}) {
  return (
    <article className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <h3 className="text-sm font-semibold text-ink">{title}</h3>
          {subtitle ? (
            <p className="mt-1 text-sm leading-6 text-[color:var(--ink-soft)]">
              {subtitle}
            </p>
          ) : null}
        </div>
        <StatusBadge tone="info">model</StatusBadge>
      </div>
      <dl className="mt-4 grid gap-3 sm:grid-cols-2">
        {stats.map((stat) => (
          <div key={stat.label}>
            <dt className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
              {stat.label}
            </dt>
            <dd className="mt-1 font-mono text-sm text-ink">{stat.value}</dd>
          </div>
        ))}
      </dl>
    </article>
  );
}
