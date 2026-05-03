export function SecretInput({
  label,
  value,
  helpText,
}: {
  label: string;
  value: string;
  helpText?: string;
}) {
  return (
    <label className="block space-y-2">
      <span className="text-sm font-semibold text-ink">{label}</span>
      <input
        readOnly
        type="password"
        value={value}
        className="w-full rounded-lg border border-[color:var(--line)] bg-[color:var(--surface-2)] px-3 py-2 text-sm text-[color:var(--ink-soft)]"
      />
      {helpText ? (
        <span className="block text-sm leading-6 text-[color:var(--ink-muted)]">
          {helpText}
        </span>
      ) : null}
    </label>
  );
}
