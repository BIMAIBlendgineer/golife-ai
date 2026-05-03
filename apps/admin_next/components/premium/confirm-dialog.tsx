export function ConfirmDialog({
  title,
  body,
  actionLabel,
  action,
}: {
  title: string;
  body: string;
  actionLabel: string;
  action?: string;
}) {
  return (
    <div className="rounded-lg border border-[color:rgba(173,81,53,0.18)] bg-[color:rgba(173,81,53,0.04)] p-4">
      <p className="text-sm font-semibold text-ink">{title}</p>
      <p className="mt-2 text-sm leading-6 text-[color:var(--ink-soft)]">{body}</p>
      <div className="mt-4">
        <button
          type={action ? "submit" : "button"}
          formAction={action}
          className="rounded-lg border border-[color:var(--line-strong)] bg-[color:var(--surface)] px-3 py-2 text-sm font-medium text-ink"
        >
          {actionLabel}
        </button>
      </div>
    </div>
  );
}
