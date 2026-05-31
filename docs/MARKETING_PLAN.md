# Conservatio Marketing Plan

## Positioning

**One-liner:** Professional conservation documentation that works offline, exports beautiful reports, and runs on your own hardware.

**Elevator pitch:** Conservatio replaces Word templates, WhatsApp photo folders, and scattered Google Drive files with a structured, searchable, offline-first documentation system. Condition reports, treatment proposals, image annotation, client management, and multilingual PDF export. Native iOS and Android, web dashboard, self-hosted on a Raspberry Pi.

**Differentiators:**
1. Built by someone who understands conservation, not a generic SaaS team
2. Offline-first (works in churches, basements, excavation sites)
3. Self-hosted option (your data never leaves your network)
4. Multilingual reports (Greek, English, expandable)
5. Professional PDF export that makes conservators look more professional, not more bureaucratic
6. Open source core

## Target audience (in launch order)

### Phase 1: Private conservators in Greece (0-6 months)
- Solo practitioners and small studios (2-5 people)
- Document paintings, icons, wall paintings, archaeological finds
- Current workflow: Word, Excel, photos on phone, email to clients
- Pain: spending 30-40% of time on documentation admin
- Language: Greek-first, English second
- Reach: ~200-500 active conservators in Greece

### Phase 2: Mediterranean heritage professionals (6-12 months)
- Italy, Spain, Turkey, Balkans, Cyprus
- Church conservation, archaeological sites, small museums
- Same pain points, different languages
- Reach: ~5,000-10,000 professionals

### Phase 3: European and international (12+ months)
- EU-funded heritage projects (require structured documentation)
- UK, France, Germany conservation communities
- Museum professionals seeking affordable alternatives to TMS
- Reach: ~50,000+ professionals globally

## Revenue model

### Free tier (self-hosted)
- Unlimited objects, reports, images
- Single user
- Local PDF export
- Community support
- Purpose: adoption, open-source credibility, conference talks

### Pro tier (hosted, 15 EUR/month)
- Cloud sync across devices
- Team collaboration (up to 5 users)
- Branded PDF templates (studio logo, custom header)
- Client portal (read-only access for clients)
- Priority email support

### Studio tier (hosted, 39 EUR/month)
- Unlimited team members
- Advanced project management
- Time tracking and invoicing export
- Custom report templates
- API access
- Phone support

### Institutional tier (custom pricing)
- For museums, archaeological services, heritage authorities
- On-premises deployment
- Integration with existing collection management systems
- Training and onboarding
- SLA

## Pre-launch checklist

### Product (before any marketing)
- [ ] Working object creation flow (iOS)
- [ ] Photo capture and basic image annotation
- [ ] Condition report creation with damage checklist
- [ ] PDF export (one professional template)
- [ ] User registration and auth
- [ ] Backend deployed on Pi
- [ ] TestFlight beta for iOS

### Branding
- [ ] Logo (proper vector, not just favicon)
- [ ] App Store screenshots (iPhone, iPad)
- [ ] Play Store screenshots
- [ ] Social media assets (LinkedIn banner, Twitter header)
- [ ] Demo video (60 seconds, showing condition report workflow)

## Launch channels (ranked by expected impact)

### 1. Conservation community direct outreach
**Why:** This is a niche market. Personal connection beats ads.

**Actions:**
- Attend ICOM Greece meetings and present the tool
- Contact the Greek Ministry of Culture conservation department
- Reach out to conservation studies programs (University of West Attica, TEI Athens)
- Demo at local conservation workshops
- Ask 5-10 conservators to beta test (personal network, LinkedIn)

### 2. LinkedIn
**Why:** Conservators, museum professionals, and heritage managers are active on LinkedIn. This is not a Twitter/X audience.

**Content plan (2 posts/week):**
- Week 1: "I built an app for conservators." Show before/after (Word template vs. Conservatio PDF)
- Week 2: Technical deep-dive on the architecture (the case study, condensed)
- Week 3: "Why I self-host conservation data on a Raspberry Pi" (this will get tech press attention)
- Week 4: Demo video of the condition report workflow
- Ongoing: share conservation projects (with permission), user testimonials, feature updates

**Target connections:** conservation professionals, museum directors, heritage NGOs, EU project managers, archaeological institutes

### 3. Academic publications and conferences
**Why:** Conservation is an academic-adjacent field. Papers and talks build credibility that no ad campaign can match.

**Target venues:**
- ICOM (International Council of Museums) annual conference
- ICCROM (International Centre for the Study of the Preservation and Restoration of Cultural Property)
- Digital Heritage conference
- Journal of the American Institute for Conservation (AIC)
- Studies in Conservation (IIC journal)
- European Association of Archaeologists (EAA) annual meeting

**Paper topics:**
1. "Affordable Digital Conservation Documentation for Under-Resourced Heritage Institutions"
2. "Self-Hosted Heritage Data: A Raspberry Pi Approach to Conservation Privacy"
3. "From Field to Report: Offline-First Mobile Documentation for Archaeological Conservation"

### 4. GitHub and open source community
**Why:** Developers in the heritage/GLAM (Galleries, Libraries, Archives, Museums) space actively look for open-source tools.

**Actions:**
- Polish the README with GIFs showing the app in action
- Submit to awesome-selfhosted list
- Submit to awesome-conservation or cultural heritage GitHub lists
- Write a dev.to / Medium article: "Building a multiplatform heritage app with KMP"
- Post on Hacker News (the Pi self-hosting angle plays well here)

### 5. Heritage sector press
**Why:** Niche publications reach exactly the right audience.

**Target outlets:**
- The Art Newspaper
- Museum Next
- Apollo Magazine
- Heritage Daily
- Conservation DistList (the conservation community's main mailing list, extremely influential)
- AIC News
- ICOM newsletters

**Pitch angle:** "A Greek developer built an open-source conservation documentation app that runs on a 35 EUR computer"

### 6. Product Hunt launch
**Why:** One-day visibility spike, good for backlinks and credibility badge.

**Timing:** After iOS and web are polished, with a demo video. Aim for a weekday (Tuesday-Thursday).

**Prep:** Have 5+ beta users ready to comment with real use cases.

### 7. EU funding and heritage grants
**Why:** EU actively funds digital heritage infrastructure. Conservatio could qualify for grants.

**Programs to research:**
- Creative Europe (digital culture strand)
- Horizon Europe (cultural heritage calls)
- Digital Europe Programme
- National Greek NSRF digital transformation funds
- Erasmus+ (if tied to conservation education)

**Angle:** "Open-source digital infrastructure for European cultural heritage documentation"

## Content marketing calendar (first 3 months after MVP)

### Month 1: Soft launch
- Week 1: LinkedIn announcement post
- Week 2: Conservation DistList announcement email
- Week 3: Hacker News "Show HN" post
- Week 4: Dev.to technical article

### Month 2: Build credibility
- Week 1: First user testimonial (video or quote)
- Week 2: Case study: "How [conservator name] documented a Byzantine icon restoration with Conservatio"
- Week 3: Conference submission (ICOM or Digital Heritage)
- Week 4: Product Hunt launch

### Month 3: Expand reach
- Week 1: Demo video on YouTube (full workflow)
- Week 2: Pitch to The Art Newspaper and Heritage Daily
- Week 3: University workshop or guest lecture
- Week 4: Launch Italian/Spanish language support, announce in those communities

## Metrics to track

| Metric | Target (6 months) |
|--------|-------------------|
| GitHub stars | 500+ |
| Beta testers | 20-50 active conservators |
| Paid subscribers | 10-20 (Pro tier) |
| Conference talks | 1-2 accepted |
| Paper submissions | 1 submitted |
| LinkedIn followers | 500+ |
| Countries with users | 5+ |
| Conservation DistList mentions | 3+ |

## Key messages

### For conservators
"Stop spending your evenings formatting Word documents. Conservatio gives you professional condition reports in minutes, not hours."

### For museums
"Museum-grade documentation at a fraction of the cost. No IT department required."

### For heritage authorities
"A standardized, searchable digital inventory for your jurisdiction's cultural assets. Open source, self-hosted, your data stays yours."

### For press
"A Greek developer is building the open-source alternative to enterprise museum software, and it runs on a Raspberry Pi."

### For academics
"An open, interoperable conservation documentation platform designed around professional ethics and international standards."

## Budget (MVP phase)

| Item | Cost |
|------|------|
| Apple Developer Program | 99 EUR/year |
| Google Play Developer | 25 EUR one-time |
| Domain (peterdsp.dev, already owned) | 0 |
| Hosting (Raspberry Pi, already owned) | 0 |
| Cloudflare (free tier) | 0 |
| LinkedIn (organic only) | 0 |
| Conference travel (1 event) | ~300-500 EUR |
| **Total year 1** | **~500 EUR** |

The cost structure is a feature. "Built and hosted for under 500 EUR" is a story in itself.
