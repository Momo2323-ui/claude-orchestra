---
name: skill-selector
description: Use when an orchestra has multiple skills, MCPs, or connectors that could plausibly handle the same task (e.g. frontend has frontend-design + ui-ux-pro-max + remotion + Figma + 21st.dev). Scores each candidate against the user's vision, prior preferences, and task complexity, picks the winner, EXPLAINS the choice when non-obvious, and asks the human to disambiguate when confidence is below 70%. Logs every pick to learnings for pattern improvement over time.
license: MIT
version: 1.0.0
---

# Skill Selector — Picking Between Similar Skills Within an Orchestra

> *"In an orchestra there could be so many skills and they might be doing same job but in
> different ways. So you need to make sure you check all and try them all if the task is
> complex, even you can ask the human."* — Moksh
>
> This skill operationalizes that into a transparent scoring + announcement + learning loop.

## The problem this solves

Most orchestras have **multiple candidates** for the same task:

| Orchestra | Example overlap |
|---|---|
| DESIGN | frontend-design · ui-ux-pro-max · modern-web-design · web-design-engineer · taste-design · 21st.dev (`magic`) |
| RESEARCH | search-agent · deep-research · market-research · firecrawl · brightdata-plugin · nimble |
| LEAD GEN | Apollo · Apify · brightdata · search-agent · sales-outreach |
| BUILD | code-reviewer · pr-review-toolkit · superpowers:requesting-code-review |
| CONTENT | content-creator · copywriting · marketing-content-creator · book-co-author |

Picking randomly = inconsistent quality. Picking by recency = staleness. Picking by name = bias.

**This skill picks deterministically, explains why, and asks when uncertain.**

---

## When to invoke

- **Automatically:** when more than ONE skill in the active orchestra's roster matches the task signal
- **Manually:** when the user says "pick the right skill for X" or "which design skill should I use"
- **Inside `orchestra-router`:** as a sub-step after orchestra activation, before player invocation

**Skip when:** only one skill in the orchestra matches the task (no choice to make), or the user has explicitly named a specific skill ("use ui-ux-pro-max").

---

## The scoring algorithm

For each candidate skill in the target orchestra, compute a score 0–1:

```
score = (
    relevance_to_task        * 0.35   # how well the skill description matches the task
  + user_vision_alignment    * 0.25   # match against stated vision (e.g. "premium" → max-pro)
  + prior_preference_weight  * 0.20   # pulled from ~/.claude/projects/<x>/memory/feedback
  + complexity_fit           * 0.15   # task complexity vs skill's complexity-fit field
  + skill_freshness          * 0.05   # slight novelty boost for less-used skills
)
```

### Computing each component

**relevance_to_task** (0–1)
- Read user prompt + extract keywords
- Read candidate's `description` frontmatter
- Score based on overlap + semantic fit (use judgment, not just literal word match)

**user_vision_alignment** (0–1)
- Pull stated vision from user prompt (e.g. "ultra-polished", "rapid prototype", "long-form analytical")
- Score how the candidate aligns
- Examples:
  - "premium coffee shop" → ui-ux-pro-max scores 0.9, rapid-prototyper scores 0.3
  - "throwaway POC" → rapid-prototyper scores 0.9, ui-ux-pro-max scores 0.4

**prior_preference_weight** (0–1)
- Check `~/.claude/projects/<current-project>/memory/` for feedback entries mentioning this skill
- Positive feedback → boost (e.g. 0.8); negative → penalty (e.g. 0.2)
- Default: 0.5 (neutral)

**complexity_fit** (0–1)
- Task complexity signals: number of files affected, integration concerns, design judgment needed
- Compare to candidate's `complexity-fit` frontmatter field (`simple` | `moderate` | `complex`)
- Mismatch = 0.3; exact match = 1.0

**skill_freshness** (0–1)
- How recently was this skill used? (check selection log below)
- Less recently used → slight boost (encourages trying alternatives, avoids monoculture)
- Cap at 0.3 weight increment — never let novelty override genuine fit

---

## The decision tree

```
1. List candidates from the target orchestra's First Chair + Section
2. Score each candidate
3. Sort descending
4. Compute (top - second) gap
5. Decide:

   IF top_score >= 0.85 AND second_score <= 0.5:
       → SILENT PICK — pick top, no announcement (clear winner, obvious choice)

   ELIF top_score >= 0.7 AND (top - second) >= 0.15:
       → ANNOUNCED PICK — pick top, announce choice + reason

   ELIF top_score >= 0.7 AND (top - second) < 0.15:
       → ASK_HUMAN — two strong options too close to call

   ELSE (top_score < 0.7):
       → ASK_HUMAN — low confidence about any skill fitting; clarify task with user
```

### Threshold tuning

The 70% / 85% / 15-point gap thresholds are tunable per orchestra in `orchestra-system.md`:

```markdown
### ② DESIGN
skill-selector:
  silent-pick-threshold: 0.85
  announce-pick-threshold: 0.7
  ask-human-gap-threshold: 0.15
```

Defaults work for most cases. Tune per Moksh's preference over time.

---

## Announcement formats

### Silent pick (clear winner)

```
🎼 BUILD active · Conductor: architect · Using: code-reviewer
```

No skill-selector noise. The skill name appears in the `Using:` field. User sees the pick implicitly.

### Announced pick (non-obvious choice)

```
🎼 DESIGN active · Conductor: design-ux-architect
   Selected: ui-ux-pro-max
   ↳ over: frontend-design, modern-web-design
   ↳ reason: user said "premium coffee shop" → aesthetic-heavy fit; prior preference for max-pro stack
```

Keep reason to **one sentence**. Avoid long justifications — the choice should feel obvious once explained.

### ASK_HUMAN (close call or low confidence)

```
🎼 DESIGN active · Conductor: design-ux-architect

🤚 ASK_HUMAN: Two strong design options for this task:
   1. ui-ux-pro-max — best for maximum polish, premium feel, opinionated aesthetics
   2. frontend-design — best for fast iteration, modern minimal aesthetics
   
   Which fits your vision better? (Say "your call" and I'll pick top.)
```

If user says "your call" → pick top + log a normal "Announced pick" with reason "user deferred."

---

## The selection log

Every pick gets logged to `~/.claude/docs/learnings/skill-selections.md`:

```markdown
## 2026-05-25 17:32 — DESIGN
- **Task:** "make me a coffee shop website"
- **Candidates:** [ui-ux-pro-max, frontend-design, modern-web-design]
- **Scores:** [0.87, 0.71, 0.65]
- **Gap (top-second):** 0.16
- **Decision:** ANNOUNCED PICK — ui-ux-pro-max
- **Reason:** premium-coffee-shop keyword cluster + prior preference for max-pro
- **Outcome:** TBD (update on user feedback)
- **User feedback:** _populate when known_

## 2026-05-25 19:14 — RESEARCH
- **Task:** "find the latest on multi-agent frameworks"
- **Candidates:** [search-agent, deep-research, firecrawl, brightdata-plugin]
- **Scores:** [0.78, 0.76, 0.45, 0.40]
- **Gap:** 0.02 ← TOO CLOSE
- **Decision:** ASK_HUMAN
- **User answer:** "search-agent"
- **Outcome:** Pending verification
```

Over time, this becomes a dataset for:
- Tuning scoring weights per orchestra
- Learning Moksh's actual preferences (vs declared ones)
- Identifying skills that consistently win/lose (signal for promotion/demotion)
- Identifying redundant skills (always lose, never picked — candidate for archival)

---

## Applies to skills AND MCPs/connectors

Same algorithm. Just point at the right candidate set:

**For MCPs/connectors** (e.g. Apollo vs Apify vs Nimble vs brightdata-plugin for lead research):

```yaml
# In each MCP/connector's metadata
best-for: ["B2B-leads", "company-enrichment"]
complexity-fit: moderate
cost-profile: "expensive"   # cheap | standard | expensive
auth-required: true
preferred-when: ["small-batch", "company-name-known"]
```

Selection adds two more signals:
- **cost_alignment** — match task budget signals ("just a quick test" → cheap MCP wins)
- **auth_readiness** — penalize if required auth tokens aren't configured

---

## Examples

### Example 1: Silent pick (clear winner)

```
User: "fix the typo in line 42 of auth.ts"

Orchestra: BUILD
Candidates: [code-reviewer (0.45), pr-review-toolkit (0.52), focused-fix (0.91)]
Decision: SILENT PICK — focused-fix

Announcement: 🎼 BUILD active · Conductor: architect · Using: focused-fix
```

### Example 2: Announced pick (interesting choice)

```
User: "design a hero section for a yoga studio landing page"

Orchestra: DESIGN
Candidates:
  - ui-ux-pro-max (0.88)         premium, aesthetic-heavy
  - modern-web-design (0.74)     contemporary minimal
  - taste-design (0.71)          curated aesthetic
  - frontend-design (0.69)       fast iteration

Top score 0.88, second 0.74, gap 0.14 (just under 0.15) → ANNOUNCED PICK

Announcement:
🎼 DESIGN active · Conductor: design-ux-architect
   Selected: ui-ux-pro-max  
   ↳ over: modern-web-design, taste-design, frontend-design
   ↳ reason: yoga studio = sensory/aesthetic-heavy → max-pro's polish fits
```

### Example 3: ASK_HUMAN (genuine ambiguity)

```
User: "find out who's the best contact at Acme Corp for AI procurement"

Orchestra: LEAD GEN & SALES
Candidates:
  - Apollo (0.79)              org enrichment, contact info
  - nimble:company-deep-dive (0.77)   deep company intelligence
  - apollo_contacts_search (0.72)     contact-level search

Top 0.79, second 0.77, gap 0.02 → ASK_HUMAN

🤚 ASK_HUMAN: Two strong options for finding contacts at Acme Corp:
   1. Apollo (org enrichment + contact search) — best when you have a name list
   2. nimble:company-deep-dive — best for deep context on the org first, contacts second
   
   Do you already have specific contact names to enrich, or do you need the org intel first?
   (Say "your call" and I'll start with Apollo.)
```

### Example 4: Low confidence (any candidate is a poor fit)

```
User: "i want to do the thing with the stuff"

Orchestra: ??? (ambiguous)
Top candidate scores all below 0.5 → ASK_HUMAN

🤚 ASK_HUMAN: I'm not confident any skill fits this task well — could you tell me more?
   - What are you trying to build or learn?
   - Is this code, content, research, or something else?
```

---

## Common pitfalls

| Pitfall | Why bad | Better |
|---|---|---|
| Pick on alphabetical order | No signal, arbitrary | Score on relevance |
| Pick always-the-same skill | Monoculture, misses better fits | Use freshness boost |
| Announce every pick | Noisy, drowns out real work | Silent for clear wins, announce only non-obvious |
| ASK_HUMAN for everything | Annoying, defeats automation | Only when confidence < 70% or gap < 15pts |
| Skip the log entry | Loses learning data | Always log, even silent picks |
| Score on skill name length / "fanciness" | Bias toward complex skills for simple tasks | Use `complexity-fit` field |
| Ignore prior preferences | Repeats user's known mistakes | Pull from auto-memory feedback |

---

## Integration with orchestra-router

Once orchestra-router v2 ships, this skill is invoked automatically as a sub-step:

```
orchestra-router v2:
  1. Match intent → orchestra(s) activated
  2. For each orchestra:
     → invoke skill-selector to pick player(s)
     → if ASK_HUMAN returned, pause + ask user
     → if pick returned, continue
  3. Run hallucination-guard ENTRY gate
  4. Execute chain with selected players
  5. ...
```

Until v2 ships, invoke manually:

```
Skill(skill-selector) when an orchestra has 2+ candidates for the same task.
```

---

## Out of scope (don't do these)

- **Selecting BETWEEN orchestras.** That's orchestra-router's job (intent matching). skill-selector picks WITHIN one orchestra.
- **Modifying skill files.** This skill picks; it doesn't edit candidates.
- **Auto-installing missing skills.** That's orchestra-intake's job.

---

## Credits

- **Scoring algorithm structure** — original to orchestra v2 design
- **ASK_HUMAN status** — borrowed from `hallucination-guard` skill (same family)
- **Decision-tree thresholds** — Moksh's Q4 default (70% confidence) and Q3 default (announce non-obvious only)
- **CrewAI's role-overlap insight** — validation that explicit scoring beats implicit LLM-routing

MIT licensed. Improve and PR back to `claude-orchestra`.
