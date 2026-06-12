# Merge plan — `local-v2-work` (Moksh's 37-file snapshot) × cloud v2 (score engine)

> Written before the branch lands, from dispatch's snapshot report (commit `00eb50c`,
> 37 files, +4,082). Goal: one clean public v2 with zero loss and zero leaks.
> ⚠️ Precondition: the snapshot must be amended to exclude `goal/`, `codex/`,
> `CODEX-FIXES.md` (personal business material) BEFORE pushing — see decision log.

## File-by-file reconciliation

| Local files | Action | Why |
|---|---|---|
| `.github/ISSUE_TEMPLATE/*`, `.github/pull_request_template.md`, `.github/dependabot.yml`, `CODEOWNERS` | **Adopt as-is** | No cloud counterpart; closes P1 #7 + P2 items |
| `ROADMAP.md`, `docs/TROUBLESHOOTING.md`, `CONTRIBUTING.md` (v2) | **Adopt as-is** | Closes P0 #5, P1 #6, P2 #11 |
| `assets/demo.gif`, `assets/asciinema-script.md` | **Adopt as-is** | Closes P1 #9; embed GIF near top of README |
| `agents/auditor.md` | **Adopt** + registry: AUDIT conductor `red-team-lead` → `auditor` | The AUDIT orchestra gets its real conductor |
| `skills/hallucination-guard/` | **Adopt** + file: universal gate (entry/exit), registry roster AUDIT first-chair + NEXUS section | Design decision #4 |
| `skills/skill-selector/` | **Adopt** + file: KNOWLEDGE/AUDIT section | Complements the engine: `orchestra route` picks orchestras deterministically; skill-selector picks players *within* one, with the 0.35/0.25/0.20/0.15/0.05 formula and 0.85/0.5 announce thresholds |
| `install.v2.sh` (428 lines) | **Merge into `install.sh`** — adopt auto-scan, `--guided`, `--upgrade`, `--rollback`; keep cloud engine/registry/telemetry wiring + idempotency tests | One installer, both feature sets; delete `install.v2.sh` after |
| `UNINSTALL.md` | **Adopt**, rewrite around `uninstall.sh` (script first, manual second) | Doc + script, not doc vs script |
| `examples/01-real-prompts.md` | **Merge into `examples/real-prompts.md`** | Keep live engine outputs; fold in local prose; delete the duplicate |
| `README.md` (155-line local delta) | **Reconcile by hand** | Cloud v2 rewrite is newer; pull in demo GIF + any local sections that survive |
| `IMPROVEMENT_PLAN.md` (+1) | Trivial merge | |
| `.gitignore` (+4) | Merge with cloud version (which removed the soak-staging ignores) + add the personal-files block | |
| `.codegraph/` | **Drop from public repo** | Local tool cache, noise |
| `goal/`, `codex/`, `CODEX-FIXES.md` | **Never merged — stay local + gitignored** | Personal/business material on a public repo |

## Design-decision alignment (the 18 locked decisions from local docs)

Already live in cloud v2: AUDIT high-stakes-only + universal flag + `ORCHESTRA_AUDIT_MODE` ·
ASK_HUMAN at <70% confidence · five statuses in router doctrine · NEEDS-WORK default verdict ·
Ralph-loop opt-in ≤3 · compact announce.

Arrives with the branch (adopt verbatim): hallucination-guard 5 layers · skill-selector formula
+ learnings log · auditor agent · Result-object handoffs · cycle detection (depth 10, A→B→A,
indirect → ASK_HUMAN, 5-min timeout) · bounce-back ≤3 · chain shapes (sequential / parallel /
conductor-tree).

Merge work: constitution gains a **Chain Protocol** section (shapes + cycle rules + handoff
object) · installer unification · learnings log feeds `orchestra board` alongside usage
telemetry · per-skill metadata (`best-for`, `complexity-fit`, …) read by `orchestra index` and
passed to skill-selector · curl one-liner installer (P1 #13) last.

## Merge order (smallest blast radius first — per local decision #15)

1. Strip-amend + push `local-v2-work` (Moksh) → 2. adopt no-conflict files (.github, docs,
assets, agents, skills) → 3. registry/constitution updates (auditor, new skills filed, chain
protocol) → 4. installer unification + tests → 5. README/examples reconciliation → 6. regenerate
board + real-prompts → 7. full regression (shellcheck, install/uninstall round-trip, routes) →
8. merge to `main`, tag **v2.0**, close the loop in IMPROVEMENT_PLAN.

---

**Status 2026-06-12: EXECUTED.** All 18 text files transferred via dispatch export (manifest-verified,
byte-exact from commit `a7db607`) and merged per this plan. Unified installer (v3.0.0) adopts the
local skeleton + engine wiring; install.v2.sh retired. Remaining: `assets/demo.gif` (binary — arrives
with the `local-v2-work` push), asciinema recording, v3.0.0 tag after Moksh's review.
