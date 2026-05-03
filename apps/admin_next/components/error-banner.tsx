import { StatusPill } from "@/components/status-pill";
import { getAdminMessages } from "@/lib/i18n";

export async function ErrorBanner({
  error,
  fetchedAt,
}: {
  error: string | null;
  fetchedAt?: string;
}) {
  if (!error) {
    return null;
  }
  const { messages } = await getAdminMessages();

  return (
    <div className="rounded-lg border border-[color:rgba(173,81,53,0.24)] bg-[color:var(--danger-soft)] p-4">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div className="space-y-1">
          <p className="text-sm font-semibold text-[color:var(--copper)]">
            {messages.shared.adminApiFallbackActive}
          </p>
          <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
            {error}
          </p>
          {fetchedAt ? (
            <p className="text-sm leading-6 text-[color:var(--ink-muted)]">
              {messages.shared.snapshotFetched} {fetchedAt}
            </p>
          ) : null}
        </div>
        <StatusPill tone="danger">{messages.shared.fallbackSnapshot}</StatusPill>
      </div>
    </div>
  );
}
