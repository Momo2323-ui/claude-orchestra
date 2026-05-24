# Security Policy

Claude Orchestra modifies files inside your `~/.claude/` directory. That's an intimate part of
your dev environment, so this document tells you **exactly** what gets touched, **how to audit
before you run anything**, and **how to reverse it** if you change your mind.

If you spot a security issue, see [Reporting a vulnerability](#reporting-a-vulnerability) below.

---

## What `install.sh` actually does

Running `./install.sh` performs **only** these writes — nothing else, no network calls, no sudo:

| Target | Action | Reversible? |
|---|---|---|
| `~/.claude/skills/orchestra-router/` | Create (replaces if exists) | `rm -rf` the directory |
| `~/.claude/skills/orchestra-intake/` | Create (replaces if exists) | `rm -rf` the directory |
| `~/.claude/hooks/orchestra-route.sh` | Copy file, `chmod +x` | Delete the file |
| `~/.claude/rules/orchestra-system.md` | Copy **only if file doesn't already exist** | Delete the file |
| `~/.claude/settings.json` | Append one entry to `hooks.UserPromptSubmit` via `jq` merge | Restore from auto-backup (see below) |
| `~/.claude/CLAUDE.md` | Append the "Orchestra System" rule **only if marker text not present** | Edit out the appended block |

The installer **always backs up** `settings.json` to
`~/.claude/settings.json.bak.YYYYMMDD-HHMMSS` before modifying it. The backup is yours to keep
or delete.

It does **not**:
- Make network requests
- Require `sudo`
- Install npm/pip/brew packages on your behalf
- Touch anything outside `~/.claude/`
- Send telemetry

The only runtime requirement is `jq`, used to merge `settings.json` safely instead of doing
unsafe text substitution.

---

## Audit before you run

We recommend reading the installer before executing it. Three commands:

```bash
# 1. Read every line of what's about to run
cat install.sh

# 2. Verify it parses cleanly (catches syntax tampering)
bash -n install.sh

# 3. Optional but recommended — lint it
shellcheck install.sh
```

If anything in `install.sh` looks unfamiliar or off, **don't run it** and open an issue.

The hook script (`hooks/orchestra-route.sh`) is intentionally tiny — it only prints a routing
directive to stdout. Read it the same way:

```bash
cat hooks/orchestra-route.sh
```

It performs no I/O beyond that single `cat <<EOF` and has zero external dependencies.

---

## Verify what changed after install

After running `./install.sh`, you can confirm exactly what was modified:

```bash
# See the most recent settings.json backup — diff it against current
ls -lt ~/.claude/settings.json.bak.* | head -1
diff "$(ls -t ~/.claude/settings.json.bak.* | head -1)" ~/.claude/settings.json

# Confirm the only files added under ~/.claude/
ls -la ~/.claude/skills/orchestra-router \
       ~/.claude/skills/orchestra-intake \
       ~/.claude/hooks/orchestra-route.sh

# See the rule appended to CLAUDE.md
grep -A 20 "Orchestra System (NON-NEGOTIABLE)" ~/.claude/CLAUDE.md
```

---

## Uninstall / reverse

There is no `uninstall.sh` yet (tracked in `IMPROVEMENT_PLAN.md` P1). To remove Claude
Orchestra manually:

```bash
# 1. Remove the two skills
rm -rf ~/.claude/skills/orchestra-router ~/.claude/skills/orchestra-intake

# 2. Remove the hook script
rm ~/.claude/hooks/orchestra-route.sh

# 3. Restore settings.json from the most recent backup
cp "$(ls -t ~/.claude/settings.json.bak.* | head -1)" ~/.claude/settings.json

# 4. (Optional) Remove the appended rule block from ~/.claude/CLAUDE.md
#    Open it in your editor and delete the section starting with
#    "### Rule 13 — Orchestra System (NON-NEGOTIABLE)" (or similar)

# 5. (Optional) Remove the constitution if you don't want to keep it
rm ~/.claude/rules/orchestra-system.md
```

A future release will ship a scripted uninstaller.

---

## What's checked in CI

Every push and PR runs:

- **`shellcheck`** on all `*.sh` files in the repository (`severity: warning` and up). Failures
  block merging.

See [`.github/workflows/shellcheck.yml`](.github/workflows/shellcheck.yml).

There is no CodeQL workflow because this repository contains no JavaScript or Python source —
only Bash and Markdown. `shellcheck` IS the security linter for this stack.

---

## Supported versions

| Version | Supported |
|---|---|
| `main` (latest) | Yes |
| Older tags | No — pull `main` for fixes |

This is a small project; security fixes land on `main` and we cut a new tag.

---

## Reporting a vulnerability

**Please do not open public GitHub issues for security problems.**

Report privately via GitHub Security Advisory:
**https://github.com/Momo2323-ui/claude-orchestra/security/advisories/new**

Or email the maintainer directly (see profile at https://github.com/Momo2323-ui).

What we ask:
- A reproduction (or a clear description of the issue)
- The affected file(s) / commit(s)
- The impact you see

What you can expect:
- Acknowledgement within 7 days
- A fix or mitigation plan within 30 days for confirmed issues
- Credit in the release notes (unless you'd rather stay anonymous)

---

## Out of scope

These are explicitly **not** vulnerabilities in Claude Orchestra:

- Vulnerabilities in third-party skills you install separately (report to those projects)
- Misconfigurations in your own `orchestra-system.md` after you customize it
- Behavior of Claude Code itself (report to Anthropic)
- The fact that `install.sh` modifies `~/.claude/` — that's the documented purpose, audit it
  before running

---

*Last updated: 2026-05-24.*
