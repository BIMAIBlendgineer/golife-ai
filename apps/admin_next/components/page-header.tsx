import { PremiumPageHeader } from "@/components/premium/page-header";

export function PageHeader({
  eyebrow,
  title,
  description,
  badge,
}: {
  eyebrow: string;
  title: string;
  description: string;
  badge?: string;
}) {
  return (
    <PremiumPageHeader
      eyebrow={eyebrow}
      title={title}
      description={description}
      badge={badge}
    />
  );
}
