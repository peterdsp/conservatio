# Conservatio Backend

Supabase-powered backend providing authentication, database, storage, and API.

## Setup

1. Create a Supabase project at https://supabase.com
2. Run the migration in `supabase/migrations/001_initial_schema.sql` in the SQL Editor
3. Create a storage bucket called `conservation-images` with public access disabled
4. Copy your project URL and anon key to the mobile apps and web companion

## Storage Buckets

Create these buckets in Supabase Storage:
- `conservation-images`: object photos, condition report images, damage annotations
- `report-exports`: generated PDF reports

## Authentication

The app uses Supabase Auth with:
- Email/password login
- Magic link login (optional)
- Row Level Security ensures data isolation per user

## API

The mobile apps and web companion connect directly to Supabase using the client SDK.
No custom backend server is needed for the MVP.

## Database Schema

See `supabase/migrations/001_initial_schema.sql` for the full schema including:
- conservation_objects
- condition_reports
- projects
- clients
- treatment_proposals

All tables have RLS enabled with per-user access policies.
