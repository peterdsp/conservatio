import { Box, FileText, FolderKanban, Users } from "lucide-react";

const stats = [
  { label: "Objects", value: "0", icon: Box, color: "text-primary" },
  { label: "Reports", value: "0", icon: FileText, color: "text-secondary" },
  { label: "Projects", value: "0", icon: FolderKanban, color: "text-tertiary" },
  { label: "Clients", value: "0", icon: Users, color: "text-primary-dark" },
];

export function DashboardContent() {
  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-bold">Welcome back</h1>
        <p className="mt-1 text-heritage-text-secondary">
          Your conservation workspace overview
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => (
          <div
            key={stat.label}
            className="rounded-xl border border-heritage-outline/10 bg-white p-6 shadow-sm"
          >
            <div className="flex items-center justify-between">
              <p className="text-sm font-medium text-heritage-text-secondary">
                {stat.label}
              </p>
              <stat.icon size={20} className={stat.color} />
            </div>
            <p className="mt-2 text-3xl font-bold">{stat.value}</p>
          </div>
        ))}
      </div>

      <div className="rounded-xl border border-heritage-outline/10 bg-white p-8 text-center shadow-sm">
        <Box size={48} className="mx-auto text-heritage-outline" />
        <h3 className="mt-4 text-lg font-semibold">Get Started</h3>
        <p className="mt-2 text-sm text-heritage-text-secondary">
          Add your first conservation object from the mobile app or create one
          here.
        </p>
        <button className="mt-4 rounded-lg bg-primary px-6 py-2.5 text-sm font-medium text-white transition-colors hover:bg-primary-dark">
          Create Object
        </button>
      </div>
    </div>
  );
}
