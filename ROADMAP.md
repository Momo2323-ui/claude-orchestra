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
- Example `my-22-orchestras.md` worked config

### v1.1 — trust + polish pass
- `SECURITY.md` with the install contract spelled out
- `IMPROVEMENT_PLAN.md` published so the roadmap is visible
- README rewritten around the audit-first install path
- `shellcheck` CI on every push and PR
- `assets/banner.svg` + `assets/diagram.svg` for the README

### v3.0 — the multi-orchestra release
- **22 orchestras.** ㉑ AUDIT promoted from a single agent to a full orchestra (defaults to
  NEEDS WORK, demands fresh evidence, bounces work back with specific fix lists), and
  ㉒ CYBERSECURITY added as a slot for your own security tools.
- **Two new skills installed:** `skill-selector` (picks between similar skills in an orchestra and
  asks you when it's unsure) and `hallucination-guard` (an anti-hallucination wrapper).
- **The `auditor` agent** — the AUDIT conductor, installed alongside the skills.
- **A bigger `install.sh`:** curl-pipe install, `--dry-run`, `--minimal`, `--prefix`, and
  backup-before-mutate on every file it touches.
- **Cross-cutting doctrine** baked into the constitution: the internal-first search ladder, the
  Harmony 3-layer ensemble, the calibration loop, and the NEXUS 7-phase map. These are *doctrine
  the model follows* — strong conventions, not a runtime engine.
- **Repo housekeeping shipped too:** this `ROADMAP.md`, [`UNINSTALL.md`](UNINSTALL.md),
  [`examples/01-real-prompts.md`](examples/01-real-prompts.md), the PR/issue templates,
  `CODEOWNERS`, and `.github/dependabot.yml`.

> **What this repo does *not* bundle.** The maintainer runs extra *personal* layers on top — a
> local semantic skill-index, a `claude-mem` memory store, and a few private coordination skills.
> Those depend on personal infrastructure and are intentionally **not** part of the public
> template. If you want them, the doctrine points at where they'd plug in — but the core install
> stays Bash + Markdown + `jq`.

---

## Considered (might do, depends on soak signal)

These are ideas that came out of v2/v2.1/v2.2 design and the auditor's findings. None are
committed — they ship only if soak data shows they're worth it.

- **Cross-skill AUDIT automation.** Today the cross-skill audit is invoked manually after a
  Phase batch. A wrapper that triggers it automatically after N new skills land could
  short-circuit doctrinal drift before it ships.
- **Internal-ladder curation tooling.** A reference skill for users who add a memory/knowledge
  store to the internal search ladder — pruning/promotion (mark winners, surface patterns) so the
  internal rungs stay signal-rich instead of accumulating noise.
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
