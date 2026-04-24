import { cn } from "@/lib/cn";

const toneClasses = {
  sage: "border-[color:rgba(93,122,104,0.2)] bg-[color:rgba(93,122,104,0.08)]",
  clay: "border-[color:rgba(208,100,71,0.2)] bg-[color:rgba(208,100,71,0.08)]",
  bronze:
    "border-[color:rgba(138,108,47,0.2)] bg-[color:rgba(138,108,47,0.08)]",
  ink: "border-[color:var(--line)] bg-white/58",
};

export function MetricCard({
  label,
  value,
  note,
  tone = "ink",
}: {
  label: string;
  value: string;
  note: string;
  tone?: keyof typeof toneClasses;
}) {
  return (
    <article
      className={cn(
        "rounded-[22px] border p-5",
        toneClasses[tone],
      )}
    >
      <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
        {label}
      </p>
      <p className="mt-4 font-mono text-3xl font-semibold tracking-[-0.04em] text-ink">
        {value}
      </p>
      <p className="mt-3 text-sm leading-6 text-[color:var(--ink-soft)]">
        {note}
      </p>
    </article>
  );
}
