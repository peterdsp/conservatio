# Conservatio at 14.99: what the price buys, and what ships first

Status: decisions for the 1.0 listing, taken 12 November 2026. The app is a
one-time purchase at 14.99 EUR (base territory Greece, other territories
follow Apple's equalisation). No subscription, no in-app purchase, no trial.

## Who pays 14.99, and why that number

The buyer is a working conservator: a solo practitioner or a two to five
person studio, in Greece first, then the Mediterranean. The alternative today
is a Word template, a WhatsApp thread of photographs and an afternoon of
retyping per report. One report that takes an hour less pays for the app.
The price is the cost of one courier run or one roll of Japanese tissue; it is
below the threshold where a studio has to ask anyone, and above the point
where an app reads as a toy. A museum buying five seats pays what one
condition-report template from a publisher costs.

The one-time price also fits the data: a condition report is a document the
studio must still be able to open in ten years. A subscription that stops the
app from exporting would be wrong for this profession. Everything is stored
on the device as JSON and JPEG, the PDF is the deliverable, and sync to the
studio's own server is optional.

## What the 14.99 build contains

Each line is something a conservator does with the app that the Word
template cannot do, or does in a tenth of the time.

1. A condition report whose fields are the profession's: object, materials,
   dimensions and weight, purpose of examination, examiner and date, overall
   rating, previous interventions, examination conditions (light, relative
   humidity, temperature), damage list, recommended treatment, notes.
2. Damage marked directly on the photograph: numbered markers with type,
   severity and description, drawn onto the same photograph in the PDF with a
   per-photograph legend.
3. A controlled vocabulary: 15 object types, 21 damage types, 4 severities,
   9 report types, 5 ratings, so two reports by two people read the same.
4. A bilingual PDF, Greek and English on one page, A4 or Letter, with the
   studio's own letterhead: logo, name, address, the conservator's name and
   title, and a signature image. This is what EU-funded and museum work asks
   for and what the template cannot produce without a second afternoon.
5. Works without an account and without a signal: churches, storerooms and
   excavation sites. Sync is a choice, made later, to the studio's own server,
   with a durable outbox so nothing recorded offline is lost.
6. Site location on an object: coordinates taken on the spot, a small map in
   the app, the coordinates in the PDF. For archaeological and church work.
7. Export of the report with its original photographs as one ZIP, and of the
   whole collection as JSON, so the studio's records never depend on the app.
8. Projects and clients, so reports are filed under the job they were done for.
9. Account deletion in the app, and no telemetry: object values and site
   locations are sensitive, and the app never phones home.

## What comes after 1.0, in order

These were weighed for the 14.99 build and left out so that 1.0 ships. Each
is an update, not a new price.

- Treatment record per report: steps, materials used, hours, before and after
  photograph pairs. The data model and the server table exist; the screens do
  not. Largest single feature, and the one studios ask for after the report.
- Measured extent per damage marker (area in square centimetres or percent)
  with totals in the report. The marker already stores a rectangle.
- Before and after comparison across two reports of the same object, as a
  side-by-side viewer and a PDF page.
- Report versioning: an immutable snapshot per export, numbered on the
  document.
- Custom templates: reorder sections, hide fields, defaults per client.
- Loan and transport checklists as report-type sections.
- Full Greek localisation of every workflow screen.
- A project-level PDF bundle: every report for a client in one document.

## What was decided against

- A subscription. See above.
- A free tier with a watermark. A watermarked condition report is not a
  condition report, and the profession would not use it to evaluate the app.
- Cloud storage tiers (the "2 GB free, then upgradeable" wording in the old
  settings screen). Storage is the studio's own server or nothing.
- The Android and web clients as part of the 1.0 promise. They run from
  source and stay that way until the iOS app has paying users.

## The brand that carries it

The mark is a heavy C holding a small square: the bracket and the object,
the thing being kept. Verdigris, the patina on bronze, is the one accent, on
slate ink and frost. The same mark is the app icon (frost on ink), the site's
mark, and the favicon; the same three colours are the app's palette, the
site's and the PDF's. Type is Albert Sans on the site and the system face in
the app, one weight doing the work. Nothing is glass, nothing floats, surfaces
separate by a step in tone.
