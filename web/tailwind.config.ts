import type { Config } from "tailwindcss";

const config: Config = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary: {
          DEFAULT: "#0d7480",
          light: "#3fb3a8",
          dark: "#095861",
          50: "#eef6f6",
          100: "#d3e9e8",
          200: "#a8d3d1",
          300: "#6fb9b5",
          400: "#3fb3a8",
          500: "#0d7480",
          600: "#0b6670",
          700: "#095861",
          800: "#074249",
          900: "#042b30",
        },
        secondary: {
          DEFAULT: "#1f3038",
          light: "#5d6b72",
          dark: "#132026",
          50: "#f7f9fa",
          100: "#ecf0f2",
          200: "#cfd7db",
          300: "#a9b5bb",
          400: "#7f8d94",
          500: "#5d6b72",
          600: "#3f4d54",
          700: "#1f3038",
          800: "#132026",
          900: "#0b1418",
        },
        tertiary: {
          DEFAULT: "#b06f12",
          light: "#d9a04a",
          dark: "#7f4f0a",
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
        // Greek Font Society's classical Greek typeface  --  proper polytonic
        // glyph shapes that mirror Oxford Classical Texts and stone-cut
        // inscriptions when set in uppercase.
        classical: ["GFS Didot", "Merriweather", "Georgia", "serif"],
      },
    },
  },
  plugins: [],
};

export default config;
