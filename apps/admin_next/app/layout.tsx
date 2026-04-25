import type { Metadata } from "next";

import { PageShell } from "@/components/page-shell";
import { getAdminMessages } from "@/lib/i18n";

export async function generateMetadata(): Promise<Metadata> {
  const { messages } = await getAdminMessages();
  return {
    title: messages.metadata.title,
    description: messages.metadata.description,
  };
}

export default async function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const { locale } = await getAdminMessages();
  return (
    <html lang={locale}>
      <body>
        <PageShell>{children}</PageShell>
      </body>
    </html>
  );
}
