"use client";

import { useState } from "react";

export function CopyableField({
  label,
  value,
}: {
  label: string;
  value: string;
}) {
  const [copied, setCopied] = useState(false);

  async function handleCopy() {
    await navigator.clipboard.writeText(value);
    setCopied(true);
    window.setTimeout(() => setCopied(false), 1200);
  }

  return (
    <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-3">
      <div className="flex items-center justify-between gap-3">
        <div className="min-w-0">
          <p className="text-[11px] font-semibold uppercase tracking-[0.16em] text-[color:var(--ink-muted)]">
            {label}
          </p>
          <p className="mt-1 truncate font-mono text-sm text-ink">{value}</p>
        </div>
        <button
          type="button"
          onClick={handleCopy}
          className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm font-medium text-ink"
        >
          {copied ? "Copied" : "Copy"}
        </button>
      </div>
    </div>
  );
}
