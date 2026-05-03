import { PremiumMetricCard } from "@/components/premium/metric-card";

export function MetricCard({
  label,
  value,
  note,
  tone = "ink",
}: {
  label: string;
  value: string;
  note: string;
  tone?: "sage" | "clay" | "bronze" | "ink";
}) {
  const mappedTone =
    tone === "sage"
      ? "good"
      : tone === "clay"
        ? "danger"
        : tone === "bronze"
          ? "warn"
          : "neutral";
  return (
    <PremiumMetricCard
      label={label}
      value={value}
      note={note}
      tone={mappedTone}
    />
  );
}
