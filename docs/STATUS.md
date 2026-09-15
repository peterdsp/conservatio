# Implementation Status

This document records what actually ships today versus what is designed or
planned, so the marketing and architecture docs can be checked against reality.
It reflects the code in this repository, verified by reading the source.

Legend: Shipping = implemented and working in the app; Partial = some of it
works; Planned = designed or modelled but not implemented.

## By platform

| Capability | iOS | Android | Web |
|---|---|---|---|
| Object cataloguing (create/edit, photos) | Shipping | Shipping | Shipping (CRUD) |
| Condition reports | Shipping | Planned ("coming soon") | Partial (form, no PDF) |
| On-photo damage annotation (positioned markers) | Shipping | Planned (model has no coordinates) | Not present |
| PDF export | Shipping | Planned | Not present |
| Report language: English / Greek / bilingual | Shipping (PDF) | N/A (no PDF) | N/A (no PDF) |
| Camera capture | Shipping (camera + gallery) | Partial (gallery import only) | N/A |
| Projects | Shipping | Planned ("coming soon") | Shipping (CRUD) |
| Clients | Shipping | Planned ("coming soon") | Shipping (CRUD) |
| Offline storage | Shipping (native store) | Shipping (native store) | N/A |
| Sync to server | Shipping (durable outbox, retries, status, conflict handling) | Partial (best-effort push, no queue) | Shipping (direct REST) |
| Bilingual UI (app chrome) | Shipping (en/el) | Shipping (en/el) | Shipping (en/el) |

## Backend and data

- The live backend is a self-hosted **Ktor + PostgreSQL** server (`server/`),
  reached at `conservatio-api.peterdsp.dev`. Auth is JWT plus OAuth.
- A **Supabase** schema previously existed under `backend/` but was never wired
  into the running app; it has been removed. Architecture docs now describe the
  Ktor server.
- The shared **KMP module** defines domain models, repository interfaces, a Ktor
  API client, and **SQLDelight** schemas. The iOS and Android apps do **not**
  currently consume the shared module or SQLDelight; each persists to native
  on-device storage. "Offline-first via SQLDelight" is a design target, not the
  current implementation.
- The server persists a report's `damageAnnotations` as text on write but does
  not return it on read; iOS keeps annotations locally as the source of truth
  and now sends them on sync.

## Not yet built (modelled or designed only)

- **Treatment proposals** (structured methodology, materials, cost, steps,
  progress). A `TreatmentProposal` model exists in the shared module and the DB
  schema, but there is no API route and no client UI. Reports capture
  recommended treatment as free text only.
- **Before/after comparison** views.
- **Android** condition reports, annotation, PDF export, camera capture,
  projects, clients, and an offline sync queue.
- **Web** PDF generation.
- Third-party cloud storage providers (Google Drive, iCloud, OneDrive) shown in
  Settings are placeholders, not connected.

## Licensing

Conservatio is **proprietary** and source-available (see `LICENSE`), co-authored
by Petros Dhespollari (engineering, brand) and Amalia Boura (conservation
domain). It is not open source. Public copy should say "source-available under a
proprietary license," never "open source."
