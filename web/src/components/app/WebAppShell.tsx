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
  Pencil,
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
import {
  Lang,
  enumLabel,
  makeT,
  supportedLanguages,
} from "@/lib/i18n";

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

type ImageAsset = { name: string; dataUrl: string };

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
  images: ImageAsset[];
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
  images: ImageAsset[];
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
  images: ImageAsset[];
};

type ClientFormState = Omit<Client, "id" | "createdAt" | "updatedAt">;
type ProjectFormState = Omit<Project, "id" | "createdAt" | "updatedAt">;
type ReportFormState = Omit<Report, "id" | "createdAt" | "updatedAt">;

type ModalState =
  | { kind: "object"; mode: "create" | "edit"; record?: ConservationObject }
  | { kind: "client"; mode: "create" | "edit"; record?: Client }
  | { kind: "project"; mode: "create" | "edit"; record?: Project }
  | { kind: "report"; mode: "create" | "edit"; record?: Report }
  | null;

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
  images: [],
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
  images: [],
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
    images: [
      { name: "front-detail.jpg", dataUrl: "" },
      { name: "corner-loss.jpg", dataUrl: "" },
    ],
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
    images: [{ name: "lamp-overview.jpg", dataUrl: "" }],
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
    images: [{ name: "front-detail.jpg", dataUrl: "" }],
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
    images: [{ name: "lamp-overview.jpg", dataUrl: "" }],
    createdAt: "2026-05-28",
    updatedAt: "2026-05-28",
  },
];

const API_BASE_URL = "https://conservatio-api.peterdsp.dev";

// OAuth client IDs are public (they're embedded in the redirect URL the user
// hits anyway). Secrets stay only on the server. Set these as Next public env
// vars when wiring each provider; the buttons stay disabled until they're set.
const OAUTH_CONFIG = {
  google: {
    clientId: process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || "",
    authUrl: "https://accounts.google.com/o/oauth2/v2/auth",
    scope: "openid email profile",
  },
  linkedin: {
    clientId: process.env.NEXT_PUBLIC_LINKEDIN_CLIENT_ID || "",
    authUrl: "https://www.linkedin.com/oauth/v2/authorization",
    scope: "openid email profile",
  },
  apple: {
    clientId: process.env.NEXT_PUBLIC_APPLE_SERVICES_ID || "",
    authUrl: "https://appleid.apple.com/auth/authorize",
    scope: "name email",
  },
} as const;

type OAuthProvider = keyof typeof OAUTH_CONFIG;

function oauthRedirectUri() {
  if (typeof window === "undefined") return "";
  return `${window.location.origin}${window.location.pathname}`;
}

function beginOAuthFlow(provider: OAuthProvider) {
  if (typeof window === "undefined") return;
  const config = OAUTH_CONFIG[provider];
  if (!config.clientId) return;
  const state = crypto.randomUUID();
  window.sessionStorage.setItem("conservatio.oauthState", state);
  window.sessionStorage.setItem("conservatio.oauthProvider", provider);
  const params = new URLSearchParams({
    client_id: config.clientId,
    redirect_uri: oauthRedirectUri(),
    response_type: "code",
    scope: config.scope,
    state,
  });
  if (provider === "apple") {
    params.set("response_mode", "form_post");
  }
  window.location.href = `${config.authUrl}?${params.toString()}`;
}

async function completeOAuthFlow(
  provider: OAuthProvider,
  code: string,
): Promise<{ token: string; email: string; displayName: string } | string> {
  try {
    const response = await fetch(`${API_BASE_URL}/api/auth/oauth/${provider}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        code,
        redirectUri: oauthRedirectUri(),
      }),
    });
    if (!response.ok) {
      const error = (await response.json().catch(() => ({}))) as {
        error?: string;
      };
      return error.error ?? `Sign-in failed (${response.status}).`;
    }
    const data = (await response.json()) as {
      token: string;
      email: string;
      displayName: string;
    };
    return data;
  } catch {
    return "Sign-in failed (network).";
  }
}

const defaultSyncAccount: SyncAccount = {
  token: "",
  email: "",
  displayName: "",
};

function today() {
  return new Date().toISOString().slice(0, 10);
}

function createId(_prefix: string) {
  // Plain UUIDs so the server (which requires UUID-format IDs for POST/PUT)
  // accepts them as-is. The previous "obj-<uuid>" form was being rejected by
  // UUID.fromString, which silently swallowed every sync push and made the
  // post-sync pull look empty.
  if (typeof crypto !== "undefined" && "randomUUID" in crypto) {
    return crypto.randomUUID();
  }
  return `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`;
}

const UUID_RE =
  /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/i;

// Defensive: existing localStorage may hold older "obj-<uuid>" IDs from before
// the createId change. Extract the embedded UUID so the server accepts those
// records on first sync after the upgrade. If there's no UUID at all (e.g.
// the seed "obj-1"), pass the original through so callers can still skip it.
function toServerId(id: string): string {
  const match = id.match(UUID_RE);
  return match ? match[0] : id;
}

function stripImageDataUrls(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(stripImageDataUrls);
  if (value && typeof value === "object") {
    const next: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
      if (k === "images" && Array.isArray(v)) {
        next[k] = v.map((entry) =>
          entry && typeof entry === "object"
            ? { ...(entry as Record<string, unknown>), dataUrl: "" }
            : entry,
        );
      } else {
        next[k] = stripImageDataUrls(v);
      }
    }
    return next;
  }
  return value;
}

// IDs of records baked into the in-app sample data. These should never be
// auto-pushed to the server — they're demo content, not user records.
const SEED_IDS = new Set<string>([
  "obj-1",
  "obj-2",
  "client-1",
  "client-2",
  "project-1",
  "project-2",
  "report-1",
  "report-2",
]);

function readLocalArray<T>(key: string): T[] {
  if (typeof window === "undefined") return [];
  const raw = window.localStorage.getItem(key);
  if (!raw) return [];
  try {
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? (parsed as T[]) : [];
  } catch {
    return [];
  }
}

function safeSetItem(key: string, value: unknown) {
  try {
    window.localStorage.setItem(key, JSON.stringify(value));
    return true;
  } catch {
    // Quota exceeded — try again without the heavy image data URLs.
    try {
      window.localStorage.setItem(
        key,
        JSON.stringify(stripImageDataUrls(value)),
      );
      return true;
    } catch {
      return false;
    }
  }
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
    safeSetItem(key, value);
  }, [key, value]);

  return [value, setValue] as const;
}

// Older persisted data used `imageNames: string[]`. Hydrate it to ImageAsset[].
function normalizeImages(raw: unknown): ImageAsset[] {
  if (!Array.isArray(raw)) return [];
  return raw
    .map((entry) => {
      if (typeof entry === "string") return { name: entry, dataUrl: "" };
      if (entry && typeof entry === "object" && "name" in entry) {
        return {
          name: String((entry as ImageAsset).name ?? ""),
          dataUrl: String((entry as ImageAsset).dataUrl ?? ""),
        };
      }
      return null;
    })
    .filter((entry): entry is ImageAsset => entry !== null && !!entry.name);
}

function normalizeObject(raw: any): ConservationObject {
  return {
    id: raw.id,
    title: raw.title ?? "",
    objectType: raw.objectType ?? "Other",
    materials: raw.materials ?? [],
    ownerName: raw.ownerName ?? "",
    locationDescription: raw.locationDescription ?? "",
    inventoryNumber: raw.inventoryNumber ?? "",
    description: raw.description ?? "",
    dimensions: raw.dimensions ?? { height: "", width: "", depth: "", unit: "cm" },
    images: raw.images ? normalizeImages(raw.images) : normalizeImages(raw.imageNames),
    createdAt: raw.createdAt ?? today(),
    updatedAt: raw.updatedAt ?? today(),
  };
}

function normalizeReport(raw: any): Report {
  return {
    id: raw.id,
    objectId: raw.objectId ?? "",
    reportType: raw.reportType ?? "Initial assessment",
    condition: raw.condition ?? "Fair",
    examiner: raw.examiner ?? "",
    examinationDate: raw.examinationDate ?? "",
    notes: raw.notes ?? "",
    recommendations: raw.recommendations ?? "",
    images: raw.images ? normalizeImages(raw.images) : normalizeImages(raw.imageNames),
    createdAt: raw.createdAt ?? today(),
    updatedAt: raw.updatedAt ?? today(),
  };
}

export function WebAppShell() {
  const [activeSection, setActiveSection] = useState<WebSection>("dashboard");
  const [collapsed, setCollapsed] = useState(false);
  const [modal, setModal] = useState<ModalState>(null);
  const [language, setLanguage] = usePersistentState<Lang>(
    "conservatio.lang",
    "en",
  );
  const t = useMemo(() => makeT(language), [language]);
  // Default to empty arrays so a fresh install never pushes demo data up to
  // the server on first sync. Demo records load only via the "Load sample
  // data" button in Settings.
  const [rawObjects, setObjects] = usePersistentState<ConservationObject[]>(
    "conservatio.objects",
    [],
  );
  const [clients, setClients] = usePersistentState<Client[]>(
    "conservatio.clients",
    [],
  );
  const [projects, setProjects] = usePersistentState<Project[]>(
    "conservatio.projects",
    [],
  );
  const [rawReports, setReports] = usePersistentState<Report[]>(
    "conservatio.reports",
    [],
  );
  const [syncAccount, setSyncAccount] = usePersistentState(
    "conservatio.syncAccount",
    defaultSyncAccount,
  );
  const [syncStatus, setSyncStatus] = useState(
    syncAccount.token ? t("sync.signedIn") : t("sync.offline"),
  );
  const [query, setQuery] = useState("");
  const [passedLogin, setPassedLogin] = usePersistentState(
    "conservatio.passedLogin",
    false,
  );

  // Hydrate legacy persisted records that used `imageNames`.
  const objects = useMemo(
    () => rawObjects.map(normalizeObject),
    [rawObjects],
  );
  const reports = useMemo(
    () => rawReports.map(normalizeReport),
    [rawReports],
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
    void syncWithServer(syncAccount);
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

  function readLocalSnapshot() {
    // Read directly from localStorage so the push always sees the freshest
    // persisted state, not a stale React closure (which on first mount can
    // still be the initial empty array before hydration completes).
    return {
      objects: readLocalArray<ConservationObject>("conservatio.objects").map(
        normalizeObject,
      ),
      clients: readLocalArray<Client>("conservatio.clients"),
      projects: readLocalArray<Project>("conservatio.projects"),
      reports: readLocalArray<Report>("conservatio.reports").map(normalizeReport),
    };
  }

  async function pushPendingItems(
    account: SyncAccount,
    remoteIds: {
      objects: Set<string>;
      clients: Set<string>;
      projects: Set<string>;
      reports: Set<string>;
    },
    snapshot: ReturnType<typeof readLocalSnapshot>,
  ) {
    const { objects: localObjects, clients: localClients, projects: localProjects, reports: localReports } =
      snapshot;

    let pushed = 0;
    for (const item of localObjects) {
      if (remoteIds.objects.has(item.id) || SEED_IDS.has(item.id)) continue;
      try {
        const uploaded = await uploadObjectImages(item, account);
        await apiRequest("/api/objects", {
          method: "POST",
          body: JSON.stringify(toApiObjectRequest(uploaded)),
        }, account);
        pushed++;
      } catch {
        /* swallow — keep local copy */
      }
    }
    for (const item of localClients) {
      if (remoteIds.clients.has(item.id) || SEED_IDS.has(item.id)) continue;
      try {
        await apiRequest("/api/clients", {
          method: "POST",
          body: JSON.stringify(toApiClientRequest(item)),
        }, account);
        pushed++;
      } catch { /* swallow */ }
    }
    for (const item of localProjects) {
      if (remoteIds.projects.has(item.id) || SEED_IDS.has(item.id)) continue;
      try {
        await apiRequest("/api/projects", {
          method: "POST",
          body: JSON.stringify(toApiProjectRequest(item)),
        }, account);
        pushed++;
      } catch { /* swallow */ }
    }
    for (const item of localReports) {
      if (remoteIds.reports.has(item.id) || SEED_IDS.has(item.id)) continue;
      try {
        const uploaded = await uploadReportImages(item, account);
        await apiRequest("/api/reports", {
          method: "POST",
          body: JSON.stringify(toApiReportRequest(uploaded)),
        }, account);
        pushed++;
      } catch { /* swallow */ }
    }
    return pushed;
  }

  async function uploadOneImage(
    image: ImageAsset,
    account: SyncAccount,
  ): Promise<ImageAsset> {
    if (!image.dataUrl) return image;
    if (looksLikeServerImageId(image.name)) return image;
    const imageId = await uploadImageBlob(image, account);
    if (!imageId) return image;
    return { name: imageId, dataUrl: image.dataUrl };
  }

  async function uploadObjectImages(
    object: ConservationObject,
    account: SyncAccount,
  ): Promise<ConservationObject> {
    if (!account.token || object.images.length === 0) return object;
    const uploaded = await Promise.all(
      object.images.map((image) => uploadOneImage(image, account)),
    );
    return { ...object, images: uploaded };
  }

  async function uploadReportImages(
    report: Report,
    account: SyncAccount,
  ): Promise<Report> {
    if (!account.token || report.images.length === 0) return report;
    const uploaded = await Promise.all(
      report.images.map((image) => uploadOneImage(image, account)),
    );
    return { ...report, images: uploaded };
  }

  // Full sync: pull what's on the server, push anything local that isn't there,
  // then pull again so the merged set is reflected locally. Local-only items
  // (push failed, network blip, etc.) are kept rather than overwritten.
  async function syncWithServer(account = syncAccount) {
    if (!account.token) return;
    const snapshot = readLocalSnapshot();
    try {
      setSyncStatus(t("sync.syncing"));
      const [remoteObjects, remoteClients, remoteProjects, remoteReports] =
        await Promise.all([
          apiRequest<ApiObject[]>("/api/objects", {}, account),
          apiRequest<ApiClient[]>("/api/clients", {}, account),
          apiRequest<ApiProject[]>("/api/projects", {}, account),
          apiRequest<ApiReport[]>("/api/reports", {}, account),
        ]);

      const remoteIds = {
        objects: new Set(remoteObjects.map((entry) => entry.id)),
        clients: new Set(remoteClients.map((entry) => entry.id)),
        projects: new Set(remoteProjects.map((entry) => entry.id)),
        reports: new Set(remoteReports.map((entry) => entry.id)),
      };

      const pushedCount = await pushPendingItems(account, remoteIds, snapshot);

      const [finalObjects, finalClients, finalProjects, finalReports] =
        await Promise.all([
          apiRequest<ApiObject[]>("/api/objects", {}, account),
          apiRequest<ApiClient[]>("/api/clients", {}, account),
          apiRequest<ApiProject[]>("/api/projects", {}, account),
          apiRequest<ApiReport[]>("/api/reports", {}, account),
        ]);

      // Preserve local image data URLs across the refresh.
      const objectImagesById = new Map(
        snapshot.objects.map(
          (entry) => [toServerId(entry.id), entry.images] as const,
        ),
      );
      const reportImagesById = new Map(
        snapshot.reports.map(
          (entry) => [toServerId(entry.id), entry.images] as const,
        ),
      );

      const finalObjectIds = new Set(finalObjects.map((entry) => entry.id));
      const finalClientIds = new Set(finalClients.map((entry) => entry.id));
      const finalProjectIds = new Set(finalProjects.map((entry) => entry.id));
      const finalReportIds = new Set(finalReports.map((entry) => entry.id));

      // Defensive: keep any record that the server doesn't (yet) know about,
      // including the seed demo records the user may still be looking at.
      const localOnlyObjects = snapshot.objects.filter(
        (entry) => !finalObjectIds.has(toServerId(entry.id)),
      );
      const localOnlyClients = snapshot.clients.filter(
        (entry) => !finalClientIds.has(toServerId(entry.id)),
      );
      const localOnlyProjects = snapshot.projects.filter(
        (entry) => !finalProjectIds.has(toServerId(entry.id)),
      );
      const localOnlyReports = snapshot.reports.filter(
        (entry) => !finalReportIds.has(toServerId(entry.id)),
      );

      setObjects([
        ...finalObjects.map((entry) =>
          mergeImagesIntoObject(fromApiObject(entry), objectImagesById.get(entry.id)),
        ),
        ...localOnlyObjects,
      ]);
      setClients([...finalClients.map(fromApiClient), ...localOnlyClients]);
      setProjects([...finalProjects.map(fromApiProject), ...localOnlyProjects]);
      setReports([
        ...finalReports.map((entry) =>
          mergeImagesIntoReport(fromApiReport(entry), reportImagesById.get(entry.id)),
        ),
        ...localOnlyReports,
      ]);

      setSyncStatus(
        pushedCount > 0
          ? `${t("sync.pushed")} · ${new Date().toLocaleTimeString()}`
          : `${t("sync.syncedAt")} ${new Date().toLocaleTimeString()}`,
      );
    } catch {
      setSyncStatus(t("sync.failed"));
    }
  }

  async function signIn(
    email: string,
    password: string,
    displayName: string,
    mode: AuthMode,
  ): Promise<string | null> {
    try {
      setSyncStatus(t("sync.signingIn"));
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
        if (status === 401) return t("login.errInvalid");
        if (status === 409) return t("login.errExists");
        return `${t("login.errAuth")} (${status}).`;
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
      await syncWithServer(account);
      return null;
    } catch {
      setSyncStatus(t("login.errAuth"));
      return t("login.errNetwork");
    }
  }

  function signOut() {
    setSyncAccount(defaultSyncAccount);
    setSyncStatus(t("sync.offline"));
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
      images: form.images,
      createdAt: timestamp,
      updatedAt: timestamp,
    };

    if (syncAccount.token) {
      try {
        const uploaded = await uploadObjectImages(object, syncAccount);
        const remote = await apiRequest<ApiObject>("/api/objects", {
          method: "POST",
          body: JSON.stringify(toApiObjectRequest(uploaded)),
        });
        const merged = mergeImagesIntoObject(
          fromApiObject(remote),
          uploaded.images,
        );
        setObjects((current) => [merged, ...current]);
        setSyncStatus(`${t("nav.objects")} ${t("sync.synced")}`);
      } catch {
        setObjects((current) => [object, ...current]);
        setSyncStatus(`${t("nav.objects")} ${t("sync.savedLocal")}`);
      }
    } else {
      setObjects((current) => [object, ...current]);
    }
    setActiveSection("objects");
    setModal(null);
  }

  async function updateObject(id: string, form: ObjectFormState) {
    const timestamp = today();
    const materials = form.materialsText
      .split(",")
      .map((material) => material.trim())
      .filter(Boolean);
    const existing = objects.find((object) => object.id === id);
    if (!existing) {
      setModal(null);
      return;
    }
    const updated: ConservationObject = {
      ...existing,
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
      images: form.images,
      updatedAt: timestamp,
    };

    setObjects((current) =>
      current.map((object) => (object.id === id ? updated : object)),
    );

    if (syncAccount.token) {
      try {
        const uploaded = await uploadObjectImages(updated, syncAccount);
        await apiRequest(`/api/objects/${toServerId(id)}`, {
          method: "PUT",
          body: JSON.stringify(toApiObjectRequest(uploaded)),
        });
        setObjects((current) =>
          current.map((object) => (object.id === id ? uploaded : object)),
        );
        setSyncStatus(`${t("nav.objects")} ${t("sync.synced")}`);
      } catch {
        setSyncStatus(`${t("nav.objects")} ${t("sync.savedLocal")}`);
      }
    }
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
        setSyncStatus(`${t("nav.clients")} ${t("sync.synced")}`);
      } catch {
        setClients((current) => [client, ...current]);
        setSyncStatus(`${t("nav.clients")} ${t("sync.savedLocal")}`);
      }
    } else {
      setClients((current) => [client, ...current]);
    }
    setActiveSection("clients");
    setModal(null);
  }

  async function updateClient(id: string, form: ClientFormState) {
    const timestamp = today();
    const existing = clients.find((client) => client.id === id);
    if (!existing) {
      setModal(null);
      return;
    }
    const updated: Client = {
      ...existing,
      ...form,
      name: form.name.trim(),
      contactPerson: form.contactPerson.trim(),
      email: form.email.trim(),
      phone: form.phone.trim(),
      address: form.address.trim(),
      notes: form.notes.trim(),
      updatedAt: timestamp,
    };
    setClients((current) =>
      current.map((client) => (client.id === id ? updated : client)),
    );
    if (syncAccount.token) {
      try {
        await apiRequest(`/api/clients/${toServerId(id)}`, {
          method: "PUT",
          body: JSON.stringify(toApiClientRequest(updated)),
        });
        setSyncStatus(`${t("nav.clients")} ${t("sync.synced")}`);
      } catch {
        setSyncStatus(`${t("nav.clients")} ${t("sync.savedLocal")}`);
      }
    }
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
        setSyncStatus(`${t("nav.projects")} ${t("sync.synced")}`);
      } catch {
        setProjects((current) => [project, ...current]);
        setSyncStatus(`${t("nav.projects")} ${t("sync.savedLocal")}`);
      }
    } else {
      setProjects((current) => [project, ...current]);
    }
    setActiveSection("projects");
    setModal(null);
  }

  async function updateProject(id: string, form: ProjectFormState) {
    const timestamp = today();
    const existing = projects.find((project) => project.id === id);
    if (!existing) {
      setModal(null);
      return;
    }
    const updated: Project = {
      ...existing,
      ...form,
      title: form.title.trim(),
      description: form.description.trim(),
      budget: form.budget.trim(),
      currency: form.currency.trim() || "EUR",
      updatedAt: timestamp,
    };
    setProjects((current) =>
      current.map((project) => (project.id === id ? updated : project)),
    );
    if (syncAccount.token) {
      try {
        await apiRequest(`/api/projects/${toServerId(id)}`, {
          method: "PUT",
          body: JSON.stringify(toApiProjectRequest(updated)),
        });
        setSyncStatus(`${t("nav.projects")} ${t("sync.synced")}`);
      } catch {
        setSyncStatus(`${t("nav.projects")} ${t("sync.savedLocal")}`);
      }
    }
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
        const uploaded = await uploadReportImages(report, syncAccount);
        await apiRequest<{ id: string }>("/api/reports", {
          method: "POST",
          body: JSON.stringify(toApiReportRequest(uploaded)),
        });
        setReports((current) => [uploaded, ...current]);
        setSyncStatus(`${t("nav.reports")} ${t("sync.synced")}`);
      } catch {
        setReports((current) => [report, ...current]);
        setSyncStatus(`${t("nav.reports")} ${t("sync.savedLocal")}`);
      }
    } else {
      setReports((current) => [report, ...current]);
    }
    setActiveSection("reports");
    setModal(null);
  }

  async function updateReport(id: string, form: ReportFormState) {
    const timestamp = today();
    const existing = reports.find((report) => report.id === id);
    if (!existing) {
      setModal(null);
      return;
    }
    const updated: Report = {
      ...existing,
      ...form,
      examiner: form.examiner.trim(),
      notes: form.notes.trim(),
      recommendations: form.recommendations.trim(),
      updatedAt: timestamp,
    };
    setReports((current) =>
      current.map((report) => (report.id === id ? updated : report)),
    );
    if (syncAccount.token) {
      try {
        const uploaded = await uploadReportImages(updated, syncAccount);
        await apiRequest(`/api/reports/${toServerId(id)}`, {
          method: "PUT",
          body: JSON.stringify(toApiReportRequest(uploaded)),
        });
        setReports((current) =>
          current.map((report) => (report.id === id ? uploaded : report)),
        );
        setSyncStatus(`${t("nav.reports")} ${t("sync.synced")}`);
      } catch {
        setSyncStatus(`${t("nav.reports")} ${t("sync.savedLocal")}`);
      }
    }
    setModal(null);
  }

  async function deleteObject(id: string) {
    if (syncAccount.token) {
      void apiRequest(`/api/objects/${toServerId(id)}`, { method: "DELETE" });
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
      void apiRequest(`/api/clients/${toServerId(id)}`, { method: "DELETE" });
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
      void apiRequest(`/api/projects/${toServerId(id)}`, { method: "DELETE" });
    }
    setProjects((current) => current.filter((project) => project.id !== id));
  }

  function deleteReport(id: string) {
    if (syncAccount.token) {
      void apiRequest(`/api/reports/${toServerId(id)}`, { method: "DELETE" });
    }
    setReports((current) => current.filter((report) => report.id !== id));
  }

  function clearAllData() {
    if (typeof window !== "undefined") {
      if (!window.confirm(t("settings.clearConfirm"))) return;
    }
    setObjects([]);
    setClients([]);
    setProjects([]);
    setReports([]);
    setActiveSection("dashboard");
  }

  function loadSampleData() {
    setObjects(seedObjects);
    setClients(seedClients);
    setProjects(seedProjects);
    setReports(seedReports);
    setActiveSection("dashboard");
  }

  async function saveProfile(displayName: string): Promise<string | null> {
    const trimmed = displayName.trim();
    setSyncAccount({ ...syncAccount, displayName: trimmed });
    if (!syncAccount.token) return null;
    try {
      await apiRequest("/api/auth/profile", {
        method: "PUT",
        body: JSON.stringify({ displayName: trimmed }),
      });
      return null;
    } catch {
      return t("settings.profileSaveFailed");
    }
  }

  const showLogin = !passedLogin && !syncAccount.token;

  if (showLogin) {
    return (
      <LoginScreen
        t={t}
        onSignIn={async (email, password, displayName, mode) => {
          const error = await signIn(email, password, displayName, mode);
          if (!error) setPassedLogin(true);
          return error;
        }}
        onOAuthSession={(account) => {
          setSyncAccount(account);
          setPassedLogin(true);
          void syncWithServer(account);
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
          t={t}
        />
        <main className="flex-1 overflow-auto">
          <TopBar
            t={t}
            activeSection={activeSection}
            onCreateObject={() => setModal({ kind: "object", mode: "create" })}
            onNavigate={setActiveSection}
          />
          <div className="mx-auto w-full max-w-7xl px-4 py-6 sm:px-6 lg:px-8 lg:py-8">
            {activeSection === "dashboard" && (
              <DashboardView
                t={t}
                lang={language}
                token={syncAccount.token}
                objects={objects}
                clients={clients}
                projects={projects}
                reports={reports}
                syncStatus={syncStatus}
                onCreate={(kind) => setModal({ kind, mode: "create" } as ModalState)}
                onNavigate={setActiveSection}
              />
            )}
            {activeSection === "objects" && (
              <ObjectsView
                t={t}
                lang={language}
                token={syncAccount.token}
                objects={filteredObjects}
                query={query}
                onQueryChange={setQuery}
                onCreateObject={() => setModal({ kind: "object", mode: "create" })}
                onEditObject={(record) =>
                  setModal({ kind: "object", mode: "edit", record })
                }
                onDeleteObject={deleteObject}
              />
            )}
            {activeSection === "projects" && (
              <ProjectsView
                t={t}
                lang={language}
                projects={projects}
                clients={clients}
                objects={objects}
                onCreateProject={() => setModal({ kind: "project", mode: "create" })}
                onEditProject={(record) =>
                  setModal({ kind: "project", mode: "edit", record })
                }
                onDeleteProject={deleteProject}
              />
            )}
            {activeSection === "clients" && (
              <ClientsView
                t={t}
                lang={language}
                clients={clients}
                projects={projects}
                onCreateClient={() => setModal({ kind: "client", mode: "create" })}
                onEditClient={(record) =>
                  setModal({ kind: "client", mode: "edit", record })
                }
                onDeleteClient={deleteClient}
              />
            )}
            {activeSection === "reports" && (
              <ReportsView
                t={t}
                lang={language}
                token={syncAccount.token}
                reports={reports}
                objects={objects}
                onCreateReport={() => setModal({ kind: "report", mode: "create" })}
                onEditReport={(record) =>
                  setModal({ kind: "report", mode: "edit", record })
                }
                onDeleteReport={deleteReport}
              />
            )}
            {activeSection === "settings" && (
              <SettingsView
                t={t}
                language={language}
                onLanguageChange={setLanguage}
                syncAccount={syncAccount}
                syncStatus={syncStatus}
                onSaveProfile={saveProfile}
                onClearAll={clearAllData}
                onLoadSample={loadSampleData}
                onRefresh={() => syncWithServer()}
                onSignOut={signOut}
              />
            )}
          </div>
        </main>
      </div>

      {modal?.kind === "object" && (
        <ObjectModal
          t={t}
          lang={language}
          token={syncAccount.token}
          mode={modal.mode}
          initial={modal.record}
          onClose={() => setModal(null)}
          onSave={(form) =>
            modal.mode === "edit" && modal.record
              ? updateObject(modal.record.id, form)
              : createObject(form)
          }
        />
      )}
      {modal?.kind === "client" && (
        <ClientModal
          t={t}
          lang={language}
          mode={modal.mode}
          initial={modal.record}
          onClose={() => setModal(null)}
          onSave={(form) =>
            modal.mode === "edit" && modal.record
              ? updateClient(modal.record.id, form)
              : createClient(form)
          }
        />
      )}
      {modal?.kind === "project" && (
        <ProjectModal
          t={t}
          lang={language}
          mode={modal.mode}
          initial={modal.record}
          clients={clients}
          objects={objects}
          onClose={() => setModal(null)}
          onSave={(form) =>
            modal.mode === "edit" && modal.record
              ? updateProject(modal.record.id, form)
              : createProject(form)
          }
        />
      )}
      {modal?.kind === "report" && (
        <ReportModal
          t={t}
          lang={language}
          token={syncAccount.token}
          mode={modal.mode}
          initial={modal.record}
          objects={objects}
          onClose={() => setModal(null)}
          onSave={(form) =>
            modal.mode === "edit" && modal.record
              ? updateReport(modal.record.id, form)
              : createReport(form)
          }
        />
      )}
    </div>
  );
}

function LoginScreen({
  t,
  onSignIn,
  onOAuthSession,
  onContinueOffline,
}: {
  t: (key: string) => string;
  onSignIn: (
    email: string,
    password: string,
    displayName: string,
    mode: AuthMode,
  ) => Promise<string | null>;
  onOAuthSession: (account: SyncAccount) => void;
  onContinueOffline: () => void;
}) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [displayName, setDisplayName] = useState("");
  const [isRegistering, setIsRegistering] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [oauthBusy, setOauthBusy] = useState(false);

  // Pick up the provider redirect back to this page.
  useEffect(() => {
    if (typeof window === "undefined") return;
    const params = new URLSearchParams(window.location.search);
    const code = params.get("code");
    const state = params.get("state");
    if (!code) return;
    const stored = window.sessionStorage.getItem("conservatio.oauthState");
    const provider = window.sessionStorage.getItem(
      "conservatio.oauthProvider",
    ) as OAuthProvider | null;
    if (!provider || !stored || stored !== state) {
      // Clean up the URL even if we bail.
      window.history.replaceState({}, "", window.location.pathname);
      return;
    }
    setOauthBusy(true);
    completeOAuthFlow(provider, code)
      .then((result) => {
        if (typeof result === "string") {
          setError(result);
        } else {
          onOAuthSession({
            token: result.token,
            email: result.email,
            displayName: result.displayName,
          });
        }
      })
      .finally(() => {
        window.sessionStorage.removeItem("conservatio.oauthState");
        window.sessionStorage.removeItem("conservatio.oauthProvider");
        window.history.replaceState({}, "", window.location.pathname);
        setOauthBusy(false);
      });
  }, [onOAuthSession]);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!email.trim() || !password.trim()) return;
    setIsLoading(true);
    setError(null);
    const wasRegistering = isRegistering;
    const result = await onSignIn(
      email.trim(),
      password,
      displayName.trim(),
      wasRegistering ? "register" : "login",
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
            {t("login.tagline")}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="mt-10 space-y-3">
          {isRegistering && (
            <input
              value={displayName}
              onChange={(event) => setDisplayName(event.target.value)}
              className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3.5 text-sm outline-none transition focus:border-primary"
              placeholder={t("login.fullName")}
              type="text"
              autoComplete="name"
            />
          )}
          <input
            value={email}
            onChange={(event) => setEmail(event.target.value)}
            className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3.5 text-sm outline-none transition focus:border-primary"
            placeholder={t("login.email")}
            type="email"
            autoComplete="email"
            required
          />
          <input
            value={password}
            onChange={(event) => setPassword(event.target.value)}
            className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3.5 text-sm outline-none transition focus:border-primary"
            placeholder={t("login.password")}
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
              ? t("login.signingIn")
              : isRegistering
                ? t("login.createAccount")
                : t("login.signIn")}
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
              {isRegistering ? t("login.haveAccount") : t("login.noAccount")}
            </button>
          </div>
        </form>

        <div className="mt-8 flex items-center gap-3">
          <div className="h-px flex-1 bg-heritage-outline/20" />
          <span className="text-xs text-heritage-text-secondary">
            {t("login.or")}
          </span>
          <div className="h-px flex-1 bg-heritage-outline/20" />
        </div>

        <div className="mt-5 space-y-2">
          <OAuthButton
            provider="google"
            label={t("login.continueGoogle")}
            disabledLabel={t("login.oauthUnavailable")}
            onStart={beginOAuthFlow}
            busy={oauthBusy}
          />
          <OAuthButton
            provider="linkedin"
            label={t("login.continueLinkedIn")}
            disabledLabel={t("login.oauthUnavailable")}
            onStart={beginOAuthFlow}
            busy={oauthBusy}
          />
          <OAuthButton
            provider="apple"
            label={t("login.continueApple")}
            disabledLabel={t("login.oauthUnavailable")}
            onStart={beginOAuthFlow}
            busy={oauthBusy}
          />
        </div>

        {oauthBusy && (
          <p className="mt-3 text-center text-xs text-heritage-text-secondary">
            {t("login.finishingOauth")}
          </p>
        )}

        <div className="mt-6 text-center">
          <button
            onClick={onContinueOffline}
            className="text-sm text-heritage-text-secondary transition hover:text-heritage-text"
            type="button"
          >
            {t("login.offline")}
          </button>
          <p className="mt-2 text-xs text-heritage-text-secondary">
            {t("login.offlineHint")}
          </p>
        </div>

        <p className="mt-10 text-center text-xs text-heritage-text-secondary">
          v0.1.0
        </p>
      </div>
    </div>
  );
}

function OAuthButton({
  provider,
  label,
  disabledLabel,
  onStart,
  busy,
}: {
  provider: OAuthProvider;
  label: string;
  disabledLabel: string;
  onStart: (provider: OAuthProvider) => void;
  busy: boolean;
}) {
  const configured = !!OAUTH_CONFIG[provider].clientId;
  return (
    <button
      onClick={() => onStart(provider)}
      disabled={!configured || busy}
      className="flex w-full items-center justify-center gap-2 rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3 text-sm font-semibold text-heritage-text transition hover:bg-heritage-surface-variant disabled:cursor-not-allowed disabled:opacity-50"
      type="button"
      title={configured ? undefined : disabledLabel}
    >
      <ProviderGlyph provider={provider} />
      {label}
    </button>
  );
}

function ProviderGlyph({ provider }: { provider: OAuthProvider }) {
  switch (provider) {
    case "google":
      return (
        <svg width="18" height="18" viewBox="0 0 48 48" aria-hidden>
          <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3c-1.6 4.6-6 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3 0 5.8 1.1 8 3l5.7-5.7C33.6 6 29 4 24 4 13 4 4 13 4 24s9 20 20 20 20-9 20-20c0-1.2-.1-2.3-.4-3.5z" />
          <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 16 19 13 24 13c3 0 5.8 1.1 8 3l5.7-5.7C33.6 6 29 4 24 4 16.3 4 9.6 8.3 6.3 14.7z" />
          <path fill="#4CAF50" d="M24 44c5 0 9.5-1.9 12.8-5l-5.9-5C28.9 35.6 26.5 36 24 36c-5.2 0-9.6-3.3-11.3-8L6 32.7C9.3 39.4 16.1 44 24 44z" />
          <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.4-2.3 4.4-4.3 5.9l5.9 5C39.7 35.7 44 30.4 44 24c0-1.2-.1-2.3-.4-3.5z" />
        </svg>
      );
    case "linkedin":
      return (
        <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden fill="#0A66C2">
          <path d="M20.5 2h-17C2.7 2 2 2.7 2 3.5v17c0 .8.7 1.5 1.5 1.5h17c.8 0 1.5-.7 1.5-1.5v-17c0-.8-.7-1.5-1.5-1.5zM8 19H5V9h3v10zM6.5 7.7C5.5 7.7 4.8 7 4.8 6s.7-1.7 1.7-1.7c1 0 1.7.7 1.7 1.7s-.7 1.7-1.7 1.7zM19 19h-3v-5.3c0-1.4-.5-2.3-1.7-2.3-.9 0-1.5.6-1.7 1.2-.1.2-.1.5-.1.8V19h-3V9h3v1.3c.4-.6 1.1-1.5 2.7-1.5 2 0 3.5 1.3 3.5 4V19z" />
        </svg>
      );
    case "apple":
      return (
        <svg width="18" height="18" viewBox="0 0 24 24" aria-hidden fill="currentColor">
          <path d="M16.4 12.4c0-2.7 2.2-4 2.3-4.1-1.3-1.8-3.2-2.1-3.9-2.1-1.6-.2-3.2.9-4 .9-.8 0-2.1-.9-3.5-.9-1.8 0-3.5 1-4.4 2.6-1.9 3.2-.5 8 1.3 10.6.9 1.3 1.9 2.7 3.3 2.7 1.3 0 1.8-.8 3.5-.8s2.1.8 3.5.8c1.4 0 2.4-1.3 3.3-2.6 1-1.5 1.5-3 1.5-3.1-.1 0-2.9-1.1-2.9-4.0zM13.7 4.7c.7-.9 1.3-2.2 1.1-3.4-1.1.1-2.4.7-3.2 1.6-.7.8-1.4 2.1-1.2 3.3 1.3.1 2.5-.6 3.3-1.5z" />
        </svg>
      );
  }
}

function TopBar({
  t,
  activeSection,
  onCreateObject,
  onNavigate,
}: {
  t: (key: string) => string;
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
              Conservatio {t("top.webApp")}
            </p>
            <p className="text-xs text-heritage-text-secondary">
              {t(navLabelKey(activeSection))}
            </p>
          </div>
        </div>
        <div className="hidden flex-1 lg:block">
          <div className="flex items-center gap-3">
            <p className="text-sm font-medium text-heritage-text-secondary">
              {t(navLabelKey(activeSection))}
            </p>
            <span className="rounded-full bg-primary-50 px-3 py-1 text-xs font-bold uppercase tracking-wide text-primary">
              {t("top.webApp")}
            </span>
          </div>
        </div>
        <button
          onClick={onCreateObject}
          className="inline-flex items-center gap-2 rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-primary-dark"
          type="button"
        >
          <Plus size={18} />
          {t("top.newObject")}
        </button>
      </div>
      <div className="flex gap-2 overflow-x-auto px-4 pb-3 lg:hidden">
        {(
          [
            ["dashboard", LayoutDashboard],
            ["objects", Box],
            ["projects", FolderKanban],
            ["clients", Users],
            ["reports", FileText],
            ["settings", Settings],
          ] as Array<[WebSection, typeof Box]>
        ).map(([section, Icon]) => (
          <button
            key={section}
            onClick={() => onNavigate(section)}
            className={`flex shrink-0 items-center gap-2 rounded-full px-3 py-2 text-sm font-medium ${
              activeSection === section
                ? "bg-primary-50 text-primary"
                : "bg-white/80 text-heritage-text-secondary"
            }`}
            type="button"
          >
            <Icon size={16} />
            {t(navLabelKey(section))}
          </button>
        ))}
      </div>
    </header>
  );
}

function navLabelKey(section: WebSection) {
  return `nav.${section}`;
}

function DashboardView({
  t,
  lang,
  token,
  objects,
  clients,
  projects,
  reports,
  syncStatus,
  onCreate,
  onNavigate,
}: {
  t: (key: string) => string;
  lang: Lang;
  token: string;
  objects: ConservationObject[];
  clients: Client[];
  projects: Project[];
  reports: Report[];
  syncStatus: string;
  onCreate: (kind: "object" | "client" | "project" | "report") => void;
  onNavigate: (section: WebSection) => void;
}) {
  return (
    <div className="space-y-6">
      <div className="grid gap-6 lg:grid-cols-[1.6fr_1fr]">
        <section className="rounded-3xl border border-primary/10 bg-white p-6 shadow-sm lg:p-8">
          <p className="text-sm font-semibold uppercase tracking-[0.2em] text-primary">
            {t("dash.welcome")}
          </p>
          <div className="mt-3 flex flex-col gap-6 lg:flex-row lg:items-end lg:justify-between">
            <div>
              <h1 className="font-serif text-3xl font-bold text-heritage-text sm:text-4xl">
                {t("dash.title")}
              </h1>
              <p className="mt-3 max-w-2xl text-base leading-7 text-heritage-text-secondary">
                {t("dash.intro")}
              </p>
            </div>
            <button
              onClick={() => onCreate("object")}
              className="inline-flex items-center justify-center gap-2 rounded-2xl bg-primary px-5 py-3 text-sm font-semibold text-white shadow-sm transition hover:bg-primary-dark"
              type="button"
            >
              <Plus size={18} />
              {t("top.newObject")}
            </button>
          </div>
        </section>

        <section className="rounded-3xl border border-secondary/10 bg-secondary-900 p-6 text-white shadow-sm lg:p-8">
          <div className="flex items-start justify-between gap-4">
            <div>
              <p className="text-sm font-medium text-secondary-100">
                {t("dash.storageStatus")}
              </p>
              <h2 className="mt-2 text-2xl font-bold">{syncStatus}</h2>
            </div>
            <Cloud className="text-secondary-200" size={28} />
          </div>
          <p className="mt-4 text-sm leading-6 text-secondary-100">
            {token ? t("dash.signedInTip") : t("dash.offlineTip")}
          </p>
          <div className="mt-6 grid grid-cols-2 gap-3 text-sm">
            <StatusPill label={t("dash.localSave")} />
            <StatusPill label={token ? t("sync.signedIn") : t("dash.readyForSync")} />
          </div>
        </section>
      </div>

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        <StatCard label={t("stat.objects")} value={`${objects.length}`} icon={Box} />
        <StatCard label={t("stat.reports")} value={`${reports.length}`} icon={FileText} />
        <StatCard
          label={t("stat.projects")}
          value={`${projects.length}`}
          icon={FolderKanban}
        />
        <StatCard label={t("stat.clients")} value={`${clients.length}`} icon={Users} />
      </section>

      <div className="grid gap-6 xl:grid-cols-[0.95fr_1.45fr]">
        <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm lg:p-6">
          <SectionTitle
            title={t("dash.quickActions")}
            subtitle={t("dash.quickActionsSub")}
          />
          <div className="mt-5 grid gap-3 sm:grid-cols-2">
            <QuickActionCard
              title={t("top.newObject")}
              icon={Box}
              color="text-primary"
              onClick={() => onCreate("object")}
            />
            <QuickActionCard
              title={t("dash.takePhoto")}
              icon={Camera}
              color="text-secondary"
              onClick={() => onCreate("object")}
            />
            <QuickActionCard
              title={t("dash.newReport")}
              icon={FileText}
              color="text-tertiary"
              onClick={() => onCreate("report")}
            />
            <QuickActionCard
              title={t("dash.newProject")}
              icon={FolderKanban}
              color="text-primary-dark"
              onClick={() => onCreate("project")}
            />
          </div>
        </section>

        <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm lg:p-6">
          <div className="flex items-start justify-between gap-4">
            <SectionTitle
              title={t("dash.recentObjects")}
              subtitle={t("dash.recentObjectsSub")}
            />
            <button
              onClick={() => onNavigate("objects")}
              className="hidden items-center gap-2 rounded-xl bg-heritage-surface-variant px-3 py-2 text-sm font-semibold text-heritage-text sm:inline-flex"
              type="button"
            >
              {t("dash.viewAll")}
              <ArrowRight size={16} />
            </button>
          </div>
          <div className="mt-5 space-y-3">
            {objects.slice(0, 5).map((object) => (
              <ObjectRow key={object.id} object={object} lang={lang} token={token} />
            ))}
          </div>
        </section>
      </div>
    </div>
  );
}

function ObjectsView({
  t,
  lang,
  token,
  objects,
  query,
  onQueryChange,
  onCreateObject,
  onEditObject,
  onDeleteObject,
}: {
  t: (key: string) => string;
  lang: Lang;
  token: string;
  objects: ConservationObject[];
  query: string;
  onQueryChange: (query: string) => void;
  onCreateObject: () => void;
  onEditObject: (record: ConservationObject) => void;
  onDeleteObject: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title={t("objects.title")}
        subtitle={t("objects.subtitle")}
        actionLabel={t("objects.new")}
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
              placeholder={t("objects.searchPlaceholder")}
              type="search"
            />
          </label>
          <p className="text-sm font-medium text-heritage-text-secondary">
            {objects.length} {t("g.visible")}
          </p>
        </div>

        <div className="mt-5 grid gap-3 xl:grid-cols-2">
          {objects.map((object) => (
            <ObjectCard
              key={object.id}
              t={t}
              lang={lang}
              token={token}
              object={object}
              onEdit={() => onEditObject(object)}
              onDelete={() => onDeleteObject(object.id)}
            />
          ))}
        </div>
      </section>
    </div>
  );
}

function ProjectsView({
  t,
  lang,
  projects,
  clients,
  objects,
  onCreateProject,
  onEditProject,
  onDeleteProject,
}: {
  t: (key: string) => string;
  lang: Lang;
  projects: Project[];
  clients: Client[];
  objects: ConservationObject[];
  onCreateProject: () => void;
  onEditProject: (record: Project) => void;
  onDeleteProject: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title={t("projects.title")}
        subtitle={t("projects.subtitle")}
        actionLabel={t("projects.new")}
        onAction={onCreateProject}
      />
      <div className="grid gap-3 xl:grid-cols-2">
        {projects.map((project) => (
          <RecordCard
            key={project.id}
            icon={FolderKanban}
            title={project.title}
            badge={enumLabel(lang, "projectStatus", project.status)}
            editLabel={t("g.edit")}
            deleteLabel={t("g.delete")}
            onEdit={() => onEditProject(project)}
            onDelete={() => onDeleteProject(project.id)}
            rows={[
              [t("projects.client"), clientName(t, clients, project.clientId)],
              [t("projects.objects"), objectNames(t, objects, project.objectIds)],
              [t("projects.dates"), formatDateRange(t, project.startDate, project.endDate)],
              [t("projects.budget"), project.budget ? `${project.budget} ${project.currency}` : t("g.notSet")],
              [t("projects.description"), project.description || t("g.notSet")],
            ]}
          />
        ))}
      </div>
    </div>
  );
}

function ClientsView({
  t,
  lang,
  clients,
  projects,
  onCreateClient,
  onEditClient,
  onDeleteClient,
}: {
  t: (key: string) => string;
  lang: Lang;
  clients: Client[];
  projects: Project[];
  onCreateClient: () => void;
  onEditClient: (record: Client) => void;
  onDeleteClient: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title={t("clients.title")}
        subtitle={t("clients.subtitle")}
        actionLabel={t("clients.new")}
        onAction={onCreateClient}
      />
      <div className="grid gap-3 xl:grid-cols-2">
        {clients.map((client) => (
          <RecordCard
            key={client.id}
            icon={Users}
            title={client.name}
            badge={enumLabel(lang, "clientType", client.type)}
            editLabel={t("g.edit")}
            deleteLabel={t("g.delete")}
            onEdit={() => onEditClient(client)}
            onDelete={() => onDeleteClient(client.id)}
            rows={[
              [t("clients.contactPerson"), client.contactPerson || t("g.notSet")],
              [t("login.email"), client.email || t("g.notSet")],
              [t("clients.phone"), client.phone || t("g.notSet")],
              [t("clients.address"), client.address || t("g.notSet")],
              [
                t("clients.projects"),
                `${projects.filter((project) => project.clientId === client.id).length}`,
              ],
              [t("clients.notes"), client.notes || t("g.notSet")],
            ]}
          />
        ))}
      </div>
    </div>
  );
}

function ReportsView({
  t,
  lang,
  token,
  reports,
  objects,
  onCreateReport,
  onEditReport,
  onDeleteReport,
}: {
  t: (key: string) => string;
  lang: Lang;
  token: string;
  reports: Report[];
  objects: ConservationObject[];
  onCreateReport: () => void;
  onEditReport: (record: Report) => void;
  onDeleteReport: (id: string) => void;
}) {
  return (
    <div className="space-y-6">
      <PageHeader
        title={t("reports.title")}
        subtitle={t("reports.subtitle")}
        actionLabel={t("reports.new")}
        onAction={onCreateReport}
      />
      <div className="grid gap-3 xl:grid-cols-2">
        {reports.map((report) => (
          <ReportRecordCard
            key={report.id}
            t={t}
            lang={lang}
            token={token}
            report={report}
            objects={objects}
            onEdit={() => onEditReport(report)}
            onDelete={() => onDeleteReport(report.id)}
          />
        ))}
      </div>
    </div>
  );
}

function ReportRecordCard({
  t,
  lang,
  report,
  objects,
  token,
  onEdit,
  onDelete,
}: {
  t: (key: string) => string;
  lang: Lang;
  report: Report;
  objects: ConservationObject[];
  token: string;
  onEdit: () => void;
  onDelete: () => void;
}) {
  return (
    <article className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
      <div className="flex items-start justify-between gap-4">
        <div className="flex min-w-0 items-start gap-3">
          <div className="flex h-12 w-12 shrink-0 items-center justify-center rounded-2xl bg-primary-50 text-primary">
            <FileText size={22} />
          </div>
          <div className="min-w-0">
            <h2 className="truncate font-semibold">
              {enumLabel(lang, "reportType", report.reportType)}
            </h2>
            <p className="mt-1 text-xs font-semibold uppercase tracking-wide text-primary">
              {enumLabel(lang, "condition", report.condition)}
            </p>
          </div>
        </div>
        <div className="flex gap-1">
          <EditButton onEdit={onEdit} label={t("g.edit")} />
          <DeleteButton onDelete={onDelete} label={t("g.delete")} />
        </div>
      </div>
      <div className="mt-5 grid gap-3 text-sm sm:grid-cols-2">
        <MetaBlock
          label={t("reports.object")}
          value={objectName(t, objects, report.objectId)}
        />
        <MetaBlock label={t("reports.examiner")} value={report.examiner || t("g.notSet")} />
        <MetaBlock
          label={t("reports.date")}
          value={report.examinationDate || t("g.notSet")}
        />
        <MetaBlock label={t("reports.notes")} value={report.notes || t("g.notSet")} />
        <MetaBlock
          label={t("reports.recommendations")}
          value={report.recommendations || t("g.notSet")}
        />
      </div>
      <ImageGrid t={t} images={report.images} token={token} />
    </article>
  );
}

function SettingsView({
  t,
  language,
  onLanguageChange,
  syncAccount,
  syncStatus,
  onSaveProfile,
  onClearAll,
  onLoadSample,
  onRefresh,
  onSignOut,
}: {
  t: (key: string) => string;
  language: Lang;
  onLanguageChange: (language: Lang) => void;
  syncAccount: SyncAccount;
  syncStatus: string;
  onSaveProfile: (displayName: string) => Promise<string | null>;
  onClearAll: () => void;
  onLoadSample: () => void;
  onRefresh: () => void;
  onSignOut: () => void;
}) {
  const isSignedIn = !!syncAccount.token;
  const [displayName, setDisplayName] = useState(syncAccount.displayName);
  const [profileMessage, setProfileMessage] = useState<{
    kind: "ok" | "error";
    text: string;
  } | null>(null);
  const [savingProfile, setSavingProfile] = useState(false);

  useEffect(() => {
    setDisplayName(syncAccount.displayName);
  }, [syncAccount.displayName]);

  async function handleSaveProfile() {
    setSavingProfile(true);
    setProfileMessage(null);
    const error = await onSaveProfile(displayName);
    setSavingProfile(false);
    setProfileMessage(
      error
        ? { kind: "error", text: error }
        : { kind: "ok", text: t("settings.profileSaved") },
    );
  }

  return (
    <div className="space-y-6">
      <PageHeader title={t("settings.title")} subtitle={t("settings.subtitle")} />

      <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
        <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
          <div className="flex items-center gap-4">
            <div className="flex h-14 w-14 shrink-0 items-center justify-center rounded-2xl bg-primary-50 text-primary">
              <Users size={24} />
            </div>
            <div className="min-w-0 flex-1">
              <h2 className="font-semibold">
                {isSignedIn
                  ? syncAccount.displayName || syncAccount.email
                  : t("settings.offlineMode")}
              </h2>
              <p className="text-sm text-heritage-text-secondary">
                {isSignedIn ? syncAccount.email : t("settings.offlineHint")}
              </p>
            </div>
          </div>
          <div className="flex gap-3">
            {isSignedIn && (
              <button
                onClick={onRefresh}
                className="rounded-xl bg-heritage-surface-variant px-4 py-2.5 text-sm font-semibold text-heritage-text transition hover:bg-primary-50 hover:text-primary"
                type="button"
              >
                {t("g.syncNow")}
              </button>
            )}
            {isSignedIn && (
              <button
                onClick={onSignOut}
                className="rounded-xl bg-heritage-surface-variant px-4 py-2.5 text-sm font-semibold text-heritage-text transition hover:bg-red-50 hover:text-red-600"
                type="button"
              >
                {t("g.signOut")}
              </button>
            )}
          </div>
        </div>
        {isSignedIn && (
          <p className="mt-3 text-xs text-heritage-text-secondary">{syncStatus}</p>
        )}
      </section>

      <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
        <h2 className="text-base font-semibold">{t("settings.profile")}</h2>
        <div className="mt-4 grid gap-4 lg:grid-cols-[1fr_auto] lg:items-end">
          <div className="space-y-3">
            <label className="block space-y-2 text-sm font-medium">
              <span>{t("settings.displayName")}</span>
              <input
                value={displayName}
                onChange={(event) => setDisplayName(event.target.value)}
                disabled={!isSignedIn}
                className="w-full rounded-2xl border border-heritage-outline/20 bg-white px-4 py-3 outline-none focus:border-primary disabled:cursor-not-allowed disabled:bg-heritage-surface-variant"
                type="text"
              />
            </label>
            <label className="block space-y-2 text-sm font-medium">
              <span>{t("settings.email")}</span>
              <input
                value={syncAccount.email}
                disabled
                className="w-full rounded-2xl border border-heritage-outline/20 bg-heritage-surface-variant px-4 py-3 text-heritage-text-secondary outline-none"
                type="email"
              />
            </label>
          </div>
          <button
            onClick={() => void handleSaveProfile()}
            disabled={!isSignedIn || savingProfile}
            className="rounded-xl bg-primary px-4 py-2.5 text-sm font-semibold text-white transition hover:bg-primary-dark disabled:cursor-not-allowed disabled:opacity-50"
            type="button"
          >
            {savingProfile ? t("settings.savingProfile") : t("settings.saveProfile")}
          </button>
        </div>
        {profileMessage && (
          <p
            className={`mt-3 text-xs ${
              profileMessage.kind === "ok" ? "text-condition-good" : "text-red-600"
            }`}
          >
            {profileMessage.text}
          </p>
        )}
      </section>

      <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
        <h2 className="text-base font-semibold">{t("settings.language")}</h2>
        <div className="mt-4 grid gap-2 sm:grid-cols-2 lg:max-w-md">
          {supportedLanguages.map((option) => (
            <button
              key={option.code}
              onClick={() => onLanguageChange(option.code)}
              className={`flex items-center justify-between rounded-2xl border px-4 py-3 text-sm font-semibold transition ${
                option.code === language
                  ? "border-primary bg-primary-50 text-primary"
                  : "border-heritage-outline/20 bg-heritage-surface-variant text-heritage-text hover:bg-white"
              }`}
              type="button"
            >
              <span className="flex items-center gap-2">
                <Globe size={16} />
                {option.label}
              </span>
              {option.code === language && <CheckCircle2 size={16} />}
            </button>
          ))}
        </div>
      </section>

      <div className="grid gap-4 lg:grid-cols-3">
        <SettingsGroup
          title={t("settings.reports")}
          items={[
            { label: t("settings.templates"), icon: FileText, detail: t("settings.templatesDetail") },
            { label: t("settings.exportSettings"), icon: Upload, detail: t("settings.exportDetail") },
          ]}
        />
        <SettingsGroup
          title={t("settings.app")}
          items={[
            { label: t("settings.appearance"), icon: Palette, detail: t("settings.theme") },
            {
              label: t("settings.storage"),
              icon: HardDrive,
              detail: isSignedIn ? t("settings.cloudSync") : t("settings.localStorage"),
            },
            { label: t("settings.about"), icon: Info, detail: "v0.1.0" },
          ]}
        />
        <SettingsGroup
          title={t("settings.syncStorage")}
          items={[
            { label: t("settings.account"), icon: Users, detail: isSignedIn ? syncAccount.email : t("g.offline") },
            { label: t("dash.storageStatus"), icon: Cloud, detail: syncStatus },
          ]}
        />
      </div>

      <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between">
          <div>
            <h2 className="font-semibold">{t("settings.dangerTitle")}</h2>
            <p className="mt-1 text-sm text-heritage-text-secondary">
              {t("settings.dangerSub")}
            </p>
          </div>
          <div className="flex gap-3">
            <button
              onClick={onLoadSample}
              className="inline-flex items-center justify-center rounded-xl bg-heritage-surface-variant px-4 py-2.5 text-sm font-semibold text-heritage-text transition hover:bg-primary-50 hover:text-primary"
              type="button"
            >
              {t("settings.loadSample")}
            </button>
            <button
              onClick={onClearAll}
              className="inline-flex items-center justify-center rounded-xl bg-red-50 px-4 py-2.5 text-sm font-semibold text-red-600 transition hover:bg-red-100"
              type="button"
            >
              {t("settings.clearAll")}
            </button>
          </div>
        </div>
      </section>
    </div>
  );
}

function SettingsGroup({
  title,
  items,
}: {
  title: string;
  items: Array<{ label: string; icon: typeof Box; detail: string }>;
}) {
  return (
    <section className="rounded-3xl border border-heritage-outline/10 bg-white p-5 shadow-sm">
      <h2 className="text-base font-semibold">{title}</h2>
      <div className="mt-4 space-y-2">
        {items.map((item) => (
          <div
            key={item.label}
            className="flex w-full items-center justify-between gap-3 rounded-2xl bg-heritage-surface-variant px-4 py-3 text-left"
          >
            <span className="flex items-center gap-3 text-sm font-medium">
              <item.icon size={18} />
              {item.label}
            </span>
            <span className="truncate text-right text-xs text-heritage-text-secondary">
              {item.detail}
            </span>
          </div>
        ))}
      </div>
    </section>
  );
}

function ObjectModal({
  t,
  lang,
  token,
  mode,
  initial,
  onClose,
  onSave,
}: {
  t: (key: string) => string;
  lang: Lang;
  token: string;
  mode: "create" | "edit";
  initial?: ConservationObject;
  onClose: () => void;
  onSave: (form: ObjectFormState) => void;
}) {
  const [form, setForm] = useState<ObjectFormState>(() =>
    initial
      ? {
          title: initial.title,
          objectType: initial.objectType,
          materialsText: initial.materials.join(", "),
          ownerName: initial.ownerName,
          locationDescription: initial.locationDescription,
          inventoryNumber: initial.inventoryNumber,
          description: initial.description,
          height: initial.dimensions.height,
          width: initial.dimensions.width,
          depth: initial.dimensions.depth,
          unit: initial.dimensions.unit,
          images: initial.images,
        }
      : emptyObjectForm,
  );

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
      t={t}
      eyebrow={mode === "edit" ? t("objects.edit") : t("objects.new")}
      title={mode === "edit" ? t("objects.edit") : t("objects.create")}
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.title.trim()}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title={t("objects.basic")}>
          <TextField
            label={t("objects.objectTitle")}
            value={form.title}
            onChange={(value) => update("title", value)}
            required
          />
          <SelectField
            label={t("objects.type")}
            value={form.objectType}
            options={objectTypes}
            optionLabels={objectTypes.reduce<Record<string, string>>(
              (acc, type) => {
                acc[type] = enumLabel(lang, "objectType", type);
                return acc;
              },
              {},
            )}
            onChange={(value) => update("objectType", value as ObjectType)}
          />
          <TextField
            label={t("objects.inventoryNumber")}
            value={form.inventoryNumber}
            onChange={(value) => update("inventoryNumber", value)}
          />
        </FormSection>

        <FormSection title={t("objects.materials")}>
          <TextField
            label={t("objects.materials")}
            value={form.materialsText}
            onChange={(value) => update("materialsText", value)}
            placeholder={t("objects.materialsPlaceholder")}
          />
          <p className="text-xs text-heritage-text-secondary">
            {t("objects.materialsHint")}
          </p>
        </FormSection>

        <FormSection title={t("objects.dimensions")}>
          <div className="grid grid-cols-3 gap-3">
            <TextField label="H" value={form.height} onChange={(value) => update("height", value)} />
            <TextField label="W" value={form.width} onChange={(value) => update("width", value)} />
            <TextField label="D" value={form.depth} onChange={(value) => update("depth", value)} />
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

        <FormSection title={t("objects.locationOwner")}>
          <TextField
            label={t("objects.ownerName")}
            value={form.ownerName}
            onChange={(value) => update("ownerName", value)}
          />
          <TextField
            label={t("objects.locationDescription")}
            value={form.locationDescription}
            onChange={(value) => update("locationDescription", value)}
          />
        </FormSection>

        <FormSection title={t("objects.photos")}>
          <PhotoInput
            t={t}
            token={token}
            images={form.images}
            onChange={(images) => update("images", images)}
          />
        </FormSection>

        <FormSection title={t("objects.description")}>
          <TextAreaField
            label={t("objects.description")}
            value={form.description}
            onChange={(value) => update("description", value)}
            placeholder={t("objects.descPlaceholder")}
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function ClientModal({
  t,
  lang,
  mode,
  initial,
  onClose,
  onSave,
}: {
  t: (key: string) => string;
  lang: Lang;
  mode: "create" | "edit";
  initial?: Client;
  onClose: () => void;
  onSave: (form: ClientFormState) => void;
}) {
  const [form, setForm] = useState<ClientFormState>(() =>
    initial
      ? {
          name: initial.name,
          type: initial.type,
          contactPerson: initial.contactPerson,
          email: initial.email,
          phone: initial.phone,
          address: initial.address,
          notes: initial.notes,
        }
      : emptyClientForm,
  );

  function update<Key extends keyof ClientFormState>(
    key: Key,
    value: ClientFormState[Key],
  ) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!form.name.trim()) return;
    onSave(form);
  }

  return (
    <ModalFrame
      t={t}
      eyebrow={mode === "edit" ? t("clients.edit") : t("clients.new")}
      title={mode === "edit" ? t("clients.edit") : t("clients.create")}
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.name.trim()}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title={t("clients.client")}>
          <TextField
            label={t("clients.name")}
            value={form.name}
            onChange={(value) => update("name", value)}
            required
          />
          <SelectField
            label={t("clients.type")}
            value={form.type}
            options={clientTypes}
            optionLabels={clientTypes.reduce<Record<string, string>>(
              (acc, type) => {
                acc[type] = enumLabel(lang, "clientType", type);
                return acc;
              },
              {},
            )}
            onChange={(value) => update("type", value)}
          />
          <TextField
            label={t("clients.contactPerson")}
            value={form.contactPerson}
            onChange={(value) => update("contactPerson", value)}
          />
        </FormSection>
        <FormSection title={t("clients.contact")}>
          <TextField
            label={t("login.email")}
            value={form.email}
            onChange={(value) => update("email", value)}
            type="email"
          />
          <TextField
            label={t("clients.phone")}
            value={form.phone}
            onChange={(value) => update("phone", value)}
          />
          <TextField
            label={t("clients.address")}
            value={form.address}
            onChange={(value) => update("address", value)}
          />
        </FormSection>
        <FormSection title={t("clients.notes")}>
          <TextAreaField
            label={t("clients.notes")}
            value={form.notes}
            onChange={(value) => update("notes", value)}
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function ProjectModal({
  t,
  lang,
  mode,
  initial,
  clients,
  objects,
  onClose,
  onSave,
}: {
  t: (key: string) => string;
  lang: Lang;
  mode: "create" | "edit";
  initial?: Project;
  clients: Client[];
  objects: ConservationObject[];
  onClose: () => void;
  onSave: (form: ProjectFormState) => void;
}) {
  const [form, setForm] = useState<ProjectFormState>(() =>
    initial
      ? {
          title: initial.title,
          clientId: initial.clientId,
          objectIds: initial.objectIds,
          status: initial.status,
          startDate: initial.startDate,
          endDate: initial.endDate,
          description: initial.description,
          budget: initial.budget,
          currency: initial.currency,
        }
      : { ...emptyProjectForm, clientId: clients[0]?.id ?? "" },
  );

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
    if (!form.title.trim()) return;
    onSave(form);
  }

  return (
    <ModalFrame
      t={t}
      eyebrow={mode === "edit" ? t("projects.edit") : t("projects.new")}
      title={mode === "edit" ? t("projects.edit") : t("projects.create")}
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.title.trim()}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title={t("projects.project")}>
          <TextField
            label={t("projects.titleField")}
            value={form.title}
            onChange={(value) => update("title", value)}
            required
          />
          <SelectField
            label={t("projects.client")}
            value={form.clientId}
            options={["", ...clients.map((client) => client.id)]}
            optionLabels={{ "": t("projects.noClient"), ...labelMap(clients) }}
            onChange={(value) => update("clientId", value)}
          />
          <SelectField
            label={t("projects.status")}
            value={form.status}
            options={projectStatuses}
            optionLabels={projectStatuses.reduce<Record<string, string>>(
              (acc, status) => {
                acc[status] = enumLabel(lang, "projectStatus", status);
                return acc;
              },
              {},
            )}
            onChange={(value) => update("status", value as ProjectStatus)}
          />
        </FormSection>
        <FormSection title={t("projects.timelineBudget")}>
          <TextField
            label={t("projects.startDate")}
            value={form.startDate}
            onChange={(value) => update("startDate", value)}
            type="date"
          />
          <TextField
            label={t("projects.endDate")}
            value={form.endDate}
            onChange={(value) => update("endDate", value)}
            type="date"
          />
          <div className="grid grid-cols-[1fr_96px] gap-3">
            <TextField
              label={t("projects.budget")}
              value={form.budget}
              onChange={(value) => update("budget", value)}
            />
            <TextField
              label={t("projects.currency")}
              value={form.currency}
              onChange={(value) => update("currency", value)}
            />
          </div>
        </FormSection>
        <FormSection title={t("projects.linkedObjects")}>
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
        <FormSection title={t("projects.description")}>
          <TextAreaField
            label={t("projects.description")}
            value={form.description}
            onChange={(value) => update("description", value)}
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function ReportModal({
  t,
  lang,
  token,
  mode,
  initial,
  objects,
  onClose,
  onSave,
}: {
  t: (key: string) => string;
  lang: Lang;
  token: string;
  mode: "create" | "edit";
  initial?: Report;
  objects: ConservationObject[];
  onClose: () => void;
  onSave: (form: ReportFormState) => void;
}) {
  const [form, setForm] = useState<ReportFormState>(() =>
    initial
      ? {
          objectId: initial.objectId,
          reportType: initial.reportType,
          condition: initial.condition,
          examiner: initial.examiner,
          examinationDate: initial.examinationDate,
          notes: initial.notes,
          recommendations: initial.recommendations,
          images: initial.images,
        }
      : {
          ...emptyReportForm,
          objectId: objects[0]?.id ?? "",
          examinationDate: today(),
        },
  );

  function update<Key extends keyof ReportFormState>(
    key: Key,
    value: ReportFormState[Key],
  ) {
    setForm((current) => ({ ...current, [key]: value }));
  }

  function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    if (!form.objectId) return;
    onSave(form);
  }

  return (
    <ModalFrame
      t={t}
      eyebrow={mode === "edit" ? t("reports.edit") : t("reports.new")}
      title={mode === "edit" ? t("reports.edit") : t("reports.create")}
      onClose={onClose}
      onSubmit={handleSubmit}
      submitDisabled={!form.objectId}
    >
      <div className="grid gap-5 lg:grid-cols-2">
        <FormSection title={t("reports.report")}>
          <SelectField
            label={t("reports.object")}
            value={form.objectId}
            options={objects.map((object) => object.id)}
            optionLabels={labelMap(objects)}
            onChange={(value) => update("objectId", value)}
          />
          <SelectField
            label={t("reports.reportType")}
            value={form.reportType}
            options={reportTypes}
            optionLabels={reportTypes.reduce<Record<string, string>>(
              (acc, type) => {
                acc[type] = enumLabel(lang, "reportType", type);
                return acc;
              },
              {},
            )}
            onChange={(value) => update("reportType", value)}
          />
          <SelectField
            label={t("reports.condition")}
            value={form.condition}
            options={conditionRatings}
            optionLabels={conditionRatings.reduce<Record<string, string>>(
              (acc, condition) => {
                acc[condition] = enumLabel(lang, "condition", condition);
                return acc;
              },
              {},
            )}
            onChange={(value) => update("condition", value as ConditionRating)}
          />
        </FormSection>
        <FormSection title={t("reports.examination")}>
          <TextField
            label={t("reports.examiner")}
            value={form.examiner}
            onChange={(value) => update("examiner", value)}
          />
          <TextField
            label={t("reports.date")}
            value={form.examinationDate}
            onChange={(value) => update("examinationDate", value)}
            type="date"
          />
          <PhotoInput
            t={t}
            token={token}
            images={form.images}
            onChange={(images) => update("images", images)}
          />
        </FormSection>
        <FormSection title={t("reports.notes")}>
          <TextAreaField
            label={t("reports.notes")}
            value={form.notes}
            onChange={(value) => update("notes", value)}
          />
        </FormSection>
        <FormSection title={t("reports.recommendations")}>
          <TextAreaField
            label={t("reports.recommendations")}
            value={form.recommendations}
            onChange={(value) => update("recommendations", value)}
          />
        </FormSection>
      </div>
    </ModalFrame>
  );
}

function ModalFrame({
  t,
  eyebrow,
  title,
  children,
  submitDisabled,
  onClose,
  onSubmit,
}: {
  t: (key: string) => string;
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
        <div className="max-h-[66vh] overflow-y-auto p-5 lg:p-6">{children}</div>
        <div className="flex items-center justify-end gap-3 border-t border-heritage-outline/10 p-5 lg:p-6">
          <button
            onClick={onClose}
            className="rounded-xl px-4 py-2.5 text-sm font-semibold text-heritage-text-secondary hover:bg-heritage-surface-variant"
            type="button"
          >
            {t("g.cancel")}
          </button>
          <button
            className="rounded-xl bg-primary px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-primary-dark disabled:cursor-not-allowed disabled:opacity-50"
            disabled={submitDisabled}
            type="submit"
          >
            {t("g.save")}
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
    </button>
  );
}

function ObjectRow({
  object,
  lang,
  token,
}: {
  object: ConservationObject;
  lang: Lang;
  token: string;
}) {
  return (
    <div className="flex items-center gap-3 rounded-2xl bg-heritage-surface-variant p-3">
      <ObjectThumb object={object} token={token} />
      <div className="min-w-0 flex-1">
        <p className="truncate text-sm font-semibold">{object.title}</p>
        <p className="truncate text-xs text-heritage-text-secondary">
          {enumLabel(lang, "objectType", object.objectType)}
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
  t,
  lang,
  object,
  token,
  onEdit,
  onDelete,
}: {
  t: (key: string) => string;
  lang: Lang;
  object: ConservationObject;
  token: string;
  onEdit: () => void;
  onDelete: () => void;
}) {
  return (
    <article className="rounded-3xl border border-heritage-outline/10 bg-heritage-surface-variant p-4">
      <div className="flex gap-4">
        <ObjectThumb object={object} token={token} large />
        <div className="min-w-0 flex-1">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-start sm:justify-between">
            <div>
              <h2 className="font-semibold">{object.title}</h2>
              <p className="mt-1 text-sm text-heritage-text-secondary">
                {enumLabel(lang, "objectType", object.objectType)}
                {object.inventoryNumber ? ` - ${object.inventoryNumber}` : ""}
              </p>
            </div>
            <div className="flex items-center gap-2">
              <ConditionBadge label={t("g.documented")} />
              <EditButton onEdit={onEdit} label={t("g.edit")} />
              <DeleteButton onDelete={onDelete} label={t("g.delete")} />
            </div>
          </div>
          <div className="mt-4 grid gap-3 text-sm sm:grid-cols-2">
            <MetaBlock label={t("objects.owner")} value={object.ownerName || t("g.notSet")} />
            <MetaBlock
              label={t("objects.location")}
              value={object.locationDescription || t("g.notSet")}
            />
            <MetaBlock
              label={t("objects.materials")}
              value={object.materials.length ? object.materials.join(", ") : t("g.notSet")}
            />
            <MetaBlock label={t("objects.dimensions")} value={formatDimensions(t, object)} />
            <MetaBlock
              label={t("objects.description")}
              value={object.description || t("g.notSet")}
            />
          </div>
          <ImageGrid t={t} images={object.images} token={token} />
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
  editLabel,
  deleteLabel,
  onEdit,
  onDelete,
}: {
  icon: typeof Box;
  title: string;
  badge: string;
  rows: Array<[string, string]>;
  editLabel: string;
  deleteLabel: string;
  onEdit: () => void;
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
        <div className="flex gap-1">
          <EditButton onEdit={onEdit} label={editLabel} />
          <DeleteButton onDelete={onDelete} label={deleteLabel} />
        </div>
      </div>
      <div className="mt-5 grid gap-3 text-sm sm:grid-cols-2">
        {rows.map(([label, value]) => (
          <MetaBlock key={label} label={label} value={value} />
        ))}
      </div>
    </article>
  );
}

function EditButton({
  label,
  onEdit,
}: {
  label: string;
  onEdit: () => void;
}) {
  return (
    <button
      onClick={onEdit}
      className="rounded-xl p-2 text-heritage-text-secondary transition hover:bg-primary-50 hover:text-primary"
      type="button"
      aria-label={label}
      title={label}
    >
      <Pencil size={17} />
    </button>
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
      className="rounded-xl p-2 text-heritage-text-secondary transition hover:bg-red-50 hover:text-red-600"
      type="button"
      aria-label={label}
      title={label}
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

async function fileToDataUrl(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(typeof reader.result === "string" ? reader.result : "");
    reader.onerror = () => reject(reader.error);
    reader.readAsDataURL(file);
  });
}

function looksLikeServerImageId(name: string) {
  // Server returns "<uuid>.<ext>" — uuid format matches 8-4-4-4-12 hex chars.
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\.[A-Za-z0-9]+$/.test(
    name,
  );
}

async function uploadImageBlob(
  image: ImageAsset,
  account: SyncAccount,
): Promise<string | null> {
  if (!account.token || !image.dataUrl) return null;
  try {
    const fetched = await fetch(image.dataUrl);
    const blob = await fetched.blob();
    const filename = image.name || "photo.jpg";
    const form = new FormData();
    form.append("file", new File([blob], filename, { type: blob.type || "image/jpeg" }));
    const response = await fetch(`${API_BASE_URL}/api/images`, {
      method: "POST",
      headers: { Authorization: `Bearer ${account.token}` },
      body: form,
    });
    if (!response.ok) return null;
    const json = (await response.json()) as { imageId?: string };
    return json.imageId ?? null;
  } catch {
    return null;
  }
}

async function compressImage(
  file: File,
  maxDim = 2048,
  quality = 0.88,
): Promise<string> {
  const rawDataUrl = await fileToDataUrl(file);
  if (!rawDataUrl.startsWith("data:image/")) return rawDataUrl;

  return new Promise((resolve) => {
    const image = new Image();
    image.onload = () => {
      const longest = Math.max(image.width, image.height);
      const scale = longest > maxDim ? maxDim / longest : 1;
      const targetWidth = Math.round(image.width * scale);
      const targetHeight = Math.round(image.height * scale);

      const canvas = document.createElement("canvas");
      canvas.width = targetWidth;
      canvas.height = targetHeight;
      const context = canvas.getContext("2d");
      if (!context) {
        resolve(rawDataUrl);
        return;
      }
      context.drawImage(image, 0, 0, targetWidth, targetHeight);
      try {
        resolve(canvas.toDataURL("image/jpeg", quality));
      } catch {
        resolve(rawDataUrl);
      }
    };
    image.onerror = () => resolve(rawDataUrl);
    image.src = rawDataUrl;
  });
}

function PhotoInput({
  t,
  images,
  onChange,
  token,
}: {
  t: (key: string) => string;
  images: ImageAsset[];
  onChange: (images: ImageAsset[]) => void;
  token: string;
}) {
  async function handleFiles(files: FileList | null) {
    if (!files || files.length === 0) return;
    const additions: ImageAsset[] = [];
    for (const file of Array.from(files)) {
      try {
        const dataUrl = await compressImage(file);
        additions.push({ name: file.name, dataUrl });
      } catch {
        // Skip unreadable files instead of crashing the form.
      }
    }
    if (additions.length > 0) onChange([...images, ...additions]);
  }

  function removeAt(index: number) {
    onChange(images.filter((_, i) => i !== index));
  }

  return (
    <>
      <label className="flex cursor-pointer flex-col items-center justify-center rounded-2xl border border-dashed border-heritage-outline/30 bg-heritage-surface-variant px-4 py-8 text-center transition hover:border-primary hover:bg-primary-50">
        <ImagePlus className="text-primary" size={30} />
        <span className="mt-3 text-sm font-semibold">{t("objects.attach")}</span>
        <span className="mt-1 text-xs text-heritage-text-secondary">
          {t("objects.attachHint")}
        </span>
        <input
          className="hidden"
          multiple
          type="file"
          accept="image/*"
          onChange={(event) => {
            void handleFiles(event.target.files);
            event.target.value = "";
          }}
        />
      </label>
      <p className="text-xs text-heritage-text-secondary">{t("objects.photosHint")}</p>
      {images.length > 0 && (
        <div className="grid grid-cols-3 gap-2 sm:grid-cols-4">
          {images.map((image, index) => (
            <div
              key={`${image.name}-${index}`}
              className="group relative aspect-square overflow-hidden rounded-2xl bg-white"
            >
              <ImageRenderer
                image={image}
                token={token}
                className="h-full w-full object-cover"
              />
              <button
                type="button"
                onClick={() => removeAt(index)}
                className="absolute right-1 top-1 rounded-full bg-white/90 p-1 text-heritage-text shadow-sm transition hover:bg-red-50 hover:text-red-600"
                aria-label="Remove photo"
              >
                <X size={12} />
              </button>
            </div>
          ))}
        </div>
      )}
    </>
  );
}

function ImageGrid({
  t,
  images,
  token,
}: {
  t: (key: string) => string;
  images: ImageAsset[];
  token: string;
}) {
  if (images.length === 0) {
    return (
      <p className="mt-4 text-xs text-heritage-text-secondary">
        {t("objects.noPhotos")}
      </p>
    );
  }
  return (
    <div className="mt-4 grid grid-cols-3 gap-2 sm:grid-cols-4">
      {images.map((image, index) => (
        <div
          key={`${image.name}-${index}`}
          className="aspect-square overflow-hidden rounded-2xl bg-white"
        >
          <ImageRenderer
            image={image}
            token={token}
            className="h-full w-full object-cover"
          />
        </div>
      ))}
    </div>
  );
}

function ObjectThumb({
  object,
  token,
  large = false,
}: {
  object: ConservationObject;
  token: string;
  large?: boolean;
}) {
  const preview = object.images[0];
  const sizeClass = large ? "h-16 w-16" : "h-12 w-12";

  if (preview && (preview.dataUrl || (token && looksLikeServerImageId(preview.name)))) {
    return (
      <div className={`overflow-hidden rounded-2xl shadow-sm ${sizeClass}`}>
        <ImageRenderer
          image={preview}
          token={token}
          alt={object.title}
          className="h-full w-full object-cover"
        />
      </div>
    );
  }

  return (
    <div
      className={`flex shrink-0 items-center justify-center rounded-2xl bg-white text-primary shadow-sm ${sizeClass}`}
    >
      <Box size={large ? 26 : 20} />
      <span className="sr-only">{object.objectType}</span>
    </div>
  );
}

function AuthedImage({
  imageId,
  token,
  alt,
  className,
}: {
  imageId: string;
  token: string;
  alt: string;
  className: string;
}) {
  const [url, setUrl] = useState<string | null>(null);
  const [failed, setFailed] = useState(false);

  useEffect(() => {
    if (!token || !imageId) {
      setUrl(null);
      return;
    }
    let cancelled = false;
    let createdUrl: string | null = null;
    setFailed(false);
    fetch(`${API_BASE_URL}/api/images/${imageId}`, {
      headers: { Authorization: `Bearer ${token}` },
    })
      .then((response) => (response.ok ? response.blob() : null))
      .then((blob) => {
        if (cancelled || !blob) {
          if (!cancelled) setFailed(true);
          return;
        }
        createdUrl = URL.createObjectURL(blob);
        setUrl(createdUrl);
      })
      .catch(() => {
        if (!cancelled) setFailed(true);
      });
    return () => {
      cancelled = true;
      if (createdUrl) URL.revokeObjectURL(createdUrl);
    };
  }, [imageId, token]);

  if (failed) {
    return (
      <div
        className={`flex items-center justify-center bg-heritage-surface-variant px-1 text-center text-[10px] text-heritage-text-secondary ${className}`}
      >
        {alt}
      </div>
    );
  }

  if (!url) {
    return <div className={`bg-heritage-surface-variant ${className}`} />;
  }

  // eslint-disable-next-line @next/next/no-img-element
  return <img src={url} alt={alt} className={className} />;
}

function ImageRenderer({
  image,
  token,
  alt,
  className,
}: {
  image: ImageAsset;
  token: string;
  alt?: string;
  className: string;
}) {
  const label = alt ?? image.name;
  if (image.dataUrl) {
    // eslint-disable-next-line @next/next/no-img-element
    return <img src={image.dataUrl} alt={label} className={className} />;
  }
  if (token && looksLikeServerImageId(image.name)) {
    return (
      <AuthedImage
        imageId={image.name}
        token={token}
        alt={label}
        className={className}
      />
    );
  }
  return (
    <div
      className={`flex items-center justify-center bg-heritage-surface-variant px-1 text-center text-[10px] text-heritage-text-secondary ${className}`}
    >
      {label}
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

function labelMap(records: Array<{ id: string; title?: string; name?: string }>) {
  return records.reduce<Record<string, string>>((labels, record) => {
    labels[record.id] = record.title ?? record.name ?? record.id;
    return labels;
  }, {});
}

function clientName(
  t: (key: string) => string,
  clients: Client[],
  clientId: string,
) {
  return clients.find((client) => client.id === clientId)?.name ?? t("projects.noClient");
}

function objectName(
  t: (key: string) => string,
  objects: ConservationObject[],
  objectId: string,
) {
  return (
    objects.find((object) => object.id === objectId)?.title ??
    t("reports.missingObject")
  );
}

function objectNames(
  t: (key: string) => string,
  objects: ConservationObject[],
  objectIds: string[],
) {
  if (!objectIds.length) {
    return t("projects.noObjects");
  }
  return objectIds.map((objectId) => objectName(t, objects, objectId)).join(", ");
}

function formatDateRange(
  t: (key: string) => string,
  startDate: string,
  endDate: string,
) {
  if (!startDate && !endDate) {
    return t("g.notSet");
  }
  return [startDate || "—", endDate || "—"].join(" → ");
}

function formatDimensions(
  t: (key: string) => string,
  object: ConservationObject,
) {
  const values = [
    object.dimensions.height,
    object.dimensions.width,
    object.dimensions.depth,
  ].filter(Boolean);

  if (!values.length) {
    return t("g.notSet");
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
    id: toServerId(object.id),
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
    imageIds: object.images.map((image) => image.name),
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
    images: (object.imageIds ?? []).map((name) => ({ name, dataUrl: "" })),
    createdAt: object.createdAt.slice(0, 10),
    updatedAt: object.updatedAt.slice(0, 10),
  };
}

function mergeImagesIntoObject(
  object: ConservationObject,
  local: ImageAsset[] | undefined,
): ConservationObject {
  if (!local) return object;
  const lookup = new Map(local.map((image) => [image.name, image.dataUrl]));
  return {
    ...object,
    images: object.images.map((image) => ({
      ...image,
      dataUrl: image.dataUrl || lookup.get(image.name) || "",
    })),
  };
}

function mergeImagesIntoReport(
  report: Report,
  local: ImageAsset[] | undefined,
): Report {
  if (!local) return report;
  const lookup = new Map(local.map((image) => [image.name, image.dataUrl]));
  return {
    ...report,
    images: report.images.map((image) => ({
      ...image,
      dataUrl: image.dataUrl || lookup.get(image.name) || "",
    })),
  };
}

function toApiClientRequest(client: Client) {
  return {
    id: toServerId(client.id),
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
    id: toServerId(project.id),
    title: project.title,
    clientId: project.clientId ? toServerId(project.clientId) : null,
    objectIds: project.objectIds.map(toServerId),
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
    id: toServerId(report.id),
    objectId: toServerId(report.objectId),
    reportType: report.reportType
      .toUpperCase()
      .replaceAll(" ", "_")
      .replaceAll("-", "_"),
    overallCondition: toApiCondition(report.condition),
    examiner: report.examiner,
    examinationDate: report.examinationDate,
    notes: report.notes || null,
    recommendations: report.recommendations || null,
    imageIds: report.images.map((image) => image.name),
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
    images: (report.imageIds ?? []).map((name) => ({ name, dataUrl: "" })),
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
