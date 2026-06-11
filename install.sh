#!/usr/bin/env bash
#
# Claude Orchestra — installer (v2)
# Installs the orchestra system into your ~/.claude:
#   • skills/orchestra-router, skills/orchestra-intake
#   • hooks/orchestra-route.sh   (+ registers it in settings.json — safely, via jq)
#   • hooks/orchestra-telemetry.sh (+ registers under PostToolUse — feeds the ranking board)
#   • orchestra/bin/orchestra    (the score engine: index/route/board/doctor/bench/upkeep)
#   • orchestra/registry.json    (machine-readable roster — only if not already present)
#   • rules/orchestra-system.md  (the constitution template — only if not already present)
#   • appends the orchestra rule to your CLAUDE.md (only if not already present)
#
# Idempotent: safe to run more than once. Backs up settings.json before changing it.
# No sudo required. Re-running refreshes the managed skills, hooks, and engine;
# your own registry.json, rules/orchestra-system.md, and the rest of your config
# are preserved.

set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
ORCH_HOME="$CLAUDE_DIR/orchestra"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOK_CMD="bash $CLAUDE_DIR/hooks/orchestra-route.sh"
TELEMETRY_CMD="bash $CLAUDE_DIR/hooks/orchestra-telemetry.sh"
SETTINGS="$CLAUDE_DIR/settings.json"

say() { printf '  %s\n' "$1"; }
echo "🎼 Installing Claude Orchestra v2 into $CLAUDE_DIR"

# --- 0. prerequisites ---------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  echo "✗ 'jq' is required to safely merge settings.json. Install it first:"
  echo "    macOS:  brew install jq"
  echo "    Debian: sudo apt-get install jq"
  exit 1
fi

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/rules" \
         "$ORCH_HOME/bin" "$ORCH_HOME/bench"

# --- 1. skills ----------------------------------------------------------------
# Clean replace: on macOS/BSD `cp -R src dest` NESTS into an existing dest dir
# (creating skills/orchestra-router/orchestra-router) instead of overwriting.
# Removing dest first guarantees a deterministic refresh on every platform.
for s in orchestra-router orchestra-intake; do
  rm -rf "${CLAUDE_DIR:?}/skills/$s"
  cp -R "$REPO_DIR/skills/$s" "$CLAUDE_DIR/skills/$s"
done
say "✓ skills → $CLAUDE_DIR/skills/{orchestra-router,orchestra-intake}"

# --- 2. hooks + engine ----------------------------------------------------------
cp "$REPO_DIR/hooks/orchestra-route.sh"     "$CLAUDE_DIR/hooks/orchestra-route.sh"
cp "$REPO_DIR/hooks/orchestra-telemetry.sh" "$CLAUDE_DIR/hooks/orchestra-telemetry.sh"
chmod +x "$CLAUDE_DIR/hooks/orchestra-route.sh" "$CLAUDE_DIR/hooks/orchestra-telemetry.sh"
say "✓ hooks → $CLAUDE_DIR/hooks/{orchestra-route.sh,orchestra-telemetry.sh}"

cp "$REPO_DIR/bin/orchestra" "$ORCH_HOME/bin/orchestra"
chmod +x "$ORCH_HOME/bin/orchestra"
say "✓ engine → $ORCH_HOME/bin/orchestra"

# --- 3. constitution + registry (yours wins) -----------------------------------
if [ -f "$CLAUDE_DIR/rules/orchestra-system.md" ]; then
  say "• rules/orchestra-system.md already exists — left untouched (yours wins). Template is at:"
  say "  $REPO_DIR/orchestra-system.md"
else
  cp "$REPO_DIR/orchestra-system.md" "$CLAUDE_DIR/rules/orchestra-system.md"
  say "✓ constitution → $CLAUDE_DIR/rules/orchestra-system.md (fill in your tools!)"
fi

if [ -f "$ORCH_HOME/registry.json" ]; then
  say "• orchestra/registry.json already exists — left untouched (yours wins). Template is at:"
  say "  $REPO_DIR/registry/registry.template.json"
else
  cp "$REPO_DIR/registry/registry.template.json" "$ORCH_HOME/registry.json"
  say "✓ registry → $ORCH_HOME/registry.json (fill rosters; see examples/registry-filled.json)"
fi

# --- 4. register hooks in settings.json (safe jq merge) ------------------------
if [ ! -f "$SETTINGS" ]; then
  echo '{}' > "$SETTINGS"
fi
cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d-%H%M%S)"

# 4a. UserPromptSubmit routing hook — match ANY command referencing "orchestra-route"
already="$(jq '
  [.hooks.UserPromptSubmit // [] | .[]? | .hooks[]? | select((.command // "") | test("orchestra-route"))] | length
' "$SETTINGS")"
if [ "$already" -gt 0 ]; then
  say "• routing hook already registered in settings.json — skipped"
else
  tmp="$(mktemp)"
  jq --arg c "$HOOK_CMD" '
    .hooks //= {} |
    .hooks.UserPromptSubmit //= [] |
    .hooks.UserPromptSubmit += [ { "hooks": [ { "type": "command", "command": $c } ] } ]
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  say "✓ routing hook registered in settings.json (backup saved alongside)"
fi

# 4b. PostToolUse telemetry hook (local-only usage log → ranking board)
already="$(jq '
  [.hooks.PostToolUse // [] | .[]? | .hooks[]? | select((.command // "") | test("orchestra-telemetry"))] | length
' "$SETTINGS")"
if [ "$already" -gt 0 ]; then
  say "• telemetry hook already registered in settings.json — skipped"
else
  tmp="$(mktemp)"
  jq --arg c "$TELEMETRY_CMD" '
    .hooks //= {} |
    .hooks.PostToolUse //= [] |
    .hooks.PostToolUse += [ { "matcher": "Skill|Task|Agent", "hooks": [ { "type": "command", "command": $c } ] } ]
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  say "✓ telemetry hook registered in settings.json (PostToolUse, local-only log)"
fi

# --- 5. append the orchestra rule to CLAUDE.md (idempotent) -------------------
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
# Match the rule by its text, not a specific heading level — so an existing
# "### Rule 13 — Orchestra System (NON-NEGOTIABLE)" also counts as already-present.
MARKER="Orchestra System (NON-NEGOTIABLE)"
touch "$CLAUDE_MD"
if grep -qF "$MARKER" "$CLAUDE_MD"; then
  say "• orchestra rule already in CLAUDE.md — skipped"
else
  {
    echo ""
    # Extract the fenced rule block from the snippet file
    awk '/^```markdown$/{f=1;next} /^```$/{if(f)exit} f' "$REPO_DIR/CLAUDE-rule-snippet.md"
  } >> "$CLAUDE_MD"
  say "✓ orchestra rule appended to CLAUDE.md"
fi

# --- 6. first index ------------------------------------------------------------
if "$ORCH_HOME/bin/orchestra" index >/dev/null 2>&1; then
  say "✓ first inventory built — try: $ORCH_HOME/bin/orchestra doctor"
else
  say "• initial index skipped (run '$ORCH_HOME/bin/orchestra index' after filling the registry)"
fi

echo "🎼 Done. Open a new Claude Code session — the router fires on your next prompt."
echo "   Next steps:"
echo "     1. Fill rosters: \$EDITOR $ORCH_HOME/registry.json  (and rules/orchestra-system.md)"
echo "     2. Health check: $ORCH_HOME/bin/orchestra doctor"
echo "     3. Rankings:     $ORCH_HOME/bin/orchestra board && cat $ORCH_HOME/RANKING_BOARD.md"
echo "     4. Optional semantic routing: bun install -g @tobilu/qmd && $ORCH_HOME/bin/orchestra qmd on"
