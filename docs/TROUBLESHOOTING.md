# Troubleshooting

> **v3.0 status:** Most categories below carry the entries we know about today. The deeper
> "Skill X interacts oddly with Skill Y" content gets populated from real soak findings during
> the v3.0 soak period — those land in v3.1. If you hit something not covered here, please
> open a [bug report](https://github.com/Momo2323-ui/claude-orchestra/issues/new?template=bug_report.md)
> — that's the highest-leverage way to grow this file.

---

## Install

### `jq: command not found`
The installer uses `jq` to merge `settings.json` safely. Install it and re-run.

```bash
brew install jq        # macOS
sudo apt-get install jq  # Debian/Ubuntu
sudo dnf install jq    # Fedora
```

### `./install.sh: Permission denied`
The script needs execute permission. Fresh clones from GitHub should already have it; if not:
```bash
chmod +x install.sh
./install.sh
```

### `Backup created at ~/.claude/settings.json.bak.<timestamp>` but no other output
That's success on a re-install — the installer detected that nothing else needed to change
(it's idempotent). Verify with:
```bash
ls -la ~/.claude/skills/orchestra-router ~/.claude/hooks/orchestra-route.sh
grep "Orchestra System" ~/.claude/CLAUDE.md
```

### Installer wrote files but the router still doesn't fire
You almost certainly need to start a **new** Claude Code session — hooks load at session start.
Quit the current session, open a new one, send any prompt.

### `~/.claude/settings.json` is malformed after install
The installer always writes the backup *before* modifying. Restore:
```bash
cp "$(ls -t ~/.claude/settings.json.bak.* | head -1)" ~/.claude/settings.json
```
Then open an issue with the original (unedited-by-you) `settings.json` attached so we can fix
the merge logic.

---

## Routing

### No `🎼` announcement appears at the top of replies
Checklist, in order:

1. Did you open a new Claude Code session after install? Hooks don't load mid-session.
2. Is the hook script registered? Look in `~/.claude/settings.json`:
   ```bash
   jq '.hooks.UserPromptSubmit' ~/.claude/settings.json | grep orchestra-route
   ```
   Expected: one entry pointing to `~/.claude/hooks/orchestra-route.sh`.
3. Is the hook executable?
   ```bash
   ls -la ~/.claude/hooks/orchestra-route.sh   # expect: -rwxr-xr-x
   ```
4. Does the constitution exist?
   ```bash
   ls ~/.claude/rules/orchestra-system.md
   ```
5. Is Rule 13 (or your fork's equivalent) in `CLAUDE.md`?
   ```bash
   grep -c "Orchestra System" ~/.claude/CLAUDE.md   # expect: >= 1
   ```

If all five pass and the announcement still doesn't appear, open a bug report and include the
output of all five commands above.

### Wrong orchestra fires
The router matches against the `Triggers:` lines in your `orchestra-system.md`. If a prompt
keeps firing the wrong orchestra:

1. Read the actual trigger phrases in your constitution: `grep "Triggers:" ~/.claude/rules/orchestra-system.md`
2. Adjust the trigger phrases for the orchestra you *wanted* to fire
3. Open a new Claude Code session

This is a config issue, not a bug — your constitution defines the routing.

### Announcement is too noisy (lists too many tools)
You're in v2.2 EXPANSION tier (18-cap). Either:
- Switch the orchestra to `harmony-tier-default: default` (12-cap) in `orchestra-system.md`, or
- Raise the `Active Ensemble` threshold above 0.70 in `~/.claude/skills/skill-selector/SKILL.md`

See `rules/orchestra-system.md` § "v2.2 Harmony — 3-Layer Ensemble" for the knobs.

---

## ㉑ AUDIT

### AUDIT keeps returning NEEDS WORK even though the work looks fine
AUDIT defaults to NEEDS WORK and demands fresh evidence (Read / Grep / test output with file
paths + line numbers). If the source orchestra returned a claim without evidence, AUDIT will
bounce it. Two fixes:

- Make sure the source orchestra cites fresh evidence (no "should work", no "tested earlier
  today", no memory-only claims)
- Increase `AUDIT_MAX_RETRIES` in your constitution if 3 attempts are too few for the work
  type (default is 3 — raise carefully; the cap exists to prevent infinite loops)

### AUDIT loop never converges (hits the retry ceiling)
Check the bounce-back template in audit-log.md — it should list specific BLOCKERs / MAJORs to
fix. If the same blocker repeats across attempts, the fix isn't actually addressing the issue.
Escalate via 🤚 ASK_HUMAN — that's the designed escape hatch.

### AUDIT can't write to `~/.claude/docs/learnings/audit-log.md`
Known issue (surfaced 2026-05-26 during cross-skill AUDIT). The `auditor` agent's tool
permissions don't include Write access to that path by default — workaround is for the calling
session to append the verdict manually from the auditor's return summary. Tracked for v3.1: grant
the auditor a single-path Write scope on `audit-log.md`.

---

## `claude-mem` / Score Archive (Rule 14 rung 3)

### `claude-mem` won't start
The MCP needs to bind to `127.0.0.1` (loopback only — privacy invariant). Check:
```bash
echo $CLAUDE_MEM_WORKER_HOST   # must be 127.0.0.1, never 0.0.0.0
ls ~/.claude-mem/claude-mem.db
```
If `CLAUDE_MEM_WORKER_HOST=0.0.0.0` you have a host config drift — fix the env var, restart
the MCP. Never expose `claude-mem` to a network interface.

### `score-archive` skill says rung 3 is empty
Score Archive only stores AUDIT-verified outcomes. If no AUDIT-READY verdicts have been written
yet, rung 3 has no content to return. Run more sessions; outcomes accumulate as the AUDIT gate
verifies high-stakes work.

### Rule 14 ladder skips internal rungs and goes straight to WebSearch
That's a doctrine drift — the router should always check Obsidian → `~/.claude/` → score-archive
→ claude-mem before external. Check:
```bash
grep -A 5 "Internal-First Search Ladder" ~/.claude/CLAUDE.md
grep -A 10 "Internal-first" ~/.claude/skills/orchestra-router/SKILL.md
```
Both should reference the 4-rung ladder. If one or both are missing the integration, your
install drifted (or your constitution was customized to skip the rule). Re-apply by re-running
`install.sh` (idempotent — won't clobber the rest of your config).

---

## `orchestra-intake` (new tool classification)

### intake says "no orchestra fits, but I don't want to create a new one"
Two options:
- Put it on the **Reserve Bench** (`orchestra-system.md` → ⓪ section). It stays installed and
  callable by name, but never auto-fires.
- Force-classify into the closest existing orchestra. Note the mismatch in your
  `docs/learnings/orchestra-assignments.md` so it's visible next session.

### intake's security scan returns CAUTION on a tool I trust
Don't override silently. The scan output usually says *why* (e.g. unpinned dependency,
permission request for outside-`~/.claude/` paths). Either:
- Fix the upstream tool (pin the dep, drop the permission), or
- Accept the risk explicitly in your `orchestra-assignments.md` entry with a reason

CAUTION is intake telling you "I'd want a human to look at this" — not "reject."

---

## Coming in v3.1 (from soak findings)

Real bug content lands here from the soak period. If you're hitting something the categories
above don't cover, please file it — that's literally how this file grows.

Likely sections to add post-soak:
- Multi-orchestra-stack ordering edge cases
- Per-OS install differences (we test on macOS + Ubuntu; WSL2 + arch reports welcome)
- Interaction between user-installed plugins and the router
- Performance with very large `orchestra-system.md` files (>1000 lines)
