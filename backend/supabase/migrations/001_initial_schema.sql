-- Conservatio Database Schema
-- Run this in Supabase SQL Editor or as a migration

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Objects table
CREATE TABLE conservation_objects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    object_type TEXT NOT NULL CHECK (object_type IN (
        'PAINTING', 'ICON', 'WALL_PAINTING', 'SCULPTURE', 'CERAMIC',
        'METAL', 'TEXTILE', 'PAPER', 'WOOD', 'STONE', 'GLASS',
        'MOSAIC', 'ARCHAEOLOGICAL_FIND', 'FURNITURE', 'OTHER'
    )),
    materials TEXT[] NOT NULL DEFAULT '{}',
    height DOUBLE PRECISION,
    width DOUBLE PRECISION,
    depth DOUBLE PRECISION,
    diameter DOUBLE PRECISION,
    weight DOUBLE PRECISION,
    measurement_unit TEXT CHECK (measurement_unit IN ('CM', 'MM', 'M', 'INCH', 'KG', 'G')),
    owner_name TEXT,
    location_description TEXT,
    acquisition_date TIMESTAMPTZ,
    inventory_number TEXT,
    description TEXT,
    image_ids TEXT[] NOT NULL DEFAULT '{}',
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Condition reports table
CREATE TABLE condition_reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_id UUID NOT NULL REFERENCES conservation_objects(id) ON DELETE CASCADE,
    report_type TEXT NOT NULL CHECK (report_type IN (
        'INITIAL_ASSESSMENT', 'PRE_TREATMENT', 'POST_TREATMENT',
        'LOAN_OUTGOING', 'LOAN_INCOMING', 'INSURANCE', 'TRANSPORT',
        'PERIODIC_CHECK', 'EMERGENCY'
    )),
    overall_condition TEXT NOT NULL CHECK (overall_condition IN (
        'EXCELLENT', 'GOOD', 'FAIR', 'POOR', 'CRITICAL'
    )),
    examiner TEXT NOT NULL,
    examination_date TIMESTAMPTZ NOT NULL,
    damage_annotations JSONB NOT NULL DEFAULT '[]',
    notes TEXT,
    recommendations TEXT,
    image_ids TEXT[] NOT NULL DEFAULT '{}',
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Projects table
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    object_ids UUID[] NOT NULL DEFAULT '{}',
    status TEXT NOT NULL DEFAULT 'INQUIRY' CHECK (status IN (
        'INQUIRY', 'QUOTED', 'APPROVED', 'IN_PROGRESS',
        'ON_HOLD', 'COMPLETED', 'ARCHIVED'
    )),
    start_date TIMESTAMPTZ,
    end_date TIMESTAMPTZ,
    description TEXT,
    total_budget DOUBLE PRECISION,
    currency TEXT DEFAULT 'EUR',
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Clients table
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN (
        'PRIVATE_COLLECTOR', 'MUSEUM', 'GALLERY', 'CHURCH', 'MONASTERY',
        'MUNICIPALITY', 'ARCHAEOLOGICAL_SERVICE', 'UNIVERSITY',
        'FOUNDATION', 'ARCHITECT', 'INSURANCE_COMPANY', 'OTHER'
    )),
    contact_person TEXT,
    email TEXT,
    phone TEXT,
    address TEXT,
    notes TEXT,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Treatment proposals table
CREATE TABLE treatment_proposals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    object_id UUID NOT NULL REFERENCES conservation_objects(id) ON DELETE CASCADE,
    condition_report_id UUID REFERENCES condition_reports(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    proposed_by TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'DRAFT' CHECK (status IN (
        'DRAFT', 'SUBMITTED', 'APPROVED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
    )),
    methodology TEXT,
    materials_required TEXT[] NOT NULL DEFAULT '{}',
    estimated_duration TEXT,
    estimated_cost DOUBLE PRECISION,
    currency TEXT DEFAULT 'EUR',
    steps JSONB NOT NULL DEFAULT '[]',
    risks TEXT,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_conservation_objects_updated_at
    BEFORE UPDATE ON conservation_objects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_condition_reports_updated_at
    BEFORE UPDATE ON condition_reports
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at
    BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clients_updated_at
    BEFORE UPDATE ON clients
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_treatment_proposals_updated_at
    BEFORE UPDATE ON treatment_proposals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE conservation_objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE condition_reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE treatment_proposals ENABLE ROW LEVEL SECURITY;

-- RLS Policies: users can only access their own data
CREATE POLICY "Users can view own objects" ON conservation_objects
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own objects" ON conservation_objects
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own objects" ON conservation_objects
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own objects" ON conservation_objects
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own reports" ON condition_reports
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own reports" ON condition_reports
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own reports" ON condition_reports
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own reports" ON condition_reports
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own projects" ON projects
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own projects" ON projects
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own projects" ON projects
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own projects" ON projects
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own clients" ON clients
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own clients" ON clients
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own clients" ON clients
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own clients" ON clients
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Users can view own proposals" ON treatment_proposals
    FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own proposals" ON treatment_proposals
    FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own proposals" ON treatment_proposals
    FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own proposals" ON treatment_proposals
    FOR DELETE USING (auth.uid() = user_id);

-- Indexes
CREATE INDEX idx_objects_user ON conservation_objects(user_id);
CREATE INDEX idx_objects_type ON conservation_objects(object_type);
CREATE INDEX idx_reports_object ON condition_reports(object_id);
CREATE INDEX idx_reports_user ON condition_reports(user_id);
CREATE INDEX idx_projects_client ON projects(client_id);
CREATE INDEX idx_projects_user ON projects(user_id);
CREATE INDEX idx_clients_user ON clients(user_id);
CREATE INDEX idx_proposals_object ON treatment_proposals(object_id);
CREATE INDEX idx_proposals_user ON treatment_proposals(user_id);
