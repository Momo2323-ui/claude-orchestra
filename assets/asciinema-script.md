# Asciinema demo script — `claude-orchestra` 60-second demo

The recording goal: a person who's never heard of this repo watches 60 seconds, understands
what it does, and knows it's safe to run on their machine. Three beats: **(1) it's just files**
→ **(2) install is one command** → **(3) here's the announcement, every prompt, from now on.**

> Record with `asciinema rec demo.cast` from a clean terminal in a fresh tmp directory.
> Target: 50-70 seconds. Replay with `--speed 1.5` if a beat drags.

---

## Pre-recording checklist

- [ ] Terminal: ~120 col × 30 row, monospace font, dark theme (better contrast in the gif/svg)
- [ ] Prompt: trim to `$ ` (no path, no git branch, no time) for cleaner playback
- [ ] Working dir: `cd $(mktemp -d)` — clean room, no leaked paths
- [ ] `claude-orchestra` not already installed under `~/.claude/` for this user — or use
      `CLAUDE_DIR=$(mktemp -d)` to redirect the installer
- [ ] Clear the screen (`clear`) right before pressing record
- [ ] `claude` CLI installed (so the live-prompt beat at the end works)

---

## Scene-by-scene

### Scene 1 — clone (0:00 – 0:08)

Type (slowly, so it's readable):
```bash
$ git clone https://github.com/Momo2323-ui/claude-orchestra
$ cd claude-orchestra
```

Expected output:
```
Cloning into 'claude-orchestra'...
remote: ...
Resolving deltas: 100% (...), done.
```

**Why this beat exists:** prove the whole product is one git clone — no `curl | bash`, no
binary download.

---

### Scene 2 — audit before run (0:08 – 0:22)

Type:
```bash
$ cat install.sh | head -30
```

Expected output (snippet — actual installer is short):
```bash
#!/usr/bin/env bash
set -euo pipefail
# Claude Orchestra — installer
# Writes inside ~/.claude/ only. No network calls. No sudo. No telemetry.
...
```

Pause for ~2 seconds at the top of the file so a viewer can read the header comment.

**Why this beat exists:** the audit-first install path is the trust message — the README leads
with it, the demo should too. Showing the script is small + readable in `cat` is the entire
point.

---

### Scene 3 — install (0:22 – 0:32)

Type:
```bash
$ ./install.sh
```

Expected output (real install — abbreviated for brevity):
```
[install] Backing up ~/.claude/settings.json → ~/.claude/settings.json.bak.20260526-103015
[install] Installing skill: orchestra-router
[install] Installing skill: orchestra-intake
[install] Installing hook: orchestra-route.sh (+x)
[install] Copying constitution: ~/.claude/rules/orchestra-system.md (new)
[install] Appending Rule 13 to ~/.claude/CLAUDE.md
[install] Done. Open a NEW Claude Code session for the router to take effect.
```

**Why this beat exists:** show the installer is loud about what it touches and what it backs
up. Every line is auditable later.

---

### Scene 4 — verify what changed (0:32 – 0:42)

Type:
```bash
$ diff "$(ls -t ~/.claude/settings.json.bak.* | head -1)" ~/.claude/settings.json
```

Expected output:
```diff
> {"type":"command","command":"~/.claude/hooks/orchestra-route.sh"}
```

(The diff is *one line*. Single hook entry added. That's the whole settings change.)

**Why this beat exists:** the `diff` shows the install is *minimal*. Compare against any other
"installer" — they typically touch dozens of files. This one adds a single hook entry.

---

### Scene 5 — open a Claude Code session (0:42 – 0:48)

Type:
```bash
$ claude
```

(Wait for the Claude Code TUI to load. ~3 sec.)

---

### Scene 6 — the announcement (0:48 – 0:60)

Type into the Claude Code prompt:
```
Help me plan a landing page for a pricing-experiment tool.
```

Expected first line of the reply (the entire point of the demo):
```
🎼 PLANNING → DESIGN → BUILD stack
   Conductors: planner → ux-architect → architect
   Using: make-plan, figma, ui-designer, frontend-design, code-reviewer
```

(Let it sit on screen for 2-3 seconds. Stop recording here — the announcement is the payoff.)

**Why this beat exists:** the announcement is what users see *forever* after install. It's the
"this is what's playing" moment that justifies the rest of the demo.

---

## Post-recording

```bash
# Convert to SVG for the README (good for git, no animation overhead)
asciinema-svg demo.cast > assets/demo.svg

# Or upload to asciinema.org and embed the URL in the README
asciinema upload demo.cast
```

Drop the result link into the README under "What you'll see when it works" (replacing the
static code block) or right above it.

---

## Voiceover lines (optional — if recording video over the cast)

Use sparingly. Words land on the beats above, not over them.

- **0:00** "It's a git clone. That's the whole product."
- **0:08** "Read the installer before you run it. It's short."
- **0:22** "One command installs. Notice the backup it makes first."
- **0:32** "Here's everything that changed in settings: one line."
- **0:48** "And here's what you see at the top of every reply, from now on."

---

## Common recording pitfalls

- **Don't type the prompt with autocomplete on** — it'll insert weird `$_` characters into the
  cast. Disable in your shell config for the recording.
- **Don't let the terminal echo your real `$PS1`** — strip path / branch / time first.
- **Don't record over an existing install** — the messages in Scene 3 change ("already
  installed, refreshing…"), which buries the new-install story.
- **Don't speed up Scene 6** — the announcement is the entire point. Let it breathe.

---

*Recording is the maintainer's job — this file just spells out exactly what to type.*
