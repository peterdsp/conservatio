# Conservatio app: design language and a Lidhra-shaped core

Status: a plan, not a release. Nothing here has shipped, and nothing in this
document assumes a release date. See "What this does not cover" at the end.

Two things prompted it. The website was redesigned in October 2026 onto a cool
frost-and-slate palette with Albert Sans, and the iOS app is still on the warm
terracotta palette the site used to have, so the two now look like different
products. Separately, the app's engine logic lives twice, once in Swift and once
in Kotlin, which is the problem Lidhra solved with one Rust core and thin native
shells.

---

## 1. The design language

These are the website's own tokens, which the app should adopt verbatim so the
two surfaces match without a translation layer.

| Role | Value | Where it goes in the app |
| --- | --- | --- |
| Ground | `#f7f9fa` | Screen background |
| Surface | `#ecf0f2` | Cards, grouped list rows, sheet backgrounds |
| Ink | `#1f3038` | All primary text, icons, the condition gauge fill |
| Muted ink | `#5d6b72` | Secondary labels, field names, captions |
| Accent | `#0d7480` | The primary action, and nothing else per screen |
| On accent | `#ffffff` | Text on the accent |

Type is **Albert Sans** at 400, 500 and 600. One family, two weights doing the
visible work. The site's five steps map onto Dynamic Type as:

| Site step | Size | SwiftUI style |
| --- | --- | --- |
| display | 26 to 32pt, weight 600, tracking -0.035em | `largeTitle` |
| head | 24 to 36pt, weight 600 | `title` |
| lead | 20 to 24pt, weight 500 | `title3` |
| body | 17 to 19pt, weight 400, leading 1.5 | `body` |
| small | 13 to 15pt, weight 400 | `footnote` |

Three rules carry most of the resemblance:

1. **One accent per screen.** Teal appears on the primary action or one detail,
   never on several controls at once. This is the single biggest visual
   difference from the current app, which uses terracotta, stone blue and gold
   together.
2. **Surfaces separate by tone, not by line or shadow.** A card is `surface` on
   `ground`. No borders, no drop shadows at rest. The current
   `ConservatioGlass.swift` does the opposite and should go.
3. **The condition report is the hero object.** Its fields, in the order the
   website prints them: object, condition summary, previous interventions,
   recommended treatment, condition rating, export.

### Condition ratings

The app has five rating colours that fight the accent. Replace them with one
scale that reads against teal: a single gauge filled in `ink` on `surface`, with
the rating as a word beside it, exactly as the website's report fragment does.
Where a hue is genuinely needed (a list of many objects at a glance), use one
amber `#b06f12` for attention and one red `#9b2c2c` for critical, and nothing
else. Two hues, not five.

---

## 2. Audit of iosApp against that

Read against `iosApp/Conservatio/` as it stands (44 Swift files).

| File | Today | Change |
| --- | --- | --- |
| `Theme/ConservatioColors.swift` | Terracotta primary, stone blue secondary, gold tertiary, five condition colours | Replace with the six tokens above plus the two attention hues |
| `Theme/ConservatioTypography.swift` | Twelve named steps (headline/title/body/label, each large/medium/small) | Collapse to the five steps above; twelve is more than the design needs and more than the site has |
| `Theme/ConservatioGlass.swift` | Translucent panels with blur | Delete. Surfaces separate by tone |
| `Theme/HeritageGlyphs.swift` | Custom glyphs | Keep, retint to `ink` |
| `Views/**` | Uses `.conservatioBodySmall` and friends in 18 places | Mechanical rename once the type file collapses |
| `PDF/PDFReportGenerator.swift` | Generates the exported report | Align its palette and field order with the website's report fragment, since that image is what the site promises |

The quickest honest path is: tokens first, then the type collapse, then delete
the glass, then the PDF. Each step is independently shippable and visible.

---

## 3. The Rust core, Lidhra-shaped

Lidhra's arrangement, which works and is already proven in this account's own
code, is one Cargo workspace of small crates plus a thin shell per platform. The
same shape for Conservatio:

```
crates/
  conservatio-model      objects, reports, observations, clients, projects;
                         the controlled vocabulary and the rating rules
  conservatio-store      local-first persistence and the sync queue;
                         append-only so a basement with no signal never loses work
  conservatio-report     the condition report: assembly, validation,
                         bilingual EN/EL field labels, and the PDF layout
  conservatio-sync       talks to server/; retry, conflict policy, ordering
  conservatio-ffi        the C ABI the shells bind to
```

Why these five: they are the parts that exist twice today, in `iosApp/.../Models`
and `Storage` and again in `androidApp`. The rating rules and the bilingual label
table in particular must not be allowed to disagree between platforms, and that
is exactly the kind of thing a shared core prevents.

The shells stay thin and native:

- **iOS**: SwiftUI over `conservatio-ffi` through a small Swift wrapper, the way
  Lidhra's Tauri app calls its crates. Camera, annotation and file access stay in
  Swift, because they are platform work, not domain work.
- **Android**: Compose over the same FFI via JNI.
- **Web**: the existing Next.js companion keeps talking to `server/`.

On "ultralightweight": Lidhra is small because it is Tauri plus the system
webview rather than a bundled runtime. Conservatio's iOS app is already native
SwiftUI, so the win here is not binary size, it is removing the duplicated logic.
Expect the app to get **simpler**, not noticeably smaller.

### Order of work

1. `conservatio-model` with the rating rules and the vocabulary, ported from the
   Swift models, with tests that pin the current behaviour.
2. `conservatio-report` including the bilingual label table, which is the part
   most at risk of drifting between platforms.
3. `conservatio-ffi` plus the Swift wrapper, and move iOS onto it one screen at
   a time, starting with the object record.
4. `conservatio-store` and `conservatio-sync`.
5. Android onto the same FFI.

Steps 1 and 2 are worth doing even if the rest never happens, because they end
the duplication that matters most.

---

## 4. What this does not cover

- **No release.** There is no App Store listing, no Play Store listing and no
  public build. Releasing needs an App Store Connect API key, which this account
  does not have yet, plus review time measured in days.
- **No timeline.** Nothing above is a commitment to a date.
- **The website already says so.** The landing page carries a plain notice that
  nothing is released and that the status column describes what is built in the
  repository, not what can be downloaded. Keep those in step: if a client ever
  ships, the notice and the status words change together.
