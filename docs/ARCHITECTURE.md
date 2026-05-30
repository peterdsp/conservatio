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
│   Native camera │   Native camera           │
│   Canvas annot. │   Canvas annotation       │
│   SQLDelight    │   SQLDelight              │
│   PDF (UIKit)   │   PDF (Android Print)     │
└─────────────────┴───────────────────────────┘
          │               │
          └───── Sync ────┘
                  │
         ┌───────┴────────┐
         │  Supabase       │
         │  ├── Postgres   │
         │  ├── Auth       │
         │  ├── Storage    │
         │  └── Realtime   │
         └───────┬─────────┘
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

1. User creates/edits data on mobile
2. Data is saved to local SQLDelight database immediately
3. Record is marked with `sync_status = PENDING`
4. When online, sync service pushes pending records to Supabase
5. On success, `sync_status` is updated to `SYNCED`
6. Periodic pull fetches remote changes

### Web companion

The web app connects directly to Supabase via the JS client SDK. No offline support needed for desktop use.

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
Ktor-based HTTP client for Supabase REST API. Uses kotlinx.serialization for JSON encoding/decoding.

### shared/data/local/
SQLDelight database with `expect/actual` pattern for platform-specific driver creation (AndroidSqliteDriver, NativeSqliteDriver).

## Security

- Supabase Row Level Security (RLS) ensures data isolation per user
- All tables require `auth.uid() = user_id` for access
- Images stored in private Supabase Storage buckets
- No sensitive data stored in plain text locally

## Image Handling

### Capture
- Native camera APIs on iOS (AVFoundation/PhotosUI) and Android (CameraX/MediaStore)
- Images stored locally first, uploaded to Supabase Storage on sync

### Annotation
- Canvas-based overlay for marking damage areas
- Annotations stored as percentage-based coordinates (responsive to display size)
- Each annotation links to a DamageType and DamageSeverity

### Storage
- Original images stored in Supabase Storage bucket
- Thumbnails generated on upload (Supabase Image Transformations)
- Image IDs stored as arrays in the parent record

## PDF Generation

Reports are generated locally on mobile (offline capability):
- iOS: Core Graphics / UIKit PDF rendering
- Android: Android Print Framework / iText

The web companion can generate PDFs server-side via a Next.js API route.

PDF templates support:
- Branded header with conservator/studio logo
- Condition report with annotated images
- Treatment proposal with step breakdown
- Before/after comparison
- Multilingual output (Greek, English initially)
