#!/usr/bin/env bash
#
# Claude Orchestra — uninstaller
# Reverses everything install.sh did, safely:
#   • removes the two managed skills + both hooks + the engine binary
#   • removes BOTH hook entries from settings.json (jq surgery, auto-backup first)
#   • removes the appended Orchestra rule block from CLAUDE.md (only the exact block)
#   • promotes any benched skills back into ~/.claude/skills so nothing is lost
#
# Your data survives by default: registry.json, usage.jsonl, inventory, board, and
# rules/orchestra-system.md are KEPT (they're yours). Add --purge to delete those too.

set -euo pipefail

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
ORCH_HOME="$CLAUDE_DIR/orchestra"
SETTINGS="$CLAUDE_DIR/settings.json"
PURGE=0
[ "${1:-}" = "--purge" ] && PURGE=1

say() { printf '  %s\n' "$1"; }
echo "🎼 Uninstalling Claude Orchestra from $CLAUDE_DIR"

if ! command -v jq >/dev/null 2>&1; then
  echo "✗ 'jq' is required to safely edit settings.json (same as install)."
  exit 1
fi

# --- 1. promote benched skills back (nothing is lost) --------------------------
if [ -d "$ORCH_HOME/bench" ]; then
  for d in "$ORCH_HOME"/bench/*/; do
    [ -d "$d" ] || continue
    s="$(basename "$d")"
    if [ -e "$CLAUDE_DIR/skills/$s" ]; then
      say "• bench/$s NOT promoted — skills/$s already exists (left in bench)"
    else
      mv "$d" "$CLAUDE_DIR/skills/$s"
      say "✓ promoted bench/$s back to skills/$s"
    fi
  done
fi

# --- 2. remove managed skills, agent, hooks, engine ----------------------------
rm -rf "${CLAUDE_DIR:?}/skills/orchestra-router" "${CLAUDE_DIR:?}/skills/orchestra-intake" \
       "${CLAUDE_DIR:?}/skills/hallucination-guard" "${CLAUDE_DIR:?}/skills/skill-selector"
rm -f "$CLAUDE_DIR/agents/auditor.md"
rm -f "$CLAUDE_DIR/hooks/orchestra-route.sh" "$CLAUDE_DIR/hooks/orchestra-telemetry.sh"
rm -f "$CLAUDE_DIR/.orchestra-scan.md"
rm -f "$ORCH_HOME/bin/orchestra"
rmdir "$ORCH_HOME/bin" 2>/dev/null || true
say "✓ removed managed skills, the auditor agent, hooks, and the engine"

# --- 3. remove our hook entries from settings.json -----------------------------
if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.bak.$(date +%Y%m%d-%H%M%S)"
  tmp="$(mktemp)"
  jq '
    def strip(arr; pat):
      [ (arr // [])[]
        | .hooks = [ .hooks[]? | select((.command // "") | test(pat) | not) ]
        | select((.hooks | length) > 0) ];
    .hooks.UserPromptSubmit = strip(.hooks.UserPromptSubmit; "orchestra-route") |
    .hooks.PostToolUse      = strip(.hooks.PostToolUse;      "orchestra-telemetry") |
    (if .hooks.UserPromptSubmit == [] then del(.hooks.UserPromptSubmit) else . end) |
    (if .hooks.PostToolUse      == [] then del(.hooks.PostToolUse)      else . end) |
    (if .hooks == {} then del(.hooks) else . end)
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  say "✓ hook entries removed from settings.json (backup saved alongside)"
fi

# --- 4. remove the appended rule block from CLAUDE.md ---------------------------
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
MARKER="Orchestra System (NON-NEGOTIABLE)"
if [ -f "$CLAUDE_MD" ] && grep -qF "$MARKER" "$CLAUDE_MD"; then
  tmp="$(mktemp)"
  # Delete from the marker heading up to (not including) the next heading,
  # or to EOF — exactly the shape the installer appends.
  awk -v marker="$MARKER" '
    index($0, marker) && /^#/ { skip = 1; next }
    skip && /^#/ { skip = 0 }
    !skip { print }
  ' "$CLAUDE_MD" > "$tmp" && mv "$tmp" "$CLAUDE_MD"
  say "✓ orchestra rule removed from CLAUDE.md"
else
  say "• no orchestra rule found in CLAUDE.md — skipped"
fi

# --- 5. data: keep by default, delete on --purge --------------------------------
if [ "$PURGE" -eq 1 ]; then
  rm -rf "$ORCH_HOME"
  rm -f "$CLAUDE_DIR/rules/orchestra-system.md"
  say "✓ purged $ORCH_HOME and rules/orchestra-system.md"
else
  say "• kept your data: $ORCH_HOME (registry, usage log, board) and rules/orchestra-system.md"
  say "  run './uninstall.sh --purge' to delete those too"
fi

echo "🎼 Done. Open a new Claude Code session for the hook removal to take effect."
