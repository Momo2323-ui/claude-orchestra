# How it works

Claude Orchestra v2 has six moving parts. Together they turn a pile of installed tools into a
coordinated, self-ranking system.

## 1. The constitution — `~/.claude/rules/orchestra-system.md`

The human-readable source of truth. It defines each orchestra using ten fields (mission,
conductor, first chair, section, triggers, process, allowances, harness, handoff, quality gate),
plus the Reasoning Escalation doctrine (ultra keywords + `/pressure-test` gates) and the ㉑ AUDIT
orchestra. Loaded into context every session.

## 2. The registry — `~/.claude/orchestra/registry.json`

The machine-readable twin: orchestras, trigger phrases, rosters with tiers
(conductor / first-chair / section / bench), per-orchestra reasoning keywords, quality gates,
and the skill character budget. Everything the engine does — routing, ranking, doctoring —
reads from here. Change a roster? Change both files, then `orchestra index`.

## 3. The score engine — `~/.claude/orchestra/bin/orchestra`

A single Bash CLI (jq is the only hard dependency):

| Command | What it does |
|---|---|
| `index` | Scans skills, bench, agents, commands, MCP configs, plugins + registry → `inventory.tsv`; refreshes qmd collections when qmd is installed |
| `route "<prompt>"` | Hybrid scoring: word-boundary trigger matching + optional qmd (BM25+vector+rerank) boost → emits the routing directive |
| `board` | Generates the ranking board: tier weight + usage frequency + recency → S/A/B/C classes |
| `doctor` | Health checks: skill char budget, trigger collisions, unfiled tools, stale index, hook registration |
| `bench` / `promote` | Move skills out of / back into the autoload path (the "too many skills" fix) |
| `log` | Append a usage event manually |
| `qmd on\|off` | Toggle semantic search in the hook path (latency is opt-in) |
| `upkeep` / `cron` | index + doctor + board; print the crontab line |

## 4. The routing hook — `~/.claude/hooks/orchestra-route.sh`

A `UserPromptSubmit` hook. Claude Code passes the prompt as JSON on stdin; the hook extracts it,
runs `orchestra route --hook`, and injects a directive containing **only the matched slice**:

```
<orchestra-routing>
🎼 Route: DESIGN(7) + BUILD(2) · confidence: high
Conductor(s): ux-architect → architect
Players (pre-ranked, pick what the task needs): Figma, Canva, ui-designer, code-reviewer, …
Reasoning escalation: include 'ultracode + ultrathink' framing for this turn.
Quality gates before handoff: handoff spec complete for BUILD; ultrareview pass on the diff
Announce once at the top: 🎼 DESIGN active · Conductor: ux-architect · Using: <…>
</orchestra-routing>
```

NEXUS signals override everything; low-confidence routes tell the model to ask instead of guess;
and if jq, the engine, or the registry are missing, the hook falls back to the v1 static
directive — a prompt is never broken by the orchestra layer.

## 5. The telemetry hook — `~/.claude/hooks/orchestra-telemetry.sh`

A `PostToolUse` hook (matcher `Skill|Task|Agent`) that appends one JSONL line per skill/agent
invocation to `~/.claude/orchestra/usage.jsonl`. Local-only, no network. This is what lets the
ranking board reflect what you *actually use* instead of what you once installed.

## 6. The two skills

- **orchestra-router** — defines how the model acts on the injected route: trust-but-verify,
  confidence rules, NEXUS override, reasoning escalation, gates, bench discipline, announcing.
- **orchestra-intake** — the self-organizing layer: security-scan → classify → file into
  constitution + registry → `orchestra index` → budget check → log. Nothing is ever archived
  on install — it's filed.

## The flow

```
prompt → hook reads it → orchestra route scores it (registry + qmd)
       → directive injected (orchestras · conductors · players · gates · reasoning)
       → model announces + conductor sequences players → work happens
       → telemetry logs what fired → weekly upkeep re-ranks the board
```

## Why a "conductor" per orchestra?

Activating five skills at once is noise. A conductor is one lead agent that *sequences* the
orchestra's players — plan before build, research before write, design before implement. It's the
difference between an orchestra and everyone playing at once.
