import { NavSidebar } from "@/components/nav-sidebar";
import { StatusPill } from "@/components/status-pill";
import { getAdminRuntime } from "@/lib/api";

export function PageShell({ children }: { children: React.ReactNode }) {
  const runtime = getAdminRuntime();

  return (
    <div className="mx-auto flex min-h-screen w-full max-w-[1600px] flex-col gap-6 px-4 py-4 lg:grid lg:grid-cols-[290px_minmax(0,1fr)] lg:px-6">
      <div className="lg:sticky lg:top-4 lg:h-[calc(100vh-2rem)]">
        <NavSidebar />
      </div>
      <div className="space-y-6">
        <div className="rounded-[24px] border border-[color:var(--line)] bg-[color:rgba(255,248,242,0.82)] p-4">
          <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <div className="space-y-1">
              <p className="text-[11px] font-semibold uppercase tracking-[0.22em] text-[color:var(--ink-muted)]">
                Control Surface
              </p>
              <p className="text-sm leading-6 text-[color:var(--ink-soft)]">
                This panel watches the same product loop as mobile:
                capture, risks, missions, feedback, trust.
              </p>
            </div>
            <div className="flex flex-wrap gap-2">
              <StatusPill tone="good">API {runtime.baseUrl}</StatusPill>
              <StatusPill tone={runtime.tokenConfigured ? "info" : "warn"}>
                {runtime.tokenConfigured ? "Admin token set" : "Token missing"}
              </StatusPill>
            </div>
          </div>
        </div>
        <main className="space-y-6">{children}</main>
      </div>
    </div>
  );
}
