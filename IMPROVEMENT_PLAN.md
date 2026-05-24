# Claude Orchestra — Improvement Plan

> Source of truth for the v1.1 polish pass. Generated 2026-05-24 from a Phase-0
> NEXUS discovery on signals surfaced by 7 external PRs (#1–#7, all from `okwn`).
> The PRs themselves were rejected — but the *perception gaps* they revealed are real.

---

## North Star

> *"Strong enough that everyone forks it and uses it for them. Secure enough that
> people download it freely, without worry."* — Moksh

Two operating constraints fall out of that:

- **Trust-first**: this thing modifies a user's `~/.claude/`. Every doc, every commit,
  every CI run should reduce the "should I really run this?" hesitation.
- **Fork-and-customize, not install-and-forget**: the README, examples, and contributor
  docs should treat *forking + editing your own roster* as the default path, not a footnote.

---

## Phase 0 — Signals extracted from the 7 PRs

| PR | What the contributor *perceived* | What that exposes in our repo |
|---|---|---|
| #1 shellcheck CI | "no CI exists" | No automated quality signal. Contributors can't see if a change passes. |
| #2 README examples | "I can't picture how it actually behaves" | README explains the concept but never shows **input → output**. |
| #3 CodeQL | "no security posture" | No SECURITY.md, no statement of what `install.sh` actually touches. |
| #4 roadmap | "where is this going?" | Zero visible direction → stars don't grow. |
| #5 Quick Start | "install is confusing" | Reader pattern-matched the name as a Python package. Two install paths confuse. |
| #6 prereq note | "what do I need first?" | `jq` requirement is buried in a comment, not above the fold. |
| #7 CONTRIBUTING expansion | "rules too sparse" | Branch table & dev-setup section genuinely don't exist yet. |
| **Meta** | "easy to drive-by contribute" | **No friction filter for AI-drafted spam PRs.** Won't be the last campaign. |

---

## Phase 1 — Strategic themes

| Theme | One-line definition |
|---|---|
| **A. Clarity in 30 seconds** | First-time visitor knows what it is, what it needs, how to install, what they'll see. |
| **B. Show, don't tell** | Real prompt → real routing announcement → real result. |
| **C. Trust signals** | SECURITY.md, audit-first install flow, CI badge, install transparency. |
| **D. Fork-and-customize narrative** | Default path = fork → edit roster → run. Not = install-once. |
| **E. Self-documenting examples** | `examples/` makes the system teach itself. |
| **F. Anti-AI-spam armor** | PR/issue templates + explicit AI-PR guidelines. |

---

## Phase 2 — Prioritized action plan

Trust/security items now lead. Effort estimates assume Moksh + Claude pair-coding.

### P0 — Ship this week

| # | Move | Status | Effort |
|---|---|---|---|
| 1 | **`SECURITY.md`** — what install.sh touches, audit-before-run, how to verify, how to uninstall | DRAFTED | 30 min |
| 2 | **README rewrite** — prereqs box, audit-first install, "what you'll see when it works", trust links | DRAFTED | 1 hr |
| 3 | **`.github/workflows/shellcheck.yml`** — fixed (find -exec, severity filter, pinned SHAs) | DRAFTED | 20 min |
| 4 | **Close PRs #1–#6 politely**, merge or close #7 | PENDING APPROVAL | 15 min |
| 5 | **`ROADMAP.md`** — current state, next 3–5 items, "not planned" list | PENDING INPUT (need Moksh's actual vision) | 45 min |

### P1 — Next 2 weeks

| # | Move | Effort |
|---|---|---|
| 6 | **`CONTRIBUTING.md` v2** — keep voice, add branch table, add AI-PR guideline section | 45 min |
| 7 | **PR + Issue templates** — `.github/PULL_REQUEST_TEMPLATE.md` + `bug` / `orchestra-suggestion` / `question` forms | 30 min |
| 8 | **`examples/01-real-prompts.md`** — 5 real prompts → real routing across your 20 orchestras | 1 hr |
| 9 | **30-sec terminal recording** (asciinema or animated SVG) — install + first prompt + orchestra fires | 30 min |
| 10 | **`UNINSTALL.md` or `uninstall.sh`** — reverse what install.sh did, also a trust signal | 30 min |

### P2 — When time allows

| # | Move | Effort |
|---|---|---|
| 11 | **`docs/TROUBLESHOOTING.md`** — top 10 issues (hook not loading, wrong orchestra firing, etc.) | 1 hr |
| 12 | **`CODEOWNERS` + branch protection** — require Moksh review on workflows / install.sh / hooks | 15 min |
| 13 | **Dependabot config** — even no-op, it's a visible trust signal | 10 min |
| 14 | **Tag a v1.0 release** — git tag + GitHub release notes, give downloads a verifiable artifact | 20 min |

---

## Non-goals (explicit list to deflect future drive-by PRs)

- Not adding CodeQL (no JS/Python in this repo — shellcheck IS the security tool here)
- Not adding a PyPI package or `setup.py` (this is a Bash + Markdown project)
- Not auto-bundling third-party skills (the repo is the organization layer, not a skill collection)
- Not promising features without an issue tracking the work
- Not accepting AI-drafted PRs that hallucinate features or invented commands

---

## How we'll measure success

- **Anxiety reduction**: SECURITY.md exists; install flow has audit step before run step
- **Onboarding**: a new visitor can install + see their first orchestra fire in under 5 minutes
- **Contribution quality**: PR/issue templates exist; AI-spam PR rate drops
- **Discoverability**: README answers "what is this" in under 30 seconds of reading

---

## Decision log

- **2026-05-24** — Decided OSS-growth mode (per Moksh). Trust-first emphasis. All 7 contributor PRs to be closed. P0 cluster drafted same session.
