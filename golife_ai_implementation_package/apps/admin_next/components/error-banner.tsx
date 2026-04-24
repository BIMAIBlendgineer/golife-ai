import { StatusPill } from "@/components/status-pill";

export function ErrorBanner({ error }: { error: string | null }) {
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
        </div>
        <StatusPill tone="danger">Fallback snapshot</StatusPill>
      </div>
    </div>
  );
}
