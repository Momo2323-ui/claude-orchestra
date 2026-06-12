<div align="center">

<img src="assets/banner.svg" alt="Claude Orchestra" width="100%">

# 🎼 Claude Orchestra

**An operating system for your Claude Code skills, agents & MCPs.**

![license](https://img.shields.io/badge/license-MIT-green)
![claude code](https://img.shields.io/badge/Claude_Code-ready-f5b301)
![shellcheck](https://github.com/Momo2323-ui/claude-orchestra/actions/workflows/shellcheck.yml/badge.svg)
![PRs](https://img.shields.io/badge/PRs-welcome-blue)

</div>

---

I went from zero coding to 500+ Claude Code skills, agents, and MCP servers installed in a
few months. At some point I had no idea what was active, what would fire for a given task,
or whether I'd installed the same thing three times. More tools had made me *slower*.
**Claude Orchestra is what I built to fix that.**

> **Built to be forked.** This isn't a one-click install you forget about — it's a template
> you fork, customize with *your* rosters, and run on your own machine.

## The problem

```
WITHOUT Claude Orchestra:

  ~/.claude/ → 247 skills · 40 agents · 12 MCPs · 8 plugins
  → "Which one handles this task?"            🤷
  → "Did I install something for this already?" 🤷
  → "Why did THAT skill just fire?"            🤷

WITH Claude Orchestra:

  🎼 BUILD active · Conductor: architect · Using: code-reviewer, debugger, gh
  [the actual response continues here]
```

Every prompt announces exactly what's playing. No more guessing.

## The fix: 22 orchestras

Claude Orchestra files every tool into themed **orchestras**. Each has **one conductor** that
sequences its players, clear **triggers**, and quality **gates**. A routing hook reads every
request and activates the right orchestra(s) automatically — and announces it.

<img src="assets/demo.gif" alt="Claude Orchestra demo: install + first prompt → orchestra announcement" width="100%">

Compound requests stack:

```
🎼 DESIGN + BUILD active · Conductors: design-ux-architect → architect
   Using: figma, frontend-design, code-reviewer
```

Idea / business-planning prompts fire **NEXUS**, the meta-conductor that sequences whole
orchestras across a 7-phase lifecycle:

```
🎼 NEXUS active (Phase 0 → 1) · Stacking RESEARCH + PRODUCT + KNOWLEDGE
```

---

## The 22 orchestras

| # | Orchestra | What it does |
|---|---|---|
| 🌐 | **NEXUS** *(meta-conductor)* | Turns "I have an idea" into a sequenced multi-orchestra plan |
| ① | **BUILD** | Ship working, reviewed code |
| ② | **DESIGN** | Beautiful, on-brand interfaces |
| ③ | **RESEARCH** | Know more than the competition |
| ④ | **MARKETING** | Reach the right people |
| ⑤ | **CONTENT** | Words and creative that convert |
| ⑥ | **SEO + GEO** | Win search and AI answers |
| ⑦ | **LEAD GEN & SALES** | Find clients, close deals |
| ⑧ | **PRODUCT** | Build the right thing |
| ⑨ | **VIDEO + MEDIA** | Generate and edit video/image |
| ⑩ | **ANALYTICS** | Measure everything |
| ⑪ | **KNOWLEDGE & MEMORY** | Remember and connect everything |
| ⑫ | **DOCUMENTS & REPORTS** | Polished deliverables |
| ⑬ | **PAID ADS** | Ads that profit |
| ⑭ | **AUTOMATION & OPS** | Automate what repeats |
| ⑮ | **AI/ML DEVELOPMENT** | Build AI systems |
| ⑯ | **iOS / SWIFT** | Ship iOS apps |
| ⑰ | **PLANNING & PM** | Plan before building |
| ⑱ | **GROWTH & CONVERSION** | Users → revenue |
| ⑲ | **PERSONAL FINANCE** | Investment research and financial modelling |
| ⑳ | **EXECUTIVE ADVISORY** | Founder-grade strategic counsel |
| ㉑ | **AUDIT** | Verify everything. Defaults to NEEDS WORK. |
| ㉒ | **CYBERSECURITY** | Defend, detect, respond, and prove it |

The example config (`examples/my-20-orchestras.md`) shows a real filled-in setup — rosters, conductors,
and the reasoning behind each placement. Every skill links to its original author. Use it as a
starting point; add the two newer orchestras (AUDIT + CYBERSECURITY) if your stack needs them.

---

## What's inside v3

Six doctrine upgrades shipped in v3 (all in `orchestra-system.md`):

- **22 orchestras** — ㉑ AUDIT (quality gate, defaults NEEDS WORK) and ㉒ CYBERSECURITY (754 security skills) added
- **Rule 14 — Internal-First Search Ladder** — before going to the web, the system checks your knowledge base → archive → score store → only then searches externally. Saves tokens, finds prior work first.
- **v2.2 Harmony — 3-Layer Ensemble** — each orchestra activates the best *combination* of skills (≥0.70 Active Ensemble + 0.55–0.69 Standby Bench + named-only Reserve Bench), not just the single top match. No installed tool left behind.
- **Calibration Loop** — any failure logs to `audit-log.md` and gets a named anchor in the doctrine, so the same mistake can't happen twice.
- **Skill retrieval layer** — a local semantic index (1,718+ skill stubs, zero API cost, GPU-accelerated on Apple Silicon) lets the router score every installed skill against every prompt in ~2 seconds. The model never has to guess what's installed.
- **NEXUS phase map** — idea/business-planning prompts now sequence orchestras across a full 7-phase lifecycle (Discovery → Strategy → Foundation → Build → Hardening → Launch → Operate), not just activate one team.

### How NEXUS sequences orchestras

| Phase | Orchestras |
|---|---|
| 0 — Discovery | RESEARCH · PRODUCT · KNOWLEDGE |
| 1 — Strategy | PRODUCT · PLANNING · MARKETING |
| 2 — Foundation | PLANNING · DESIGN |
| 3 — Build | BUILD · DESIGN · AI/ML · iOS |
| 4 — Hardening | BUILD (QA) · AUTOMATION · CYBERSECURITY · **AUDIT** *(verdict required before Phase 5)* |
| 5 — Launch | MARKETING · CONTENT · SEO · PAID ADS · GROWTH |
| 6 — Operate | ANALYTICS · GROWTH · AUTOMATION · DOCUMENTS |

### Cross-cutting: Superpowers

Some skills apply across ALL orchestras regardless of which fired. These run on discipline, not routing:

| Skill | When it fires |
|---|---|
| `brainstorming` | Before any creative or feature work |
| `writing-plans` | Multi-step spec before touching code |
| `verification-before-completion` | Before any "done" claim — Iron Law |
| `systematic-debugging` | Any non-trivially reproducible bug |
| `test-driven-development` | Any new feature |

---

## Requirements

| Need | Why | Install |
|---|---|---|
| **Claude Code** | The host this routes inside | https://claude.com/claude-code |
| **Bash 4+** | Install script is Bash | macOS / Linux preinstalled |
| **`jq`** | Safely merges `settings.json` (no clobbering) | `brew install jq` · `apt-get install jq` |

That's it. No Python, no npm, no Docker.

---

## Install — the audit-first path (recommended)

```bash
# 1. Clone
git clone https://github.com/Momo2323-ui/claude-orchestra
cd claude-orchestra

# 2. Audit — read every line you're about to run (~80 lines)
cat install.sh

# 3. Install — idempotent, backs up settings.json before any change
./install.sh

# 4. Verify what changed
diff "$(ls -t ~/.claude/settings.json.bak.* | head -1)" ~/.claude/settings.json
ls -la ~/.claude/skills/orchestra-router ~/.claude/skills/orchestra-intake

# 5. Customize — edit your roster
$EDITOR ~/.claude/rules/orchestra-system.md
```

Open a new Claude Code session — the router fires on your next prompt.

## Install — the fast path

If you already trust the repo:

```bash
curl -fsSL https://raw.githubusercontent.com/Momo2323-ui/claude-orchestra/main/install.sh | bash
```

Or let Claude Code drive it:

```
Install this for me: https://github.com/Momo2323-ui/claude-orchestra
```

**Want to reverse the install?** See [UNINSTALL.md](UNINSTALL.md).

---

## What the installer actually does

| Target | Action |
|---|---|
| `~/.claude/skills/orchestra-router/` | Created (or refreshed if it exists) |
| `~/.claude/skills/orchestra-intake/` | Created (or refreshed if it exists) |
| `~/.claude/hooks/orchestra-route.sh` | Copied + `chmod +x` |
| `~/.claude/rules/orchestra-system.md` | Copied **only if not already present** — yours wins |
| `~/.claude/settings.json` | One entry appended to `hooks.UserPromptSubmit` (auto-backup first) |
| `~/.claude/CLAUDE.md` | Orchestra rule appended **only if marker text not present** |

Nothing else. No network calls, no `sudo`, no telemetry. Full breakdown in [**SECURITY.md**](SECURITY.md).

---

## How it works

<img src="assets/diagram.svg" alt="How Claude Orchestra routes a request: prompt → hook → router → orchestras → announcement" width="100%">

1. **The constitution** (`orchestra-system.md`) defines your orchestras — rosters, conductors, triggers, gates.
2. **The routing hook** injects a routing directive on every prompt.
3. **The router skill** matches your request to the right orchestra(s) and announces them.
4. **The intake skill** files anything new you install into the right orchestra — never archived.

→ Full walkthrough in [`docs/HOW-IT-WORKS.md`](docs/HOW-IT-WORKS.md).

## Build your own orchestras

[`docs/CREATE-YOUR-ORCHESTRA.md`](docs/CREATE-YOUR-ORCHESTRA.md) walks you through mapping
*your* tools into orchestras in about ten minutes.

## See a real setup

[`examples/my-20-orchestras.md`](examples/my-20-orchestras.md) is a real 22-orchestra config —
rosters, the reasoning behind each placement, and links to every skill so you can install the
ones you like.

---

## FAQ

**Does this install any skills/agents for me?** No. Claude Orchestra is the *organization layer* —
it doesn't bundle anyone else's tools. The example config links to skills at their original repos
so you install them yourself (and the authors get the credit).

**Will it overwrite my settings?** No. The installer backs up `settings.json`, merges with `jq`
without clobbering existing hooks, and only appends to `CLAUDE.md` if the rule isn't already there.

**Is this on PyPI / npm / homebrew?** No. It's a Bash + Markdown repo. Clone it, audit it, run
the installer. Keeping it small is the point.

**Do I have to use all 22 orchestras?** No. Delete, merge, or rename freely. The themes are a
starting taxonomy, not a rulebook.

**Does the curl installer give me the orchestras?** The curl path installs the *infrastructure*
(hook + router + intake skills). The 22-orchestra roster is a template you customize — edit
`~/.claude/rules/orchestra-system.md` to map your own tools in.

**Do I need NEXUS?** No — it's optional. Delete the section if you don't want a meta-conductor.

**Can I uninstall?** Yes — see [UNINSTALL.md](UNINSTALL.md).

---

## Security

Every install modifies your `~/.claude/`. We take that seriously — see [**SECURITY.md**](SECURITY.md)
for the full breakdown of what gets touched, how to audit before running, how to verify after, and
how to report a vulnerability privately.

## Contributing

PRs and new-orchestra ideas welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

A note for AI-assisted contributors: please verify every command, package name, and feature in
your PR actually exists in this repo before submitting. We've had AI-drafted PRs invent commands
and features that don't exist — those will be closed.

## Credits

Built by [Moksh Mittra](https://github.com/Momo2323-ui). MIT licensed — use it freely. Every skill
referenced in the example links to its original author.
