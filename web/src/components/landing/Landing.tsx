"use client";

import { useCallback, useEffect, useRef, useState } from "react";

/* The page's one live thing is the app's own annotation screen: the same
   icon photograph, the same numbered markers, the same controlled
   vocabulary. Tap the photo to add a marker, set its type and severity, and
   switch the language the report prints in. */

type Kind = "CRACK" | "FLAKING" | "PAINT_LOSS" | "CORROSION";
type Sev = "MINOR" | "MODERATE" | "SEVERE" | "CRITICAL";
type Lang = "en" | "el" | "both";

type Marker = { x: number; y: number; kind: Kind; sev: Sev; note: string };

const KINDS: Record<Kind, { en: string; el: string }> = {
  CRACK: { en: "Crack", el: "Ρωγμή" },
  FLAKING: { en: "Flaking", el: "Αποφλοίωση" },
  PAINT_LOSS: { en: "Paint loss", el: "Απώλεια χρώματος" },
  CORROSION: { en: "Corrosion", el: "Διάβρωση" },
};

const SEVS: Record<Sev, { en: string; el: string }> = {
  MINOR: { en: "Minor", el: "Ήπια" },
  MODERATE: { en: "Moderate", el: "Μέτρια" },
  SEVERE: { en: "Severe", el: "Σοβαρή" },
  CRITICAL: { en: "Critical", el: "Κρίσιμη" },
};

const HEAD = { en: "Annotations", el: "Σημειώσεις", both: "Σημειώσεις / Annotations" };

// The three markers from the app's own annotation screen, at the same places.
const START: Marker[] = [
  { x: 10.8, y: 58, kind: "FLAKING", sev: "SEVERE", note: "Lifting paint along the left edge of the mantle" },
  { x: 88, y: 44, kind: "PAINT_LOSS", sev: "MODERATE", note: "Gold ground lost around the upper right angel" },
  { x: 50, y: 95, kind: "CRACK", sev: "MINOR", note: "Craquelure across the lower border" },
];

const MAX = 6;

function word(v: { en: string; el: string }, lang: Lang) {
  if (lang === "en") return v.en;
  if (lang === "el") return v.el;
  return `${v.el} / ${v.en}`;
}

const OUTPUTS = [
  {
    id: "pdf",
    name: "The PDF report",
    line: "The object, its rating, the annotated photos and the damage list, in English, Greek or both, under your own letterhead.",
    src: "2-pdf",
    alt: "Conservatio on iPhone: the report preview of a bilingual Greek and English condition report for a Byzantine icon",
  },
  {
    id: "object",
    name: "The object record",
    line: "Owner, location, materials, dimensions and every condition report the object has had.",
    src: "3-detail",
    alt: "Conservatio on iPhone: the record of the Icon of the Virgin Hodegetria, with owner, location, dimensions and a pre-treatment report",
  },
  {
    id: "objects",
    name: "Every object",
    line: "Icons, ceramics, stone, metal, textiles, paper and wood, each with its inventory number and photo.",
    src: "4-objects",
    alt: "Conservatio on iPhone: the Objects list with an icon, a lekythos, a marble relief, a bronze lamp, a silk textile and a gospel leaf",
  },
  {
    id: "projects",
    name: "Projects and clients",
    line: "From the first inquiry to completed, with status, dates and budget for each client.",
    src: "5-projects",
    alt: "Conservatio on iPhone: the Projects list, from an inquiry for textile remounting to a completed gospel leaf consolidation",
  },
];

export function Landing() {
  const [marks, setMarks] = useState<Marker[]>(START);
  const [sel, setSel] = useState(0);
  const [lang, setLang] = useState<Lang>("en");
  const [out, setOut] = useState(0);
  const rootRef = useRef<HTMLDivElement>(null);

  const current = marks[sel];

  const add = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      if ((e.target as HTMLElement).closest("button")) return;
      const r = e.currentTarget.getBoundingClientRect();
      const x = ((e.clientX - r.left) / r.width) * 100;
      const y = ((e.clientY - r.top) / r.height) * 100;
      if (marks.length >= MAX) return;
      setMarks((m) => [...m, { x, y, kind: "CRACK", sev: "MINOR", note: "New observation" }]);
      setSel(marks.length);
    },
    [marks.length]
  );

  const update = (patch: Partial<Marker>) =>
    setMarks((m) => m.map((k, i) => (i === sel ? { ...k, ...patch } : k)));

  const reset = () => {
    setMarks(START);
    setSel(0);
  };

  /* Entrances. The page reads in full without them. */
  useEffect(() => {
    const root = rootRef.current;
    if (!root) return;
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (reduce || !("IntersectionObserver" in window)) return;
    root.classList.add("moving");
    const targets = root.querySelectorAll(".rise");
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) {
            e.target.classList.add("in");
            io.unobserve(e.target);
          }
        });
      },
      { rootMargin: "0px 0px -8% 0px", threshold: 0.05 }
    );
    targets.forEach((t) => io.observe(t));
    return () => io.disconnect();
  }, []);

  return (
    <div className="cv-landing" ref={rootRef}>
      <a className="skip" href="#main">
        Skip to content
      </a>

      <header className="bar">
        <a className="bar-mark" href="/" aria-label="Conservatio, home">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img src="/assets/mark.svg" alt="" width={24} height={24} />
          <span>Conservatio</span>
        </a>
        <nav aria-label="Sections">
          <a href="#mark">Annotate</a>
          <a href="#report">The report</a>
          <a href="#get">Get it</a>
          <a href="#questions">Questions</a>
        </nav>
        <a className="bar-act" href="/app">
          Open the web app
        </a>
      </header>

      <main id="main">
        {/* The split stage: the object stays on the bench while the page reads. */}
        <div className="stage" id="mark">
          <div className="stage-l">
            <div className="bench" data-ui="">
              <div className="photo" onClick={add}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src="/assets/app/icon-1085.webp"
                  srcSet="/assets/app/icon-640.webp 640w, /assets/app/icon-1085.webp 1085w"
                  sizes="(min-width: 900px) 34vw, 60vw"
                  width={1085}
                  height={1400}
                  alt="Byzantine icon of the Theotokos Hodegetria, egg tempera and gold leaf on panel, with numbered damage markers"
                />
                {marks.map((m, i) => (
                  <button
                    key={i}
                    type="button"
                    className={`pin s-${m.sev.toLowerCase()}`}
                    style={{ left: `${m.x}%`, top: `${m.y}%` }}
                    aria-pressed={sel === i}
                    aria-label={`Marker ${i + 1}: ${KINDS[m.kind].en}, ${SEVS[m.sev].en}`}
                    onClick={() => setSel(i)}
                  >
                    {i + 1}
                  </button>
                ))}
              </div>
              <div className="legend" aria-live="polite">
                <p className="legend-h">
                  <span>{HEAD[lang]}</span>
                  <span>{marks.length}</span>
                </p>
                <ul>
                  {marks.map((m, i) => (
                    <li key={i} className={sel === i ? "on" : ""}>
                      <button type="button" onClick={() => setSel(i)}>
                        <i className={`dot-n s-${m.sev.toLowerCase()}`}>{i + 1}</i>
                        <span className="lg-t">
                          <b>{word(KINDS[m.kind], lang)}</b>
                          <span>{m.note}</span>
                        </span>
                        <span className={`chip s-${m.sev.toLowerCase()}`}>{word(SEVS[m.sev], lang)}</span>
                      </button>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
          </div>

          <div className="stage-r">
            <section className="hero" aria-labelledby="title">
              <h1 id="title" className="name">
                conservatio
                <span className="sr">, condition reports for cultural heritage</span>
              </h1>
              <div className="hero-copy">
                <p className="lead rise">
                  Photograph a heritage object, mark the damage on the photo, and hand over a
                  PDF condition report.
                </p>
                <p className="note rise">
                  For iPhone and iPad, coming to the App Store. The web companion is open now.
                </p>
                <div className="acts rise">
                  <a className="btn" href="#mark-it">
                    Try it on this icon
                  </a>
                  <a className="btn btn-2" href="/app">
                    Open the web app
                  </a>
                </div>
              </div>
            </section>

            <section className="blocks" id="mark-it" aria-labelledby="mark-h">
              <h2 id="mark-h" className="rise">
                Mark it where it is.
              </h2>

              <div className="block">
                <h3 className="rise">Tap the photo to add a marker.</h3>
                <p className="rise">
                  Each marker is numbered and carries a damage type from a fixed list, a severity
                  and a note. Pick one on the icon and change it here.
                </p>
                <div className="ctl rise" role="group" aria-label={`Damage type for marker ${sel + 1}`}>
                  <span className="ctl-l">Marker {sel + 1}, damage</span>
                  <div className="seg">
                    {(Object.keys(KINDS) as Kind[]).map((k) => (
                      <button key={k} type="button" aria-pressed={current.kind === k} onClick={() => update({ kind: k })}>
                        {KINDS[k].en}
                      </button>
                    ))}
                  </div>
                </div>
                <div className="ctl rise" role="group" aria-label={`Severity for marker ${sel + 1}`}>
                  <span className="ctl-l">Severity</span>
                  <div className="seg">
                    {(Object.keys(SEVS) as Sev[]).map((s) => (
                      <button key={s} type="button" aria-pressed={current.sev === s} onClick={() => update({ sev: s })}>
                        {SEVS[s].en}
                      </button>
                    ))}
                  </div>
                </div>
                <p className="readout rise" aria-hidden="true">
                  <i className={`dot-n s-${current.sev.toLowerCase()}`}>{sel + 1}</i>
                  {word(KINDS[current.kind], lang)}, {word(SEVS[current.sev], lang)}
                </p>
                <p className="small rise">
                  {marks.length < MAX ? `${MAX - marks.length} more markers fit in this demo. ` : "That is the demo's limit. "}
                  <button type="button" className="tlink" onClick={reset}>
                    Start over
                  </button>
                </p>
              </div>

              <div className="block">
                <h3 className="rise">The report prints it in Greek, English or both.</h3>
                <p className="rise">
                  Damage types, severities and headings are translated. Your own notes stay as you
                  wrote them.
                </p>
                <div className="ctl rise" role="group" aria-label="Report language">
                  <span className="ctl-l">Report language</span>
                  <div className="seg">
                    <button type="button" aria-pressed={lang === "en"} onClick={() => setLang("en")}>
                      English
                    </button>
                    <button type="button" aria-pressed={lang === "el"} onClick={() => setLang("el")} lang="el">
                      Ελληνικά
                    </button>
                    <button type="button" aria-pressed={lang === "both"} onClick={() => setLang("both")}>
                      Both
                    </button>
                  </div>
                </div>
                <p className="readout rise" aria-hidden="true">
                  <i className={`dot-n s-${current.sev.toLowerCase()}`}>{sel + 1}</i>
                  {word(KINDS[current.kind], lang)}, {word(SEVS[current.sev], lang)}
                </p>
              </div>

              <div className="block">
                <h3 className="rise">It works with no signal.</h3>
                <p className="rise">
                  Everything is saved on the iPhone or iPad, with no account needed. Churches,
                  storerooms and excavation trenches are where the objects are.
                </p>
                <figure className="rise">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src="/assets/app/metamorphosis-1200.webp"
                    alt="The small Byzantine Church of the Metamorphosis in Athens, stone walls under a tiled dome"
                    width={1200}
                    height={797}
                    loading="lazy"
                    decoding="async"
                  />
                  <figcaption>The Church of the Metamorphosis, Athens.</figcaption>
                </figure>
              </div>
            </section>
          </div>
        </div>

        {/* What you hand over: the app's own screens. */}
        <section className="outputs" id="report" aria-labelledby="report-h">
          <div className="out-l">
            <h2 id="report-h" className="rise">
              What you hand over.
            </h2>
            <div className="out-names rise" role="tablist" aria-label="App screens">
              {OUTPUTS.map((o, i) => (
                <button
                  key={o.id}
                  type="button"
                  role="tab"
                  id={`tab-${o.id}`}
                  aria-selected={out === i}
                  aria-controls="out-stage"
                  onClick={() => setOut(i)}
                >
                  {o.name}
                </button>
              ))}
            </div>
            <p className="out-line rise" aria-live="polite">
              {OUTPUTS[out].line}
            </p>
          </div>
          <div className="out-stage" id="out-stage" role="tabpanel" aria-labelledby={`tab-${OUTPUTS[out].id}`}>
            {OUTPUTS.map((o, i) => (
              // eslint-disable-next-line @next/next/no-img-element
              <img
                key={o.id}
                className={out === i ? "on" : ""}
                src={`/assets/app/${o.src}-660.webp`}
                srcSet={`/assets/app/${o.src}-440.webp 440w, /assets/app/${o.src}-660.webp 660w`}
                sizes="(min-width: 900px) 380px, 78vw"
                width={660}
                height={1434}
                alt={o.alt}
                aria-hidden={out !== i}
                loading="eager"
                decoding="async"
              />
            ))}
          </div>
        </section>

        {/* How to get it, set like a menu. */}
        <section className="get" id="get" aria-labelledby="get-h">
          <h2 id="get-h" className="rise">
            How to get it.
          </h2>
          <div className="get-cols">
            <div className="grp rise">
              <h3>iPhone and iPad</h3>
              <div className="item">
                <p className="row">
                  <span>Conservatio</span>
                  <span>Coming soon</span>
                </p>
                <p className="desc">One purchase, no subscription. A build is in TestFlight and the App Store listing is being prepared.</p>
              </div>
            </div>
            <div className="grp rise">
              <h3>Today</h3>
              <div className="item">
                <p className="row">
                  <a href="/app">Web companion</a>
                  <span>Free</span>
                </p>
                <p className="desc">Objects, projects and clients in the browser. PDF export stays on the iPhone and iPad.</p>
              </div>
              <div className="item">
                <p className="row">
                  <span>Android</span>
                  <span>From source</span>
                </p>
                <p className="desc">Cataloguing and photos work. Reports and PDF export are in progress.</p>
              </div>
              <div className="item">
                <p className="row">
                  <a href="https://github.com/peterdsp/conservatio">Source code</a>
                  <span>GitHub</span>
                </p>
                <p className="desc">Published for transparency and personal evaluation.</p>
              </div>
            </div>
          </div>
        </section>

        {/* Questions, as reading text. */}
        <section className="faq" id="questions" aria-labelledby="faq-h">
          <h2 id="faq-h" className="rise">
            Questions.
          </h2>
          <div className="faq-text rise">
            <p>
              <b>Do I need an account?</b> No. Tap Continue without an account and start
              documenting. Sign-in is only there for sync.
            </p>
            <p>
              <b>Does it work offline?</b> Fully. Objects, photos, markers and reports are saved on
              the device, and the PDF is made there too.
            </p>
            <p>
              <b>What goes into a report?</b> The object record, the purpose of examination, the
              examiner and date, the overall rating, the annotated photos, the damage list and the
              recommended treatment.
            </p>
            <p>
              <b>Which report types?</b> Initial assessment, pre-treatment, post-treatment,
              outgoing and incoming loan, insurance, transport, periodic check and emergency.
            </p>
            <p>
              <b>Can it carry my studio&apos;s name?</b> Yes. The PDF takes your logo, name,
              address and signature, on A4 or Letter.
            </p>
            <p>
              <b>Which languages?</b> The app is in English and Greek, and the report prints in
              either or both on the same page.
            </p>
            <p>
              <b>Who is it for?</b> Private conservators, small museums, galleries, churches and
              archaeological teams who are done with Word templates and retyping.
            </p>
          </div>
        </section>

        {/* Lidhra, from the same maker. */}
        <section className="lidhra-promo" aria-labelledby="lidhra-promo-title" lang="en">
          <div className="lidhra-promo__copy">
            <h2 className="lidhra-promo__title rise" id="lidhra-promo-title">
              The debrid download manager for iPhone, Mac and Apple TV
            </h2>
            <p className="lidhra-promo__text rise">
              Paste a magnet or a link and Lidhra fetches it through Real-Debrid, AllDebrid, TorBox
              or six other services, then downloads it natively and resumes where it stopped.
              Finished files wait in a library, ready to play or cast to a TV.
            </p>
            <div className="lidhra-promo__facts rise">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img className="lidhra-promo__icon" src="/assets/lidhra/lidhra-icon.webp" width={48} height={48} alt="Lidhra app icon" loading="lazy" decoding="async" />
              <p>
                <strong>For iPhone, iPad, Mac, Apple TV and Vision Pro</strong>
                <br />
                One purchase, no subscription.
              </p>
            </div>
            <div className="lidhra-promo__actions rise">
              <a className="lidhra-promo__badge" href="https://apps.apple.com/app/lidhra-debrid-downloader/id6790952504?ct=conservatio&mt=8" rel="noopener">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src="/assets/lidhra/app-store-badge-black.svg" width={120} height={40} alt="Download Lidhra on the App Store" loading="lazy" decoding="async" />
              </a>
              <a className="tlink" href="https://lidhra.peterdsp.dev/" rel="noopener">
                See how Lidhra works
              </a>
            </div>
          </div>
          <figure className="lidhra-promo__shots rise">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img className="lidhra-promo__library" src="/assets/lidhra/lidhra-transfers-1200.webp" srcSet="/assets/lidhra/lidhra-transfers-640.webp 640w, /assets/lidhra/lidhra-transfers-1200.webp 1200w" sizes="(min-width: 900px) 50vw, 92vw" width={1200} height={600} alt="Lidhra on Mac: downloads coming to the device and files ready in the debrid cloud, with progress bars" loading="lazy" decoding="async" />
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img className="lidhra-promo__phone" src="/assets/lidhra/lidhra-add-360.webp" srcSet="/assets/lidhra/lidhra-add-240.webp 240w, /assets/lidhra/lidhra-add-360.webp 360w" sizes="(min-width: 900px) 160px, 28vw" width={360} height={570} alt="Lidhra on iPhone: the Add a transfer sheet, with a field for a magnet or an https link" loading="lazy" decoding="async" />
          </figure>
        </section>
      </main>

      <footer className="foot">
        <figure className="foot-pic">
          {/* eslint-disable-next-line @next/next/no-img-element */}
          <img
            src="/assets/app/daphni-1200.webp"
            alt="Byzantine wall painting of an angel in the Monastery of Daphni, Athens, with paint loss and cracking"
            width={1200}
            height={1600}
            loading="lazy"
            decoding="async"
          />
        </figure>
        <div className="foot-r">
          <a className="bar-mark" href="/">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img src="/assets/mark.svg" alt="" width={24} height={24} />
            <span>Conservatio</span>
          </a>
          <nav className="foot-menu" aria-label="Footer">
            <a href="/app">Web app</a>
            <a href="https://github.com/peterdsp/conservatio">GitHub</a>
            <a href="https://github.com/peterdsp/conservatio/releases">Releases</a>
            <a href="/support.html">Support</a>
            <a href="/privacy.html">Privacy</a>
          </nav>
          <div className="foot-small">
            <p>
              Made by Petros Dhespollari, <a href="https://peterdsp.dev">peterdsp.dev</a>
            </p>
            <p className="credits">
              Pictures: the Theotokos Hodegetria icon, Finnish National Gallery, public domain;{" "}
              <a href="https://commons.wikimedia.org/w/index.php?curid=174845629">Fresco in the church of the Monastery of Daphni</a> by Giovanni Dall&rsquo;Orto,{" "}
              <a href="https://creativecommons.org/licenses/by-sa/2.5/it/deed.en/">CC BY-SA 2.5</a>;{" "}
              <a href="https://commons.wikimedia.org/w/index.php?curid=31951912">Church of the Metamorphosis</a> by Jorge L&aacute;scar,{" "}
              <a href="https://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a>. Via Wikimedia Commons.
            </p>
            <p>&copy; 2026 Petros Dhespollari</p>
          </div>
        </div>
      </footer>
    </div>
  );
}
