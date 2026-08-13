import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./app/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./lib/**/*.{ts,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        ink: "var(--ink)",
        sand: "var(--paper)",
        moss: "var(--moss)",
        sage: "var(--sage)",
        clay: "var(--clay)",
        amber: "var(--amber)",
        bronze: "var(--bronze)",
        steel: "var(--steel)",
      },
    },
  },
  plugins: [],
};

export default config;
