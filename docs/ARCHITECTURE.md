# Architecture

## Overview

Conservatio follows a multiplatform architecture with KMP (Kotlin Multiplatform) for shared business logic and native UI layers per platform.

```
┌─────────────────────────────────────────────┐
│              Shared (KMP - Kotlin)           │
│  ├── Domain: models, repository interfaces  │
│  ├── Data: Ktor API client, SQLDelight DB   │
│  ├── DI: Koin modules                       │
│  └── Design: shared color/spacing tokens    │
├─────────────────┬───────────────────────────┤
│   iOS (SwiftUI) │   Android (Compose)       │
│   Camera+photos │   Gallery import          │
│   Annotation    │   (annotation planned)    │
│   Local store   │   Local store             │
│   PDF (UIKit)   │   (PDF planned)           │
└─────────────────┴───────────────────────────┘
        (shared SQLDelight DB defined, not yet wired)
          │               │
          └───── Sync ────┘
                  │
         ┌────────┴────────────┐
         │  Server (Ktor)       │
         │  ├── PostgreSQL      │
         │  ├── JWT + OAuth     │
         │  ├── Image storage   │
         │  └── REST /api/...   │
         │  Self-hosted (Docker)│
         └────────┬────────────┘
                 │
         ┌───────┴────────┐
         │  Web (Next.js)  │
         │  Dashboard      │
         │  Report editing │
         │  Client mgmt    │
         └────────────────┘
```

## Data Flow

### Offline-first (Mobile)

Intended design: a shared SQLDelight database with a `sync_status` column drives sync. Current implementation on iOS uses native on-device JSON stores plus a durable change outbox; the flow is otherwise the same:

1. User creates/edits data on mobile
2. Data is saved to local device storage immediately
3. The change is appended to a durable, persisted outbox (survives app restart)
4. When online, the sync engine pushes queued changes to the Conservatio server (Ktor REST API), coalescing per record and using idempotent upserts so a retried create never duplicates a record
5. On success the change is removed from the outbox; auth, offline, and server errors keep it queued for retry, with visible sync status
6. A pull fetches remote changes and merges them without discarding unsynced local edits (local pending changes win)

The Android app currently uses local JSON storage with best-effort push and no offline queue. Neither client is wired to the shared SQLDelight module yet.

### Web companion

The web app connects directly to the Conservatio server via its REST API (`/api/...`). No offline support needed for desktop use.

## Domain Model

### Core entities

- **ConservationObject:** the physical object being conserved (painting, icon, sculpture, etc.)
- **ConditionReport:** documents the state of an object at a point in time
- **TreatmentProposal:** proposed conservation treatment with methodology, materials, steps, cost
- **Project:** groups objects and reports under a client engagement
- **Client:** the person or institution commissioning conservation work

### Relationships

```
Client 1──* Project *──* ConservationObject
                              │
                              ├──* ConditionReport
                              │       │
                              │       └──* DamageAnnotation
                              │
                              └──* TreatmentProposal
                                      │
                                      └──* TreatmentStep
```

## Module Structure

### shared/domain/model/
Kotlin data classes with `@Serializable` annotation. These are the source of truth for the data schema across all platforms.

### shared/domain/repository/
Interfaces defining CRUD + Flow-based observation for each entity. Platform-specific implementations use SQLDelight for local storage.

### shared/data/remote/
Ktor-based HTTP client for the Conservatio server REST API (`/api/...`). Uses kotlinx.serialization for JSON encoding/decoding.

### shared/data/local/
SQLDelight database with `expect/actual` pattern for platform-specific driver creation (AndroidSqliteDriver, NativeSqliteDriver). This is defined in the shared module but not yet consumed by the iOS or Android apps, which currently persist to native on-device stores.

## Security

- The Ktor server scopes every query to the authenticated user, ensuring data isolation
- Requests are authenticated with a JWT (email/password or OAuth) sent as a Bearer token
- Images are stored on the server and served only to their owner
- No sensitive data stored in plain text locally

## Image Handling

### Capture
- iOS: camera capture via UIImagePickerController and gallery import via PhotosUI
- Android: gallery/document import (in-app camera capture is not yet implemented)
- Images stored locally first, uploaded to the Conservatio server on sync

### Annotation (iOS)
- Tap-to-place numbered damage markers overlaid on a photo
- Annotations stored as percentage-based coordinates (responsive to display size and orientation)
- Each annotation links to a DamageType and DamageSeverity, and renders in the exported PDF with a legend
- Not yet implemented on Android (its DamageAnnotation model has no coordinates)

### Storage
- Original images uploaded to and stored on the Conservatio server
- The server returns an image ID (`<uuid>.jpg`) referenced by the parent record
- Image IDs stored as arrays in the parent record

## PDF Generation

Reports are generated locally on-device, offline. Implemented on iOS only (Core Graphics / UIKit PDF rendering); Android PDF export and any web-side PDF generation are not implemented yet.

The iOS PDF currently includes:
- Branded header with report metadata
- Condition summary with controlled damage vocabulary
- Photo documentation with numbered damage markers and a per-photo legend
- Recommended-treatment notes and free-text notes
- A condition-rating gauge
- Content toggles (photos, annotations, gauge) and paper size (A4/Letter)
- Report language: English, Greek, or bilingual Greek/English for headings, labels, controlled vocabulary, and dates; user-entered text is never translated

Planned:
- Structured treatment proposals with a step breakdown
- Before/after comparison plates
- Android and web PDF export
