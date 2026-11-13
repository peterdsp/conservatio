# Conservatio design language

One system for the app, the website, the store images and the PDF. Decided
12 November 2026 with the new mark; the earlier terracotta, stone blue and
gold palette and the glass surfaces are gone.

## The mark

A heavy C holding a small square: the bracket and the object, the thing being
kept. The C is drawn as a 34 unit radius arc with a 16 unit stroke on a 100
unit square, open to the right; the square is 16 units, set inside the bowl
at (50, 42) so the mark never reads as a G at small sizes. Vector source:
`site/assets/mark.svg`; wordmark: `site/assets/wordmark.svg`; favicon (ink
tile): `site/favicon.svg` and `web/public/favicon.svg`; app icon (frost arc,
verdigris square on an ink tile): `iosApp/Conservatio/Assets.xcassets/AppIcon.appiconset`,
all sizes resized from the 1024 tile; in-app logo: `Logo.imageset` at 2x and 3x.

## Colour

| Role | Light | Dark | Where |
| --- | --- | --- | --- |
| Ground | `#f7f9fa` | `#0f1a1e` | screen and page background |
| Surface | `#ecf0f2` | `#1c2d34` | cards, rows, fields, panels |
| Ink | `#1f3038` | `#e9eef0` | all primary text and icons |
| Muted ink | `#5d6b72` | `#9aa8ae` | secondary labels, captions |
| Accent, verdigris | `#0d7480` | `#3fb3a8` | the primary action and one detail per screen |
| Attention | `#b06f12` | `#d9a04a` | fair condition |
| Critical | `#9b2c2c` | `#d96b6b` | poor and critical condition |

Verdigris is the patina on bronze, a conservation phenomenon, which is why it
is the one hue. Surfaces separate by a step in tone, never by a line or a
shadow at rest. Condition ratings are a word beside a gauge in ink; only fair
and worse carry a hue.

In code: `iosApp/Conservatio/Theme/ConservatioColors.swift` (dynamic light
and dark), `site/styles.css` custom properties, `web/tailwind.config.ts`
`primary` (verdigris), `secondary` (ink scale), `tertiary` (attention).

## Type

Website and store images: Albert Sans 400, 500, 600, five steps. App: the
system face through `ConservatioTypography.swift`, so navigation and controls
look like the platform. Headlines are two lines or fewer; no uppercase
letter-spaced labels; no monospace outside code.

## Surfaces and components

- Panels: `glassPanel()` is now a flat surface step with continuous 16 pt
  corners. `glassPanelDark()` is the one ink panel a screen may carry.
- Buttons: `.glassPrimary` is a flat verdigris fill with a white label;
  `.glassSecondary` is ink on surface. 12 pt corners, press darkens.
- Fields and rows: surface step, 12 pt corners, no ring.
- No ambient gradients, no blurred circles, no line-art backdrops.

## The PDF

Ink on white, the studio's letterhead (logo, name, address) in the header,
the conservator's name, title and signature image in the footer. Same three
colours, same type rules.
