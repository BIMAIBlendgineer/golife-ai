export function PremiumShell({
  sidebar,
  topbar,
  children,
}: {
  sidebar: React.ReactNode;
  topbar: React.ReactNode;
  children: React.ReactNode;
}) {
  return (
    <div className="mx-auto grid min-h-screen w-full max-w-[1680px] grid-cols-1 gap-6 px-4 py-4 lg:grid-cols-[280px_minmax(0,1fr)] lg:px-6">
      <div className="lg:sticky lg:top-4 lg:h-[calc(100vh-2rem)]">{sidebar}</div>
      <div className="min-w-0 space-y-6">
        {topbar}
        <main className="space-y-6">{children}</main>
      </div>
    </div>
  );
}
