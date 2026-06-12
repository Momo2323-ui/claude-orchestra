# Roadmap

This is the honest version of where Claude Orchestra has been, where it's going, and what it
deliberately *won't* try to become. No fake dates, no marketing-speak.

> The repo is a template — your fork's roadmap will diverge. This roadmap is for the upstream
> reference config + the install/router/intake machinery only.

---

## Shipped

### v1.0 — first public version
- The four moving parts: `orchestra-system.md` constitution, `orchestra-route.sh` hook,
  `orchestra-router` skill, `orchestra-intake` skill
- `install.sh` — idempotent, backs up `settings.json`, never clobbers your custom rules
- 20-orchestra starter taxonomy + the NEXUS meta-conductor
- Example `my-20-orchestras.md` worked config

### v1.1 — trust + polish pass
- `SECURITY.md` with the install contract spelled out
- `IMPROVEMENT_PLAN.md` published so the roadmap is visible
- README rewritten around the audit-first install path
- `shellcheck` CI on every push and PR
- `assets/banner.svg` + `assets/diagram.svg` for the README

### v2 — internal-only (not yet pushed)
*All v2 / v2.1 / v2.2 work lives in `~/.claude/` during the soak period. It will land as a
single atomic v3.0.0 commit — see [the v3 plan](#v30--the-next-atomic-release) below.*
- ㉑ AUDIT promoted to a full orchestra (was a single agent in v1) — defaults to NEEDS WORK,
  demands fresh evidence, bounces work back with specific fix lists (max 3 attempts)
- Cycle-detection router (depth + duration + lookback caps)
- `install.v2.sh` — drafted, soak-pending
- ~70 reserve-bench agents archived (description-tax reclaim, recall-indexed for restore)

### v2.1 — primitives layer (in-flight)
- Handoff Standard — every project keeps a `HANDOFF.md` at root; session resume reads it first
- Context-Compaction Protocol — `PreCompact` hook saves state, `PostCompact` rehydrates
- Calibration Loop — failures get named in doctrine so the same mistake doesn't recur

### v2.2 — Harmony / 3-Layer Ensemble (in-flight)
- Three layers per orchestra activation: **Active** (candidates ≥0.70, full doctrine loaded) ·
  **Standby** (0.55–0.69, listed by name, conductor summons by name) · **Reserve** (dormant)
- Two tiers per task: **DEFAULT** (12-cap) · **EXPANSION** (18-cap, standby auto-promotes)
- Inventory-as-source-of-truth — `skill-selector`'s pool is `~/.claude/.orchestra-scan.md`
  (the full installed inventory), not just the curated `orchestra-system.md` index
- New skill: `orchestra-coverage-audit` — runs after every install batch + end of soak

---

## v3.0 — the next atomic release

The v3 launch ships everything from v2, v2.1, v2.2 above, plus the v3-specific layer below, as
**one atomic commit** to `main` + tag `v3.0.0`. Nothing piecemeal — the soak period is what
shakes out any drift first.

### Already built locally, awaiting soak (Phase 1 complete 2026-05-26)
- **Standing Rule 14 — Internal-First Search Ladder.** Every research task checks internal
  rungs (Obsidian / `~/.claude/` / score-archive / claude-mem) before going external. Skips
  allowed only on explicit user override or genuinely brand-new info.
- **6 new skills** (ruflo-inspired primitives, all renamed + scoped down + native-primitives only):
  - `section-comms` — named-agent + SendMessage coordination patterns (pipeline / fan-out / supervisor)
  - `parallel-section-performance` — `claude -p` background spawning with budget + model + tool guardrails
  - `score-archive` — wraps `claude-mem` as Rule 14 rung 3 (AUDIT-verified outcomes only)
  - `maestro-routing` — 3-tier Haiku / Sonnet / Opus selection via 5-dimension scoring
  - `player-profiles` — 50+ named-agent role catalog (pure prompt library)
  - `score-memorization` — 3-cache discipline doc (Anthropic prompt cache · `claude-mem` · score-archive)
- **Cross-skill AUDIT verdict: READY** (auditor agent verified all 7 new skills + 4 cross-cutting
  doctrine changes with fresh evidence — 0 blockers, 0 majors, 0 minors)

### Soak gate (current)
v3.0.0 will not be tagged until ~1 week of real-world dogfooding catches:
- Whether Rule 14's ladder actually triggers on research tasks
- Whether v2.2 ensemble announcements feel right (not noisy)
- Whether `score-archive` writes happen consistently after AUDIT-READY
- Any unexpected interaction between `section-comms` / `parallel-section-performance` / `maestro-routing`

Findings land in `docs/learnings/audit-log.md` as calibration entries. If a finding blocks
release, it gets fixed pre-tag. Otherwise it goes into the v3.1 backlog.

### Will ship alongside v3.0
- This `ROADMAP.md`
- [`UNINSTALL.md`](UNINSTALL.md) — the explicit reverse of `install.sh`
- [`examples/01-real-prompts.md`](examples/01-real-prompts.md) — 5 worked prompts → routing
- `docs/TROUBLESHOOTING.md` skeleton (populated from soak)
- `.github/pull_request_template.md` + bug/feature issue templates
- `CODEOWNERS` + `.github/dependabot.yml`
- A 30–60s asciinema demo (script ready in `assets/`; recording happens before tag)

---

## Considered (might do, depends on soak signal)

These are ideas that came out of v2/v2.1/v2.2 design and the auditor's findings. None are
committed — they ship only if soak data shows they're worth it.

- **Cross-skill AUDIT automation.** Today the cross-skill audit is invoked manually after a
  Phase batch. A wrapper that triggers it automatically after N new skills land could
  short-circuit doctrinal drift before it ships.
- **Score-archive curation tooling.** The score-archive currently captures every AUDIT-READY
  outcome. A pruning/promotion tool (mark winners, archive losers, surface patterns) would
  keep rung 3 of the internal ladder signal-rich.
- **Auto-fill TROUBLESHOOTING from soak issues.** A skill that watches issues filed against
  the repo + audit-log entries marked `calibration-anchor` and proposes TROUBLESHOOTING
  additions.
- **v3.1 — a `--scan-existing-setup` mode for `install.sh`.** Today install.sh writes its files;
  v3.1 could detect an existing `~/.claude/` setup and surface a coverage report (which
  orchestras already match the user's installed tools) before writing anything.
- **Per-orchestra `harmony-tier-default: lean`.** Reserved in the spec but no orchestra uses
  it yet. Some single-tool orchestras might benefit (RESEARCH on a small machine, e.g.) — wait
  for soak to surface a real example.
- **A Cursor / Aider / Cline plugin layer.** Claude Orchestra is currently Claude Code only.
  The orchestra-system doctrine is portable, but the install machinery is not. Out of scope
  for v3; tracked as a v4 question.

---

## Won't do (anti-features)

Saying "no" is what keeps the project small. These are deliberate:

- **No bundled third-party skills.** Claude Orchestra is the *organization layer*. Example
  configs link out to skills at their source repos so authors keep the credit. Bundling = legal
  + maintenance + trust cost we don't take on.
- **No network calls from `install.sh`.** No telemetry, no auto-update, no remote config. Every
  byte the installer writes is in the cloned repo, auditable in your shell.
- **No `sudo`, no npm/pypi/brew package, no daemon.** The whole project is Bash + Markdown +
  `jq`. If it ever needs to be more than that, it's a different project.
- **No "Just trust us" defaults.** Every install behavior is reversible (see
  [`UNINSTALL.md`](UNINSTALL.md)). The installer backs up `settings.json` and never overwrites
  your customized constitution. SECURITY.md spells out every write.
- **No silent auto-update.** Pulling new versions is `git pull` + re-run the installer (which is
  idempotent and never clobbers your customizations). Anything that auto-pulls without your
  hands on the keyboard is out of scope.
- **No CLI binary.** No `claude-orchestra` command on your PATH. The router lives inside Claude
  Code; adding another binary surface is adding another thing to audit.
- **No closed-source release.** MIT, period.

---

## How this roadmap evolves

- Soak findings → `docs/learnings/audit-log.md` → graduate to `docs/TROUBLESHOOTING.md` (if
  user-facing) or to this file's "Considered" section (if design-facing)
- Each tagged release closes the "v3.0 / v3.1 / …" section above with what actually shipped
- "Considered" items either promote to a versioned section (with a target release) or move to
  "Won't do" (with reasoning)
- "Won't do" items never expire silently — if one moves out, this file says why in the commit
  message

---

## Open questions (input welcome)

- Should the orchestra-intake security scan have a `--strict` mode that auto-rejects anything
  with a non-pinned dependency? (Currently it flags + asks the user.)
- Should v3.1 add an `orchestra-doctor` skill that audits a user's customized `orchestra-system.md`
  for the same kind of cross-skill issues the cross-skill AUDIT just caught?
- Should NEXUS Phase 0 fire automatically on every greenfield prompt, or stay opt-in?

If you have opinions, open a discussion at
<https://github.com/Momo2323-ui/claude-orchestra/discussions> (or an issue if you'd rather a
direct ask).
