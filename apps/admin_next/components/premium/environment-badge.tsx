import { StatusBadge } from "@/components/premium/status-badge";

export function EnvironmentBadge({ environment }: { environment: string }) {
  const normalized = environment.toLowerCase();
  const tone =
    normalized === "production"
      ? "good"
      : normalized === "staging"
        ? "warn"
        : "info";
  return <StatusBadge tone={tone}>{normalized}</StatusBadge>;
}
