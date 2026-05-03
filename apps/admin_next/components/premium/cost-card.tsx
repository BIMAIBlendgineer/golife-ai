export function CostCard({
  title,
  amount,
  note,
  breakdown,
}: {
  title: string;
  amount: string;
  note?: string;
  breakdown?: React.ReactNode;
}) {
  return (
    <article className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-4">
      <p className="text-sm font-semibold text-ink">{title}</p>
      <p className="mt-3 font-mono text-2xl font-semibold text-ink">{amount}</p>
      {note ? (
        <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">{note}</p>
      ) : null}
      {breakdown ? <div className="mt-4">{breakdown}</div> : null}
    </article>
  );
}
