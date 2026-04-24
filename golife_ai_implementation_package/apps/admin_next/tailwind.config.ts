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
        ink: "#171412",
        sand: "#f6eee7",
        moss: "#5d7a68",
        clay: "#d06447",
        bronze: "#8a6c2f",
      },
    },
  },
  plugins: [],
};

export default config;
