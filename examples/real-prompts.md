# Real prompts → real routing

Five everyday prompts, run through the actual `orchestra route` engine against the
[worked-example registry](registry-filled.json). This block is injected into Claude's
context **before it starts answering** — so it begins the task already knowing the team.

### 1 · A clear build task

**You type:** `fix the login bug and add tests then deploy`

**What gets injected for Claude (real engine output):**

```
<orchestra-routing>
🎼 Route: BUILD(6) · confidence: high
Conductor(s): architect
Players (pre-ranked, pick what the task needs): architect, code-reviewer, debugger, github, security-review, tdd-guide
Reasoning escalation: include 'ultracode' framing for this turn.
Quality gates before handoff: /pressure-test before prod deploy (high-stakes); builds clean + tested; ultrareview pass on the diff
Announce once at the top: 🎼 BUILD active · Conductor: architect · Using: <the players you actually use>
Reserve Bench tools never auto-fire (explicit name only). Full doctrine: ~/.claude/rules/orchestra-system.md
</orchestra-routing>
```

### 2 · A compound task — two orchestras stack

**You type:** `design a landing page and implement it`

**What gets injected for Claude (real engine output):**

```
<orchestra-routing>
🎼 Route: DESIGN(5) + BUILD(2) · confidence: medium
Conductor(s): ux-architect → architect
Players (pre-ranked, pick what the task needs): Canva, Figma, architect, brand-guardian, canvas-design, code-reviewer, debugger, github, security-review, tdd-guide, ui-designer, ux-architect
Reasoning escalation: include 'ultracode + ultrathink' framing for this turn.
Quality gates before handoff: /pressure-test before prod deploy (high-stakes); builds clean + tested; handoff spec complete for BUILD; ultrareview pass on the diff
Announce once at the top: 🎼 DESIGN active · Conductor: ux-architect · Using: <the players you actually use>
Reserve Bench tools never auto-fire (explicit name only). Full doctrine: ~/.claude/rules/orchestra-system.md
</orchestra-routing>
```

### 3 · An idea — NEXUS takes over everything

**You type:** `I have an idea for a fitness app, should I build it?`

**What gets injected for Claude (real engine output):**

```
<orchestra-routing>
🎼 Route: NEXUS(109) + BUILD(2) · confidence: high
Conductor(s): nexus → architect
Players (pre-ranked, pick what the task needs): architect, code-reviewer, debugger, github, nexus, pressure-test, security-review, tdd-guide
Reasoning escalation: include 'ultracode + ultrathink + ultraplan' framing for this turn.
Quality gates before handoff: /pressure-test before prod deploy (high-stakes); builds clean + tested; pressure-test the plan before Phase 2 (Foundation); ultrareview pass on the diff
Announce once at the top: 🎼 NEXUS active · Conductor: nexus · Using: <the players you actually use>
Reserve Bench tools never auto-fire (explicit name only). Full doctrine: ~/.claude/rules/orchestra-system.md
</orchestra-routing>
```

### 4 · Sales + content — note the ask-before-send gate

**You type:** `write a cold email sequence for prospects and find leads`

**What gets injected for Claude (real engine output):**

```
<orchestra-routing>
🎼 Route: SALES(6) + CONTENT(3) · confidence: high
Conductor(s): outbound-strategist → content-creator
Players (pre-ranked, pick what the task needs): Apollo_io, Gmail, HubSpot, content-creator, content-humanizer, copywriting, customer-success, hook-generator, outbound-strategist
Reasoning escalation: include 'ultrathink' framing for this turn.
Quality gates before handoff: ASK before sending any outreach; humanize pass before publishing
Announce once at the top: 🎼 SALES active · Conductor: outbound-strategist · Using: <the players you actually use>
Reserve Bench tools never auto-fire (explicit name only). Full doctrine: ~/.claude/rules/orchestra-system.md
</orchestra-routing>
```

### 5 · High-stakes — the AUDIT orchestra fires

**You type:** `pressure test my launch plan before I send it to investors`

**What gets injected for Claude (real engine output):**

```
<orchestra-routing>
🎼 Route: AUDIT(7) + PLANNING(2) · confidence: high
Conductor(s): red-team-lead → planner
Players (pre-ranked, pick what the task needs): Linear, code-review, make-plan, orchestra-router, planner, pre-mortem, pressure-test, red-team-lead, security-review
Reasoning escalation: include 'ultraplan + ultrareview + ultrathink' framing for this turn.
Quality gates before handoff: loop until clean or 3 iterations (opt-in Ralph loop); plan pressure-tested before execution starts; verdict: SHIP / FIX-FIRST / STOP with reasons
Announce once at the top: 🎼 AUDIT active · Conductor: red-team-lead · Using: <the players you actually use>
Reserve Bench tools never auto-fire (explicit name only). Full doctrine: ~/.claude/rules/orchestra-system.md
</orchestra-routing>
```

## What if nothing matches?

Low-confidence routes tell Claude to use judgment — and to ask you ONE clarifying question
if the request is genuinely ambiguous, instead of guessing. With `qmd` installed, paraphrases
("my checkout flow feels clunky") still find the right team via semantic search.
