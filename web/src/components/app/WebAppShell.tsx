"use client";

import { FormEvent, useEffect, useMemo, useState } from "react";
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
  Trash2,
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

type ConditionRating = "Excellent" | "Good" | "Fair" | "Poor" | "Critical";
type ProjectStatus =
  | "Inquiry"
  | "Quoted"
  | "Approved"
  | "In progress"
  | "On hold"
  | "Completed"
  | "Archived";

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

type Client = {
  id: string;
  name: string;
  type: string;
  contactPerson: string;
  email: string;
  phone: string;
  address: string;
  notes: string;
  createdAt: string;
  updatedAt: string;
};

type Project = {
  id: string;
  title: string;
  clientId: string;
  objectIds: string[];
  status: ProjectStatus;
  startDate: string;
  endDate: string;
  description: string;
  budget: string;
  currency: string;
  createdAt: string;
  updatedAt: string;
};

type Report = {
  id: string;
  objectId: string;
  reportType: string;
  condition: ConditionRating;
  examiner: string;
  examinationDate: string;
  notes: string;
  recommendations: string;
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

type ClientFormState = Omit<Client, "id" | "createdAt" | "updatedAt">;
type ProjectFormState = Omit<Project, "id" | "createdAt" | "updatedAt">;
type ReportFormState = Omit<Report, "id" | "createdAt" | "updatedAt">;
type ModalKind = "object" | "client" | "project" | "report";

type AuthMode = "login" | "register";

type SyncAccount = {
  token: string;
  email: string;
  displayName: string;
};

type ApiObject = {
  id: string;
  title: string;
  objectType: string;
  materials: string[];
  height?: number | null;
  width?: number | null;
  depth?: number | null;
  measurementUnit?: string | null;
  ownerName?: string | null;
  locationDescription?: string | null;
  inventoryNumber?: string | null;
  description?: string | null;
  imageIds: string[];
  createdAt: string;
  updatedAt: string;
};

type ApiClient = {
  id: string;
  name: string;
  type: string;
  contactPerson?: string | null;
  email?: string | null;
  phone?: string | null;
  address?: string | null;
  notes?: string | null;
  createdAt: string;
  updatedAt: string;
};

type ApiProject = {
  id: string;
  title: string;
  clientId?: string | null;
  objectIds: string[];
  status: string;
  startDate?: string | null;
  endDate?: string | null;
  description?: string | null;
  totalBudget?: number | null;
  currency?: string | null;
  createdAt: string;
  updatedAt: string;
};

type ApiReport = {
  id: string;
  objectId: string;
  reportType: string;
  overallCondition: string;
  examiner: string;
  examinationDate: string;
  notes?: string | null;
  recommendations?: string | null;
  imageIds?: string[];
  createdAt: string;
  updatedAt: string;
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

const conditionRatings: ConditionRating[] = [
  "Excellent",
  "Good",
  "Fair",
  "Poor",
  "Critical",
];

const projectStatuses: ProjectStatus[] = [
  "Inquiry",
  "Quoted",
  "Approved",
  "In progress",
  "On hold",
  "Completed",
  "Archived",
];

const reportTypes = [
  "Initial assessment",
  "Pre-treatment",
  "Post-treatment",
  "Loan outgoing",
  "Loan incoming",
  "Insurance",
  "Transport",
  "Periodic check",
  "Emergency",
];

const clientTypes = [
  "Private collector",
  "Museum",
  "Gallery",
  "Church",
  "Monastery",
  "Municipality",
  "Archaeological service",
  "University",
  "Foundation",
  "Architect",
  "Insurance company",
  "Other",
];

const emptyObjectForm: ObjectFormState = {
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

const emptyClientForm: ClientFormState = {
  name: "",
  type: "Private collector",
  contactPerson: "",
  email: "",
  phone: "",
  address: "",
  notes: "",
};

const emptyProjectForm: ProjectFormState = {
  title: "",
  clientId: "",
  objectIds: [],
  status: "Inquiry",
  startDate: "",
  endDate: "",
  description: "",
  budget: "",
  currency: "EUR",
};

const emptyReportForm: ReportFormState = {
  objectId: "",
  reportType: "Initial assessment",
  condition: "Fair",
  examiner: "",
  examinationDate: "",
  notes: "",
  recommendations: "",
  imageNames: [],
};

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

const seedClients: Client[] = [
  {
    id: "client-1",
    name: "Agios Nikolaos Church",
    type: "Church",
    contactPerson: "Fr. Dimitrios",
    email: "office@example.org",
    phone: "",
    address: "Athens",
    notes: "Primary contact for icon survey work.",
    createdAt: "2026-05-18",
    updatedAt: "2026-06-01",
  },
  {
    id: "client-2",
    name: "Municipal Collection",
    type: "Municipality",
    contactPerson: "Eleni Markou",
    email: "",
    phone: "",
    address: "Gallery 2",
    notes: "",
    createdAt: "2026-05-12",
    updatedAt: "2026-05-28",
  },
];

const seedProjects: Project[] = [
  {
    id: "project-1",
    title: "Byzantine icon survey",
    clientId: "client-1",
    objectIds: ["obj-1"],
    status: "In progress",
    startDate: "2026-05-18",
    endDate: "",
    description: "Initial documentation and condition review for panel icons.",
    budget: "1200",
    currency: "EUR",
    createdAt: "2026-05-18",
    updatedAt: "2026-06-01",
  },
  {
    id: "project-2",
    title: "Municipal metalwork review",
    clientId: "client-2",
    objectIds: ["obj-2"],
    status: "Approved",
    startDate: "2026-05-12",
    endDate: "",
    description: "Condition checks for bronze and iron objects before storage.",
    budget: "900",
    currency: "EUR",
    createdAt: "2026-05-12",
    updatedAt: "2026-05-28",
  },
];

const seedReports: Report[] = [
  {
    id: "report-1",
    objectId: "obj-1",
    reportType: "Initial assessment",
    condition: "Fair",
    examiner: "Petros Dhespollari",
    examinationDate: "2026-06-01",
    notes: "Surface grime and localized paint instability observed.",
    recommendations: "Stabilize flakes before cleaning tests.",
    imageNames: ["front-detail.jpg"],
    createdAt: "2026-06-01",
    updatedAt: "2026-06-01",
  },
  {
    id: "report-2",
    objectId: "obj-2",
    reportType: "Periodic check",
    condition: "Good",
    examiner: "Petros Dhespollari",
    examinationDate: "2026-05-28",
    notes: "Stable surface deposits. No active corrosion confirmed.",
    recommendations: "Keep humidity stable and recheck in six months.",
    imageNames: ["lamp-overview.jpg"],
    createdAt: "2026-05-28",
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

const API_BASE_URL = "https://conservatio-api.peterdsp.dev";

const defaultSyncAccount: SyncAccount = {
  token: "",
  email: "",
  displayName: "",
};

function today() {
  return new Date().toISOString().slice(0, 10);
}

function createId(prefix: string) {
  if (typeof crypto !== "undefined" && "randomUUID" in crypto) {
    return `${prefix}-${crypto.randomUUID()}`;
  }

  return `${prefix}-${Date.now()}`;
}

function usePersistentState<T>(key: string, fallback: T) {
  const [value, setValue] = useState<T>(fallback);

  useEffect(() => {
    const rawValue = window.localStorage.getItem(key);
    if (!rawValue) {
      return;
    }

    try {
      setValue(JSON.parse(rawValue) as T);
    } catch {
      window.localStorage.removeItem(key);
    }
  }, [key]);

  useEffect(() => {
    window.localStorage.setItem(key, JSON.stringify(value));
  }, [key, value]);

  return [value, setValue] as const;
}

export function WebAppShell() {
  const [activeSection, setActiveSection] = useState<WebSection>("dashboard");
  const [collapsed, setCollapsed] = useState(false);
  const [modal, setModal] = useState<ModalKind | null>(null);
  const [objects, setObjects] = usePersistentState(
    "conservatio.objects",
    seedObjects,
  );
  const [clients, setClients] = usePersistentState(
    "conservatio.clients",
    seedClients,
  );
  const [projects, setProjects] = usePersistentState(
    "conservatio.projects",
    seedProjects,
  );
  const [reports, setReports] = usePersistentState(
    "conservatio.reports",
    seedReports,
  );
  const [syncAccount, setSyncAccount] = usePersistentState(
    "conservatio.syncAccount",
    defaultSyncAccount,
  );
  const [syncStatus, setSyncStatus] = useState(
    syncAccount.token ? "Signed in" : "Offline local mode",
  );
  const [query, setQuery] = useState("");
  const [passedLogin, setPassedLogin] = usePersistentState(
    "conservatio.passedLogin",
    false,
  );

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

  useEffect(() => {
    if (!syncAccount.token) {
      return;
    }

    void refreshFromServer(syncAccount);
    // Refresh persisted sessions only when the saved token changes.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [syncAccount.token]);

  async function apiRequest<T>(
    path: string,
    options: RequestInit = {},
    account = syncAccount,
  ): Promise<T> {
    const response = await fetch(`${API_BASE_URL}${path}`, {
      ...options,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${account.token}`,
        ...options.headers,
      },
    });

    if (!response.ok) {
      throw new Error(`API ${response.status}`);
    }

    if (response.status === 204) {
      return undefined as T;
    }

    return (await response.json()) as T;
  }

  async function refreshFromServer(account = syncAccount) {
    if (!account.token) {
      return;
    }

    try {
      setSyncStatus("Syncing with server");
      const [remoteObjects, remoteClients, remoteProjects, remoteReports] =
        await Promise.all([
          apiRequest<ApiObject[]>("/api/objects", {}, account),
          apiRequest<ApiClient[]>("/api/clients", {}, account),
          apiRequest<ApiProject[]>("/api/projects", {}, account),
          apiRequest<ApiReport[]>("/api/reports", {}, account),
        ]);

      setObjects(remoteObjects.map(fromApiObject));
      setClients(remoteClients.map(fromApiClient));
      setProjects(remoteProjects.map(fromApiProject));
      setReports(remoteReports.map(fromApiReport));
      setSyncStatus(`Synced ${new Date().toLocaleTimeString()}`);
    } catch {
      setSyncStatus("Sync failed, using local data");
    }
  }

  async function signIn(
    email: string,
    password: string,
    displayName: string,
    mode: AuthMode,
  ): Promise<string | null> {
    try {
      setSyncStatus("Signing in");
      const path = mode === "login" ? "/api/auth/login" : "/api/auth/register";
      const body =
        mode === "login"
          ? { email, password }
          : { email, password, displayName: displayName || email.split("@")[0] || email };
      const response = await fetch(`${API_BASE_URL}${path}`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });

      if (!response.ok) {
        const status = response.status;
        if (status === 401) return "Invalid email or password.";
        if (status === 409) return "An account with this email already exists.";
        return `Authentication failed (${status}).`;
      }

      const auth = (await response.json()) as {
        token: string;
        email: string;
        displayName: string;
      };
      const account: SyncAccount = {
        token: auth.token,
        email: auth.email,
        displayName: auth.displayName,
      };
      setSyncAccount(account);
      await refreshFromServer(account);
      return null;
    } catch {
      setSyncStatus("Sign in failed");
      return "Could not connect. Check your network or try again.";
    }
  }

  function signOut() {
    setSyncAccount(defaultSyncAccount);
    setSyncStatus("Offline local mode");
    setPassedLogin(false);
  }

  async function createObject(form: ObjectFormState) {
    const timestamp = today();
    const materials = form.materialsText
      .split(",")
      .map((material) => material.trim())
      .filter(Boolean);
    const object: ConservationObject = {
      id: createId("obj"),
      title: form.title.trim(),
      objectType: form.objectType,
      materials,
      ownerName: form.ownerName.trim(),
      locationDescription: form.locationDescription.trim(),
      inventoryNumber: form.inventoryNumber.trim(),
      description: form.description.trim(),
      dimensions: {
        height: form.height.trim(),
        width: form.width.trim(),
        depth: form.depth.trim(),
        unit: form.unit,
      },
      imageNames: form.imageNames,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    if (syncAccount.token) {
      try {
        const remote = await apiRequest<ApiObject>("/api/objects", {
          method: "POST",
          body: JSON.stringify(toApiObjectRequest(object)),
        });
        setObjects((current) => [fromApiObject(remote), ...current]);
        setSyncStatus("Object synced");
      } catch {
        setObjects((current) => [object, ...current]);
        setSyncStatus("Object saved locally, sync failed");
      }
    } else {
      setObjects((current) => [object, ...current]);
    }
    setActiveSection("objects");
    setModal(null);
  }

  async function createClient(form: ClientFormState) {
    const timestamp = today();
    const client: Client = {
      ...form,
      id: createId("client"),
      name: form.name.trim(),
      contactPerson: form.contactPerson.trim(),
      email: form.email.trim(),
      phone: form.phone.trim(),
      address: form.address.trim(),
      notes: form.notes.trim(),
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    if (syncAccount.token) {
      try {
        const remote = await apiRequest<ApiClient>("/api/clients", {
          method: "POST",
          body: JSON.stringify(toApiClientRequest(client)),
        });
        setClients((current) => [fromApiClient(remote), ...current]);
        setSyncStatus("Client synced");
      } catch {
        setClients((current) => [client, ...current]);
        setSyncStatus("Client saved locally, sync failed");
      }
    } else {
      setClients((current) => [client, ...current]);
    }
    setActiveSection("clients");
    setModal(null);
  }

  async function createProject(form: ProjectFormState) {
    const timestamp = today();
    const project: Project = {
      ...form,
      id: createId("project"),
      title: form.title.trim(),
      description: form.description.trim(),
      budget: form.budget.trim(),
      currency: form.currency.trim() || "EUR",
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    if (syncAccount.token) {
      try {
        const remote = await apiRequest<ApiProject>("/api/projects", {
          method: "POST",
          body: JSON.stringify(toApiProjectRequest(project)),
        });
        setProjects((current) => [fromApiProject(remote), ...current]);
        setSyncStatus("Project synced");
      } catch {
        setProjects((current) => [project, ...current]);
        setSyncStatus("Project saved locally, sync failed");
      }
    } else {
      setProjects((current) => [project, ...current]);
    }
    setActiveSection("projects");
    setModal(null);
  }

  async function createReport(form: ReportFormState) {
    const timestamp = today();
    const report: Report = {
      ...form,
      id: createId("report"),
      examiner: form.examiner.trim(),
      notes: form.notes.trim(),
      recommendations: form.recommendations.trim(),
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    if (syncAccount.token) {
      try {
        await apiRequest<{ id: string }>("/api/reports", {
          method: "POST",
          body: JSON.stringify(toApiReportRequest(report)),
        });
        await refreshFromServer();
        setSyncStatus("Report synced");
      } catch {
        setReports((current) => [report, ...current]);
        setSyncStatus("Report saved locally, sync failed");
      }
    } else {
      setReports((current) => [report, ...current]);
    }
    setActiveSection("reports");
    setModal(null);
  }

  async function deleteObject(id: string) {
    if (syncAccount.token) {
      void apiRequest(`/api/objects/${id}`, { method: "DELETE" });
    }
    setObjects((current) => current.filter((object) => object.id !== id));
    setProjects((current) =>
      current.map((project) => ({
        ...project,
        objectIds: project.objectIds.filter((objectId) => objectId !== id),
      })),
    );
    setReports((current) => current.filter((report) => report.objectId !== id));
  }

  function deleteClient(id: string) {
    if (syncAccount.token) {
      void apiRequest(`/api/clients/${id}`, { method: "DELETE" });
    }
    setClients((current) => current.filter((client) => client.id !== id));
    setProjects((current) =>
      current.map((project) =>
        project.clientId === id ? { ...project, clientId: "" } : project,
      ),
    );
  }

  function deleteProject(id: string) {
    if (syncAccount.token) {
      void apiRequest(`/api/projects/${id}`, { method: "DELETE" });
    }
    setProjects((current) => current.filter((project) => project.id !== id));
  }

  function deleteReport(id: string) {
    if (syncAccount.token) {
      void apiRequest(`/api/reports/${id}`, { method: "DELETE" });
    }
    setReports((current) => current.filter((report) => report.id !== id));
  }

  function resetDemoData() {
    setObjects(seedObjects);
    setClients(seedClients);
    setProjects(seedProjects);
    setReports(seedReports);
    setActiveSection("dashboard");
  }

  const showLogin = !passedLogin && !syncAccount.token;

  if (showLogin) {
    return (
      <LoginScreen
        onSignIn={async (email, password, displayName, mode) => {
          const error = await signIn(email, password, displayName, mode);
          if (!error) setPassedLogin(true);
          return error;
        }}
        onContinueOffline={() => setPassedLogin(true)}
      />
    );
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
            onCreateObject={() => setModal("object")}
            onNavigate={setActiveSection}
          />
          <div className="mx-auto w-full max-w-7xl px-4 py-6 sm:px-6 lg:px-8 lg:py-8">
            {activeSection === "dashboard" && (
              <DashboardView
                objects={objects}
                clients={clients}
                projects={projects}
                reports={reports}
                syncStatus={syncStatus}
                onCreate={setModal}
                onNavigate={setActiveSection}
              />
            )}
            {activeSection === "objects" && (
              <ObjectsView
                objects={filteredObjects}
                query={query}
                onQueryChange={setQuery}
                onCreateObject={() => setModal("object")}
                onDeleteObject={deleteObject}
              />
            )}
            {activeSection === "projects" && (
              <ProjectsView
                projects={projects}
                clients={clients}
                objects={objects}
                onCreateProject={() => setModal("project")}
                onDeleteProject={deleteProject}
              />
            )}
            {activeSection === "clients" && (
              <ClientsView
                clients={clients}
                projects={projects}
                onCreateClient={() => setModal("client")}
                onDeleteClient={deleteClient}
              />
            )}
            {activeSection === "reports" && (
              <ReportsView
                reports={reports}
                objects={objects}
                onCreateReport={() => setModal("report")}
                onDeleteReport={deleteReport}
              />
            )}
            {activeSection === "settings" && (
              <SettingsView
                syncAccount={syncAccount}
                syncStatus={syncStatus}
                onResetDemoData={resetDemoData}
                onRefresh={() => refreshFromServer()}
                onSignOut={signOut}
              />
            )}
          </div>
        </main>
      </div>

      {modal === "object" && (
        <CreateObjectModal
          onClose={() => setModal(null)}
          onSave={createObject}
        />
      )}
      {modal === "client" && (
        <CreateClientModal
          onClose={() => setModal(null)}
          onSave={createClient}
        />
      )}
      {modal === "project" && (
        <CreateProjectModal
          clients={clients}
          objects={objects}
          onClose={() => setModal(null)}
          onSave={createProject}
        />
      )}
      {modal === "report" && (
        <CreateReportModal
          objects={objects}
          onClose={() => setModal(null)}
          onSave={createReport}
        />
      )}
    </div>
  );
}

function LoginScreen({
  onSignIn,
  onContinueOffline,
}: {
  onSignIn: (
    email: string,
    password: string,
    displayName: string,
    mode: AuthMode,
  ) => Promise<string | null>;
  onContinueOffline: () => void;
}) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [isRegistering, setIsRegistering] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!email.trim() || !password.trim()) return;
    setIsLoading(true);
    setError(null);
    const result = await onSignIn(
      email.trim(),
      password,
      displayName.trim(),
      isRegistering ? "register" : "login",
    );
    if (result) setError(result);
    setIsLoading(false);
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-heritage-bg text-heritage-text">
      <div className="fixed inset-0 -z-10 bg-[radial-gradient(circle_at_top_left,#fff0e8_0,#faf7f4_32%,#f2eeea_100%)]" />
      <div className="w-full max-w-md px-6">
        <div className="flex flex-col items-center">
          <div className="flex h-24 w-24 items-center justify-center rounded-3xl bg-primary-50">
            <ShieldCheck className="text-primary" size={44} />
          </div>
          <h1 className="mt-5 text-3xl font-bold text-primary">Conservatio</h1>
          <p className="mt-2 text-sm text-heritage-text-secondary">
            Document heritage. Protect history.
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-10 space-y-3">
          {isRegistering && (
            <input
              value={displayName}
              onChange={(event) => setDisplayName(event.target.value)}
              className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3.5 text-sm outline-none transition focus:border-primary"
              placeholder="Full Name"
              type="text"
              autoComplete="name"
            />
          )}
          <input
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3.5 text-sm outline-none transition focus:border-primary"
            placeholder="Email"
            type="email"
            autoComplete="email"
            required
          />
          <input
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3.5 text-sm outline-none transition focus:border-primary"
            placeholder="Password"
            type="password"
            autoComplete={isRegistering ? "new-password" : "current-password"}
            required
          />

          {error && (
            <p className="text-center text-xs text-red-600">{error}</p>
          )}

          <button
            className="w-full rounded-2xl bg-primary px-4 py-3.5 text-sm font-semibold text-white transition hover:bg-primary-dark disabled:cursor-not-allowed disabled:opacity-40"
            disabled={!email.trim() || !password.trim() || isLoading}
            type="submit"
          >
            {isLoading
              ? "Signing in..."
              : isRegistering
                ? "Create Account"
                : "Sign In"}
          </button>

          <div className="text-center">
            <button
              onClick={() => {
                setIsRegistering((v) => !v);
                setError(null);
              }}
              className="text-xs font-medium text-primary hover:underline"
              type="button"
            >
              {isRegistering
                ? "Already have an account? Sign In"
                : "New here? Create Account"}
            </button>
          </div>
        </form>

        <div className="mt-8 flex items-center gap-3">
          <div className="h-px flex-1 bg-heritage-outline/20" />
          <span className="text-xs text-heritage-text-secondary">or</span>
          <div className="h-px flex-1 bg-heritage-outline/20" />
        </div>

        <div className="mt-6 text-center">
          <button
            onClick={onContinueOffline}
            className="text-sm text-heritage-text-secondary transition hover:text-heritage-text"
            type="button"
          >
            Continue Offline
          </button>
          <p className="mt-2 text-xs text-heritage-text-secondary">
            Data will be saved locally in this browser only.
          </p>
        </div>

        <p className="mt-10 text-center text-xs text-heritage-text-secondary">
          v0.1.0
        </p>
      </div>
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
            <p className="text-base font-bold text-primary">
              Conservatio Web App
            </p>
            <p className="text-xs text-heritage-text-secondary">
              {labelForSection(activeSection)}
            </p>
          </div>
        </div>
        <div className="hidden flex-1 lg:block">
          <div className="flex items-center gap-3">
            <p className="text-sm font-medium text-heritage-text-secondary">
              {labelForSection(activeSection)}
            </p>
            <span className="rounded-full bg-primary-50 px-3 py-1 text-xs font-bold uppercase tracking-wide text-primary">
              Web App
            </span>
          </div>
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
  clients,
  projects,
  reports,
  syncStatus,
  onCreate,
  onNavigate,
}: {
  objects: ConservationObject[];
  clients: Client[];
  projects: Project[];
  reports: Report[];
  syncStatus: string;
  onCreate: (kind: ModalKind) => void;
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
                Conservatio Web App
              </h1>
              <p className="mt-3 max-w-2xl text-base leading-7 text-heritage-text-secondary">
                The same conservation workflow from iOS and Android, expanded
                for desktop screens with wider lists, panels, and creation
                forms. Data is saved in this browser.
              </p>
            </div>
            <button
              onClick={() => onCreate("object")}
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
                Storage status
              </p>
              <h2 className="mt-2 text-2xl font-bold">{syncStatus}</h2>
            </div>
            <Cloud className="text-secondary-200" size={28} />
          </div>
          <p className="mt-4 text-sm leading-6 text-secondary-100">
            Objects, clients, projects, and reports persist with local browser
            storage until backend sync is connected.
          </p>
          <div className="mt-6 grid grid-cols-2 gap-3 text-sm">
            <StatusPill label="Local save" />
            <StatusPill label="Ready for sync" />
          </div>
        </section>
      </div>

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label="Objects" value={`${objects.length}`} icon={Box} />
        <StatCard label="Reports" value={`${reports.length}`} icon={FileText} />
        <StatCard
          label="Projects"
          value={`${projects.length}`}
          icon={FolderKanban}
        />
        <StatCard label="Clients" value={`${clients.length}`} icon={Users} />
      </section>

      <div className="grid gap-6 xl:grid-cols-[0.95fr_1.45fr]">
        <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm lg:p-6">
          <SectionTitle
            title="Quick Actions"
            subtitle="Create real records that stay available after refresh."
          />
          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            <QuickActionCard
              title="New Object"
              icon={Box}
              color="text-primary"
              onClick={() => onCreate("object")}
            />
            <QuickActionCard
              title="Take Photo"
              icon={Camera}
              color="text-secondary"
              onClick={() => onCreate("object")}
            />
            <QuickActionCard
              title="New Report"
              icon={FileText}
              color="text-tertiary"
              onClick={() => onCreate("report")}
            />
            <QuickActionCard
              title="New Project"
              icon={FolderKanban}
              color="text-primary-dark"
              onClick={() => onCreate("project")}
            />
          </div>
        </section>

        <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm lg:p-6">
          <div className="flex items-start justify-between gap-4">
            <SectionTitle
              title="Recent Objects"
              subtitle="Newest object records with inventory metadata."
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
  onDeleteObject,
}: {
  objects: ConservationObject[];
  query: string;
  onQueryChange: (query: string) => void;
  onCreateObject: () => void;
  onDeleteObject: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Objects"
        subtitle="Search, create, and delete conservation objects using the same fields as the mobile apps."
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
            <ObjectCard
              key={object.id}
              object={object}
              onDelete={() => onDeleteObject(object.id)}
            />
          ))}
        </div>
      </section>
    </div>
  );
}

function ProjectsView({
  projects,
  clients,
  objects,
  onCreateProject,
  onDeleteProject,
}: {
  projects: Project[];
  clients: Client[];
  objects: ConservationObject[];
  onCreateProject: () => void;
  onDeleteProject: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Projects"
        subtitle="Track conservation work by client, status, timeline, budget, and linked objects."
        actionLabel="New Project"
        onAction={onCreateProject}
      />
      <div className="grid gap-3 xl:grid-cols-2">
        {projects.map((project) => (
          <RecordCard
            key={project.id}
            icon={FolderKanban}
            title={project.title}
            badge={project.status}
            onDelete={() => onDeleteProject(project.id)}
            rows={[
              ["Client", clientName(clients, project.clientId)],
              ["Objects", objectNames(objects, project.objectIds)],
              ["Dates", formatDateRange(project.startDate, project.endDate)],
              ["Budget", project.budget ? `${project.budget} ${project.currency}` : "Not set"],
              ["Description", project.description || "Not set"],
            ]}
          />
        ))}
      </div>
    </div>
  );
}

function ClientsView({
  clients,
  projects,
  onCreateClient,
  onDeleteClient,
}: {
  clients: Client[];
  projects: Project[];
  onCreateClient: () => void;
  onDeleteClient: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Clients"
        subtitle="Manage churches, museums, galleries, collectors, and other conservation clients."
        actionLabel="New Client"
        onAction={onCreateClient}
      />
      <div className="grid gap-3 xl:grid-cols-2">
        {clients.map((client) => (
          <RecordCard
            key={client.id}
            icon={Users}
            title={client.name}
            badge={client.type}
            onDelete={() => onDeleteClient(client.id)}
            rows={[
              ["Contact", client.contactPerson || "Not set"],
              ["Email", client.email || "Not set"],
              ["Phone", client.phone || "Not set"],
              ["Address", client.address || "Not set"],
              [
                "Projects",
                `${projects.filter((project) => project.clientId === client.id).length}`,
              ],
              ["Notes", client.notes || "Not set"],
            ]}
          />
        ))}
      </div>
    </div>
  );
}

function ReportsView({
  reports,
  objects,
  onCreateReport,
  onDeleteReport,
}: {
  reports: Report[];
  objects: ConservationObject[];
  onCreateReport: () => void;
  onDeleteReport: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title="Reports"
        subtitle="Create condition reports linked to real object records."
        actionLabel="New Report"
        onAction={onCreateReport}
      />
      <div className="grid gap-3 xl:grid-cols-2">
        {reports.map((report) => (
          <RecordCard
            key={report.id}
            icon={FileText}
            title={report.reportType}
            badge={report.condition}
            onDelete={() => onDeleteReport(report.id)}
            rows={[
              ["Object", objectName(objects, report.objectId)],
              ["Examiner", report.examiner || "Not set"],
              ["Date", report.examinationDate || "Not set"],
              ["Notes", report.notes || "Not set"],
              ["Recommendations", report.recommendations || "Not set"],
              [
                "Photos",
                report.imageNames.length
                  ? report.imageNames.join(", ")
                  : "No photos attached",
              ],
            ]}
          />
        ))}
      </div>
    </div>
  );
}

function SettingsView({
  syncAccount,
  syncStatus,
  onResetDemoData,
  onRefresh,
  onSignOut,
}: {
  syncAccount: SyncAccount;
  syncStatus: string;
  onResetDemoData: () => void;
  onRefresh: () => void;
  onSignOut: () => void;
}) {
  const isSignedIn = !!syncAccount.token;
  const groups = [
    {
      title: "Account",
      items: [
        {
          label: "Profile",
          icon: Users,
          detail: isSignedIn ? syncAccount.displayName || syncAccount.email : "Offline",
        },
        { label: "Sync and Storage", icon: Cloud, detail: syncStatus },
      ],
    },
    {
      title: "Reports",
      items: [
        { label: "Templates", icon: FileText, detail: "Default template" },
        { label: "Export Settings", icon: Upload, detail: "PDF wiring pending" },
        { label: "Language", icon: Globe, detail: "English" },
      ],
    },
    {
      title: "App",
      items: [
        { label: "Appearance", icon: Palette, detail: "Conservatio theme" },
        { label: "Storage", icon: HardDrive, detail: isSignedIn ? "Cloud sync" : "localStorage" },
        { label: "About", icon: Info, detail: "v0.1.0" },
      ],
    },
  ];

  return (
    <div className="space-y-6">
      <PageHeader
        title="Settings"
        subtitle="Manage your account, preferences, and app configuration."
      />

      <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
        <div className="flex items-center gap-4">
          <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-primary-50 text-primary">
            <Users size={24} />
          </div>
          <div className="min-w-0 flex-1">
            <h2 className="font-semibold">
              {isSignedIn
                ? syncAccount.displayName || syncAccount.email
                : "Offline Mode"}
            </h2>
            <p className="text-sm text-heritage-text-secondary">
              {isSignedIn
                ? syncAccount.email
                : "Data is stored locally in this browser."}
            </p>
          </div>
          <div className="flex gap-3">
            {isSignedIn && (
              <button
                onClick={onRefresh}
                className="rounded-xl bg-heritage-surface-variant px-4 py-2.5 text-sm font-semibold text-heritage-text transition hover:bg-primary-50 hover:text-primary"
                type="button"
              >
                Sync Now
              </button>
            )}
            {isSignedIn && (
              <button
                onClick={onSignOut}
                className="rounded-xl bg-heritage-surface-variant px-4 py-2.5 text-sm font-semibold text-heritage-text transition hover:bg-red-50 hover:text-red-600"
                type="button"
              >
                Sign Out
              </button>
            )}
          </div>
        </div>
        {isSignedIn && (
          <p className="mt-3 text-xs text-heritage-text-secondary">
            {syncStatus}
          </p>
        )}
      </section>

      <div className="grid gap-4 lg:grid-cols-3">
        {groups.map((group) => (
          <section
            key={group.title}
            className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm"
          >
            <h2 className="text-base font-semibold">{group.title}</h2>
            <div className="mt-4 space-y-2">
              {group.items.map((item) => (
                <div
                  key={item.label}
                  className="flex w-full items-center justify-between rounded-2xl bg-heritage-surface-variant px-4 py-3 text-left"
                >
                  <span className="flex items-center gap-3 text-sm font-medium">
                    <item.icon size={18} />
                    {item.label}
                  </span>
                  <span className="text-xs text-heritage-text-secondary">
                    {item.detail}
                  </span>
                </div>
              ))}
            </div>
          </section>
        ))}
      </div>

      <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="font-semibold">Reset local data</h2>
            <p className="mt-1 text-sm text-heritage-text-secondary">
              Restores the browser demo records for objects, clients, projects,
              and reports.
            </p>
          </div>
          <button
            onClick={onResetDemoData}
            className="inline-flex items-center justify-center rounded-xl bg-heritage-surface-variant px-4 py-2.5 text-sm font-semibold text-heritage-text transition hover:bg-primary-50 hover:text-primary"
            type="button"
          >
            Reset Demo Data
          </button>
        </div>
      </section>
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
  const [form, setForm] = useState<ObjectFormState>(emptyObjectForm);

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
    <ModalFrame
      eyebrow="New Object"
      title="Create conservation object"
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.title.trim()}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title="Basic Information">
          <TextField
            label="Object title"
            value={form.title}
            onChange={(value) => update("title", value)}
            required
          />
          <SelectField
            label="Type"
            value={form.objectType}
            options={objectTypes}
            onChange={(value) => update("objectType", value as ObjectType)}
          />
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
          <PhotoInput
            imageNames={form.imageNames}
            onChange={(imageNames) => update("imageNames", imageNames)}
          />
        </FormSection>

        <FormSection title="Description">
          <TextAreaField
            label="Description"
            value={form.description}
            onChange={(value) => update("description", value)}
            placeholder="Condition context, handling notes, or acquisition details"
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function CreateClientModal({
  onClose,
  onSave,
}: {
  onClose: () => void;
  onSave: (form: ClientFormState) => void;
}) {
  const [form, setForm] = useState<ClientFormState>(emptyClientForm);

  function update<Key extends keyof ClientFormState>(
    key: Key,
    value: ClientFormState[Key],
  ) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!form.name.trim()) {
      return;
    }
    onSave(form);
  }

  return (
    <ModalFrame
      eyebrow="New Client"
      title="Create client"
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.name.trim()}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title="Client">
          <TextField
            label="Name"
            value={form.name}
            onChange={(value) => update("name", value)}
            required
          />
          <SelectField
            label="Type"
            value={form.type}
            options={clientTypes}
            onChange={(value) => update("type", value)}
          />
          <TextField
            label="Contact person"
            value={form.contactPerson}
            onChange={(value) => update("contactPerson", value)}
          />
        </FormSection>
        <FormSection title="Contact">
          <TextField
            label="Email"
            value={form.email}
            onChange={(value) => update("email", value)}
            type="email"
          />
          <TextField
            label="Phone"
            value={form.phone}
            onChange={(value) => update("phone", value)}
          />
          <TextField
            label="Address"
            value={form.address}
            onChange={(value) => update("address", value)}
          />
        </FormSection>
        <FormSection title="Notes">
          <TextAreaField
            label="Notes"
            value={form.notes}
            onChange={(value) => update("notes", value)}
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function CreateProjectModal({
  clients,
  objects,
  onClose,
  onSave,
}: {
  clients: Client[];
  objects: ConservationObject[];
  onClose: () => void;
  onSave: (form: ProjectFormState) => void;
}) {
  const [form, setForm] = useState<ProjectFormState>({
    ...emptyProjectForm,
    clientId: clients[0]?.id ?? "",
  });

  function update<Key extends keyof ProjectFormState>(
    key: Key,
    value: ProjectFormState[Key],
  ) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function toggleObject(objectId: string) {
    setForm((current) => ({
      ...current,
      objectIds: current.objectIds.includes(objectId)
        ? current.objectIds.filter((id) => id !== objectId)
        : [...current.objectIds, objectId],
    }));
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!form.title.trim()) {
      return;
    }
    onSave(form);
  }

  return (
    <ModalFrame
      eyebrow="New Project"
      title="Create project"
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.title.trim()}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title="Project">
          <TextField
            label="Title"
            value={form.title}
            onChange={(value) => update("title", value)}
            required
          />
          <SelectField
            label="Client"
            value={form.clientId}
            options={["", ...clients.map((client) => client.id)]}
            optionLabels={{ "": "No client", ...labelMap(clients) }}
            onChange={(value) => update("clientId", value)}
          />
          <SelectField
            label="Status"
            value={form.status}
            options={projectStatuses}
            onChange={(value) => update("status", value as ProjectStatus)}
          />
        </FormSection>
        <FormSection title="Timeline and Budget">
          <TextField
            label="Start date"
            value={form.startDate}
            onChange={(value) => update("startDate", value)}
            type="date"
          />
          <TextField
            label="End date"
            value={form.endDate}
            onChange={(value) => update("endDate", value)}
            type="date"
          />
          <div className="grid grid-cols-[1fr_96px] gap-3">
            <TextField
              label="Budget"
              value={form.budget}
              onChange={(value) => update("budget", value)}
            />
            <TextField
              label="Currency"
              value={form.currency}
              onChange={(value) => update("currency", value)}
            />
          </div>
        </FormSection>
        <FormSection title="Linked Objects">
          <div className="space-y-2">
            {objects.map((object) => (
              <label
                key={object.id}
                className="flex items-center gap-3 rounded-2xl bg-white px-4 py-3 text-sm"
              >
                <input
                  checked={form.objectIds.includes(object.id)}
                  onChange={() => toggleObject(object.id)}
                  type="checkbox"
                />
                <span>{object.title}</span>
              </label>
            ))}
          </div>
        </FormSection>
        <FormSection title="Description">
          <TextAreaField
            label="Description"
            value={form.description}
            onChange={(value) => update("description", value)}
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function CreateReportModal({
  objects,
  onClose,
  onSave,
}: {
  objects: ConservationObject[];
  onClose: () => void;
  onSave: (form: ReportFormState) => void;
}) {
  const [form, setForm] = useState<ReportFormState>({
    ...emptyReportForm,
    objectId: objects[0]?.id ?? "",
    examinationDate: today(),
  });

  function update<Key extends keyof ReportFormState>(
    key: Key,
    value: ReportFormState[Key],
  ) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!form.objectId) {
      return;
    }
    onSave(form);
  }

  return (
    <ModalFrame
      eyebrow="New Report"
      title="Create condition report"
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.objectId}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title="Report">
          <SelectField
            label="Object"
            value={form.objectId}
            options={objects.map((object) => object.id)}
            optionLabels={labelMap(objects)}
            onChange={(value) => update("objectId", value)}
          />
          <SelectField
            label="Report type"
            value={form.reportType}
            options={reportTypes}
            onChange={(value) => update("reportType", value)}
          />
          <SelectField
            label="Condition"
            value={form.condition}
            options={conditionRatings}
            onChange={(value) => update("condition", value as ConditionRating)}
          />
        </FormSection>
        <FormSection title="Examination">
          <TextField
            label="Examiner"
            value={form.examiner}
            onChange={(value) => update("examiner", value)}
          />
          <TextField
            label="Date"
            value={form.examinationDate}
            onChange={(value) => update("examinationDate", value)}
            type="date"
          />
          <PhotoInput
            imageNames={form.imageNames}
            onChange={(imageNames) => update("imageNames", imageNames)}
          />
        </FormSection>
        <FormSection title="Notes">
          <TextAreaField
            label="Notes"
            value={form.notes}
            onChange={(value) => update("notes", value)}
          />
        </FormSection>
        <FormSection title="Recommendations">
          <TextAreaField
            label="Recommendations"
            value={form.recommendations}
            onChange={(value) => update("recommendations", value)}
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function ModalFrame({
  eyebrow,
  title,
  children,
  submitDisabled,
  onClose,
  onSubmit,
}: {
  eyebrow: string;
  title: string;
  children: React.ReactNode;
  submitDisabled: boolean;
  onClose: () => void;
  onSubmit: (event: FormEvent<HTMLFormElement>) => void;
}) {
  return (
    <div className="fixed inset-0 z-40 flex items-center justify-center bg-heritage-text/35 p-4 backdrop-blur-sm">
      <form
        onSubmit={onSubmit}
        className="max-h-[92vh] w-full max-w-5xl overflow-hidden rounded-3xl bg-white shadow-2xl"
      >
        <div className="flex items-start justify-between gap-4 border-b border-heritage-outline/10 p-5 lg:p-6">
          <div>
            <p className="text-sm font-semibold uppercase tracking-[0.16em] text-primary">
              {eyebrow}
            </p>
            <h2 className="mt-1 text-2xl font-bold">{title}</h2>
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
          {children}
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
            disabled={submitDisabled}
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

function ObjectCard({
  object,
  onDelete,
}: {
  object: ConservationObject;
  onDelete: () => void;
}) {
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
            <div className="flex items-center gap-2">
              <ConditionBadge label="Documented" />
              <DeleteButton onDelete={onDelete} label="Delete object" />
            </div>
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
            <MetaBlock
              label="Photos"
              value={
                object.imageNames.length
                  ? object.imageNames.join(", ")
                  : "No photos attached"
              }
            />
            <MetaBlock
              label="Description"
              value={object.description || "Not set"}
            />
          </div>
        </div>
      </div>
    </article>
  );
}

function RecordCard({
  icon: Icon,
  title,
  badge,
  rows,
  onDelete,
}: {
  icon: typeof Box;
  title: string;
  badge: string;
  rows: Array<[string, string]>;
  onDelete: () => void;
}) {
  return (
    <article className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
      <div className="flex items-start justify-between gap-4">
        <div className="flex min-w-0 items-start gap-3">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-primary-50 text-primary">
            <Icon size={22} />
          </div>
          <div className="min-w-0">
            <h2 className="truncate font-semibold">{title}</h2>
            <p className="mt-1 text-xs font-semibold uppercase tracking-wide text-primary">
              {badge}
            </p>
          </div>
        </div>
        <DeleteButton onDelete={onDelete} label={`Delete ${title}`} />
      </div>
      <div className="mt-5 grid gap-3 text-sm sm:grid-cols-2">
        {rows.map(([label, value]) => (
          <MetaBlock key={label} label={label} value={value} />
        ))}
      </div>
    </article>
  );
}

function DeleteButton({
  label,
  onDelete,
}: {
  label: string;
  onDelete: () => void;
}) {
  return (
    <button
      onClick={onDelete}
      className="rounded-xl p-2 text-heritage-text-secondary transition hover:bg-primary-50 hover:text-primary"
      type="button"
      aria-label={label}
    >
      <Trash2 size={17} />
    </button>
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
  type = "text",
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
  required?: boolean;
  type?: string;
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
        type={type}
      />
    </label>
  );
}

function TextAreaField({
  label,
  value,
  onChange,
  placeholder,
}: {
  label: string;
  value: string;
  onChange: (value: string) => void;
  placeholder?: string;
}) {
  return (
    <label className="space-y-2 text-sm font-medium">
      <span>{label}</span>
      <textarea
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="min-h-32 w-full resize-y rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3 outline-none focus:border-primary"
        placeholder={placeholder}
      />
    </label>
  );
}

function SelectField({
  label,
  value,
  options,
  optionLabels,
  onChange,
}: {
  label: string;
  value: string;
  options: string[];
  optionLabels?: Record<string, string>;
  onChange: (value: string) => void;
}) {
  return (
    <label className="space-y-2 text-sm font-medium">
      <span>{label}</span>
      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3 outline-none focus:border-primary"
      >
        {options.map((option) => (
          <option key={option} value={option}>
            {optionLabels?.[option] ?? option}
          </option>
        ))}
      </select>
    </label>
  );
}

function PhotoInput({
  imageNames,
  onChange,
}: {
  imageNames: string[];
  onChange: (imageNames: string[]) => void;
}) {
  return (
    <>
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
            onChange(
              Array.from(event.target.files ?? []).map((file) => file.name),
            )
          }
        />
      </label>
      <p className="text-xs text-heritage-text-secondary">
        {imageNames.length} photo(s) attached
      </p>
    </>
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

function labelMap(records: Array<{ id: string; title?: string; name?: string }>) {
  return records.reduce<Record<string, string>>((labels, record) => {
    labels[record.id] = record.title ?? record.name ?? record.id;
    return labels;
  }, {});
}

function clientName(clients: Client[], clientId: string) {
  return clients.find((client) => client.id === clientId)?.name ?? "No client";
}

function objectName(objects: ConservationObject[], objectId: string) {
  return objects.find((object) => object.id === objectId)?.title ?? "Missing object";
}

function objectNames(objects: ConservationObject[], objectIds: string[]) {
  if (!objectIds.length) {
    return "No objects linked";
  }

  return objectIds.map((objectId) => objectName(objects, objectId)).join(", ");
}

function formatDateRange(startDate: string, endDate: string) {
  if (!startDate && !endDate) {
    return "Not set";
  }

  return [startDate || "No start", endDate || "No end"].join(" to ");
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

function toApiObjectType(type: ObjectType) {
  return type.toUpperCase().replaceAll(" ", "_");
}

function fromApiObjectType(type: string): ObjectType {
  const normalized = type
    .toLowerCase()
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
  const match = objectTypes.find(
    (objectType) => objectType.toLowerCase() === normalized.toLowerCase(),
  );

  return match ?? "Other";
}

function toApiCondition(condition: ConditionRating) {
  return condition.toUpperCase();
}

function fromApiCondition(condition: string): ConditionRating {
  const normalized =
    condition.charAt(0).toUpperCase() + condition.slice(1).toLowerCase();
  return conditionRatings.includes(normalized as ConditionRating)
    ? (normalized as ConditionRating)
    : "Fair";
}

function toApiObjectRequest(object: ConservationObject) {
  return {
    id: object.id,
    title: object.title,
    objectType: toApiObjectType(object.objectType),
    materials: object.materials,
    height: toNumber(object.dimensions.height),
    width: toNumber(object.dimensions.width),
    depth: toNumber(object.dimensions.depth),
    measurementUnit: object.dimensions.unit,
    ownerName: object.ownerName || null,
    locationDescription: object.locationDescription || null,
    inventoryNumber: object.inventoryNumber || null,
    description: object.description || null,
    imageIds: object.imageNames,
  };
}

function fromApiObject(object: ApiObject): ConservationObject {
  return {
    id: object.id,
    title: object.title,
    objectType: fromApiObjectType(object.objectType),
    materials: object.materials ?? [],
    ownerName: object.ownerName ?? "",
    locationDescription: object.locationDescription ?? "",
    inventoryNumber: object.inventoryNumber ?? "",
    description: object.description ?? "",
    dimensions: {
      height: object.height?.toString() ?? "",
      width: object.width?.toString() ?? "",
      depth: object.depth?.toString() ?? "",
      unit: toWebUnit(object.measurementUnit),
    },
    imageNames: object.imageIds ?? [],
    createdAt: object.createdAt.slice(0, 10),
    updatedAt: object.updatedAt.slice(0, 10),
  };
}

function toApiClientRequest(client: Client) {
  return {
    id: client.id,
    name: client.name,
    type: client.type,
    contactPerson: client.contactPerson || null,
    email: client.email || null,
    phone: client.phone || null,
    address: client.address || null,
    notes: client.notes || null,
  };
}

function fromApiClient(client: ApiClient): Client {
  return {
    id: client.id,
    name: client.name,
    type: client.type,
    contactPerson: client.contactPerson ?? "",
    email: client.email ?? "",
    phone: client.phone ?? "",
    address: client.address ?? "",
    notes: client.notes ?? "",
    createdAt: client.createdAt.slice(0, 10),
    updatedAt: client.updatedAt.slice(0, 10),
  };
}

function toApiProjectRequest(project: Project) {
  return {
    id: project.id,
    title: project.title,
    clientId: project.clientId || null,
    objectIds: project.objectIds,
    status: project.status,
    startDate: project.startDate || null,
    endDate: project.endDate || null,
    description: project.description || null,
    totalBudget: toNumber(project.budget),
    currency: project.currency || null,
  };
}

function fromApiProject(project: ApiProject): Project {
  return {
    id: project.id,
    title: project.title,
    clientId: project.clientId ?? "",
    objectIds: project.objectIds ?? [],
    status: normalizeProjectStatus(project.status),
    startDate: project.startDate?.slice(0, 10) ?? "",
    endDate: project.endDate?.slice(0, 10) ?? "",
    description: project.description ?? "",
    budget: project.totalBudget?.toString() ?? "",
    currency: project.currency ?? "EUR",
    createdAt: project.createdAt.slice(0, 10),
    updatedAt: project.updatedAt.slice(0, 10),
  };
}

function toApiReportRequest(report: Report) {
  return {
    id: report.id,
    objectId: report.objectId,
    reportType: report.reportType
      .toUpperCase()
      .replaceAll(" ", "_")
      .replaceAll("-", "_"),
    overallCondition: toApiCondition(report.condition),
    examiner: report.examiner,
    examinationDate: report.examinationDate,
    notes: report.notes || null,
    recommendations: report.recommendations || null,
    imageIds: report.imageNames,
  };
}

function fromApiReport(report: ApiReport): Report {
  return {
    id: report.id,
    objectId: report.objectId,
    reportType: fromApiReportType(report.reportType),
    condition: fromApiCondition(report.overallCondition),
    examiner: report.examiner,
    examinationDate: report.examinationDate.slice(0, 10),
    notes: report.notes ?? "",
    recommendations: report.recommendations ?? "",
    imageNames: report.imageIds ?? [],
    createdAt: report.createdAt.slice(0, 10),
    updatedAt: report.updatedAt.slice(0, 10),
  };
}

function fromApiReportType(reportType: string) {
  const normalized = reportType
    .toLowerCase()
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
  const match = reportTypes.find(
    (type) => type.toLowerCase() === normalized.toLowerCase(),
  );

  return match ?? "Initial assessment";
}

function normalizeProjectStatus(status: string): ProjectStatus {
  const match = projectStatuses.find(
    (projectStatus) => projectStatus.toLowerCase() === status.toLowerCase(),
  );
  return match ?? "Inquiry";
}

function toWebUnit(unit?: string | null): "cm" | "m" | "in" {
  if (unit === "m" || unit === "M") {
    return "m";
  }

  if (unit === "in" || unit === "INCH") {
    return "in";
  }

  return "cm";
}

function toNumber(value: string) {
  if (!value.trim()) {
    return null;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}
