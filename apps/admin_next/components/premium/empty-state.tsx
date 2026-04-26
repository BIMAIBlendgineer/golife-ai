export function EmptyState({
  title,
  body,
}: {
  title: string;
  body: string;
}) {
  return (
    <div className="rounded-lg border border-dashed border-[color:var(--line-strong)] bg-[color:var(--surface)] p-6 text-center">
      <p className="text-sm font-semibold text-ink">{title}</p>
      <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">{body}</p>
    </div>
  );
}
