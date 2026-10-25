import type { Metadata } from "next";
import { WebAppShell } from "@/components/app/WebAppShell";

export const metadata: Metadata = {
  title: "Conservatio web companion",
  description:
    "Browse and edit objects, projects and clients from the desktop. Condition reports, annotation and PDF export live in the mobile apps.",
};

export default function AppPage() {
  return <WebAppShell />;
}
