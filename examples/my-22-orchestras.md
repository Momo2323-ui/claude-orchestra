# A real 22-orchestra config (worked example)

This is a real, working orchestra setup — the rosters, the reasoning, and links to the skills used.
It's here so you can see the pattern *filled in*, not just the template.

**Notes:**
- Personal projects are anonymized (`my-mobile-app`, `my-ios-app`, `my-agency`).
- `[anthropics]` links to <https://github.com/anthropics/skills>. `[custom]` = an agent I wrote
  myself (yours will differ). `[community]` = a third-party skill — in a real published config,
  link each to its own source repo so authors get the credit.
- This is one person's taxonomy. Copy what's useful, change the rest.

---

### ✦ NEXUS — meta-conductor
Fires on idea/business-planning signals and sequences the orchestras across a 7-phase lifecycle
(Discovery → Strategy → Foundation → Build → Hardening → Launch → Operate). My single highest-value
piece — it turns "I have an idea" into a sequenced plan instead of jumping to code.

### ① BUILD — *Ship working, reviewed code.*
- **Conductor:** architect `[custom]`
- **First Chair:** code-reviewer `[custom]`, debugger `[custom]`, tdd-guide `[custom]`, QA agents
- **Section:** security-review `[community]`, deployment-patterns `[community]`, webapp-testing `[anthropics]`
- **Triggers:** build, fix bug, refactor, implement, deploy, ship, code review
- **Used on:** `my-mobile-app` (React Native), `my-ios-app` (Swift)
- **Allowances:** edit code freely; ASK before schema changes, dep removals, prod deploy

### ② DESIGN — *Beautiful, on-brand interfaces.*
- **Conductor:** ux-architect `[custom]`
- **First Chair:** ui-designer `[custom]`, brand-guardian `[custom]`
- **Section:** canvas-design `[anthropics]`, web-artifacts-builder `[anthropics]`, theme-factory `[anthropics]`
- **Triggers:** design, UI, UX, mockup, layout, wireframe, brand
- **Handoff:** → BUILD

### ③ RESEARCH — *Know more than the competition.*
- **Conductor:** research-agent `[custom]`
- **Section:** deep-research `[community]`, competitor-profiling `[community]`
- **Triggers:** research, investigate, competitive analysis, what's the latest
- **Allowance:** STOP after ~5 fruitless searches; check existing notes first.

### ④ MARKETING — *Reach the right people.*
- **Conductor:** marketing `[custom]`
- **Section:** social-media-strategist `[community]`, growth-hacker `[community]`
- **Triggers:** marketing strategy, social media, campaign, GTM

### ⑤ CONTENT — *Words and creative that convert.*
- **Conductor:** content-creator `[custom]`
- **Section:** copywriting `[community]`, content-humanizer `[community]`, hook-generator `[community]`
- **Triggers:** write copy, blog, newsletter, content, carousel, captions
- **Handoff:** ← MARKETING, → SEO

### ⑥ SEO + GEO — *Win search + AI answers.*
- **Conductor:** seo-specialist `[custom]`
- **Section:** schema, programmatic-seo, ai-citation-strategist `[community]`
- **Triggers:** SEO, rank, schema, AI search, GEO, AEO

### ⑦ LEAD GEN & SALES — *Find clients, close deals.*
- **Conductor:** outbound-strategist `[community]`
- **Section:** pipeline-analyst, pricing-strategist, customer-success `[community]`
- **Triggers:** find leads, prospect, outreach, cold email, pipeline, pricing, RevOps
- **Allowance:** ASK before sending any outreach.

### ⑧ PRODUCT — *Build the right thing.*
- **Conductor:** product-manager `[custom]`
- **Section:** create-prd, jobs-to-be-done, experiment-designer `[community]`
- **Triggers:** product strategy, PRD, roadmap, feature prioritization
- **Used on:** `my-mobile-app`, `my-ios-app`

### ⑨ VIDEO + MEDIA — *Generate and edit video/image.*
- **Conductor:** media-coach `[community]`
- **Section:** remotion, slack-gif-creator `[anthropics]`, image-gen `[community]`
- **Triggers:** make video, reels, generate image, thumbnail

### ⑩ ANALYTICS — *Measure everything.*
- **Conductor:** analytics-reporter `[custom]`
- **Section:** cohort-analysis, ab-test-analysis, statistical-analyst `[community]`
- **Plugins/MCPs:** PostHog, Amplitude
- **Triggers:** analytics, metrics, funnel, cohort, dashboard, A/B results

### ⑪ KNOWLEDGE & MEMORY — *Remember and connect everything.*
- **Conductor:** zk-steward `[community]`
- **Section:** knowledge-graph tooling, codebase-mapper, this orchestra-intake skill
- **Triggers:** remember, knowledge graph, notes, map this codebase

### ⑫ DOCUMENTS & REPORTS — *Polished deliverables.*
- **Conductor:** document-generator `[custom]`
- **Section:** docx / pdf / pptx / xlsx `[anthropics]`, doc-coauthoring `[anthropics]`, slidev
- **Triggers:** create report, deck, export PDF, slides

### ⑬ PAID ADS — *Ads that profit.*
- **Conductor:** ppc-strategist `[community]`
- **Triggers:** Google/Meta ads, paid media, PPC, ad creative
- **Allowance:** ASK before spending money / launching live campaigns.

### ⑭ AUTOMATION & OPS — *Automate what repeats.*
- **Conductor:** automation-architect `[community]`
- **Section:** workflow-architect, n8n tooling
- **Triggers:** automate, workflow, recurring task, schedule, pipeline
- **Note:** "from now on when X" → a HOOK, not memory.

### ⑮ AI/ML — *Build AI systems.*
- **Conductor:** ai-engineer `[custom]`
- **Section:** mcp-builder `[anthropics]`, multi-agent patterns, RAG tooling
- **Triggers:** AI pipeline, fine-tune, multi-agent, build MCP, RAG, embeddings

### ⑯ MOBILE — *Ship mobile apps.*
- **Conductor:** mobile-app-builder `[custom]`
- **Triggers:** iOS, Android, Swift, React Native, app store
- **Used on:** `my-ios-app`

### ⑰ PLANNING & PM — *Plan before building.*
- **Conductor:** planner `[custom]`
- **Section:** make-plan, sprint-plan, OKRs, pre-mortem
- **Triggers:** plan, PRD, sprint, OKRs, roadmap, user stories

### ⑱ GROWTH & CONVERSION — *Users → revenue.*
- **Conductor:** growth-hacker `[community]`
- **Section:** churn-prevention, paywalls, referrals, onboarding, pricing
- **Triggers:** conversion, churn, retention, paywall, ASO, activation
- **Used on:** `my-mobile-app`, `my-ios-app`

### ⑲ FINANCE — *Money decisions.*
- **Conductor:** investment-researcher `[community]`
- **Section:** financial-analyst, saas-metrics-coach
- **Triggers:** invest, valuation, DCF, earnings, burn/runway, SaaS metrics
- **Allowance:** NEVER execute trades or move money — analysis only.

### ⑳ EXECUTIVE ADVISORY — *Founder-grade strategic counsel.*
- **Conductor:** chief-of-staff `[community]`
- **Section:** ceo/cfo/cto-advisor, scenario-war-room, decision-logger, stress-test `[community]`
- **Triggers:** as CEO/CFO, founder advice, board deck, M&A, should I hire/raise/pivot
- **Allowance:** advisory only — never executes hiring/spending/legal actions.

### ㉑ AUDIT — *Verify everything. Default to NEEDS WORK.*
- **Conductor:** auditor `[custom]`
- **First Chair:** code-reviewer `[custom]`, evidence-collector `[community]`, verification-before-completion `[community]`
- **Triggers:** auto-fires after BUILD / AI/ML / AUTOMATION / FINANCE / any change to CI, install, hooks, secrets. Explicit: "audit this", "verify", "double-check".
- **Allowance:** READ + INSPECT only — writes only to an append-only audit log.
- **Quality Gate:** READY only with fresh, cited evidence (paths + lines, this session).

### ㉒ CYBERSECURITY — *Defend, detect, respond, and prove it.*
- **Conductor:** security-engineer `[community]`
- **Section:** secure-code-review, threat-modeling, detection-engineering, incident-response `[community]`
- **Triggers:** security review, pentest (authorized), vulnerability, CVE, threat model, incident, hardening
- **Allowance:** analysis/detection freely; ASK before any active exploit on a live system, prod secrets, or sending findings externally.
- **Handoff:** ← BUILD (AppSec), → AUDIT (test output)

### ⓪ RESERVE BENCH — installed, dormant, named-invoke only
Off-domain specialists (vertical industries, game/XR dev, niche engineering, output-mode
utilities) that stay installed and callable by name but never auto-fire.
