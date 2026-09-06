# iOS Pilot Release Readiness

Scope: a small TestFlight pilot with Greek conservators, focused on one workflow:
create an object, capture photos, record damage, annotate photos, export a Greek
or bilingual condition report, and synchronize after working offline.

Status legend: [x] done/verified, [ ] open, [~] partial.

This build was NOT uploaded and no testers were contacted, per task scope.

## A. Verified in this pass (simulator + tests + code)

- [x] iOS app builds clean (Debug, iPhone 17 and iPhone 17 Pro Max simulators, iOS 26.5).
- [x] Unit test suite green: 20 tests, 0 failures, including 12 PDF report-language tests (English, Greek, bilingual headings and controlled vocabulary; user text printed verbatim).
- [x] Offline entry: the full workflow is reachable without an account via "Continue without an account" (was previously gated behind online OAuth). Fixed this pass.
- [x] In-app "Sign in to sync" added under Settings > Account so offline users can authenticate later. Fixed this pass.
- [x] Empty state: Objects shows "No Objects Yet" with guidance.
- [x] Create object: form works; Save is disabled until a non-whitespace title exists. Whitespace-only title fixed this pass.
- [x] Greek text handling: storage, on-screen display, and PDF export verified end to end with a seeded Greek object (title, materials, owner, location, description all render correctly).
- [x] Bilingual and Greek PDF export: renders correctly (title bar, object section, condition summary, recommended treatment, notes, condition-rating gauge); verified on device screen.
- [x] Export blocker fixed: object detail used two `.sheet(isPresented:)` on one view and presented from a Menu, which produced a blank preview sheet. Consolidated to a single `.sheet(item:)`; preview now renders. Fixed this pass.
- [x] Dynamic Type at accessibility XXXL: body text scales and wraps, tab labels stay legible (large hero title truncates, cosmetic only).
- [x] Saved-work preservation: seeded and created records persist across app relaunch (local JSON stores).

## B. Requires a physical device or a human tester (not verifiable here)

- [ ] Real camera capture on device (the simulator has no camera; the gallery/PhotosPicker path works, the live camera flow is unverified).
- [ ] Live Greek keyboard input on device (the automation harness cannot inject Greek; storage/display/export were verified via seeded UTF-8 data, but real typing should be confirmed).
- [ ] VoiceOver pass and full accessibility audit (only Dynamic Type was checked visually; VoiceOver labels, focus order, and contrast need a human).
- [ ] OAuth sign-in end to end (Google, Apple, GitHub) against the live backend.
- [ ] Offline to online sync round-trip against the live server with a signed-in account.
- [ ] Share sheet export to Files, Mail, AirDrop on device.
- [ ] Performance with many objects and large photos, and memory use during PDF export with several annotated images.
- [ ] TestFlight distribution: signing, provisioning, export compliance, and App Store privacy strings review.

## C. Known gaps and limitations (assess before or during pilot)

- [~] App interface is mostly English. Only some strings (dashboard, settings, login, cloud) localize to Greek; the workflow screens (create object, annotation, object detail, report creation) are English-only. The report EXPORT is fully Greek or bilingual. Decide whether English app chrome is acceptable for these testers.
- [ ] Sync coverage is partial: only objects created while signed in are pushed to the server. Condition reports, projects, and clients are stored locally only, and object edits are not pushed. If "synchronize after working offline" must include reports on the server, this is a blocker for that half of the workflow; PDF export is unaffected and works offline.
- [ ] Report cards in object detail are not tappable: you can export only the latest report via the menu, and there is no edit-existing-report or export-a-specific-report path.
- [ ] `ExportReportButton.swift` is currently unused (dead code); the export lives in the object-detail menu.
- [ ] The floating tab bar overlaps the bottom of some detail screens; confirm nothing important is obscured.

## D. Suggested pre-pilot decisions

1. Accept English app chrome for the pilot, or localize the core workflow screens first.
2. Confirm whether reports need to reach the server during the pilot, or whether local PDF export is sufficient for these testers.
3. Confirm the pilot device set (models and iOS versions) and run section B on at least one real device.
