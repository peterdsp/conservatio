export type ObjectType =
  | "PAINTING"
  | "ICON"
  | "WALL_PAINTING"
  | "SCULPTURE"
  | "CERAMIC"
  | "METAL"
  | "TEXTILE"
  | "PAPER"
  | "WOOD"
  | "STONE"
  | "GLASS"
  | "MOSAIC"
  | "ARCHAEOLOGICAL_FIND"
  | "FURNITURE"
  | "OTHER";

export type ConditionRating =
  | "EXCELLENT"
  | "GOOD"
  | "FAIR"
  | "POOR"
  | "CRITICAL";

export type ReportType =
  | "INITIAL_ASSESSMENT"
  | "PRE_TREATMENT"
  | "POST_TREATMENT"
  | "LOAN_OUTGOING"
  | "LOAN_INCOMING"
  | "INSURANCE"
  | "TRANSPORT"
  | "PERIODIC_CHECK"
  | "EMERGENCY";

export type ProjectStatus =
  | "INQUIRY"
  | "QUOTED"
  | "APPROVED"
  | "IN_PROGRESS"
  | "ON_HOLD"
  | "COMPLETED"
  | "ARCHIVED";

export type ClientType =
  | "PRIVATE_COLLECTOR"
  | "MUSEUM"
  | "GALLERY"
  | "CHURCH"
  | "MONASTERY"
  | "MUNICIPALITY"
  | "ARCHAEOLOGICAL_SERVICE"
  | "UNIVERSITY"
  | "FOUNDATION"
  | "ARCHITECT"
  | "INSURANCE_COMPANY"
  | "OTHER";

export interface ConservationObject {
  id: string;
  title: string;
  object_type: ObjectType;
  materials: string[];
  dimensions?: {
    height?: number;
    width?: number;
    depth?: number;
    diameter?: number;
    weight?: number;
    unit: string;
  };
  owner_name?: string;
  location_description?: string;
  inventory_number?: string;
  description?: string;
  image_ids: string[];
  created_at: string;
  updated_at: string;
}

export interface ConditionReport {
  id: string;
  object_id: string;
  report_type: ReportType;
  overall_condition: ConditionRating;
  examiner: string;
  examination_date: string;
  notes?: string;
  recommendations?: string;
  image_ids: string[];
  created_at: string;
  updated_at: string;
}

export interface Project {
  id: string;
  title: string;
  client_id?: string;
  object_ids: string[];
  status: ProjectStatus;
  start_date?: string;
  end_date?: string;
  description?: string;
  total_budget?: number;
  currency?: string;
  created_at: string;
  updated_at: string;
}

export interface Client {
  id: string;
  name: string;
  type: ClientType;
  contact_person?: string;
  email?: string;
  phone?: string;
  address?: string;
  notes?: string;
  created_at: string;
  updated_at: string;
}
