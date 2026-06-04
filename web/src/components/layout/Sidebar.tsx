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
  label: string;
  section: WebSection;
}> = [
  { icon: LayoutDashboard, label: "Dashboard", section: "dashboard" },
  { icon: Box, label: "Objects", section: "objects" },
  { icon: FolderKanban, label: "Projects", section: "projects" },
  { icon: Users, label: "Clients", section: "clients" },
  { icon: FileText, label: "Reports", section: "reports" },
  { icon: Settings, label: "Settings", section: "settings" },
];

type SidebarProps = {
  activeSection: WebSection;
  collapsed: boolean;
  onNavigate: (section: WebSection) => void;
  onToggleCollapsed: () => void;
};

export function Sidebar({
  activeSection,
  collapsed,
  onNavigate,
  onToggleCollapsed,
}: SidebarProps) {
  return (
    <aside
      className={`hidden shrink-0 flex-col border-r border-heritage-outline/15 bg-white/90 shadow-sm backdrop-blur transition-all duration-200 lg:flex ${
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
            className={`flex w-full items-center gap-3 rounded-lg px-3 py-2.5 text-left text-sm font-medium transition-colors ${
              activeSection === item.section
                ? "bg-primary-50 text-primary"
                : "text-heritage-text-secondary hover:bg-heritage-surface-variant hover:text-heritage-text"
            }`}
            type="button"
          >
            <item.icon size={20} />
            {!collapsed && <span>{item.label}</span>}
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
