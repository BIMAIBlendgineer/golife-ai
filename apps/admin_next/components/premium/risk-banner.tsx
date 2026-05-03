import { StatusBadge, type StatusBadgeTone } from "@/components/premium/status-badge";
import { cn } from "@/lib/cn";

const bannerTone: Record<StatusBadgeTone, string> = {
  neutral: "border-[color:var(--line)] bg-[color:var(--surface-2)]",
  good: "border-[color:rgba(72,118,96,0.2)] bg-[color:rgba(72,118,96,0.06)]",
  warn: "border-[color:rgba(168,109,61,0.2)] bg-[color:rgba(168,109,61,0.06)]",
  danger: "border-[color:rgba(173,81,53,0.2)] bg-[color:rgba(173,81,53,0.06)]",
  info: "border-[color:rgba(70,101,122,0.2)] bg-[color:rgba(70,101,122,0.06)]",
};

export function RiskBanner({
  title,
  body,
  tone = "warn",
}: {
  title: string;
  body: string;
  tone?: StatusBadgeTone;
}) {
  return (
    <div className={cn("rounded-lg border p-4", bannerTone[tone])}>
      <div className="flex flex-wrap items-center justify-between gap-3">
        <h2 className="text-sm font-semibold text-ink">{title}</h2>
        <StatusBadge tone={tone}>{title}</StatusBadge>
      </div>
      <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">{body}</p>
    </div>
  );
}
