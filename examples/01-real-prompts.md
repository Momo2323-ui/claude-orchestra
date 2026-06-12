# Real prompts → real routing (5 worked examples)

This is what Claude Orchestra actually does in a session. Five real prompts, each with the
routing announcement you'd see at the top of Claude Code's reply and a short note on *why* the
router picked what it did.

> The orchestras and conductors below are from the example
> [`my-20-orchestras.md`](my-20-orchestras.md). Your config will name agents differently — the
> routing pattern is identical.

---

## 1) An idea → NEXUS (the meta-conductor)

**You type:**

```
I've been thinking about a video tool for short-form creators that auto-pulls captions
from any source and rewrites them in the user's voice. Is this a good idea?
```

**Top of the reply:**

```
🎼 NEXUS active (Phase 0 → Discovery) · Stacking RESEARCH + PRODUCT + KNOWLEDGE
   Sequencing: brainstorming skill → competitor scan → JTBD → value-prop draft
```

**Why this fired:** "thinking about", "is this a good idea" are direct NEXUS triggers — the
meta-conductor takes ideas and sequences whole orchestras across its 7-phase lifecycle. Phase 0
is Discovery: research what exists, who'd want this, what job it does.

**What you don't have to do:** ask for a brainstorm, pull a competitor scan, then write a PRD.
NEXUS sequences those moves for you and only escalates to BUILD when there's enough to build on.

---

## 2) A research question → RESEARCH with the internal ladder first

**You type:**

```
What's the current best practice for chunking documents for retrieval-augmented generation?
```

**Top of the reply:**

```
🎼 RESEARCH active · Conductor: research-agent
   🔍 Internal ladder: 0 hits across 3 rungs → going external
   Using: WebSearch, deep-research
```

**Why this fired:** "current best practice for" is a research signal. But before the router
runs `WebSearch`, the **Internal-First Search Ladder** (Standing Rule 14) checks your own
knowledge first — your notes, your existing learnings, prior session captures — and only
escalates externally on a clean miss. The ladder is announced so you know nothing was hiding
in your own brain that would have saved a web search.

**What you don't have to do:** explicitly tell the model "check my notes first." The rule does
it on every research-classified prompt.

---

## 3) "Build me X" → multi-orchestra stack

**You type:**

```
Build me a landing page for a pricing-experiment tool. Hero, 3 benefit blocks, pricing table,
FAQ. Tailwind + Next.js.
```

**Top of the reply:**

```
🎼 PLANNING → DESIGN → BUILD stack
   Conductors: planner → ux-architect → architect
   Using: make-plan, figma, ui-designer, frontend-design, code-reviewer
```

**Why this fired:** "build me a landing page" doesn't map to a single orchestra — it's a
compound request. The router stacks three: PLANNING first (so we have a shape before pixels),
DESIGN second (so the layout decisions exist before code), BUILD last (so implementation
follows from approved design). Each conductor sequences its own players.

**What you don't have to do:** ask for a plan, then ask for a design, then ask for code. One
prompt, three orchestras, one announcement that tells you the order.

---

## 4) "Verify this" → AUDIT (defaults to NEEDS WORK)

**You type:**

```
I shipped the new auth middleware. Is it actually working?
```

**Top of the reply:**

```
🎼 ㉑ AUDIT active · Conductor: auditor
   Using: code-reviewer, evidence-collector, verification-before-completion
   Default verdict: NEEDS WORK — flips to READY only with fresh evidence
```

**Why this fired:** "is it actually working" is a verification phrase. AUDIT is designed to be
the last gate before any high-stakes claim reaches you. It defaults to NEEDS WORK and requires
fresh `Read` / `Grep` / `test` output (with file paths and line numbers cited) before flipping
to READY. Memory and pattern-matching don't count.

**What you don't have to do:** trust a "looks good" reply. AUDIT either shows you the evidence
or sends the work back to the source orchestra with a specific fix list (max 3 attempts before
it escalates to you).

---

## 5) "I just installed X" → INTAKE (files into the right orchestra, never archived)

**You type:**

```
I just installed this Blender add-on developer skill: https://github.com/example/blender-addon-skill
```

**Top of the reply:**

```
🎼 orchestra-intake skill running
   Step 1: 5-step security scan on the source (source legitimacy, code scan, perms, sandbox check)
   Step 2: classify — game/XR dev specialist, no current orchestra covers
   Step 3: option — promote to the Reserve Bench OR create a new XR/GAME-DEV orchestra
   (ASK_HUMAN before creating a new orchestra)
```

**Why this fired:** "I installed X" is a direct intake trigger. The intake skill scans, then
classifies, then files into the right orchestra — and **never** archives. Off-domain tools go
to the Reserve Bench (installed, named-invoke only). If a cluster of new tools forms a
coherent area no existing orchestra covers, intake proposes a new orchestra (you approve before
the constitution changes).

**What you don't have to do:** remember whether you installed something six months ago, or
hand-edit `orchestra-system.md` to add a new section. Intake does it, with an audit trail in
`docs/learnings/orchestra-assignments.md`.

---

## The pattern across all 5

| Prompt type | Orchestra(s) | Key behavior |
|---|---|---|
| "I have an idea…" | NEXUS | Sequences whole orchestras across 7 phases |
| "What's the latest…?" | RESEARCH | Checks internal ladder *before* external search |
| "Build me X" | PLANNING + DESIGN + BUILD | Stacks; one conductor per orchestra |
| "Is X actually working?" | ㉑ AUDIT | Defaults to NEEDS WORK; demands fresh evidence |
| "I installed X" | orchestra-intake | Scans → classifies → files (never archives) |

**The common thread:** every prompt gets routed, every routing is announced, every orchestra
has one conductor that sequences its players, and the gates (Rule 14 internal-first, AUDIT
evidence requirement, intake security scan) are non-negotiable.

If your prompt doesn't fire any of these patterns, the router won't lie and announce something
fake — it'll just answer the question directly. The orchestra is for tasks; chitchat passes
through.

---

## See also

- [`my-20-orchestras.md`](my-20-orchestras.md) — the worked-example config that produced these
  conductor names
- [`../docs/HOW-IT-WORKS.md`](../docs/HOW-IT-WORKS.md) — the four moving parts behind the
  routing
- [`../docs/CREATE-YOUR-ORCHESTRA.md`](../docs/CREATE-YOUR-ORCHESTRA.md) — make this config
  yours in ~10 min
