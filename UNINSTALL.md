# Uninstall

Claude Orchestra is reversible. There's no telemetry to disable, no remote state to clean up,
no daemon to kill — every install action writes to local files under `~/.claude/`, and every one
can be undone with `rm` / a backup restore / an editor.

This document is the explicit reverse of [`install.sh`](install.sh). If anything below feels
unfamiliar, read it against `install.sh` directly — they're meant to mirror each other.

> If you only want to *pause* the routing (not remove anything), see the
> [Pause routing without uninstalling](#pause-routing-without-uninstalling) section at the bottom.

---

## TL;DR — the four commands

```bash
# 1. Remove the two installed skills
rm -rf ~/.claude/skills/orchestra-router ~/.claude/skills/orchestra-intake

# 2. Remove the routing hook script
rm ~/.claude/hooks/orchestra-route.sh

# 3. Restore settings.json from the most recent install backup
cp "$(ls -t ~/.claude/settings.json.bak.* | head -1)" ~/.claude/settings.json

# 4. Open ~/.claude/CLAUDE.md in your editor and delete the appended block
#    (starts with: "### Rule 13 — Orchestra System (NON-NEGOTIABLE)")
$EDITOR ~/.claude/CLAUDE.md
```

Start a new Claude Code session afterward. The router is gone.

---

## The full breakdown (one section per install target)

For reference, here's what `install.sh` writes and how to reverse each write.

### 1. `~/.claude/skills/orchestra-router/`

What it is: the skill that reads your prompt, matches it to one or more orchestras, and
announces the activation. ~1 KB of Markdown.

```bash
rm -rf ~/.claude/skills/orchestra-router
```

Verify it's gone:
```bash
ls ~/.claude/skills/orchestra-router 2>&1 | head -1
# expected: ls: ...: No such file or directory
```

### 2. `~/.claude/skills/orchestra-intake/`

What it is: the skill that runs the security scan + classifies + files anything new you install
into the right orchestra.

```bash
rm -rf ~/.claude/skills/orchestra-intake
```

### 3. `~/.claude/hooks/orchestra-route.sh`

What it is: a `UserPromptSubmit` hook that prints the routing directive on every prompt. The
hook itself contains no logic — just a `cat <<EOF` block.

```bash
rm ~/.claude/hooks/orchestra-route.sh
```

### 4. `~/.claude/settings.json` — remove the hook entry

The installer added one entry to `hooks.UserPromptSubmit`. The safe way to reverse is to
restore from the auto-backup the installer made:

```bash
# See what backups exist
ls -lt ~/.claude/settings.json.bak.*

# Restore the most recent one (the one made right before install)
cp "$(ls -t ~/.claude/settings.json.bak.* | head -1)" ~/.claude/settings.json
```

**If you don't want to restore from backup** — for example, because you've made other settings
changes since install — edit `~/.claude/settings.json` and remove the entry under
`hooks.UserPromptSubmit` that points to `orchestra-route.sh`. Validate with `jq`:

```bash
jq . ~/.claude/settings.json   # must print without error
```

### 5. `~/.claude/CLAUDE.md` — remove the appended rule

The installer appended a rule block to `CLAUDE.md` (only if the marker text wasn't already
present). Open the file and delete the block:

```bash
$EDITOR ~/.claude/CLAUDE.md
```

The block to remove starts with:
```
### Rule 13 — Orchestra System (NON-NEGOTIABLE)
```
…and ends at the next top-level `## ` heading (or end of file).

You don't need to remove anything else from `CLAUDE.md` — your other rules and project
configuration are untouched.

### 6. `~/.claude/rules/orchestra-system.md` (the constitution)

Only present if `install.sh` copied it (it copies only when the file doesn't already exist —
your customizations are never overwritten). Keep or delete to taste:

```bash
# Optional: remove the constitution entirely
rm ~/.claude/rules/orchestra-system.md

# Or just back it up out of the way in case you ever return
mv ~/.claude/rules/orchestra-system.md ~/.claude/rules/orchestra-system.md.disabled
```

If you keep it but want it inert, the rule block in `CLAUDE.md` is what *activates* it — once
Rule 13 is gone, an orphan `orchestra-system.md` has no effect.

### 7. Leftover backups

```bash
ls ~/.claude/settings.json.bak.*
```

These were made by the installer before each settings merge. They're yours — keep them as a
safety net, or remove:

```bash
rm ~/.claude/settings.json.bak.*
```

---

## Verify the uninstall

```bash
# All four files/dirs should be gone
ls ~/.claude/skills/orchestra-router 2>&1 | head -1
ls ~/.claude/skills/orchestra-intake 2>&1 | head -1
ls ~/.claude/hooks/orchestra-route.sh 2>&1 | head -1

# No "orchestra-route" entry left in settings
jq '.hooks.UserPromptSubmit' ~/.claude/settings.json | grep -i orchestra
# expected: no output

# No "Orchestra System" rule left in CLAUDE.md
grep -c "Orchestra System (NON-NEGOTIABLE)" ~/.claude/CLAUDE.md
# expected: 0
```

Open a new Claude Code session and send any prompt. You should see *no* `🎼` announcement
at the top of the reply — routing is off.

---

## Pause routing without uninstalling

If you just want to silence the announcements temporarily, you don't need to uninstall — disable
the hook in `settings.json`:

```bash
# Backup first
cp ~/.claude/settings.json ~/.claude/settings.json.bak.pause.$(date +%Y%m%d-%H%M%S)

# Comment-out or remove the orchestra-route entry under hooks.UserPromptSubmit
$EDITOR ~/.claude/settings.json
```

Re-enable by adding the entry back. The skills and constitution stay installed — they just
won't fire unless invoked by name.

---

## Why this is reversible by design

`install.sh` follows three rules that make uninstall trivial:

1. **Only writes inside `~/.claude/`.** Nothing outside that directory is touched.
2. **Always backs up `settings.json` before changing it.** The backup path is printed during
   install — copy it back to restore.
3. **Never overwrites the constitution if it already exists.** Your customizations to
   `orchestra-system.md` survive every re-install and every uninstall.

These are documented in [`SECURITY.md`](SECURITY.md) — the install + uninstall contract is
explicit, auditable, and small.

---

## If something doesn't reverse cleanly

Open an issue: <https://github.com/Momo2323-ui/claude-orchestra/issues>. Include the exact
command you ran and the unexpected output. Uninstall bugs are P0 — we want to fix them fast.

For sensitive uninstall-related issues (e.g. you suspect a step left something behind it
shouldn't have), report privately via
<https://github.com/Momo2323-ui/claude-orchestra/security/advisories/new>.
