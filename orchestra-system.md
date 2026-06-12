# Orchestra System — The Constitution (Template)

The orchestra system organizes **every** skill, agent, MCP, plugin, and connector you've installed
into themed **orchestras** plus one **Reserve Bench**. Each orchestra is a coordinated team with a
single conductor, a clear roster, strict allowances, and quality gates. This is how a large Claude
Code ecosystem gets used at 100% efficiency — without the model guessing what to fire.

> **This file is a template.** Copy it to `~/.claude/rules/orchestra-system.md` and fill the
> rosters with *your* tools. A filled-in real-world example is in
> [`examples/my-20-orchestras.md`](examples/my-20-orchestras.md).

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
7. **The registry is the machine twin.** This file is the human-readable doctrine;
   `~/.claude/orchestra/registry.json` is the machine-readable roster the score engine routes,
   ranks, and doctors from. Every roster or trigger change updates BOTH, then re-runs
   `orchestra index`.
8. **Escalate reasoning deliberately.** High-stakes domains carry a reasoning keyword
   (see *Reasoning Escalation* below) that the router injects automatically.

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

### The NEXUS phase map

| Phase | Orchestras it stacks |
|---|---|
| 0 — Discovery | RESEARCH · PRODUCT · KNOWLEDGE |
| 1 — Strategy | PRODUCT · PLANNING · MARKETING |
| 2 — Foundation | PLANNING · DESIGN |
| 3 — Build | BUILD · DESIGN · AI/ML · MOBILE |
| 4 — Hardening | BUILD (QA) · AUTOMATION · CYBERSECURITY · **AUDIT** *(verdict required before Phase 5)* |
| 5 — Launch | MARKETING · CONTENT · SEO · PAID ADS · GROWTH |
| 6 — Operate | ANALYTICS · GROWTH · AUTOMATION · DOCUMENTS |

> NEXUS is optional. If you don't want a meta-conductor, delete this section. The orchestras
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
- **Quality Gate:** every recommendation passes a `/pressure-test` before it's delivered

### ㉑ AUDIT — *Adversarial review before anything high-stakes ships, sends, or spends.*
- **Conductor:** `auditor` (ships with this repo: `agents/auditor.md`)
- **First Chair:** `hallucination-guard` (entry/exit gates), `/pressure-test`, code-review, security-review
- **Triggers:** audit this, pressure test, stress test, red team, is this safe, poke holes,
  before I launch/send
- **Auto-fire policy:** fires automatically **only on high-stakes actions** (prod deploys,
  money movements, outbound sends, irreversible changes). Everything else: explicit invoke,
  or append the universal flag word `AUDIT` to any prompt to force it. Configurable:
  `ORCHESTRA_AUDIT_MODE: high-stakes (default) | universal | off`.
- **Verdict posture:** defaults to **NEEDS WORK** — evidence flips it to READY, never optimism.
- **Loop mode (opt-in):** re-run the gate after each fix until clean, max 3 iterations.
- **Quality Gate:** verdict delivered as **READY / NEEDS WORK** (ship-level: SHIP / FIX-FIRST /
  STOP) with specific, routed fixes.

### ㉒ CYBERSECURITY — *Defend, detect, respond — and prove it.*
- **Conductor:** `<your security-lead agent>`
- **First Chair:** `<security-review, secret-scanning, dependency-audit skills>`
- **Section:** `<pentest, threat-model, incident-response, hardening, compliance skills>`
- **Triggers:** security, vulnerability, CVE, pentest, threat model, harden, incident, breach,
  secrets, OWASP, audit dependencies
- **Allowances:** defensive analysis freely; NEVER exploit targets you don't own; ASK before
  any active scanning of third-party systems
- **Handoff:** ← BUILD/AUTOMATION (pre-ship), → AUDIT (evidence verdict)
- **Quality Gate:** scan outputs captured, zero CRITICAL/HIGH unaddressed, secrets clean

---

## Reasoning Escalation — the ultra keywords

Recent Claude Code builds recognize reasoning keywords in the prompt. The router injects the
right one per orchestra (the `reasoning` field in the registry) so hard tasks automatically get
deeper thinking — and easy tasks don't pay for it:

| Keyword | What it does | Default orchestras |
|---|---|---|
| `ultrathink` | Deepest single-track reasoning | NEXUS, RESEARCH, FINANCE, EXECUTIVE ADVISORY |
| `ultraplan` | Planning-mode escalation | PLANNING & PM, PRODUCT, NEXUS Phase 0–1 |
| `ultracode` | Multi-agent orchestration for build work | BUILD, AI/ML, MOBILE |
| `ultrareview` | Review-mode escalation | AUDIT, BUILD quality gate |

Stacked routes (2+ orchestras) escalate to `ultrathink` automatically. `/pressure-test` is the
adversarial complement: keywords make thinking deeper, the pressure-test makes it survive
contact with reality. High-stakes gates use both.

---

## Harmony — the 3-Layer Ensemble (how players activate inside an orchestra)

An orchestra never activates "everything at once" — and never just one tool either. Each
activation builds an **ensemble**:

| Layer | Score (skill-selector) | Behavior |
|---|---|---|
| **Active Ensemble** | ≥ 0.70 | Loaded fully; the conductor sequences these |
| **Standby Bench** | 0.55 – 0.69 | Listed by name only; conductor summons mid-task if needed |
| **Reserve** | below / off-domain | Dormant; explicit name-invoke only |

Two tiers per task: **DEFAULT** (cap 12 active+standby) and **EXPANSION** (cap 18, standby
auto-promotes) for genuinely large tasks. The `skill-selector` skill computes the scores; the
score engine's pre-ranked players list is its starting pool. This is how "none of the tools go
wasted" works without drowning every prompt in noise.

## Rule 14 — Internal-First Search Ladder

Before any external research, climb the internal rungs **in order**:

1. **Your knowledge base** (Obsidian / notes — via qmd or your knowledge MCP)
2. **`~/.claude/` itself** (existing skills, learnings, docs, prior outputs)
3. **Score archive / memory** (AUDIT-verified outcomes from past sessions)
4. **Only then** external (WebSearch, scrapers, APIs)

Skip rungs only on explicit user override or genuinely brand-new information. This saves
tokens, finds prior work first, and stops the system re-buying knowledge it already owns.

## The Calibration Loop

Every failure becomes doctrine. When something breaks (wrong route, hallucinated claim, audit
bounce), append a **named calibration anchor** to `~/.claude/docs/learnings/audit-log.md` and,
if doctrinal, a line in the relevant skill/agent file. The same mistake must be structurally
unable to happen twice. (`orchestra board` + the usage log are the quantitative half of this;
calibration anchors are the qualitative half.)

## The Chain Protocol (multi-orchestra work)

- **Three chain shapes** — the router picks per task: **Sequential** (each step feeds the
  next), **Parallel fan-out** (independent streams, e.g. multi-component builds), and
  **Conductor-led tree** (one agent delegates dynamically).
- **Result-object handoffs** — every cross-orchestra handoff carries: `from, to, task_ref,
  value, context, evidence, next_actions, acceptance_criteria, status` (one of DONE /
  DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED / ASK_HUMAN). No bare "done" handoffs.
- **Cycle detection (safety):** max handoff depth 10 · direct cycles (A→B→A) blocked ·
  indirect cycles (A→B→C→A) trigger 🤚 ASK_HUMAN · chain timeout 5 min. AUDIT bounce-backs
  are exempt up to their 3-attempt cap.
- **Bounce-back:** a NEEDS-WORK verdict returns to the source orchestra with specific issues,
  required fixes, and re-submit criteria. Three failed attempts escalate to the human.

---

## ⓪ RESERVE BENCH — installed, dormant, named-invoke only

Off-domain specialists (vertical industries, game/XR dev, niche engineering, output-mode utilities)
that you've installed but don't want auto-firing. They stay live and instantly available **by
explicit name** — never triggered automatically. Promote into an active orchestra only on a real
pivot.

---

## Always-Rule: organize on every install, create orchestras when needed

Every time you install/add ANYTHING (skill, plugin, MCP, connector, agent), run the
[orchestra-intake skill](skills/orchestra-intake/SKILL.md): security-scan → classify → file into
the right orchestra(s) → update `registry.json` → re-run `orchestra index` → log it. **If the
new tool(s) form a coherent area no existing orchestra covers, CREATE a new orchestra** (full
10-field structure), add it here AND to the registry, bump the count, and note it. Never dump
new tools undifferentiated; never archive on install. The roster is living — it grows as your
ecosystem grows.

## Staying healthy at scale

- **Budget:** Claude Code truncates skill discovery past its character budget ("your skills are
  too much"). `orchestra doctor` measures it; `orchestra bench <skill>` moves cold skills out of
  the autoload path (still indexed + invocable by path). See `docs/SCALING-SKILLS.md`.
- **Rankings:** `orchestra board` regenerates the ranking board from tier + real usage telemetry.
- **Upkeep:** weekly `orchestra upkeep` (index + doctor + board) via cron — `orchestra cron`
  prints the line — or in cloud sessions: `/loop 24h "run orchestra upkeep"`.
