# Conservatio Roadmap (reprioritized)

This roadmap is written from the verified state of the repository after the
report, marketing, sync, cleanup, and pilot-readiness work. It is centered on one
outcome: a reliable iOS condition-report workflow for Greek conservators.

## Verified product state (what is actually true today)

- The iOS core workflow runs offline end to end: create object, add photos, record
  damage, annotate photos on a percentage-based canvas, and export a Greek or
  bilingual condition report to PDF. Verified on simulator; 20 unit tests pass,
  including 12 that assert Greek and bilingual PDF output.
- Fixed during pilot-readiness: the app was gated behind online OAuth (now has an
  offline entry), the PDF export presented a blank sheet (double `.sheet` bug),
  there was no way to sign in later (added Settings > Sign in to sync), and a
  whitespace-only title could be saved.
- Greek is fully supported in stored data, on-screen display, and the exported
  report. The app chrome itself is still mostly English; only dashboard, settings,
  login, and cloud strings localize.
- Sync is partial. Only objects created while signed in are pushed to the Ktor
  server. Condition reports, projects, and clients are local-only, and object edits
  are not pushed. PDF export is fully offline and unaffected.
- The backend is Ktor plus PostgreSQL, self-hosted via Docker. The abandoned
  Supabase backend and dead web Supabase scaffolding were removed.
- The KMP `shared/` module is effectively dormant: iOS does not import it at all,
  and Android only uses it to start Koin. Each app reimplements its own models,
  storage, and API client.
- `TreatmentProposal` exists only as a shared model and a server table. There is no
  treatment UI in either app.
- Android has the app-language bug fixed, but Projects and Clients are placeholders
  and reports/projects are not available. It is intentionally not at iOS parity.

Guiding principle: prove one reliable, delightful iOS workflow for Greek
conservators before widening scope. Every item below is judged against that.

---

## Tier 1: Release blockers (before inviting testers)

### 1.1 On-device verification pass
- User problem: the simulator cannot validate camera capture, live Greek keyboard
  input, OAuth sign-in, the share sheet, or a real offline-to-online sync. These
  are exactly the things a field tester will hit first.
- Smallest useful scope: run section B of `docs/pilot/RELEASE_READINESS.md` on one
  physical iPhone against the live backend; fix whatever fails.
- Dependencies: a provisioned device, the running Ktor server.
- Acceptance: every section B item passes or is documented as a known limitation.
- Effort: S (0.5 to 1 day). Uncertainty: low, unless OAuth or camera reveal issues.

### 1.2 Decide and honor the meaning of "sync after offline" for reports
- User problem: today a condition report created offline never reaches the server.
  If a tester reinstalls or changes device, reports are gone (only local JSON and
  any exported PDFs survive). The pilot explicitly promises "synchronize after
  working offline."
- Smallest useful scope (option A): push condition reports on create and pull them
  on sync, mirroring the existing object path (`ObjectStore.syncCreatedObject` and
  `syncFromServer`). Option B: scope the pilot to local-only and state clearly in
  the tester guide that the exported PDF is the durable artifact.
- Dependencies: server report routes (already exist), auth.
- Acceptance: a report made offline appears on the server after sign-in and sync
  (option A), or the pilot docs and UI make local-only explicit (option B).
- Effort: M (2 to 4 days) for real report sync; S to scope and document. Uncertainty:
  medium (edit and delete propagation, ordering).

---

## Tier 2: Pilot improvements (during the pilot, before wider release)

### 2.1 Localize the core workflow screens to Greek
- User problem: testers are Greek conservators, but create-object, annotation,
  object-detail, and report-creation screens are English-only.
- Smallest useful scope: route the visible strings on those four screens through
  the existing `t(...)` helper and add Greek entries. Not full app translation.
- Dependencies: none (the i18n mechanism already exists and works).
- Acceptance: with app language set to Greek, the whole pilot flow reads in Greek.
- Effort: M (2 to 3 days). Uncertainty: low.

### 2.2 Open and manage a specific report
- User problem: report cards are not tappable; you can only export the latest report
  from a menu, and cannot view or edit an existing report.
- Smallest useful scope: make a report card open a report detail with edit and an
  export button for that specific report.
- Dependencies: none.
- Acceptance: any report can be opened, edited, and exported individually.
- Effort: M. Uncertainty: low.

### 2.3 Complete sync coverage and basic conflict handling
- User problem: projects, clients, and object edits do not sync; multi-device or
  reinstall loses data beyond created objects.
- Smallest useful scope: push and pull for reports, projects, clients, and object
  updates, with last-write-wins and a visible last-synced time (the Sync Now button
  already exists).
- Dependencies: 1.2, server routes (exist).
- Acceptance: all record types round-trip through the server; Sync Now reflects it.
- Effort: L (1 to 2 weeks). Uncertainty: medium to high (conflict edge cases).

### 2.4 Accessibility and layout polish
- User problem: VoiceOver is unaudited; the hero title truncates at large text; the
  floating tab bar overlaps bottom content on detail screens.
- Smallest useful scope: add VoiceOver labels to icon-only controls, fix the tab-bar
  overlap padding, allow the hero title to scale or shrink.
- Dependencies: none.
- Acceptance: a VoiceOver pass of the workflow succeeds; no clipped controls at XXXL.
- Effort: S to M. Uncertainty: low.

### 2.5 Housekeeping
- Remove or wire the unused `ExportReportButton.swift`. Effort: S.

---

## Tier 3: Later experiments (each must be justified before starting)

These are explicitly decisions, not commitments. Default is "not now."

### Treatment proposals
- Value: real, but it is a second workflow. The model and server table exist; the UI
  does not. Verdict: defer until the condition-report workflow is proven in the pilot.

### Controlled vocabulary (formal standards)
- Value: interoperability and rigor (for example aligning damage terms to a
  recognized lexicon). Cost: research plus ongoing curation. Verdict: incremental.
  The current bilingual controlled vocabulary in `ReportLocalization` is enough for
  the pilot; formalize only if testers ask for a specific standard.

### On-device AI (damage detection or report drafting)
- Value: could speed drafting. Cost: model size, accuracy liability on heritage
  objects, and maintenance. Verdict: not now. Revisit only after the manual workflow
  is loved; a wrong AI damage call on an artifact is worse than no AI.

### Android parity
- Value: broader reach. Cost: doubles UI maintenance while the product is unproven.
  Verdict: hold. Keep Android at its current state (language fixed, honest
  coming-soon placeholders). Do not expand until the iOS pilot validates the product.

### PowerSync
- Value: a robust offline sync engine with conflict handling. Cost: new
  infrastructure and a dependency, plus backend changes. Verdict: not yet. The
  current REST push and pull is adequate at pilot scale; adopt PowerSync only if
  2.3 proves that hand-rolled sync cannot keep up.

### KMP revival
- Value: shared domain and logic across platforms, less duplication. Cost: a large
  refactor that competes directly with shipping the iOS pilot; iOS currently uses
  none of it. Verdict: do not revive now. Make an explicit choice later: either
  commit to KMP as a strategic bet once iOS is proven, or formally retire the
  `shared/` module so it stops implying an architecture the apps do not follow.

### Self-hosting as a product feature
- Value: data sovereignty is a genuine marketing differentiator. Cost: support and
  documentation burden. Verdict: keep the existing Docker Compose path available and
  documented, but do not invest in a one-click installer during the pilot.

### Additional platforms
- The web companion already talks to the same REST API; keep it as a companion. Do
  not add new platforms during the pilot.

---

## Recommended next three concrete tasks

1. Run the on-device verification pass (Tier 1.1) on a physical iPhone against the
   live backend, and fix anything that fails.
2. Resolve report sync (Tier 1.2): either implement condition-report create-sync so
   "sync after offline" is literally true for reports, or scope the pilot to
   local-only and make that explicit in the app and the tester guide.
3. Localize the core workflow screens to Greek (Tier 2.1) so the entire pilot flow,
   not only the exported PDF, is in the testers' language.
