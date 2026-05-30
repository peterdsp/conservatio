"use client";

import { useState } from "react";
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

const navItems = [
  { icon: LayoutDashboard, label: "Dashboard", href: "/" },
  { icon: Box, label: "Objects", href: "/objects" },
  { icon: FolderKanban, label: "Projects", href: "/projects" },
  { icon: Users, label: "Clients", href: "/clients" },
  { icon: FileText, label: "Reports", href: "/reports" },
  { icon: Settings, label: "Settings", href: "/settings" },
];

export function Sidebar() {
  const [collapsed, setCollapsed] = useState(false);

  return (
    <aside
      className={`flex flex-col border-r border-heritage-outline/20 bg-white transition-all duration-200 ${
        collapsed ? "w-16" : "w-64"
      }`}
    >
      <div className="flex h-16 items-center justify-between px-4">
        {!collapsed && (
          <h1 className="text-xl font-bold text-primary">Conservatio</h1>
        )}
        <button
          onClick={() => setCollapsed(!collapsed)}
          className="rounded-lg p-1.5 text-heritage-text-secondary hover:bg-heritage-surface-variant"
        >
          {collapsed ? <ChevronRight size={18} /> : <ChevronLeft size={18} />}
        </button>
      </div>

      <nav className="flex-1 space-y-1 px-2 py-4">
        {navItems.map((item) => (
          <a
            key={item.href}
            href={item.href}
            className="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium text-heritage-text-secondary transition-colors hover:bg-heritage-surface-variant hover:text-heritage-text"
          >
            <item.icon size={20} />
            {!collapsed && <span>{item.label}</span>}
          </a>
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
