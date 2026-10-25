"use client";

import { useCallback, useEffect, useRef, useState } from "react";

/* The page's one live thing: the loupe. It reads the pointer off a real
   photograph of a wall painting and prints the position at the report's own
   1:2 scale, plus the recorded observation nearest the pointer. */

type Mark = {
  id: string;
  left: number;
  top: number;
  type: string;
  sev: string;
  area: string;
};

const MARKS: Mark[] = [
  { id: "loss", left: 46, top: 35, type: "Paint loss", sev: "Poor", area: "0.23" },
  { id: "crack", left: 71, top: 56, type: "Active cracking", sev: "Fair", area: "0.08" },
  { id: "efflor", left: 33, top: 74, type: "Surface efflorescence", sev: "Fair", area: "0.41" },
];

// The object is 145 x 210 cm, the report's own dimensions; the readout halves
// them for the 1:2 plate scale.
const OBJ_W = 145;
const OBJ_H = 210;

export function Landing() {
  const [active, setActive] = useState<Mark>(MARKS[0]);
  const [pos, setPos] = useState("tap or move across");
  const [recorded, setRecorded] = useState(false);
  const loupeRef = useRef<HTMLDivElement>(null);
  const xRef = useRef<HTMLBRElement | null>(null);
  const yRef = useRef<HTMLBRElement | null>(null);
  const rootRef = useRef<HTMLDivElement>(null);

  const read = useCallback((e: React.PointerEvent<HTMLDivElement>) => {
    const box = loupeRef.current;
    if (!box) return;
    const r = box.getBoundingClientRect();
    const px = (e.clientX - r.left) / r.width;
    const py = (e.clientY - r.top) / r.height;
    if (px < 0 || px > 1 || py < 0 || py > 1) return;
    if (xRef.current) xRef.current.style.left = `${px * 100}%`;
    if (yRef.current) yRef.current.style.top = `${py * 100}%`;
    setPos(`${((px * OBJ_W) / 2).toFixed(1)} × ${((py * OBJ_H) / 2).toFixed(1)} cm`);
    let best = active;
    let bd = Infinity;
    for (const m of MARKS) {
      const dx = m.left / 100 - px;
      const dy = m.top / 100 - py;
      const d = dx * dx + dy * dy;
      if (d < bd) {
        bd = d;
        best = m;
      }
    }
    if (bd < 0.045) setActive(best);
  }, [active]);

  /* Entrances. The page renders in full without them. */
  useEffect(() => {
    const root = rootRef.current;
    if (!root) return;
    const targets = root.querySelectorAll("section, .plate .note, .rows, .slip, figure");
    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    if (!("IntersectionObserver" in window) || reduce) {
      targets.forEach((t) => t.classList.add("in"));
      return;
    }
    const io = new IntersectionObserver(
      (entries) => {
        entries.forEach((e) => {
          if (e.isIntersecting) {
            e.target.classList.add("in");
            io.unobserve(e.target);
          }
        });
      },
      { rootMargin: "0px 0px -10% 0px", threshold: 0.06 }
    );
    targets.forEach((t) => io.observe(t));
    const hero = root.querySelector(".hero");
    if (hero) hero.classList.add("in");
    return () => io.disconnect();
  }, []);

  return (
    <div className="cv-landing" ref={rootRef}>
      <a className="skip" href="#main">
        Skip to content
      </a>

      <main id="main">
        {/* hero: a control that reads the page */}
        <section className="hero">
          <div className="hero-l">
            <div className="hero-top">
              <a className="hero-mark" href="/">
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img src="/favicon.svg" alt="" width={26} height={26} />
                <span>Conservatio</span>
              </a>
              <span style={{ display: "flex", gap: "1.25rem" }}>
                <a className="tlink" href="/app">
                  Open the web app
                </a>
                <a className="tlink" href="https://github.com/peterdsp/conservatio">
                  GitHub
                </a>
              </span>
            </div>
            <div className="hero-bottom">
              <h1>
                <span className="mask">
                  <span>Condition reports for</span>
                </span>
                <span className="mask">
                  <span>cultural heritage.</span>
                </span>
              </h1>
              <p className="sub rise">
                Structured condition reports, damage marked directly on the photograph, and a
                bilingual PDF at the end. Built for conservators, museums, churches and
                archaeological teams, and built to work with no signal at all.
              </p>
              <p className="devnote rise">
                <b>Nothing is released yet.</b> Conservatio is in active development. There is no App
                Store listing, no Play Store listing and no public build: the iOS, Android and web
                clients run from source only. Everything below describes what is built and working in
                the repository today, not what you can download.
              </p>
              <div className="hero-act rise">
                <a className="btn" href="#platforms">
                  See what runs today
                </a>
                <a className="tlink" href="#report">
                  How a report is made
                </a>
              </div>
            </div>
          </div>
          <div className="hero-r">
            <div className="loupe">
              <div
                className="loupe-img"
                ref={loupeRef}
                data-ui=""
                onPointerMove={read}
                onPointerDown={read}
                onPointerLeave={() => setPos("tap or move across")}
              >
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src="/assets/2987-fresco-in-the-church-of-the.jpg"
                  alt="Byzantine wall painting of an angel in the Monastery of Daphni, Athens, with paint loss, surface efflorescence and cracking"
                  width={1920}
                  height={2560}
                  decoding="async"
                />
                <span className="xhair" aria-hidden="true">
                  <b className="vx" ref={xRef} />
                  <b className="hz" ref={yRef} />
                </span>
                {MARKS.map((m) => (
                  <button
                    key={m.id}
                    type="button"
                    className="mark"
                    style={{ left: `${m.left}%`, top: `${m.top}%` }}
                    aria-pressed={active.id === m.id}
                    onClick={() => setActive(m)}
                  >
                    <i />
                    <span className="sr">{`${m.type}, ${m.sev.toLowerCase()}`}</span>
                  </button>
                ))}
              </div>
              <div className="loupe-read">
                <dl>
                  <dt>Damage</dt>
                  <dd>{active.type}</dd>
                  <dt>Condition</dt>
                  <dd>{active.sev}</dd>
                  <dt>Affected area</dt>
                  <dd>{active.area} m²</dd>
                  <dt>Pointer, at 1:2</dt>
                  <dd>{pos}</dd>
                </dl>
              </div>
              <p className="loupe-cap">
                Three recorded observations on a wall painting in the Monastery of Daphni, Athens.
                Tap a marker, or move across the photograph to read the position off it.
              </p>
            </div>
          </div>
        </section>

        {/* showcase: one observation, three states */}
        <section className="lit" id="screens">
          <h2>One observation, three times.</h2>
          <div className="states">
            <div className="state">
              <span className="word">Photographed</span>
              <div data-ui="">
                <div className="ui-bar">
                  <span>IMG_2347.JPG</span>
                  <span className="chip">attached</span>
                </div>
                <div className="ui-main">
                  <div className="r">
                    <span>Wall painting, north wall</span>
                    <span className="sev">no observation yet</span>
                  </div>
                </div>
              </div>
              <p className="says">
                A photograph on its own is evidence of nothing. It needs to say what is wrong with
                the object and how much of it.
              </p>
            </div>

            <div className="state live">
              <span className="word">Annotated</span>
              <div data-ui="">
                <div className="ui-bar">
                  <span>IMG_2347.JPG</span>
                  <span className="chip">{recorded ? "2 observations" : "1 observation"}</span>
                </div>
                <div className="ui-main">
                  <div className="r">
                    <span>Damage type</span>
                    <span className="sev">Loss of paint and plaster</span>
                  </div>
                  <div className="r">
                    <span>Severity</span>
                    <span className="sev">Poor</span>
                  </div>
                  <div className="r">
                    <span>Measured extent</span>
                    <span className="sev">0.23 m²</span>
                  </div>
                  <div className="r">
                    <span>{recorded ? "Recorded by" : "Note"}</span>
                    <span className="sev">
                      {recorded ? "E. Papadopoulou, today" : "detachment risk along upper layer"}
                    </span>
                  </div>
                </div>
              </div>
              <button className="act" type="button" onClick={() => setRecorded((v) => !v)}>
                {recorded ? "Undo" : "Record the observation"}
              </button>
              <p className="says">
                Marked on the photograph itself, with a type from a controlled list, a severity and
                a measured extent. This is the step that makes the rest automatic.
              </p>
            </div>

            <div className="state">
              <span className="word">Reported</span>
              <div data-ui="">
                <div className="ui-bar">
                  <span>CR-2024-0457 · condition summary</span>
                  <span className="chip">PDF</span>
                </div>
                <div className="ui-main">
                  <div className="r">
                    <span>Loss of paint and plaster (0.23 m²)</span>
                    <span className="sev">Poor</span>
                  </div>
                  <div className="r">
                    <span>Active cracking cluster with micro-cracking</span>
                    <span className="sev">Poor</span>
                  </div>
                  <div className="r">
                    <span>Surface soiling and localised efflorescence</span>
                    <span className="sev">Fair</span>
                  </div>
                  <div className="gauge" aria-hidden="true">
                    <i style={{ width: "28%" }} />
                  </div>
                </div>
              </div>
              <p className="says">
                The same observation, printed into the condition report with its rating and its
                place in the overall condition. Nobody retyped it.
              </p>
            </div>
          </div>
        </section>

        {/* how it works: the itinerary slip */}
        <section className="band" id="report">
          <div className="slip-wrap">
            <div>
              <h2 className="rise">From first look to signed report.</h2>
              <p className="intro rise">
                A condition report is a sequence, not a form. Conservatio keeps the sequence and
                takes the retyping out of it, so the document at the end matches what was actually
                on the wall.
              </p>
            </div>
            <div>
              <figure className="rise" style={{ margin: "0 0 2rem" }}>
                {/* eslint-disable-next-line @next/next/no-img-element */}
                <img
                  src="/assets/report-preview.jpeg"
                  alt="A printed Conservatio condition report on a conservator's desk, with an annotated fresco photograph beside the object details, condition summary and recommended treatment"
                  width={1535}
                  height={1024}
                  loading="lazy"
                  decoding="async"
                />
                <figcaption
                  style={{
                    marginTop: 12,
                    fontSize: 13,
                    color: "var(--muted)",
                    lineHeight: 1.5,
                  }}
                >
                  The exported report. Sample content: the object, the conservator and the report
                  number are invented for this page.
                </figcaption>
              </figure>
              <div className="slip rise">
                <h3>On site</h3>
                <Line what="Photograph the object" val="camera" />
                <Line what="Mark damage on the photo" val="on the spot" />
                <Line what="Rate each observation" val="controlled list" />
                <Line what="Measure and note the extent" val="m²" />
                <h3>Back at the desk</h3>
                <Line what="Review the object record" val="any device" />
                <Line what="Write the treatment proposal" val="structured" />
                <Line what="Attach photographs" val="22 files" />
                <h3>To the client</h3>
                <Line what="Export the PDF" val="EN · EL · both" />
                <Line what="File it under the project" val="automatic" />
                <div className="total">
                  <span>A report you can hand over</span>
                  <span>same day</span>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* features: the plate with margin notes */}
        <section className="band sur" id="features">
          <div className="plate">
            <h2 className="rise">What the app holds.</h2>
            <div className="l">
              <Note title="Condition reports">
                Structured checklists, controlled vocabulary and damage rating. The Word template is
                replaced, not reproduced.
              </Note>
              <Note title="Image annotation">
                Cracks, paint loss and corrosion marked on the photograph itself. Each mark carries
                a type, a severity and a note.
              </Note>
              <Note title="Treatment notes">
                Recommended steps and observations recorded inside the report. Structured proposals
                with materials and costs are on the roadmap.
              </Note>
            </div>
            <div className="panel rise" data-ui="">
              <div className="ui-bar">
                <span>Condition report</span>
                <span className="chip">CR-2024-0457</span>
              </div>
              <div className="ui-main">
                <dl className="f">
                  <dt>Title</dt>
                  <dd>Wall painting (fresco)</dd>
                  <dt>Date</dt>
                  <dd>Late 18th century</dd>
                  <dt>Location</dt>
                  <dd>Church of St Nicholas, Thessaloniki</dd>
                  <dt>Technique</dt>
                  <dd>Fresco on lime plaster</dd>
                  <dt>Dimensions</dt>
                  <dd>145 × 210 cm</dd>
                  <dt>Conservator</dt>
                  <dd>E. Papadopoulou</dd>
                </dl>
              </div>
              <div className="ui-bar">
                <span>Observations</span>
                <span className="chip">4</span>
              </div>
              <div className="ui-main">
                <Row a="Loss of paint and plaster" b="0.23 m²" />
                <Row a="Active cracking cluster" b="Poor" />
                <Row a="Detachment risk, upper layer" b="Poor" />
                <Row a="Surface soiling, efflorescence" b="Fair" />
              </div>
              <div className="ui-bar">
                <span>Recommended treatment</span>
                <span className="chip">5 steps</span>
              </div>
              <div className="ui-main">
                <Row a="Stabilisation of active cracking" b="1" />
                <Row a="Consolidation of detached plaster" b="2" />
                <Row a="Infilling with lime plaster" b="3" />
                <Row a="Reversible retouching" b="4" />
                <Row a="Environmental monitoring" b="5" />
              </div>
              <div className="ui-bar">
                <span>Condition rating</span>
                <span className="chip">Poor</span>
              </div>
              <div className="ui-main">
                <div className="gauge" aria-hidden="true">
                  <i style={{ width: "28%" }} />
                </div>
                <div className="r" style={{ paddingTop: 10 }}>
                  <span>Export</span>
                  <span className="sev">EN · EL · bilingual</span>
                </div>
              </div>
            </div>
            <div className="r">
              <Note title="Project management">
                Objects, clients and reports grouped into projects, with status, timeline and budget
                in one place.
              </Note>
              <Note title="Offline first">
                Churches, basements and excavation sites have no signal. Everything is written
                locally and syncs when you reconnect.
              </Note>
              <Note title="Bilingual export">
                Condition report PDFs in English, Greek or both. Headings, labels and dates are
                translated; your own text stays as written.
              </Note>
            </div>
          </div>
        </section>

        {/* list: what runs where, honestly */}
        <section className="band" id="platforms">
          <div className="colpic">
            <div>
              <h2 className="rise">Where it runs today.</h2>
              <p className="intro rise">
                None of this is released. iOS is the most complete client, Android and the web
                companion are behind it, and this list says exactly how far each one has got in the
                repository.
              </p>
              <div className="rows rise">
                <p className="grp">iOS, native SwiftUI, runs from source</p>
                <PRow label="Object cataloguing" value="built" />
                <PRow label="Camera capture and on-site annotation" value="built" />
                <PRow label="Condition reports" value="built" />
                <PRow label="Offline storage and sync" value="built" />
                <PRow label="Bilingual PDF export" value="built" />
                <p className="grp">Android, Jetpack Compose and Material 3, runs from source</p>
                <PRow label="Object cataloguing" value="built" />
                <PRow label="Photo attachment" value="built" />
                <PRow label="Bilingual interface" value="built" />
                <PRow label="Condition reports and annotation" value="in progress" dot="soon" />
                <PRow label="PDF export" value="in progress" dot="soon" />
                <p className="grp">Web, desktop companion, the only part you can open today</p>
                <PRow label="Browse and edit objects, projects, clients" value="built" />
                <PRow label="No install needed" value="browser" dot="part" />
                <PRow label="PDF export" value="mobile only" dot="soon" />
              </div>
            </div>
            <figure className="rise">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/assets/kastoria-4.jpg"
                alt="Painted interior of a Byzantine church in Kastoria, Greece"
                width={1920}
                height={1284}
                loading="lazy"
                decoding="async"
              />
              <figcaption>
                Kastoria. The kind of interior where a report is written standing up, with no signal
                and one hand free.
              </figcaption>
            </figure>
          </div>
        </section>

        {/* proof: who this is for */}
        <section className="band" id="whom">
          <div className="colpic">
            <div>
              <h2 className="rise">Who it is for.</h2>
              <p className="intro rise">
                Conservatio fills the gap between a folder of Word files and an enterprise
                collections system. It is sized for the people who actually hold the scalpel.
              </p>
              <div className="whom rise" style={{ marginTop: "2.5rem" }}>
                <span className="lead">Written for</span>
                <span className="n">private conservators</span>
                <span className="n">small museums</span>
                <span className="n">churches and heritage sites</span>
                <span className="n">galleries</span>
                <span className="n">archaeological teams</span>
              </div>
              <p className="intro rise" style={{ marginTop: "2.5rem" }}>
                Private conservators get fast reports and professional PDFs with less admin. Small
                museums get affordable object inventory, condition history and maintenance tracking.
                Churches and heritage sites get a simple photo-based record, a maintenance calendar
                and a restoration history.
              </p>
            </div>
            <figure className="rise">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img
                src="/assets/lascar-church-of-metamorphosis-4517753626.jpg"
                alt="Painted vault and walls of the Church of the Metamorphosis"
                width={1920}
                height={1275}
                loading="lazy"
                decoding="async"
              />
              <figcaption>
                Church of the Metamorphosis. Parish records of this kind are the gap between a Word
                file and an enterprise system.
              </figcaption>
            </figure>
          </div>
        </section>

        {/* cta: a plain sentence and one action */}
        <section className="cta">
          <div className="col">
            <p className="rise">
              The code is published for transparency and personal evaluation. Read it, run it, and
              tell me what a real condition report needs that this does not have yet.
            </p>
            <div className="act rise">
              <a className="btn" href="/app">
                Open the web companion
              </a>
              <a className="tlink" href="https://github.com/peterdsp/conservatio">
                View on GitHub
              </a>
            </div>
          </div>
        </section>
      </main>

      <footer className="foot">
        <div className="in">
          <span>Conservation documentation</span>
          <nav>
            <a href="/app">Web app</a>
            <a href="https://github.com/peterdsp/conservatio">GitHub</a>
            <a href="https://github.com/peterdsp/conservatio/releases">Releases</a>
            <a href="https://peterdsp.dev">peterdsp.dev</a>
          </nav>
          <span>© 2026 Petros Dhespollari</span>
        </div>
        <p className="credits">
          Pictures:{" "}
          <a href="https://commons.wikimedia.org/w/index.php?curid=174845629">
            “Fresco in the church of the Monastery of Daphni (Athens)”
          </a>{" "}
          by Giovanni Dall’Orto,{" "}
          <a href="https://creativecommons.org/licenses/by-sa/2.5/it/deed.en/">CC BY-SA 2.5</a>;{" "}
          <a href="https://commons.wikimedia.org/w/index.php?curid=125931969">“Kastoria (4)”</a> by
          TijsB, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC BY-SA 2.0</a>;{" "}
          <a href="https://commons.wikimedia.org/w/index.php?curid=31951912">
            “Lascar Church of metamorphosis”
          </a>{" "}
          by Jorge Láscar,{" "}
          <a href="https://creativecommons.org/licenses/by/2.0/">CC BY 2.0</a>. All via Wikimedia
          Commons.
        </p>
      </footer>
    </div>
  );
}

function Line({ what, val }: { what: string; val: string }) {
  return (
    <div className="line">
      <span className="what">{what}</span>
      <span className="dots" />
      <span className="val">{val}</span>
    </div>
  );
}

function Note({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="note rise">
      <b>{title}</b>
      <span>{children}</span>
    </div>
  );
}

function Row({ a, b }: { a: string; b: string }) {
  return (
    <div className="r">
      <span>{a}</span>
      <span className="sev">{b}</span>
    </div>
  );
}

function PRow({ label, value, dot }: { label: string; value: string; dot?: "soon" | "part" }) {
  return (
    <div className="row">
      <span className="nm">
        <i className={dot} />
        {label}
      </span>
      <span className="v">{value}</span>
    </div>
  );
}
