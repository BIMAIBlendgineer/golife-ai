import Link from "next/link";

type PaginationFooterProps = {
  summary: string;
  previousHref?: string | null;
  nextHref?: string | null;
  previousLabel: string;
  nextLabel: string;
};

export function PaginationFooter({
  summary,
  previousHref,
  nextHref,
  previousLabel,
  nextLabel,
}: PaginationFooterProps) {
  return (
    <div className="flex flex-col gap-3 rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] px-4 py-3 text-sm text-[color:var(--ink-soft)] md:flex-row md:items-center md:justify-between">
      <p>{summary}</p>
      <div className="flex gap-2">
        {previousHref ? (
          <Link
            href={previousHref}
            className="rounded-lg border border-[color:var(--line)] px-3 py-2 font-medium text-ink transition-colors hover:bg-[color:var(--surface-2)]"
          >
            {previousLabel}
          </Link>
        ) : null}
        {nextHref ? (
          <Link
            href={nextHref}
            className="rounded-lg border border-[color:var(--line-strong)] bg-[color:var(--surface-2)] px-3 py-2 font-medium text-ink transition-colors hover:bg-white"
          >
            {nextLabel}
          </Link>
        ) : null}
      </div>
    </div>
  );
}
