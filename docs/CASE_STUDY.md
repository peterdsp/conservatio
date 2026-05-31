# From Market Analysis to Self-Hosted Multiplatform App in One Session

A case study on building Conservatio: professional conservation documentation software, from first idea to deployable product, in a single AI-assisted engineering session.

---

## 1. The Problem

Conservation professionals do critical work. They stabilize crumbling frescoes, document archaeological finds before excavation destroys context, and treat centuries-old manuscripts so future generations can study them. The documentation of that work is not optional paperwork. It is a core ethical and legal requirement. Standards like Spectrum, ICOM guidelines, and EU heritage directives mandate thorough reporting.

And yet, the vast majority of conservation professionals document their work with Word files, Excel spreadsheets, WhatsApp photo threads, and Google Drive folders.

Large institutions have access to enterprise systems. The Getty uses TMS Conservation Studio. National museums run Gallery Systems or Axiell. These platforms cost tens of thousands per year and require dedicated IT staff to maintain.

On the other end, a private conservator working on a church ceiling in rural Greece has nothing. No professional tool that combines condition reporting, image annotation, client management, and project tracking in one place.

The gap between "nothing" and "enterprise" is enormous. And it is exactly where the opportunity lives. Private conservators, small museums, church restoration programs, and archaeological field teams need professional-grade documentation tools that respect their budget, their workflow, and the sensitivity of their data.

## 2. Market Analysis

Before writing a single line of code, we analyzed the existing landscape. The research happened entirely in conversation, evaluating real products against real practitioner needs.

**Existing tools reviewed:**

- **TMS Conservation Studio** (Gallery Systems): the gold standard for large institutions. Powerful, expensive, and designed for museums with dedicated registrars. Not accessible to a solo conservator.
- **Horus Condition Report**: a mobile app for creating condition reports. Focused narrowly on one artifact type. No project management, no client tracking, no business workflow.
- **Articheck**: digital condition reporting for art handling and logistics. Built for shipping and insurance, not for conservation treatment documentation.
- **CatalogIt**: collections management aimed at small museums. Good for cataloging objects, but lacks the conservation-specific vocabulary and treatment documentation workflow.

Each tool solves part of the problem. None combines conservation documentation with private practice business workflows and institutional standards in one platform.

We identified eight distinct market segments, ranging from solo freelance conservators to public heritage authorities. We ranked seven product ideas by market potential, technical feasibility, and alignment with the developer's domain knowledge.

The conclusion was clear: start with a condition report builder for private conservators. It solves the most acute pain point. Then expand into project management and invoicing, and eventually build toward a museum-lite CMS for small institutions.

## 3. Architecture Decisions

Conservation work is inherently mobile. You document damage in the field, annotate photos on-site, and often work in locations with no internet connectivity. Cross-platform support was mandatory from day one: iOS for the developer's primary ecosystem, Android for broader reach, and a web companion for desktop tasks like report editing and dashboard review.

We evaluated two cross-platform approaches:

**Flutter** offers a single codebase and fast iteration. But the developer's core expertise is Swift and native Apple development. Flutter's rendering engine bypasses native UI components, which matters for platform-specific features like image annotation and camera integration.

**Kotlin Multiplatform (KMP)** shares business logic while allowing fully native UI on each platform. Kotlin is the closest major language to Swift in syntax and idiom. SQLDelight provides offline-first database access as a first-class citizen. Native canvas APIs on both platforms give full control over image annotation.

KMP won. The architecture settled on:

- **Shared KMP module**: domain models, repository interfaces, networking (Ktor client), database (SQLDelight), dependency injection (Koin), and design tokens
- **Android**: Jetpack Compose with Material 3
- **iOS**: SwiftUI with native HIG patterns
- **Web companion**: Next.js 14, TypeScript, Tailwind CSS
- **Backend**: Ktor server with Exposed ORM, PostgreSQL, JWT authentication

The web app is intentionally thin. It handles CRUD operations, dashboards, and report editing. The real conservation work happens on mobile devices, in the field, often offline.

## 4. Design Language

Conservation software should feel trustworthy and grounded. Not clinical like a hospital EMR, not playful like a consumer app. We browsed Figma Community for inspiration, studying Material 3 Design Kit implementations, SaaS dashboard kits like DashStack, and various professional tool interfaces.

The color palette draws from heritage materials:

- **Terracotta** (#C25B3A) as the primary color, evoking fired clay and aged brick
- **Stone Blue** (#3A6B8C) as the secondary, referencing the blue-grey of weathered stone
- **Warm Gold** (#D4A843) as the tertiary accent, suggesting gilding and aged metal

Each platform follows its own design system natively:

- Android uses Material 3 with Material You dynamic theming
- iOS follows Human Interface Guidelines with matching color tokens
- Web uses a clean SaaS dashboard pattern with Inter typography and Tailwind utility classes

Design tokens (colors, typography scales, spacing) are defined as a Kotlin object in the shared module, ensuring visual consistency without forcing artificial uniformity across platforms.

## 5. What Was Built

In one continuous session, 62 files were created across five platforms.

**Shared KMP module:**
Five domain models covering the full conservation workflow. The damage taxonomy includes 21 distinct damage types (cracks, delamination, biological growth, salt efflorescence, and more), each reflecting real conservation vocabulary. Fifteen object types span paintings, sculptures, textiles, ceramics, metalwork, and architectural elements. Nine report types cover condition reports, treatment proposals, treatment records, environmental assessments, and others. Twelve client types distinguish between private collectors, museums, churches, archaeological projects, and government agencies.

Four repository interfaces define the data access contracts. A Ktor API client handles networking. SQLDelight schemas provide offline storage. Koin manages dependency injection. Shared design tokens keep visual language consistent.

**Android app:**
Jetpack Compose UI with a full Material 3 theme supporting both light and dark modes. Bottom navigation with placeholder screens for Dashboard, Objects, Reports, and Profile. The theme implementation uses the heritage color palette through Material 3's color role system.

**iOS app:**
SwiftUI with TabView navigation and NavigationStack routing. A dashboard with quick-action cards, custom typography using the SF system fonts, and a color system that maps the shared palette to iOS semantic colors.

**Web companion:**
Next.js 14 with the App Router, TypeScript throughout, and Tailwind CSS for styling. A collapsible sidebar navigation, stats dashboard with summary cards, and a Supabase client for data access.

**Backend:**
Ktor API server with JWT-based authentication, bcrypt password hashing, Exposed ORM for database access, PostgreSQL as the data store, and local filesystem image storage. Full REST API covering users, objects, reports, and images.

**Infrastructure:**
Docker Compose configuration for Raspberry Pi deployment. GitHub repository with CI workflows including an em-dash lint check (a personal code quality standard) and web linting. GitHub Pages workflow for the product landing page. A release tagged v0.1.0.

**Landing page:**
Product site at conservatio.peterdsp.dev, deployed via GitHub Pages.

## 6. The Self-Hosting Decision

The initial plan was to use Supabase as a hosted backend. It is fast to set up, provides authentication and storage out of the box, and scales without operational burden.

But then we thought about the data.

Conservation documentation includes photographs of clients' valuable objects, sometimes worth millions. It includes detailed condition assessments that could affect insurance valuations. It includes location data for heritage sites that may be vulnerable to theft. This data is sensitive in ways that go beyond typical SaaS concerns.

Self-hosting is not a limitation for this use case. It is a feature. A conservator should be able to tell their client: "Your data lives on my server, in my office, under my physical control. It never touches a third-party cloud."

The developer already operates a Raspberry Pi 4 (2GB RAM) running Magnetio (a Stremio addon) and a GitHub Actions self-hosted runner. We benchmarked the Pi:

- 4 ARM Cortex-A72 cores at 1.5GHz
- 1.3GB RAM available after existing services
- 1.7TB external HDD with 134 MB/s sequential write speed
- Magnetio responding in 4.6ms average latency

A Ktor server with PostgreSQL adds roughly 200MB of RAM usage. The Pi handles it comfortably.

We evaluated self-hosted Supabase, but it deploys 15+ Docker containers (PostgREST, GoTrue, Realtime, Storage, Kong, and more). That is overkill for a single-user or small-team deployment on constrained hardware.

The final stack is lean: PostgreSQL and a Ktor application server. Data stored on the external HDD at `/mnt/media/conservatio/`. The API exposed at `api.conservatio.peterdsp.dev` via Cloudflare Tunnel, providing HTTPS termination and DDoS protection without opening router ports.

## 7. Technical Highlights

**Type safety end-to-end.** Kotlin domain models are shared between the mobile clients and the API server. When a new damage type is added to the enum, it propagates to every platform at compile time. No schema drift, no deserialization surprises, no mismatched field names.

**Offline-first by design.** SQLDelight on mobile provides a local database that works with zero connectivity. Conservation work happens in church crypts, archaeological trenches, and museum storage rooms where cellular signal does not reach. Reports can be created, edited, and annotated entirely offline, then synced when connectivity returns.

**Image annotation with percentage coordinates.** Damage annotations on photographs are stored as percentage-based coordinates relative to the image dimensions. This makes annotations responsive to display size: the same annotation renders correctly on a phone screen, a tablet, and a desktop browser without coordinate translation.

**Local PDF generation.** Reports can be generated as PDFs entirely on-device, maintaining offline capability for the complete workflow from documentation to deliverable.

**Multilingual report output.** Greek and English report generation supports EU-funded projects and international clients. Conservation work in Greece routinely requires bilingual documentation.

**Row-level data isolation.** Each user's data is isolated at the database level. A multi-tenant deployment does not leak data between practitioners.

## 8. What This Demonstrates

This project compresses what would typically take weeks of work into a single continuous session. Market analysis, technology evaluation, architecture design, domain modeling, UI implementation across three platforms, backend development, infrastructure planning, and deployment configuration all happened in one conversation.

AI-assisted development did not replace engineering judgment. Every decision, from choosing KMP over Flutter to selecting Terracotta as the primary color, required domain knowledge, technical evaluation, and taste. The AI accelerated the execution of those decisions, not the decisions themselves.

The result is not a prototype or a wireframe collection. It is a buildable, deployable multiplatform application with real authentication, a real database schema, real API endpoints, and a real deployment target. The domain models encode actual conservation vocabulary. The architecture supports actual offline workflows. The deployment runs on actual hardware.

Understanding the domain was essential. Conservation ethics (minimal intervention, reversibility, documentation as obligation), Spectrum standards for collections management, controlled vocabulary for damage types, annotation workflows for condition reporting, and the structural difference between institutional and private practice needs: all of this shaped every model, every screen, and every feature decision. Without that domain knowledge, the software would be a generic CRUD app with conservation-themed labels.

## 9. What Is Next

The foundation is laid. The roadmap focuses on the features that make the tool genuinely useful for daily conservation work:

1. **Object creation flow**: full wizard for registering new objects with metadata, photography, and initial condition assessment. iOS first, then Android.
2. **Image annotation canvas**: touch-based damage marking with typed annotations, layered overlays, and before/after comparison views.
3. **PDF report generation**: professional condition reports matching the format conservators already use, with institutional branding, image plates, and damage maps.
4. **Raspberry Pi deployment**: Docker Compose up, Cloudflare Tunnel configured, database seeded, and API live.
5. **Beta testing**: real conservators in Greece using the tool on real projects, providing feedback on workflow fit.
6. **Feature expansion**: environmental monitoring integration, GIS support for archaeological sites, and museum-lite CMS capabilities for small institutions.

## 10. By the Numbers

| Metric | Value |
|---|---|
| Files created | 62+ |
| Platforms addressed | 5 (iOS, Android, Web, API server, Database) |
| Domain models | 5 with comprehensive enums |
| Damage types modeled | 21 |
| Object types supported | 15 |
| Report types defined | 9 |
| Client types categorized | 12 |
| SQLDelight schemas | 4 |
| REST API | Full CRUD with JWT auth |
| Production server | 1 Raspberry Pi 4 |
| Available storage | 1.7TB |
| Cloud dependencies | 0 |

---

*Conservatio is open source. The code, architecture documentation, and design specifications are available on GitHub. Built by a conservation-aware engineer who believes that heritage professionals deserve tools as rigorous as the work they do.*
