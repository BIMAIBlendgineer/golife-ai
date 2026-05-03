export function LoadingState({
  lines = 4,
}: {
  lines?: number;
}) {
  return (
    <div className="rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-4">
      <div className="animate-pulse space-y-3">
        {Array.from({ length: lines }).map((_, index) => (
          <div
            key={index}
            className="h-4 rounded bg-[color:rgba(19,24,23,0.08)]"
            style={{ width: `${Math.max(35, 100 - index * 9)}%` }}
          />
        ))}
      </div>
    </div>
  );
}
