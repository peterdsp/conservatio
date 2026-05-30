<p align="center">
  <img src="https://img.shields.io/badge/Conservatio-v0.1.0-C25B3A?style=for-the-badge&labelColor=1a1a2e" alt="Version" />
  <img src="https://img.shields.io/badge/license-MIT-blue?style=for-the-badge&labelColor=1a1a2e" alt="License" />
  <img src="https://img.shields.io/badge/kotlin-2.0-7F52FF?style=for-the-badge&logo=kotlin&labelColor=1a1a2e" alt="Kotlin" />
  <img src="https://img.shields.io/badge/swift-5.9-F05138?style=for-the-badge&logo=swift&labelColor=1a1a2e" alt="Swift" />
  <img src="https://img.shields.io/badge/compose-Material3-4285F4?style=for-the-badge&logo=jetpackcompose&labelColor=1a1a2e" alt="Compose" />
  <img src="https://img.shields.io/badge/next.js-14-000?style=for-the-badge&logo=nextdotjs&labelColor=1a1a2e" alt="Next.js" />
</p>

# Conservatio

Professional conservation documentation platform for cultural heritage professionals.

Conservatio helps conservators, small museums, galleries, churches, and archaeological teams create structured condition reports, manage conservation projects, annotate damage on images, and generate professional PDF documentation.

## Architecture

```
conservatio/
├── shared/          # KMP shared module (Kotlin)
│   ├── domain/      #   Models, repository interfaces
│   ├── data/        #   API client (Ktor), local DB (SQLDelight)
│   ├── di/          #   Koin dependency injection
│   └── design/      #   Shared design tokens
├── androidApp/      # Android app (Jetpack Compose, Material 3)
├── iosApp/          # iOS app (SwiftUI, HIG)
├── web/             # Web companion (Next.js, TypeScript, Tailwind)
├── backend/         # Supabase config and SQL migrations
└── docs/            # Architecture and design documentation
```

### Platform strategy

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Shared logic | Kotlin Multiplatform | Domain models, repositories, API client, local DB |
| Android | Jetpack Compose + Material 3 | Native Android app |
| iOS | SwiftUI + HIG | Native iOS app |
| Web | Next.js + React + Tailwind | Desktop companion, dashboards, report editing |
| Backend | Supabase (Postgres + Auth + Storage) | API, auth, image storage, sync |
| Local DB | SQLDelight | Offline-first on mobile |

### Design language

- **Android:** Material 3 (Material You) with heritage-inspired warm palette
- **iOS:** Apple Human Interface Guidelines with matching color tokens
- **Web:** Clean SaaS dashboard style (Inter font, warm earth tones)

**Color palette:**
- Primary: Terracotta `#C25B3A` (heritage, craftsmanship)
- Secondary: Stone Blue `#3A6B8C` (professional, trustworthy)
- Tertiary: Warm Gold `#D4A843` (accent, highlights)
- Background: Warm White `#FAF7F4`

## Getting Started

### Prerequisites

- JDK 17+
- Android Studio Hedgehog or later
- Xcode 15.4+ (for iOS)
- Node.js 18+ (for web)
- A Supabase project (free tier works)

### Setup

1. **Clone the repo**
   ```bash
   git clone <repo-url>
   cd conservatio
   ```

2. **Backend**
   - Create a Supabase project at https://supabase.com
   - Run `backend/supabase/migrations/001_initial_schema.sql` in the SQL Editor
   - Create storage buckets: `conservation-images`, `report-exports`
   - Copy your project URL and anon key

3. **Android**
   - Open the root project in Android Studio
   - Sync Gradle
   - Run the `androidApp` configuration

4. **iOS**
   - Build the shared framework: `./gradlew :shared:assembleXCFramework`
   - Open `iosApp/` in Xcode
   - Add the XCFramework to your project
   - Build and run

5. **Web**
   ```bash
   cd web
   cp .env.example .env.local
   # Fill in your Supabase credentials
   npm install
   npm run dev
   ```

## MVP Features

### Phase 1 (Current)
- [ ] Object profiles (title, type, materials, dimensions, photos)
- [ ] Condition reports with damage checklists
- [ ] Photo capture and image annotation
- [ ] Treatment proposals
- [ ] Client and project management
- [ ] PDF report export (Greek + English)
- [ ] Offline-first mobile with cloud sync

### Phase 2 (Planned)
- [ ] Before/after image comparison
- [ ] Report templates (customizable per client/institution)
- [ ] Team collaboration (multi-user projects)
- [ ] Environmental monitoring dashboard
- [ ] Public client portal

### Phase 3 (Future)
- [ ] AI-assisted report drafting
- [ ] GIS integration for archaeological sites
- [ ] Museum-lite CMS module
- [ ] IIIF image compatibility
- [ ] Spectrum standard compliance

## Target Users

- Private conservators and freelancers
- Small conservation studios
- Churches, monasteries, and local heritage owners
- Galleries, auction houses, and collectors
- Small and regional museums
- Archaeological field teams

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Shared logic | Kotlin 2.0, KMP, Coroutines, Serialization |
| Networking | Ktor Client |
| Local DB | SQLDelight |
| DI | Koin |
| Android UI | Jetpack Compose, Material 3, Navigation Compose |
| iOS UI | SwiftUI, NavigationStack |
| Web | Next.js 14, React 18, TypeScript, Tailwind CSS |
| Backend | Supabase (Postgres, Auth, Storage, RLS) |
| Image loading | Coil (Android), AsyncImage (iOS) |

## License

MIT. See [LICENSE](LICENSE) for details.
