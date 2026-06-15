# Orchestra System — The Constitution (Template)

The orchestra system organizes **every** skill, agent, MCP, plugin, and connector you've installed
into themed **orchestras** plus one **Reserve Bench**. Each orchestra is a coordinated team with a
single conductor, a clear roster, strict allowances, and quality gates. This is how a large Claude
Code ecosystem gets used at 100% efficiency — without the model guessing what to fire.

> **This file is a template.** Copy it to `~/.claude/rules/orchestra-system.md` and fill the
> rosters with *your* tools. A filled-in real-world example is in
> [`examples/my-22-orchestras.md`](examples/my-22-orchestras.md).

---

## Core Doctrine

1. **One Conductor per orchestra.** When an orchestra activates, its conductor agent leads and
   sequences the other players. Coordination, not just activation.
2. **Auto-activate + always announce.** Every request is routed automatically. State which
   orchestra(s) activated, who conducts, and which tools are in play — every time:
   `🎼 <ORCHESTRA> active · Conductor: <agent> · Using: <tools>`
3. **Stack when complementary.** "Make a landing page" isn't only DESIGN — it stacks
   PLANNING → DESIGN → BUILD → (QA) → optionally SEO/GROWTH. Announce the stack.
4. **Reserve Bench never auto-fires.** Off-domain specialists stay installed and instantly
   available by explicit name, but never trigger automatically.
5. **Nothing is archived on install — it is filed.** New tools run through the intake process,
   get classified, and placed into the right orchestra with usage notes.
6. **Every assignment is logged** so it survives across sessions.

---

## The Orchestra Structure (every orchestra has these 10 fields)

| Field | Meaning |
|---|---|
| **Mission** | One line — what it exists to do |
| **Conductor** | The ONE lead agent that coordinates the orchestra |
| **First Chair** | Primary agents + skills — always activate |
| **Section** | Supporting skills / MCPs / connectors — activate as needed |
| **Triggers** | Phrases that auto-fire this orchestra |
| **Process** | Phased workflow with quality gates |
| **Allowances** | Autonomous vs. needs-permission (the guardrails) |
| **Harness** | Environment, MCPs, file access the orchestra needs |
| **Handoff** | Which orchestra it passes to / receives from |
| **Quality Gate** | Definition of "done" before handoff |

---

## ✦ NEXUS — The Meta-Conductor (sits ABOVE the orchestras)

NEXUS is the meta-conductor: the moment you're in **idea or business-planning mode**, it fires and
sequences orchestras across a lifecycle (Discovery → Strategy → Foundation → Build → Hardening →
Launch → Operate).

- **Auto-fire triggers:** "I have an idea", "thinking of building", "plan a business", "what if I
  built", "should I build", "is this a good idea".
- **Why it matters:** it turns scattered ideation into a decisive, sequenced plan instead of
  jumping straight to code.

### NEXUS phase → orchestra map

| Phase | Orchestras it sequences |
|---|---|
| 0 — Discovery | RESEARCH · PRODUCT · KNOWLEDGE |
| 1 — Strategy | PRODUCT · PLANNING · MARKETING |
| 2 — Foundation | PLANNING · DESIGN |
| 3 — Build | BUILD · DESIGN · AI/ML · MOBILE |
| 4 — Hardening | BUILD (QA) · AUTOMATION · CYBERSECURITY · **AUDIT** *(verdict required before Phase 5)* |
| 5 — Launch | MARKETING · CONTENT · SEO · PAID ADS · GROWTH |
| 6 — Operate | ANALYTICS · GROWTH · AUTOMATION · DOCUMENTS |

> NEXUS is optional. If you don't want a meta-conductor, delete this section. The 22 orchestras
> work fine on their own.

---

## The 22 Orchestras

> Fill each **First Chair** / **Section** with your own installed tools. The themes below are a
> starting taxonomy — add, merge, or rename to fit your stack. The **Always-Rule** (bottom) tells
> you when to create a brand-new orchestra.

### ① BUILD — *Ship working, reviewed code.*
- **Conductor:** `<your architect/lead-dev agent>`
- **First Chair:** `<code-review, debugging, testing/QA, framework dev agents>`
- **Section:** `<deploy, perf, security-review, codebase-mapping skills>`
- **Triggers:** build, fix bug, refactor, implement, code review, add feature, deploy, ship
- **Allowances:** edit/write code freely; ASK before schema/data-model changes, dep removals, CI changes, prod deploy
- **Quality Gate:** builds clean, no errors, tested, reviewed

### ② DESIGN — *Beautiful, on-brand interfaces.*
- **Conductor:** `<your UX/design-lead agent>`
- **First Chair:** `<UI design, UX research, brand, visual skills>`
- **Triggers:** design, UI, UX, mockup, screen, layout, wireframe, visual, brand
- **Handoff:** → BUILD

### ③ RESEARCH — *Know more than the competition.*
- **Conductor:** `<your research agent>`
- **First Chair:** `<web research, scraping, competitive-intel skills>`
- **Triggers:** research, find out, investigate, competitive analysis, deep dive, what's the latest
- **Allowances:** check existing notes/knowledge first; STOP after ~5 fruitless searches

### ④ MARKETING — *Reach the right people.*
- **Conductor:** `<your marketing agent>`
- **Triggers:** marketing strategy, social media, campaign, brand awareness, go-to-market, GTM

### ⑤ CONTENT — *Words and creative that convert.*
- **Conductor:** `<your content/copy agent>`
- **Triggers:** write copy, blog post, newsletter, content, carousel, email sequence, captions

### ⑥ SEO + GEO — *Win search + AI answers.*
- **Conductor:** `<your SEO agent>`
- **Triggers:** SEO, rank, search optimization, AI search, GEO, schema markup, AEO

### ⑦ LEAD GEN & SALES — *Find clients, close deals.*
- **Conductor:** `<your sales/outbound agent>`
- **Triggers:** find leads, prospect, outreach, cold email, close deal, pipeline, RevOps, pricing
- **Allowances:** ASK before sending any outreach (visible to others)

### ⑧ PRODUCT — *Build the right thing.*
- **Conductor:** `<your product-manager agent>`
- **Triggers:** product strategy, PRD, roadmap, user research, feature prioritization

### ⑨ VIDEO + MEDIA — *Generate and edit video/image.*
- **Conductor:** `<your media agent>`
- **Triggers:** make video, reels, generate image, edit video, thumbnail

### ⑩ ANALYTICS — *Measure everything.*
- **Conductor:** `<your analytics agent>`
- **Triggers:** analytics, metrics, funnel, cohort, track, dashboard, A/B test results

### ⑪ KNOWLEDGE & MEMORY — *Remember and connect everything.*
- **Conductor:** `<your knowledge/memory agent>`
- **Triggers:** remember this, knowledge graph, notes, what do I know about, map this codebase

### ⑫ DOCUMENTS & REPORTS — *Polished deliverables.*
- **Conductor:** `<your document-generation agent>`
- **Triggers:** create report, make deck, write doc, export PDF, slide deck

### ⑬ PAID ADS — *Ads that profit.*
- **Conductor:** `<your paid-media agent>`
- **Triggers:** Google Ads, Meta ads, paid media, ad copy, PPC, campaign audit
- **Allowances:** ASK before spending money or launching live campaigns

### ⑭ AUTOMATION & OPS — *Automate what repeats.*
- **Conductor:** `<your automation agent>`
- **Triggers:** automate, workflow, when X do Y, recurring task, schedule, pipeline
- **Note:** "from now on when X" → requires a HOOK, not memory

### ⑮ AI/ML — *Build AI systems.*
- **Conductor:** `<your AI-engineer agent>`
- **Triggers:** AI pipeline, fine-tune, multi-agent, build MCP, RAG, embeddings, agent system

### ⑯ MOBILE — *Ship mobile apps.*
- **Conductor:** `<your mobile-dev agent>`
- **Triggers:** iOS, Android, Swift, React Native, app store, mobile app

### ⑰ PLANNING & PM — *Plan before building.*
- **Conductor:** `<your planner agent>`
- **Triggers:** plan, PRD, sprint, OKRs, roadmap, user stories, milestones

### ⑱ GROWTH & CONVERSION — *Users → revenue.*
- **Conductor:** `<your growth agent>`
- **Triggers:** conversion, A/B test, churn, retention, paywall, ASO, referral, pricing, activation

### ⑲ FINANCE — *Money decisions.*
- **Conductor:** `<your finance/research agent>`
- **Triggers:** invest, valuation, DCF, earnings, portfolio, burn/runway, SaaS metrics
- **Allowances:** NEVER execute trades or move money — analysis only

### ⑳ EXECUTIVE ADVISORY — *Founder-grade strategic counsel.*
- **Conductor:** `<your chief-of-staff agent>`
- **Triggers:** as CEO/CFO, founder advice, board deck, M&A, scenario planning, should I hire/raise/pivot
- **Allowances:** advisory only — never executes hiring/spending/legal actions

### ㉑ AUDIT — *Verify everything. Default to NEEDS WORK.*
- **Mission:** the last gate before high-stakes output reaches you. Defaults to NEEDS WORK; only
  flips to READY with fresh, cited evidence (paths + line numbers, this session).
- **Conductor:** `<your auditor/reviewer agent>`
- **First Chair:** `<code-review, evidence-collection, verification skills>`
- **Triggers:** auto-fires after high-stakes work (BUILD, AI/ML, AUTOMATION, FINANCE, anything
  touching CI / install / hooks / secrets / settings). Explicit: "audit this", "verify", "double-check".
- **Process:** source orchestra output + evidence → cross-check → READY or NEEDS WORK (bounce back
  with a specific fix list, capped retries, then ask a human).
- **Allowances:** READ + INSPECT only. No writes except an append-only audit log.
- **Quality Gate:** READY only with current-session evidence. "It worked yesterday" = NEEDS WORK.

### ㉒ CYBERSECURITY — *Defend, detect, respond, and prove it.*
- **Mission:** security across the stack — code review, threat modelling, detection, incident
  response, and authorized testing. (Fill with your own security skills/agents — this orchestra
  ships as a *slot*, not a bundled toolset.)
- **Conductor:** `<your security-engineer agent>`
- **First Chair:** `<secure-code-review, threat-model, detection, IR skills>`
- **Triggers:** security review, pentest (authorized), vulnerability, CVE, threat model, incident,
  hardening, secrets handling
- **Allowances:** analysis/detection freely. ASK before any active exploit against a live system,
  touching prod secrets, or sending findings externally.
- **Handoff:** ← BUILD (AppSec) · → AUDIT (test output)
- **Quality Gate:** findings + actionable remediation, no unverified claims

---

## ⓪ RESERVE BENCH — installed, dormant, named-invoke only

Off-domain specialists (vertical industries, game/XR dev, niche engineering, output-mode utilities)
that you've installed but don't want auto-firing. They stay live and instantly available **by
explicit name** — never triggered automatically. Promote into an active orchestra only on a real
pivot.

---

## Cross-cutting doctrine (applies to every orchestra)

These rules sit above routing — they apply no matter which orchestra fired.

- **Internal-first search ladder.** Before any web search, check internal sources in order:
  (1) your own notes/knowledge base, (2) your `~/.claude` docs + prior learnings, (3) your session
  memory — *then* go external. Announce a hit (`🔍 found in <source>`) or a clean miss
  (`🔍 internal: 0 hits → going external`). Saves tokens and surfaces prior work first.
- **3-layer ensemble (Harmony).** Each orchestra activates the best *combination* of tools, not
  just the single top match: an **Active Ensemble** (high-confidence picks) loads in full, a
  **Standby Bench** (medium-confidence) is summoned by name when the conductor needs it, and the
  **Reserve Bench** stays named-invoke only. No installed tool left guessing.
- **Calibration loop.** When something surprising fails, log it to an append-only learnings/audit
  file and anchor the named past-failure into doctrine, so the same mistake can't recur.
- **AUDIT is the high-stakes gate.** High-stakes orchestras (BUILD, AI/ML, AUTOMATION, FINANCE,
  EXECUTIVE ADVISORY, CYBERSECURITY, and any change to CI/install/hooks/secrets) hand off to
  AUDIT before "done." Low-stakes work (CONTENT, DESIGN, RESEARCH, DOCUMENTS) skips it.

> These are **doctrine the model follows**, not enforced code. The routing hook injects the
> directive; the model honors it. Treat them as strong conventions, and tune them to your taste.

---

## Always-Rule: organize on every install, create orchestras when needed

Every time you install/add ANYTHING (skill, plugin, MCP, connector, agent), run the
[orchestra-intake skill](skills/orchestra-intake/SKILL.md): security-scan → classify → file into
the right orchestra(s) → log it. **If the new tool(s) form a coherent area no existing orchestra
covers, CREATE a new orchestra** (full 10-field structure), add it here, bump the count, and note
it. Never dump new tools undifferentiated; never archive on install. The roster is living — it
grows as your ecosystem grows.
