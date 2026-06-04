"use client";

import { FormEvent, useMemo, useState } from "react";
import {
  ArrowRight,
  Box,
  Camera,
  CheckCircle2,
  Cloud,
  FileText,
  FolderKanban,
  Globe,
  HardDrive,
  ImagePlus,
  Info,
  LayoutDashboard,
  Menu,
  Palette,
  Plus,
  Search,
  Settings,
  ShieldCheck,
  Upload,
  Users,
  X,
} from "lucide-react";
import { Sidebar, WebSection } from "@/components/layout/Sidebar";

type ObjectType =
  | "Painting"
  | "Icon"
  | "Wall painting"
  | "Sculpture"
  | "Ceramic"
  | "Metal"
  | "Textile"
  | "Paper"
  | "Wood"
  | "Stone"
  | "Glass"
  | "Mosaic"
  | "Archaeological find"
  | "Furniture"
  | "Other";

type ConservationObject = {
  id: string;
  title: string;
  objectType: ObjectType;
  materials: string[];
  ownerName: string;
  locationDescription: string;
  inventoryNumber: string;
  description: string;
  dimensions: {
    height: string;
    width: string;
    depth: string;
    unit: "cm" | "m" | "in";
  };
  imageNames: string[];
  createdAt: string;
  updatedAt: string;
};

type ObjectFormState = {
  title: string;
  objectType: ObjectType;
  materialsText: string;
  ownerName: string;
  locationDescription: string;
  inventoryNumber: string;
  description: string;
  height: string;
  width: string;
  depth: string;
  unit: "cm" | "m" | "in";
  imageNames: string[];
};

const emptyForm: ObjectFormState = {
  title: "",
  objectType: "Painting",
  materialsText: "",
  ownerName: "",
  locationDescription: "",
  inventoryNumber: "",
  description: "",
  height: "",
  width: "",
  depth: "",
  unit: "cm",
  imageNames: [],
};

const objectTypes: ObjectType[] = [
  "Painting",
  "Icon",
  "Wall painting",
  "Sculpture",
  "Ceramic",
  "Metal",
  "Textile",
  "Paper",
  "Wood",
  "Stone",
  "Glass",
  "Mosaic",
  "Archaeological find",
  "Furniture",
  "Other",
];

const seedObjects: ConservationObject[] = [
  {
    id: "obj-1",
    title: "Saint Nicholas panel icon",
    objectType: "Icon",
    materials: ["tempera", "wood panel", "gold leaf"],
    ownerName: "Agios Nikolaos Church",
    locationDescription: "North nave storage cabinet",
    inventoryNumber: "CN-1842-07",
    description:
      "Panel icon with edge abrasions, localized flaking, and surface grime requiring initial assessment.",
    dimensions: { height: "42", width: "31", depth: "2.4", unit: "cm" },
    imageNames: ["front-detail.jpg", "corner-loss.jpg"],
    createdAt: "2026-05-18",
    updatedAt: "2026-06-01",
  },
  {
    id: "obj-2",
    title: "Bronze votive lamp",
    objectType: "Metal",
    materials: ["bronze", "mineral deposits"],
    ownerName: "Municipal Collection",
    locationDescription: "Case B, gallery 2",
    inventoryNumber: "MC-09-118",
    description:
      "Historic lamp with active corrosion checks pending before storage recommendation.",
    dimensions: { height: "12", width: "18", depth: "9", unit: "cm" },
    imageNames: ["lamp-overview.jpg"],
    createdAt: "2026-05-12",
    updatedAt: "2026-05-28",
  },
];

const navItems: Array<{ section: WebSection; label: string; icon: typeof Box }> =
  [
    { section: "dashboard", label: "Home", icon: LayoutDashboard },
    { section: "objects", label: "Objects", icon: Box },
    { section: "projects", label: "Projects", icon: FolderKanban },
    { section: "clients", label: "Clients", icon: Users },
    { section: "reports", label: "Reports", icon: FileText },
    { section: "settings", label: "Settings", icon: Settings },
  ];

const projectRows = [
  {
    title: "Byzantine icon survey",
    status: "In progress",
    client: "Agios Nikolaos Church",
    objects: 12,
  },
  {
    title: "Municipal metalwork review",
    status: "Approved",
    client: "Municipal Collection",
    objects: 8,
  },
  {
    title: "Gallery loan condition checks",
    status: "Inquiry",
    client: "Aster Gallery",
    objects: 5,
  },
];

const clientRows = [
  {
    name: "Agios Nikolaos Church",
    type: "Church",
    contact: "Fr. Dimitrios",
    projects: 2,
  },
  {
    name: "Municipal Collection",
    type: "Municipality",
    contact: "Eleni Markou",
    projects: 1,
  },
  {
    name: "Aster Gallery",
    type: "Gallery",
    contact: "Nikos Stavros",
    projects: 1,
  },
];

const reportRows = [
  {
    title: "Initial assessment",
    object: "Saint Nicholas panel icon",
    condition: "Fair",
    examiner: "Petros Dhespollari",
    date: "2026-06-01",
  },
  {
    title: "Periodic check",
    object: "Bronze votive lamp",
    condition: "Good",
    examiner: "Petros Dhespollari",
    date: "2026-05-28",
  },
];

export function WebAppShell() {
  const [activeSection, setActiveSection] = useState<WebSection>("dashboard");
  const [collapsed, setCollapsed] = useState(false);
  const [showCreateObject, setShowCreateObject] = useState(false);
  const [objects, setObjects] = useState<ConservationObject[]>(seedObjects);
  const [query, setQuery] = useState("");

  const filteredObjects = useMemo(() => {
    const search = query.trim().toLowerCase();
    if (!search) {
      return objects;
    }

    return objects.filter((object) =>
      [
        object.title,
        object.objectType,
        object.inventoryNumber,
        object.locationDescription,
        object.ownerName,
      ]
        .join(" ")
        .toLowerCase()
        .includes(search),
    );
  }, [objects, query]);

  function createObject(form: ObjectFormState) {
    const now = new Date().toISOString().slice(0, 10);
    const materials = form.materialsText
      .split(",")
      .map((material) => material.trim())
      .filter(Boolean);

    setObjects((current) => [
      {
        id: crypto.randomUUID(),
        title: form.title,
        objectType: form.objectType,
        materials,
        ownerName: form.ownerName,
        locationDescription: form.locationDescription,
        inventoryNumber: form.inventoryNumber,
        description: form.description,
        dimensions: {
          height: form.height,
          width: form.width,
          depth: form.depth,
          unit: form.unit,
        },
        imageNames: form.imageNames,
        createdAt: now,
        updatedAt: now,
      },
      ...current,
    ]);
    setActiveSection("objects");
    setShowCreateObject(false);
  }

  return (
    <div className="min-h-screen bg-heritage-bg text-heritage-text">
      <div className="fixed inset-0 -z-10 bg-[radial-gradient(circle_at_top_left,#fff0e8_0,#faf7f4_32%,#f2eeea_100%)]" />
      <div className="flex min-h-screen">
        <Sidebar
          activeSection={activeSection}
          collapsed={collapsed}
          onNavigate={setActiveSection}
          onToggleCollapsed={() => setCollapsed((value) => !value)}
        />
        <main className="flex-1 overflow-auto">
          <TopBar
            activeSection={activeSection}
            onCreateObject={() => setShowCreateObject(true)}
            onNavigate={setActiveSection}
          />
          <div className="mx-auto w-full max-w-7xl px-4 py-6 sm:px-6 lg:px-8 lg:py-8">
            {activeSection === "dashboard" && (
              <DashboardView
                objects={objects}
                onCreateObject={() => setShowCreateObject(true)}
                onNavigate={setActiveSection}
              />
            )}
            {activeSection === "objects" && (
              <ObjectsView
                objects={filteredObjects}
                query={query}
                onQueryChange={setQuery}
                onCreateObject={() => setShowCreateObject(true)}
              />
            )}
            {activeSection === "projects" && <ProjectsView />}
            {activeSection === "clients" && <ClientsView />}
            {activeSection === "reports" && <ReportsView />}
            {activeSection === "settings" && <SettingsView />}
          </div>
        </main>
      </div>

      {showCreateObject && (
        <CreateObjectModal
          onClose={() => setShowCreateObject(false)}
          onSave={createObject}
        />
      )}
    </div>
  );
}

function TopBar({
  activeSection,
  onCreateObject,
  onNavigate,
}: {
  activeSection: WebSection;
  onCreateObject: () => void;
  onNavigate: (section: WebSection) => void;
}) {
  return (
    <header className="sticky top-0 z-20 border-b border-heritage-outline/10 bg-heritage-bg/90 backdrop-blur">
      <div className="mx-auto flex h-16 max-w-7xl items-center gap-3 px-4 sm:px-6 lg:px-8">
        <div className="flex flex-1 items-center gap-3 lg:hidden">
          <Menu className="text-primary" size={22} />
          <div>
            <p className="text-base font-bold text-primary">Conservatio</p>
            <p className="text-xs text-heritage-text-secondary">
              {labelForSection(activeSection)}
            </p>
          </div>
        </div>
        <div className="hidden flex-1 lg:block">
          <p className="text-sm font-medium text-heritage-text-secondary">
            {labelForSection(activeSection)}
          </p>
        </div>
        <button
          onClick={onCreateObject}
          className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-primary-dark"
          type="button"
        >
          <Plus size={18} />
          New Object
        </button>
      </div>
      <div className="flex gap-2 overflow-x-auto px-4 pb-3 lg:hidden">
        {navItems.map((item) => (
          <button
            key={item.section}
            onClick={() => onNavigate(item.section)}
            className={`flex shrink-0 items-center gap-2 rounded-full px-3 py-2 text-sm font-medium ${
              activeSection === item.section
                ? "bg-primary-50 text-primary"
                : "bg-white/80 text-heritage-text-secondary"
            }`}
            type="button"
          >
            <item.icon size={16} />
            {item.label}
          </button>
        ))}
      </div>
    </header>
  );
}

function DashboardView({
  objects,
  onCreateObject,
  onNavigate,
}: {
  objects: ConservationObject[];
  onCreateObject: () => void;
  onNavigate: (section: WebSection) => void;
}) {
  return (
    <div className="space-y-6">
      <div className="grid gap-6 lg:grid-cols-[1.6fr_1fr]">
        <section className="rounded-3xl border border-primary/10 bg-white p-6 shadow-sm lg:p-8">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary">
            Welcome back
          </p>
          <div className="mt-3 flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <h1 className="font-serif text-3xl font-bold text-heritage-text sm:text-4xl">
                Your conservation workspace
              </h1>
              <p className="mt-3 max-w-2xl text-base leading-7 text-heritage-text-secondary">
                Document objects, attach field photos, prepare reports, and keep
                project context in one desktop-friendly workspace.
              </p>
            </div>
            <button
              onClick={onCreateObject}
              className="inline-flex items-center justify-center gap-2 rounded-2xl bg-primary px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-primary-dark"
              type="button"
            >
              <Plus size={18} />
              New Object
            </button>
          </div>
        </section>

        <section className="rounded-3xl border border-secondary/10 bg-secondary-900 p-6 text-white shadow-sm lg:p-8">
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-sm font-medium text-secondary-100">
                Sync status
              </p>
              <h2 className="mt-2 text-2xl font-bold">Offline-ready</h2>
            </div>
            <Cloud className="text-secondary-200" size={28} />
          </div>
          <p className="mt-4 text-sm leading-6 text-secondary-100">
            Web mirrors the mobile MVP flow locally. Backend sync can be wired
            to the same object, report, client, and project models.
          </p>
          <div className="mt-6 grid grid-cols-2 gap-3 text-sm">
            <StatusPill label="Local save" />
            <StatusPill label="Pi API ready" />
          </div>
        </section>
      </div>

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Objects" value={`${objects.length}`} icon={Box} />
        <StatCard label="Reports" value={`${reportRows.length}`} icon={FileText} />
        <StatCard
          label="Projects"
          value={`${projectRows.length}`}
          icon={FolderKanban}
        />
        <StatCard label="Clients" value={`${clientRows.length}`} icon={Users} />
      </section>

      <div className="grid gap-6 xl:grid-cols-[0.95fr_1.45fr]">
        <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm lg:p-6">
          <SectionTitle
            title="Quick Actions"
            subtitle="Same mobile actions, scaled into desktop cards."
          />
          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            <QuickActionCard
              title="New Object"
              icon={Box}
              color="text-primary"
              onClick={onCreateObject}
            />
            <QuickActionCard
              title="Take Photo"
              icon={Camera}
              color="text-secondary"
              onClick={onCreateObject}
            />
            <QuickActionCard
              title="New Report"
              icon={FileText}
              color="text-tertiary"
              onClick={() => onNavigate("reports")}
            />
            <QuickActionCard
              title="New Project"
              icon={FolderKanban}
              color="text-primary-dark"
              onClick={() => onNavigate("projects")}
            />
          </div>
        </section>

        <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm lg:p-6">
          <div className="flex items-start justify-between gap-4">
            <SectionTitle
              title="Recent Objects"
              subtitle="The same list from mobile with more metadata visible."
            />
            <button
              onClick={() => onNavigate("objects")}
              className="hidden items-center gap-2 rounded-xl bg-heritage-surface-variant px-3 py-2 text-sm font-semibold text-heritage-text sm:inline-flex"
              type="button"
            >
              View all
              <ArrowRight size={16} />
            </button>
          </div>
          <div className="mt-5 space-y-3">
            {objects.slice(0, 5).map((object) => (
              <ObjectRow key={object.id} object={object} />
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}

function ObjectsView({
  objects,
  query,
  onQueryChange,
  onCreateObject,
}: {
  objects: ConservationObject[];
  query: string;
  onQueryChange: (query: string) => void;
  onCreateObject: () => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Objects"
        subtitle="Search and manage conservation objects with the same fields used on iOS and Android."
        actionLabel="New Object"
        onAction={onCreateObject}
      />

      <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm lg:p-6">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
          <label className="relative block flex-1">
            <Search
              className="absolute left-3 top-1/2 -translate-y-1/2 text-heritage-outline"
              size={18}
            />
            <input
              value={query}
              onChange={(event) => onQueryChange(event.target.value)}
              className="w-full rounded-2xl border border-heritage-outline/20 bg-heritage-surface-variant py-3 pl-10 pr-4 text-sm outline-none transition focus:border-primary focus:bg-white"
              placeholder="Search objects, type, inventory, owner, location"
              type="search"
            />
          </label>
          <p className="text-sm font-medium text-heritage-text-secondary">
            {objects.length} visible
          </p>
        </div>

        <div className="mt-5 grid gap-3 xl:grid-cols-2">
          {objects.map((object) => (
            <ObjectCard key={object.id} object={object} />
          ))}
        </div>
      </section>
    </div>
  );
}

function ProjectsView() {
  return (
    <EntityTable
      title="Projects"
      subtitle="Mobile currently shows this as a tab. Web uses the wider screen for project status and linked object counts."
      columns={["Project", "Client", "Status", "Objects"]}
      rows={projectRows.map((project) => [
        project.title,
        project.client,
        project.status,
        `${project.objects}`,
      ])}
      icon={FolderKanban}
    />
  );
}

function ClientsView() {
  return (
    <EntityTable
      title="Clients"
      subtitle="Client records are available beside project context instead of hiding each field behind a mobile list row."
      columns={["Client", "Type", "Contact", "Projects"]}
      rows={clientRows.map((client) => [
        client.name,
        client.type,
        client.contact,
        `${client.projects}`,
      ])}
      icon={Users}
    />
  );
}

function ReportsView() {
  return (
    <EntityTable
      title="Reports"
      subtitle="Condition reports keep the mobile report model and expose examiner, date, and condition in a desktop table."
      columns={["Report", "Object", "Condition", "Examiner", "Date"]}
      rows={reportRows.map((report) => [
        report.title,
        report.object,
        report.condition,
        report.examiner,
        report.date,
      ])}
      icon={FileText}
    />
  );
}

function SettingsView() {
  const groups = [
    {
      title: "Account",
      items: [
        { label: "Profile", icon: Users },
        { label: "Sync and Storage", icon: Cloud },
      ],
    },
    {
      title: "Reports",
      items: [
        { label: "Templates", icon: FileText },
        { label: "Export Settings", icon: Upload },
        { label: "Language", icon: Globe },
      ],
    },
    {
      title: "App",
      items: [
        { label: "Appearance", icon: Palette },
        { label: "Storage", icon: HardDrive },
        { label: "About", icon: Info },
      ],
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Settings"
        subtitle="The same settings groups as iOS, arranged as desktop panels."
      />
      <div className="grid gap-4 lg:grid-cols-3">
        {groups.map((group) => (
          <section
            key={group.title}
            className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm"
          >
            <h2 className="text-base font-semibold">{group.title}</h2>
            <div className="mt-4 space-y-2">
              {group.items.map((item) => (
                <button
                  key={item.label}
                  className="flex w-full items-center justify-between rounded-2xl bg-heritage-surface-variant px-4 py-3 text-left transition hover:bg-primary-50 hover:text-primary"
                  type="button"
                >
                  <span className="flex items-center gap-3 text-sm font-medium">
                    <item.icon size={18} />
                    {item.label}
                  </span>
                  <ArrowRight size={16} />
                </button>
              ))}
            </div>
          </section>
        ))}
      </div>
    </div>
  );
}

function CreateObjectModal({
  onClose,
  onSave,
}: {
  onClose: () => void;
  onSave: (form: ObjectFormState) => void;
}) {
  const [form, setForm] = useState<ObjectFormState>(emptyForm);

  function update<Key extends keyof ObjectFormState>(
    key: Key,
    value: ObjectFormState[Key],
  ) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!form.title.trim()) {
      return;
    }
    onSave(form);
  }

  return (
    <div className="fixed inset-0 z-40 flex items-center justify-center bg-heritage-text/35 p-4 backdrop-blur-sm">
      <form
        onSubmit={handleSubmit}
        className="max-h-[92vh] w-full max-w-5xl overflow-hidden rounded-3xl bg-white shadow-2xl"
      >
        <div className="flex items-start justify-between gap-4 border-b border-heritage-outline/10 p-5 lg:p-6">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">
              New Object
            </p>
            <h2 className="mt-1 text-2xl font-bold">Create conservation object</h2>
          </div>
          <button
            onClick={onClose}
            className="rounded-xl bg-heritage-surface-variant p-2 text-heritage-text-secondary hover:text-heritage-text"
            type="button"
            aria-label="Close"
          >
            <X size={20} />
          </button>
        </div>

        <div className="max-h-[66vh] overflow-y-auto p-5 lg:p-6">
          <div className="grid gap-5 lg:grid-cols-2">
            <FormSection title="Basic Information">
              <TextField
                label="Object title"
                value={form.title}
                onChange={(value) => update("title", value)}
                required
              />
              <label className="space-y-2 text-sm font-medium">
                <span>Type</span>
                <select
                  value={form.objectType}
                  onChange={(event) =>
                    update("objectType", event.target.value as ObjectType)
                  }
                  className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3 outline-none focus:border-primary"
                >
                  {objectTypes.map((type) => (
                    <option key={type}>{type}</option>
                  ))}
                </select>
              </label>
              <TextField
                label="Inventory number"
                value={form.inventoryNumber}
                onChange={(value) => update("inventoryNumber", value)}
              />
            </FormSection>

            <FormSection title="Materials">
              <TextField
                label="Materials"
                value={form.materialsText}
                onChange={(value) => update("materialsText", value)}
                placeholder="tempera, wood panel, gold leaf"
              />
              <p className="text-xs text-heritage-text-secondary">
                Separate multiple materials with commas.
              </p>
            </FormSection>

            <FormSection title="Dimensions">
              <div className="grid grid-cols-3 gap-3">
                <TextField
                  label="H"
                  value={form.height}
                  onChange={(value) => update("height", value)}
                />
                <TextField
                  label="W"
                  value={form.width}
                  onChange={(value) => update("width", value)}
                />
                <TextField
                  label="D"
                  value={form.depth}
                  onChange={(value) => update("depth", value)}
                />
              </div>
              <div className="grid grid-cols-3 gap-2 rounded-2xl bg-heritage-surface-variant p-1">
                {(["cm", "m", "in"] as const).map((unit) => (
                  <button
                    key={unit}
                    onClick={() => update("unit", unit)}
                    className={`rounded-xl px-3 py-2 text-sm font-semibold ${
                      form.unit === unit
                        ? "bg-white text-primary shadow-sm"
                        : "text-heritage-text-secondary"
                    }`}
                    type="button"
                  >
                    {unit}
                  </button>
                ))}
              </div>
            </FormSection>

            <FormSection title="Location and Owner">
              <TextField
                label="Owner name"
                value={form.ownerName}
                onChange={(value) => update("ownerName", value)}
              />
              <TextField
                label="Location description"
                value={form.locationDescription}
                onChange={(value) => update("locationDescription", value)}
              />
            </FormSection>

            <FormSection title="Photos">
              <label className="flex cursor-pointer flex-col items-center justify-center rounded-2xl border border-dashed border-heritage-outline/30 bg-heritage-surface-variant px-4 py-8 text-center transition hover:border-primary hover:bg-primary-50">
                <ImagePlus className="text-primary" size={30} />
                <span className="mt-3 text-sm font-semibold">Attach photos</span>
                <span className="mt-1 text-xs text-heritage-text-secondary">
                  Camera and gallery equivalent for web upload.
                </span>
                <input
                  className="hidden"
                  multiple
                  type="file"
                  accept="image/*"
                  onChange={(event) =>
                    update(
                      "imageNames",
                      Array.from(event.target.files ?? []).map(
                        (file) => file.name,
                      ),
                    )
                  }
                />
              </label>
              <p className="text-xs text-heritage-text-secondary">
                {form.imageNames.length} photo(s) attached
              </p>
            </FormSection>

            <FormSection title="Description">
              <label className="space-y-2 text-sm font-medium">
                <span>Description</span>
                <textarea
                  value={form.description}
                  onChange={(event) => update("description", event.target.value)}
                  className="min-h-32 w-full resize-y rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3 outline-none focus:border-primary"
                  placeholder="Condition context, handling notes, or acquisition details"
                />
              </label>
            </FormSection>
          </div>
        </div>

        <div className="flex items-center justify-end gap-3 border-t border-heritage-outline/10 p-5 lg:p-6">
          <button
            onClick={onClose}
            className="rounded-xl px-4 py-2.5 text-sm font-semibold text-heritage-text-secondary hover:bg-heritage-surface-variant"
            type="button"
          >
            Cancel
          </button>
          <button
            className="rounded-xl bg-primary px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-primary-dark disabled:cursor-not-allowed disabled:opacity-50"
            disabled={!form.title.trim()}
            type="submit"
          >
            Save
          </button>
        </div>
      </form>
    </div>
  );
}

function PageHeader({
  title,
  subtitle,
  actionLabel,
  onAction,
}: {
  title: string;
  subtitle: string;
  actionLabel?: string;
  onAction?: () => void;
}) {
  return (
    <div className="flex flex-col gap-4 rounded-3xl border border-heritage-outline/10 bg-white p-6 shadow-sm lg:flex-row lg:items-end lg:justify-between lg:p-8">
      <div>
        <h1 className="font-serif text-3xl font-bold">{title}</h1>
        <p className="mt-2 max-w-3xl text-sm leading-6 text-heritage-text-secondary">
          {subtitle}
        </p>
      </div>
      {actionLabel && onAction && (
        <button
          onClick={onAction}
          className="inline-flex items-center justify-center gap-2 rounded-2xl bg-primary px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-primary-dark"
          type="button"
        >
          <Plus size={18} />
          {actionLabel}
        </button>
      )}
    </div>
  );
}

function SectionTitle({ title, subtitle }: { title: string; subtitle: string }) {
  return (
    <div>
      <h2 className="text-lg font-bold">{title}</h2>
      <p className="mt-1 text-sm text-heritage-text-secondary">{subtitle}</p>
    </div>
  );
}

function StatCard({
  label,
  value,
  icon: Icon,
}: {
  label: string;
  value: string;
  icon: typeof Box;
}) {
  return (
    <div className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
      <div className="flex items-center justify-between">
        <p className="text-sm font-semibold text-heritage-text-secondary">
          {label}
        </p>
        <Icon className="text-primary" size={22} />
      </div>
      <p className="mt-3 text-4xl font-bold">{value}</p>
    </div>
  );
}

function QuickActionCard({
  title,
  icon: Icon,
  color,
  onClick,
}: {
  title: string;
  icon: typeof Box;
  color: string;
  onClick: () => void;
}) {
  return (
    <button
      onClick={onClick}
      className="group rounded-2xl border border-heritage-outline/10 bg-heritage-surface-variant p-5 text-left transition hover:-translate-y-0.5 hover:bg-white hover:shadow-md"
      type="button"
    >
      <div
        className={`flex h-12 w-12 items-center justify-center rounded-2xl bg-white ${color} shadow-sm`}
      >
        <Icon size={22} />
      </div>
      <p className="mt-4 text-sm font-bold">{title}</p>
      <p className="mt-1 text-xs text-heritage-text-secondary">
        Open {title.toLowerCase()} flow
      </p>
    </button>
  );
}

function ObjectRow({ object }: { object: ConservationObject }) {
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-heritage-surface-variant p-3">
      <ObjectThumb objectType={object.objectType} />
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold">{object.title}</p>
        <p className="truncate text-xs text-heritage-text-secondary">
          {object.objectType}
          {object.inventoryNumber ? ` - ${object.inventoryNumber}` : ""}
        </p>
      </div>
      <p className="hidden text-xs font-medium text-heritage-text-secondary sm:block">
        {object.updatedAt}
      </p>
    </div>
  );
}

function ObjectCard({ object }: { object: ConservationObject }) {
  return (
    <article className="rounded-3xl border border-heritage-outline/10 bg-heritage-surface-variant p-4">
      <div className="flex gap-4">
        <ObjectThumb objectType={object.objectType} large />
        <div className="min-w-0 flex-1">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <h2 className="font-semibold">{object.title}</h2>
              <p className="mt-1 text-sm text-heritage-text-secondary">
                {object.objectType}
                {object.inventoryNumber ? ` - ${object.inventoryNumber}` : ""}
              </p>
            </div>
            <ConditionBadge label="Documented" />
          </div>
          <div className="mt-4 grid gap-3 text-sm sm:grid-cols-2">
            <MetaBlock label="Owner" value={object.ownerName || "Not set"} />
            <MetaBlock
              label="Location"
              value={object.locationDescription || "Not set"}
            />
            <MetaBlock
              label="Materials"
              value={object.materials.length ? object.materials.join(", ") : "Not set"}
            />
            <MetaBlock label="Dimensions" value={formatDimensions(object)} />
          </div>
        </div>
      </div>
    </article>
  );
}

function EntityTable({
  title,
  subtitle,
  columns,
  rows,
  icon: Icon,
}: {
  title: string;
  subtitle: string;
  columns: string[];
  rows: string[][];
  icon: typeof Box;
}) {
  return (
    <div className="space-y-6">
      <PageHeader title={title} subtitle={subtitle} />
      <section className="overflow-hidden rounded-3xl border border-heritage-outline/10 bg-white shadow-sm">
        <div className="flex items-center gap-3 border-b border-heritage-outline/10 p-5">
          <div className="flex h-11 w-11 items-center justify-center rounded-2xl bg-primary-50 text-primary">
            <Icon size={22} />
          </div>
          <div>
            <h2 className="font-semibold">{title}</h2>
            <p className="text-sm text-heritage-text-secondary">
              {rows.length} records
            </p>
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full min-w-[720px] text-left text-sm">
            <thead className="bg-heritage-surface-variant text-xs uppercase tracking-wide text-heritage-text-secondary">
              <tr>
                {columns.map((column) => (
                  <th key={column} className="px-5 py-3 font-semibold">
                    {column}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody className="divide-y divide-heritage-outline/10">
              {rows.map((row) => (
                <tr key={row.join("-")} className="hover:bg-primary-50/40">
                  {row.map((cell, index) => (
                    <td
                      key={`${cell}-${index}`}
                      className="px-5 py-4 text-heritage-text-secondary first:font-semibold first:text-heritage-text"
                    >
                      {cell}
                    </td>
                  ))}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function FormSection({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section className="space-y-4 rounded-3xl bg-heritage-surface-variant p-4">
      <h3 className="text-sm font-bold">{title}</h3>
      {children}
    </section>
  );
}

function TextField({
  label,
  value,
  onChange,
  placeholder,
  required,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  required?: boolean;
}) {
  return (
    <label className="space-y-2 text-sm font-medium">
      <span>{label}</span>
      <input
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3 outline-none focus:border-primary"
        placeholder={placeholder}
        required={required}
      />
    </label>
  );
}

function ObjectThumb({
  objectType,
  large = false,
}: {
  objectType: ObjectType;
  large?: boolean;
}) {
  return (
    <div
      className={`flex shrink-0 items-center justify-center rounded-2xl bg-white text-primary shadow-sm ${
        large ? "h-16 w-16" : "h-12 w-12"
      }`}
    >
      <Box size={large ? 26 : 20} />
      <span className="sr-only">{objectType}</span>
    </div>
  );
}

function MetaBlock({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <p className="text-xs font-semibold uppercase tracking-wide text-heritage-text-secondary">
        {label}
      </p>
      <p className="mt-1 line-clamp-2 text-sm">{value}</p>
    </div>
  );
}

function ConditionBadge({ label }: { label: string }) {
  return (
    <span className="inline-flex items-center gap-1.5 rounded-full bg-condition-good/10 px-3 py-1 text-xs font-semibold text-condition-good">
      <CheckCircle2 size={14} />
      {label}
    </span>
  );
}

function StatusPill({ label }: { label: string }) {
  return (
    <div className="flex items-center gap-2 rounded-full bg-white/10 px-3 py-2">
      <ShieldCheck size={15} />
      {label}
    </div>
  );
}

function labelForSection(section: WebSection) {
  return navItems.find((item) => item.section === section)?.label ?? "Dashboard";
}

function formatDimensions(object: ConservationObject) {
  const values = [
    object.dimensions.height,
    object.dimensions.width,
    object.dimensions.depth,
  ].filter(Boolean);

  if (!values.length) {
    return "Not set";
  }

  return `${values.join(" x ")} ${object.dimensions.unit}`;
}
