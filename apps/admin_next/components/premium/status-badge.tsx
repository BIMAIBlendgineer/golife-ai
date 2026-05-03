import { cn } from "@/lib/cn";

export type StatusBadgeTone =
  | "neutral"
  | "good"
  | "warn"
  | "danger"
  | "info";

const toneClasses: Record<StatusBadgeTone, string> = {
  neutral:
    "border-[color:var(--line)] bg-[color:var(--surface-2)] text-[color:var(--ink-soft)]",
  good:
    "border-[color:rgba(72,118,96,0.28)] bg-[color:var(--moss-soft)] text-[color:var(--moss)]",
  warn:
    "border-[color:rgba(168,109,61,0.28)] bg-[color:var(--amber-soft)] text-[color:var(--amber)]",
  danger:
    "border-[color:rgba(173,81,53,0.28)] bg-[color:var(--danger-soft)] text-[color:var(--copper)]",
  info:
    "border-[color:rgba(70,101,122,0.24)] bg-[color:var(--steel-soft)] text-[color:var(--steel)]",
};

export function StatusBadge({
  children,
  tone = "neutral",
  className,
}: {
  children: React.ReactNode;
  tone?: StatusBadgeTone;
  className?: string;
}) {
  return (
    <span
      className={cn(
        "inline-flex items-center gap-2 rounded-full border px-2.5 py-1 text-[11px] font-semibold uppercase tracking-[0.14em]",
        toneClasses[tone],
        className,
      )}
    >
      <span className="h-1.5 w-1.5 rounded-full bg-current" aria-hidden />
      {children}
    </span>
  );
}
