#!/usr/bin/env bash
# Orchestra System — PostToolUse telemetry hook
#
# Logs every Skill / subagent invocation to ~/.claude/orchestra/usage.jsonl so
# `orchestra board` can rank tools by what you ACTUALLY use, not just by tier.
# Local-only append; nothing leaves your machine. Remove the PostToolUse entry
# from settings.json to disable.

set -u

CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
USAGE_LOG="$CLAUDE_DIR/orchestra/usage.jsonl"

command -v jq >/dev/null 2>&1 || exit 0
mkdir -p "$(dirname "$USAGE_LOG")"

# PostToolUse stdin JSON: {"tool_name": "...", "tool_input": {...}, ...}
# We record skills (Skill tool), subagents (Task/Agent tool), and slash commands.
jq -r '
  [
    (now | floor | tostring),
    (.tool_name // "unknown"),
    (.tool_input.skill // .tool_input.subagent_type // .tool_input.command // "-")
  ] | @tsv
' 2>/dev/null | while IFS=$'\t' read -r ts tool name; do
  [ "$name" = "-" ] && name="$tool"
  printf '{"ts":%s,"name":"%s","event":"fired","via":"%s"}\n' "$ts" "$name" "$tool" >> "$USAGE_LOG"
done
exit 0
