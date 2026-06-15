# Contributing

Thanks for wanting to improve Claude Orchestra. This is a small, focused project — the goal is
to keep the *system* clean and adaptable, not to become a giant skill collection.

Read this end-to-end before your first PR. It's short.

---

## What we want PRs for

- **New orchestra ideas** — a coherent domain the default 22 don't cover. Use the full
  10-field structure documented in [`docs/CREATE-YOUR-ORCHESTRA.md`](docs/CREATE-YOUR-ORCHESTRA.md).
- **Doctrine improvements** — clearer triggers, better quality gates, sharper handoff
  contracts. Cite the failure mode you're solving.
- **Installer / hook hardening** — better `settings.json` handling, support for other shells
  (`fish`, `nu`), better behavior under unusual `$HOME` setups, clearer error messages.
- **Docs** — clearer setup, better troubleshooting (especially from real bugs you hit), tighter
  "create your own" guidance, worked examples beyond `my-22-orchestras.md`.
- **Bug fixes** — anything that doesn't work as the README, SECURITY.md, or UNINSTALL.md
  describes.
- **CI improvements** — extending the `shellcheck` workflow, adding install-script smoke tests.

## What we won't merge

- **Third-party skill code.** This repo is the organization layer, not a skill bundle. Link to
  skills at their source repos instead — keeps us legal and gives authors credit.
- **Personal config.** Examples must be generic or anonymized (see `my-22-orchestras.md` for
  the pattern — `my-mobile-app`, `[custom]` / `[community]` / `[anthropics]` source tags).
- **Network calls in `install.sh`.** No telemetry, no auto-update, no remote config. The
  installer must remain auditable in one `cat install.sh`.
- **`sudo` requirements.** Everything writes inside `~/.claude/`.
- **Hidden side effects.** Anything the installer or a skill does must be documented in
  SECURITY.md.

If you're unsure whether your change fits, open an
[Issue](https://github.com/Momo2323-ui/claude-orchestra/issues/new) or a Discussion *before*
you write the PR. We'd rather scope it together than ask you to re-do work.

---

## The security-scan-first rule

**Any PR that adds a new skill, agent, hook, MCP reference, or external link** must pass the
5-step security scan documented in `~/.claude/workflows/import-security-scan.md`. Include the
scan output in your PR description. The five steps:

1. **Source verification** — publisher legitimacy, stars / last-commit if a repo, signed tags
2. **Code scan** — prompt injection, credential harvesting, exfiltration paths, supply-chain
3. **Package check** (if applicable) — `npm audit`, socket.dev, similar
4. **Skill/MCP source review** — read every line; check requested permissions
5. **Decision** — SAFE / CAUTION / REJECT with reasoning

If the scan returns CAUTION or REJECT, surface it in the PR and let us discuss before merge.
We'd rather slow-walk one PR than land a malicious dependency.

---

## Test locally before opening a PR

### If you touched `install.sh` or a hook

```bash
# 1. Lint
shellcheck install.sh hooks/*.sh

# 2. Parse-check
bash -n install.sh

# 3. Preview every action without touching the filesystem
./install.sh --dry-run

# 4. Run against a throwaway prefix (NEVER your real ~/.claude/).
#    --prefix=DIR installs into DIR/.claude, so your real config is untouched.
TEST_DIR=$(mktemp -d)
./install.sh --prefix="$TEST_DIR"
find "$TEST_DIR/.claude" -type f          # inspect what landed

# 5. Idempotency — re-run; only new timestamped *.bak.* backups should appear
before=$(find "$TEST_DIR/.claude" -type f ! -name '*.bak.*' | sort)
./install.sh --prefix="$TEST_DIR"
after=$(find "$TEST_DIR/.claude" -type f ! -name '*.bak.*' | sort)
diff <(echo "$before") <(echo "$after")   # no output expected
```

### If you touched a skill or the constitution

```bash
# Validate YAML frontmatter parses
for f in skills/*/SKILL.md; do
  awk '/^---$/{c++}c==2{exit}c' "$f" | head -1 || echo "MISSING FRONTMATTER: $f"
done

# Check the constitution still has all 22 orchestras enumerated (expect 22)
grep -c '^### [①-⑳㉑㉒]' orchestra-system.md
```

### If you added a new orchestra

- 10-field structure complete (mission, conductor, first chair, section, triggers, process,
  allowances, harness, handoff, quality gate)
- Conductor is a single agent (not "various agents")
- Triggers don't collide with another orchestra's triggers (run `grep -h "Triggers:" orchestra-system.md`)
- Quality gate is testable (not just "looks good")
- Added to the `examples/my-22-orchestras.md` count if applicable

---

## The orchestra-intake flow for new tools

If your PR adds a tool reference (a new skill in the example config, a new MCP, a new
connector), follow the same flow `orchestra-intake` follows internally:

1. Security scan (above)
2. Classify — which orchestra does it belong to?
3. File — add it to that orchestra's First Chair / Section / Plugins / MCPs row in the
   relevant docs
4. If it doesn't fit any existing orchestra, propose a new orchestra (full 10-field structure)
   — *don't* just append it loosely
5. Note the classification reasoning in your PR description

---

## PR format

1. Fork → feature branch → make your change
2. Test locally (above)
3. Open a PR with a description that answers:
   - **What** changed (high-level, one paragraph)
   - **Why** — what failure mode or use case prompted this
   - **How tested** — the actual commands you ran + their output
   - **Security scan result** (if applicable — see above)
   - **Docs updated** — which files in `docs/` / README / SECURITY / UNINSTALL changed
4. Wait for `shellcheck` CI to pass
5. Reviewer comments → address → re-request review

Aim for small, focused PRs. One change per PR is easier to review and easier to revert if
something goes wrong.

---

## Commit + DCO

- Use conventional-commit style (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`) — recent
  history shows the pattern
- One commit per logical change is preferred; squashing on merge is fine if the PR is small
- No DCO sign-off requirement currently; that may change if the project grows

If your PR is AI-assisted (Claude, Copilot, etc.), please note it in the description and
**verify every command, package name, and feature actually exists in this repo before
submitting**. We've had AI-drafted PRs invent commands and features that don't exist — those
will be closed.

---

## Conduct

Be kind, be clear, assume good faith. No code of conduct boilerplate beyond that — if a
specific behavior becomes a problem we'll formalize it then. Report concerns privately to the
maintainer (see profile at <https://github.com/Momo2323-ui>).

---

## Where to ask before opening a PR

- **General "is this a good fit?"** — open a Discussion
  (<https://github.com/Momo2323-ui/claude-orchestra/discussions>)
- **A bug you want to confirm** — open an Issue with the bug template
- **A security concern** — open a private advisory
  (<https://github.com/Momo2323-ui/claude-orchestra/security/advisories/new>)

Thanks for contributing.
