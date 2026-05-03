import { StatusBadge, type StatusBadgeTone } from "@/components/premium/status-badge";

export type AuditTimelineItem = {
  id: string;
  title: string;
  meta: string;
  body?: string | null;
  tone?: StatusBadgeTone;
};

export function AuditTimeline({ items }: { items: AuditTimelineItem[] }) {
  return (
    <div className="space-y-3">
      {items.map((item) => (
        <div
          key={item.id}
          className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-4"
        >
          <div className="flex flex-wrap items-center justify-between gap-3">
            <p className="text-sm font-semibold text-ink">{item.title}</p>
            <StatusBadge tone={item.tone ?? "neutral"}>{item.meta}</StatusBadge>
          </div>
          {item.body ? (
            <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">
              {item.body}
            </p>
          ) : null}
        </div>
      ))}
    </div>
  );
}
