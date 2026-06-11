---
name: orchestra-router
description: >
  Runtime router for the orchestra system. Use at the start of EVERY task to detect intent and
  activate the right orchestra(s), then announce which fired. In v2 the routing hook pre-computes
  the route deterministically (registry triggers + optional qmd semantic search) and injects it
  as an <orchestra-routing> block — this skill defines how to act on that block, when to override
  it, and how to escalate reasoning (ultrathink/ultraplan/ultracode/ultrareview) and gates
  (/pressure-test) per orchestra.
---

# Orchestra Router — Route Every Task

Each prompt arrives with an `<orchestra-routing>` block injected by the hook: the pre-ranked
orchestras, conductors, players, reasoning keyword, and quality gates, scored deterministically
by the `orchestra` engine against `~/.claude/orchestra/registry.json`.

## Process

1. **Trust the pre-route, verify with judgment.** The injected route is computed from registry
   triggers (+ qmd semantic search when enabled). If it matches the user's actual intent, go
   with it. If it's clearly wrong (sarcasm, novel phrasing, topic shift), override it and route
   yourself from the full constitution (`~/.claude/rules/orchestra-system.md`) — and say why.
2. **Confidence rules.**
   - `high` → activate and proceed.
   - `medium` → activate, but sanity-check the stack against intent first.
   - `low` (<70%) → route by judgment; if the request is genuinely ambiguous, ask the user
     ONE clarifying question before locking the route.
3. **NEXUS overrides everything.** Idea / business-planning signals ("I have an idea",
   "should I build", "plan a business") fire the NEXUS meta-conductor, which sequences whole
   orchestras across the lifecycle instead of activating a single one.
4. **Stack when complementary.** Compound requests activate multiple orchestras in handoff
   order (e.g. PLANNING → DESIGN → BUILD). The first-ranked orchestra's conductor leads.
5. **Apply the reasoning escalation.** The route names a keyword — honor it:
   - `ultrathink` → strategy, research, finance, exec advisory: think deepest before answering.
   - `ultraplan` → produce/validate the plan before any execution.
   - `ultracode` → multi-agent build orchestration: parallelize independent work via subagents.
   - `ultrareview` → review mode: adversarial pass over the artifact before handoff.
6. **Run the gates before handoff.** Gates listed in the route are non-optional. High-stakes
   work (prod deploy, money, outbound sends, irreversible changes) additionally fires the
   AUDIT orchestra: `/pressure-test` the artifact, verdict SHIP / FIX-FIRST / STOP.
7. **Announce once, at the top**, then get to work:
   `🎼 <ORCHESTRA> active · Conductor: <agent> · Using: <the tools you actually use>`
   Keep it to one line for single-orchestra routes; show the stack for compound ones.
8. **Log what fired.** The PostToolUse telemetry hook records skill/agent usage automatically;
   if you used a tool outside those types in a load-bearing way, log it:
   `~/.claude/orchestra/bin/orchestra log <tool-name>`.

## Bench discipline

Reserve Bench tools (tier `bench`, or living in `~/.claude/orchestra/bench/`) **never auto-fire**.
Invoke them only when the user names them. A benched skill is still fully usable: read its
`SKILL.md` from the bench path and follow it.

## If the routing block is missing

The hook fell back (no engine/registry). Route manually: match intent against the trigger table
in the constitution, stack when complementary, announce, and proceed. Then recommend running
`orchestra doctor` to repair the setup.
