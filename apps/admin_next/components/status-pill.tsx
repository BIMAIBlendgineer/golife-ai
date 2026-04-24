import { cn } from "@/lib/cn";

type StatusTone = "neutral" | "good" | "warn" | "danger" | "info";

const toneClasses: Record<StatusTone, string> = {
  neutral:
    "border-[color:var(--line)] bg-white/55 text-[color:var(--ink-soft)]",
  good: "border-[color:rgba(93,122,104,0.28)] bg-[color:var(--sage-soft)] text-moss",
  warn:
    "border-[color:rgba(138,108,47,0.28)] bg-[color:var(--bronze-soft)] text-[color:var(--bronze)]",
  danger:
    "border-[color:rgba(208,100,71,0.28)] bg-[color:var(--danger-soft)] text-[color:var(--clay)]",
  info:
    "border-[color:rgba(78,112,138,0.22)] bg-[color:rgba(78,112,138,0.1)] text-[color:var(--sky)]",
};

export function StatusPill({
  children,
  tone = "neutral",
  className,
}: {
  children: React.ReactNode;
  tone?: StatusTone;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full border px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.18em]",
        toneClasses[tone],
        className,
      )}
    >
      {children}
    </span>
  );
}
