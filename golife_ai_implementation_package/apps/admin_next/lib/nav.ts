export type NavSection = {
  label: string;
  items: Array<{
    href: string;
    title: string;
    note: string;
  }>;
};

export const navSections: NavSection[] = [
  {
    label: "Operate",
    items: [
      {
        href: "/dashboard",
        title: "Dashboard",
        note: "Mission health, trust pressure, cost.",
      },
      {
        href: "/users",
        title: "Users",
        note: "Account state and support signals.",
      },
      {
        href: "/usage",
        title: "Usage",
        note: "Capture volume, fallback, latency.",
      },
      {
        href: "/ai-costs",
        title: "AI Costs",
        note: "Endpoint-level provider spend.",
      },
    ],
  },
  {
    label: "Quality",
    items: [
      {
        href: "/missions",
        title: "Missions",
        note: "Ranked output quality and risk links.",
      },
      {
        href: "/feedback",
        title: "Feedback",
        note: "Why users accept, reject, or complete.",
      },
      {
        href: "/safety",
        title: "Safety",
        note: "Blocked outputs and trust incidents.",
      },
    ],
  },
  {
    label: "System",
    items: [
      {
        href: "/feature-flags",
        title: "Feature Flags",
        note: "Operational rollout switches.",
      },
      {
        href: "/settings/models",
        title: "Models",
        note: "Provider and fallback routing.",
      },
      {
        href: "/support/export-delete",
        title: "Support Queue",
        note: "Export and delete requests.",
      },
    ],
  },
];
