import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Conservatio - Conservation Documentation Platform",
  description:
    "Professional conservation documentation, condition reporting, and project management for cultural heritage professionals.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="bg-heritage-bg text-heritage-text antialiased">
        {children}
      </body>
    </html>
  );
}
