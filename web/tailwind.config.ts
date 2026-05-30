import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#C25B3A",
          light: "#E8967A",
          dark: "#8B3D24",
          50: "#FFF5F2",
          100: "#FFDBCF",
          200: "#F5B8A0",
          300: "#E8967A",
          400: "#D4785A",
          500: "#C25B3A",
          600: "#A44A2E",
          700: "#8B3D24",
          800: "#6B2E1A",
          900: "#4A1F10",
        },
        secondary: {
          DEFAULT: "#3A6B8C",
          light: "#6999B8",
          dark: "#1E4460",
          50: "#F0F7FC",
          100: "#D0E6F5",
          200: "#A8D0E8",
          300: "#6999B8",
          400: "#4F82A2",
          500: "#3A6B8C",
          600: "#2D5570",
          700: "#1E4460",
          800: "#153349",
          900: "#0C2233",
        },
        tertiary: {
          DEFAULT: "#D4A843",
          light: "#EEC96E",
          dark: "#9B7A2E",
        },
        heritage: {
          bg: "#FAF7F4",
          surface: "#FFFFFF",
          "surface-variant": "#F2EEEA",
          text: "#1C1B1F",
          "text-secondary": "#49454F",
          outline: "#79747E",
        },
        condition: {
          excellent: "#2E7D32",
          good: "#558B2F",
          fair: "#F9A825",
          poor: "#EF6C00",
          critical: "#C62828",
        },
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        serif: ["Merriweather", "Georgia", "serif"],
      },
    },
  },
  plugins: [],
};

export default config;
