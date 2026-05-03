import {
  StatusBadge,
  type StatusBadgeTone,
} from "@/components/premium/status-badge";

export function StatusPill({
  children,
  tone = "neutral",
  className,
}: {
  children: React.ReactNode;
  tone?: StatusBadgeTone;
  className?: string;
}) {
  return (
    <StatusBadge tone={tone} className={className}>
      {children}
    </StatusBadge>
  );
}
