import type { Metadata } from "next";
import "./landing.css";
import { Landing } from "@/components/landing/Landing";

export const metadata: Metadata = {
  title: "Conservatio, condition reports for cultural heritage",
  description:
    "Structured condition reports, damage marked directly on photographs, offline in churches and excavation sites, exported as bilingual PDF. For conservators, museums, churches and archaeological teams.",
  icons: { icon: [{ url: "/favicon.svg", type: "image/svg+xml" }, { url: "/favicon-32.png", sizes: "32x32" }] },
};

export default function Home() {
  return <Landing />;
}
