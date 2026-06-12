# Setup

## Requirements

- [Claude Code](https://claude.com/claude-code)
- `jq` (for the safe `settings.json` merge) — `brew install jq` / `apt-get install jq`

## Install

```bash
git clone https://github.com/Momo2323-ui/claude-orchestra
cd claude-orchestra
./install.sh
```

The installer:

| Step | What it does | Safety |
|---|---|---|
| skills | copies `orchestra-router` + `orchestra-intake` → `~/.claude/skills/` | additive |
| hooks | copies `orchestra-route.sh` + `orchestra-telemetry.sh` → `~/.claude/hooks/` (+ `chmod +x`) | additive |
| engine | copies `bin/orchestra` → `~/.claude/orchestra/bin/` (+ `chmod +x`) | additive |
| registry | copies `registry/registry.template.json` → `~/.claude/orchestra/registry.json` | **only if not present** |
| constitution | copies `orchestra-system.md` → `~/.claude/rules/` | **only if not present** |
| settings.json | registers the hooks under `hooks.UserPromptSubmit` + `hooks.PostToolUse` | **backs up first, `jq` merge, never clobbers** |
| CLAUDE.md | appends the orchestra rule | **only if not already present** |
| first index | runs `orchestra index` once | writes only inside `~/.claude/orchestra/` |

It's **idempotent** — run it as many times as you like; it won't duplicate anything.

## After install

1. Open a **new** Claude Code session (so the hooks + rule load).
2. Fill the rosters with your tools in BOTH `~/.claude/rules/orchestra-system.md` and
   `~/.claude/orchestra/registry.json` (start from `examples/registry-filled.json`)
   → see [CREATE-YOUR-ORCHESTRA.md](CREATE-YOUR-ORCHESTRA.md).
3. Health check: `~/.claude/orchestra/bin/orchestra doctor`
4. Send any prompt — you'll see `🎼 ... active` announcing the orchestra that fired.
5. After a few days: `orchestra board` to see your toolkit ranked by real usage, and
   [SCALING-SKILLS.md](SCALING-SKILLS.md) if doctor flags your skill budget.
6. Optional semantic routing: `bun install -g @tobilu/qmd && orchestra index && orchestra qmd on`.

## Uninstall

```bash
./uninstall.sh          # reverses the install; restores benched skills; keeps your data
./uninstall.sh --purge  # also deletes registry, usage log, board, and the constitution
```

Manual steps (if you prefer) are in [SECURITY.md → Uninstall](../SECURITY.md#uninstall--reverse).

## Troubleshooting

- **Router doesn't fire** → did you start a *new* session after install? Hooks load at session start.
- **`jq: command not found`** → install jq, re-run `./install.sh`.
- **Want to undo a settings change** → the installer saved `~/.claude/settings.json.bak.<timestamp>`.
