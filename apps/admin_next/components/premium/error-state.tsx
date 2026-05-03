import { StatusBadge } from "@/components/premium/status-badge";

export function ErrorState({
  title,
  body,
}: {
  title: string;
  body: string;
}) {
  return (
    <div className="rounded-lg border border-[color:rgba(173,81,53,0.18)] bg-[color:rgba(173,81,53,0.05)] p-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm font-semibold text-ink">{title}</p>
        <StatusBadge tone="danger">error</StatusBadge>
      </div>
      <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">{body}</p>
    </div>
  );
}
