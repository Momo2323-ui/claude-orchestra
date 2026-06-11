#!/usr/bin/env bash
# Orchestra System — UserPromptSubmit routing hook (v2)
#
# v1 injected the same static directive on every prompt. v2 actually READS the
# prompt (Claude Code passes hook input as JSON on stdin), runs it through the
# deterministic `orchestra route` scorer (registry triggers + optional qmd
# semantic search), and injects a directive containing ONLY the matched
# orchestras, their conductors, and the pre-ranked players — so the model
# starts the turn already knowing which slice of your toolkit to use.
#
# Falls back to the v1 static directive if jq / the engine / the registry are
# missing, so the system never breaks a prompt.

set -u

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
ENGINE="$CLAUDE_DIR/orchestra/bin/orchestra"

fallback() {
  cat <<'DIRECTIVE'
<orchestra-routing>
🎼 ORCHESTRA SYSTEM ACTIVE — route this request before acting.
1. Idea/business-planning signals ("I have an idea", "plan a business", …) → fire the NEXUS meta-conductor.
2. Otherwise match intent to orchestra(s) via the orchestra-router skill; stack for compound requests.
3. ANNOUNCE the activation: 🎼 <ORCHESTRA> active · Conductor: <agent> · Using: <tools>.
4. Reserve Bench tools never auto-fire (explicit name only).
Full doctrine: ~/.claude/rules/orchestra-system.md
</orchestra-routing>
DIRECTIVE
  exit 0
}

command -v jq >/dev/null 2>&1 || fallback
[ -x "$ENGINE" ] || fallback

# Extract the prompt from the hook's stdin JSON ({"prompt": "...", ...}).
prompt="$(jq -r '.prompt // empty' 2>/dev/null || true)"
[ -n "$prompt" ] || fallback

"$ENGINE" route --hook "$prompt" 2>/dev/null || fallback
exit 0
