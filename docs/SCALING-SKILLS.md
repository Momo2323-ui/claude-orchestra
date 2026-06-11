# Scaling past the "your skills are too much" warning

If Claude Code told you your skills exceed its budget, you've hit the real ceiling: skill
*discovery* has a character budget. Past it, descriptions get truncated or dropped from context —
so the model literally cannot see some of your skills when choosing. More installs ≠ more power
after this line; it's silent degradation.

Claude Orchestra v2 turns that ceiling into a managed resource.

## The model: hot / warm / cold

| Tier | Where it lives | Costs budget? | How it fires |
|---|---|---|---|
| **Hot** (conductors, first-chairs) | `~/.claude/skills/` | Yes | Native autoload — always visible to the model |
| **Warm** (section players) | `~/.claude/skills/` while budget allows | Yes | Routed by the hook's pre-ranked players list |
| **Cold** (bench) | `~/.claude/orchestra/bench/` | **No** | Indexed + named-invoke only; model reads its `SKILL.md` by path and follows it |

A benched skill loses nothing but its autoload slot. It stays in the inventory, stays searchable
(qmd indexes the bench collection too), and works the moment you name it — the router skill knows
to read bench skills straight from their path.

## The workflow

```bash
orchestra doctor          # 1. measures your autoload chars vs budget (default 15000, set in registry.json)
orchestra board           # 2. ranks every tool S/A/B/C from tier + real usage telemetry
orchestra bench <skill>   # 3. bench the C-class cold skills until doctor is green
orchestra promote <skill> #    changed your mind / pivoted? bring it back
orchestra index           # 4. refresh the inventory + qmd collections
```

Repeat at upkeep time (weekly cron or `/loop`): usage telemetry keeps re-ranking, so the right
skills earn their autoload slots over time. Demotion is data-driven, not guesswork.

## Why this beats "just delete skills"

- **Nothing is archived — it's filed.** Core doctrine. A pivot or named invoke brings any bench
  tool back instantly.
- **Selection stays automatic.** The routing hook injects the matched orchestra's players per
  prompt, so even warm/cold tools get surfaced exactly when relevant — that's retrieval doing
  the job the truncated autoload list couldn't.
- **qmd makes the long tail findable.** With hundreds of tools, trigger phrases can't cover every
  paraphrase. `qmd` (BM25 + vector + LLM rerank, fully local) searches your skill descriptions
  semantically:

```bash
bun install -g @tobilu/qmd   # or: npm install -g @tobilu/qmd
orchestra index              # registers the skills + bench collections, embeds
orchestra qmd on             # let the routing hook use semantic search (adds ~1-2s/prompt)
```

`orchestra route` always uses qmd when present; the **hook** path keeps it opt-in so your prompt
latency is a choice, not a surprise.

## Rules of thumb

- Keep ≤ ~40 hot+warm skills; bench by class, not by sentiment.
- Conductors and first-chairs are never benched — restructure the orchestra instead.
- Every intake (new install) ends with `orchestra doctor`; never let the budget drift red.
- Trigger collisions (`doctor` reports them) are routing bugs — fix the registry same-day.
