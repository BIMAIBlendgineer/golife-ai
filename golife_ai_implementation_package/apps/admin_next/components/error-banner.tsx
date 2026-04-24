import { StatusPill } from "@/components/status-pill";

export function ErrorBanner({
  error,
  fetchedAt,
}: {
  error: string | null;
  fetchedAt?: string;
}) {
  if (!error) {
    return null;
  }

  return (
    <div className="rounded-[22px] border border-[color:rgba(208,100,71,0.24)] bg-[color:var(--danger-soft)] p-4">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div className="space-y-1">
          <p className="text-sm font-semibold text-[color:var(--clay)]">
            Admin API fallback active
          </p>
          <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
            {error}
          </p>
          {fetchedAt ? (
            <p className="text-sm leading-6 text-[color:var(--ink-muted)]">
              Snapshot fetched {fetchedAt}
            </p>
          ) : null}
        </div>
        <StatusPill tone="danger">Fallback snapshot</StatusPill>
      </div>
    </div>
  );
}
