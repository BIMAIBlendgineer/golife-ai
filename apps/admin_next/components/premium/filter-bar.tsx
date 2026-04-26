import { cn } from "@/lib/cn";

export function FilterBar({
  children,
  className,
}: {
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <form
      className={cn(
        "grid gap-3 rounded-lg border border-[color:var(--line)] bg-[color:var(--surface)] p-4 md:grid-cols-[minmax(220px,2fr)_repeat(auto-fit,minmax(140px,1fr))]",
        className,
      )}
    >
      {children}
    </form>
  );
}
