import { cn } from "@/lib/cn";

export function DetailDrawer({
  title,
  description,
  children,
  className,
}: {
  title: string;
  description?: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <aside
      className={cn(
        "rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-4",
        className,
      )}
    >
      <div className="border-b border-[color:var(--line)] pb-3">
        <h2 className="text-base font-semibold text-ink">{title}</h2>
        {description ? (
          <p className="mt-1 text-sm leading-6 text-[color:var(--ink-soft)]">
            {description}
          </p>
        ) : null}
      </div>
      <div className="pt-4">{children}</div>
    </aside>
  );
}
