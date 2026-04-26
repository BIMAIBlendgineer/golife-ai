import { StatusBadge } from "@/components/premium/status-badge";

export function SourceStateBadge({
  source,
  label,
}: {
  source: "live" | "fallback" | "offline";
  label: string;
}) {
  const tone =
    source === "live" ? "good" : source === "fallback" ? "warn" : "danger";
  return <StatusBadge tone={tone}>{label}</StatusBadge>;
}
