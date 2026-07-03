#!/usr/bin/env bash
# Orchestra System — UserPromptSubmit routing hook (v3, lean)
# Injects a one-line routing reminder each turn. v3 replaces the old always-on
# ceremony block: route silently via skill retrieval, announce only delegation.
# Registered in ~/.claude/settings.json under hooks.UserPromptSubmit.
#
# Intentionally simple and dependency-free: prints a directive to stdout,
# which Claude Code injects into the model's context for the turn.
cat <<'NOTE'
<routing-note>Route silently via skill retrieval (skill-selector; qmd skills collection if installed). Announce only delegation, one line. Capability gap → Gap → Recommend protocol. File new installs with orchestra-intake. High-stakes output → auditor gate.</routing-note>
NOTE
exit 0
