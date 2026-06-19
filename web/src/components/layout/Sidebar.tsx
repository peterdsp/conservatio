"use client";

import {
  LayoutDashboard,
  Box,
  FolderKanban,
  Users,
  FileText,
  Settings,
  ChevronLeft,
  ChevronRight,
} from "lucide-react";

export type WebSection =
  | "dashboard"
  | "objects"
  | "projects"
  | "clients"
  | "reports"
  | "settings";

const navItems: Array<{
  icon: typeof LayoutDashboard;
  labelKey: string;
  section: WebSection;
}> = [
  { icon: LayoutDashboard, labelKey: "nav.dashboard", section: "dashboard" },
  { icon: Box, labelKey: "nav.objects", section: "objects" },
  { icon: FolderKanban, labelKey: "nav.projects", section: "projects" },
  { icon: Users, labelKey: "nav.clients", section: "clients" },
  { icon: FileText, labelKey: "nav.reports", section: "reports" },
  { icon: Settings, labelKey: "nav.settings", section: "settings" },
];

type SidebarProps = {
  activeSection: WebSection;
  collapsed: boolean;
  onNavigate: (section: WebSection) => void;
  onToggleCollapsed: () => void;
  t: (key: string) => string;
};

export function Sidebar({
  activeSection,
  collapsed,
  onNavigate,
  onToggleCollapsed,
  t,
}: SidebarProps) {
  return (
    <aside
      className={`hidden shrink-0 flex-col border-r border-white/40 bg-white/45 shadow-[0_0_60px_-20px_rgba(60,40,30,0.25)] backdrop-blur-2xl backdrop-saturate-150 transition-all duration-200 lg:flex ${
        collapsed ? "w-16" : "w-64"
      }`}
    >
      <div className="flex h-16 items-center justify-between px-4">
        {!collapsed && (
          <div>
            <h1 className="text-xl font-bold text-primary">Conservatio</h1>
            <p className="text-xs text-heritage-text-secondary">
              Conservation workspace
            </p>
          </div>
        )}
        <button
          onClick={onToggleCollapsed}
          className="rounded-lg p-1.5 text-heritage-text-secondary hover:bg-heritage-surface-variant"
          type="button"
          aria-label="Toggle sidebar"
        >
          {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
        </button>
      </div>

      <nav className="flex-1 space-y-1 px-2 py-4">
        {navItems.map((item) => (
          <button
            key={item.section}
            onClick={() => onNavigate(item.section)}
            className={`flex w-full items-center gap-3 rounded-2xl px-3 py-2.5 text-left text-sm font-medium transition ${
              activeSection === item.section
                ? "border border-white/50 bg-white/60 text-primary shadow-[0_8px_20px_-12px_rgba(194,91,58,0.35)] ring-1 ring-inset ring-white/40 backdrop-blur-xl"
                : "text-heritage-text-secondary hover:bg-white/35 hover:text-heritage-text"
            }`}
            type="button"
          >
            <item.icon size={20} />
            {!collapsed && <span>{t(item.labelKey)}</span>}
          </button>
        ))}
      </nav>

      <div className="border-t border-heritage-outline/20 p-4">
        {!collapsed && (
          <p className="text-xs text-heritage-text-secondary">v0.1.0</p>
        )}
      </div>
    </aside>
  );
}
