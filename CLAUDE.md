# Conservatio - Agent Instructions

## Project

Conservation documentation platform for cultural heritage professionals.
KMP shared module (Kotlin), iOS (SwiftUI), Android (Compose), Web (Next.js), Server (Ktor).
Self-hosted on Raspberry Pi 4 at 192.168.10.10.

## Memory

Global memory lives in the Kujto repo. Read these before making changes:

1. `/Users/p.dhespollari/git/personal/kujtesaPersonaleAI/memory/MEMORY.md`
2. `/Users/p.dhespollari/git/personal/kujtesaPersonaleAI/memory/core/writing_style.md`
3. `/Users/p.dhespollari/git/personal/kujtesaPersonaleAI/memory/core/safety_and_git.md`
4. `/Users/p.dhespollari/git/personal/kujtesaPersonaleAI/memory/domains/conservatio_project.md`

## Rules

- Never use em-dash or en-dash characters in any output.
- Never add Co-Authored-By Claude or AI references in commits.
- No autonomous commits or pushes without user approval.
- Follow existing patterns in each module before adding new code.

## iOS Development

- Build and run with: `./simulator.sh` (Kujto zero-config simulator)
- Or: `cd iosApp && xcodegen generate && open Conservatio.xcodeproj`
- Target: iOS 17+, iPhone 17 simulator
- SwiftUI views, observable stores, JSON file persistence (MVP)

## Android Development

- Open root project in Android Studio, run `androidApp` configuration
- Or: `./gradlew :androidApp:installDebug` (requires ANDROID_SDK_ROOT)
- Target: Android 15 (API 35), Pixel 8 emulator
- Jetpack Compose, Material 3, SharedPreferences (MVP)

## Backend

- Server running on Pi: `ssh peterdsp@192.168.10.10`
- Docker Compose at `/mnt/media/conservatio/`
- Ktor API on port 8080, Postgres on port 5432
- Deploy: `cd /mnt/media/conservatio && git pull && docker compose up -d --build`

## Web

- `cd web && npm install && npm run dev`
- Next.js 14 + TypeScript + Tailwind

## Key Docs

- `docs/ARCHITECTURE.md` - system design and data flow
- `docs/DESIGN.md` - color palette, typography, components
- `docs/CASE_STUDY.md` - full project journey
- `docs/MARKETING_PLAN.md` - launch strategy and revenue model
