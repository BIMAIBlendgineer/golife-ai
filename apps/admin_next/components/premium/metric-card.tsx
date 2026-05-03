import { cn } from "@/lib/cn";

const tones = {
  neutral: "border-[color:var(--line)] bg-[color:var(--surface)]",
  good: "border-[color:rgba(72,118,96,0.18)] bg-[color:rgba(72,118,96,0.06)]",
  warn: "border-[color:rgba(168,109,61,0.18)] bg-[color:rgba(168,109,61,0.06)]",
  danger: "border-[color:rgba(173,81,53,0.18)] bg-[color:rgba(173,81,53,0.06)]",
  info: "border-[color:rgba(70,101,122,0.18)] bg-[color:rgba(70,101,122,0.06)]",
};

export function PremiumMetricCard({
  label,
  value,
  note,
  tone = "neutral",
  trend,
}: {
  label: string;
  value: string;
  note?: string;
  tone?: keyof typeof tones;
  trend?: React.ReactNode;
}) {
  return (
    <article className={cn("rounded-lg border p-4", tones[tone])}>
      <div className="flex items-start justify-between gap-3">
        <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
          {label}
        </p>
        {trend ? <div className="shrink-0">{trend}</div> : null}
      </div>
      <p className="mt-3 font-mono text-2xl font-semibold text-ink md:text-[28px]">
        {value}
      </p>
      {note ? (
        <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">
          {note}
        </p>
      ) : null}
    </article>
  );
}
