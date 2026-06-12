#!/usr/bin/env bash
#
# Claude Orchestra — installer v3
#
# Installs the full v3 system into your ~/.claude:
#   • Skills: orchestra-router, orchestra-intake, hallucination-guard, skill-selector
#   • Agent:  auditor (㉑ AUDIT conductor)
#   • Hooks:  orchestra-route.sh (UserPromptSubmit, prompt-aware routing)
#             orchestra-telemetry.sh (PostToolUse, local-only usage log → ranking board)
#   • Engine: orchestra/bin/orchestra (index / route / board / doctor / bench / upkeep)
#   • Registry: orchestra/registry.json (machine roster — only if not already present)
#   • Constitution: rules/orchestra-system.md (only if not already present)
#   • CLAUDE.md rule (only if marker not already present)
#   • Scan manifest: .orchestra-scan.md (your installed tools, ready for orchestra-intake)
#
# Flags: --minimal, --guided, --prefix=PATH, --dry-run, --no-hook, --verbose, --help
# Curl-pipe supported: curl -fsSL <raw-url>/install.sh | bash
#
# Idempotent: safe to run more than once. Backs up every file before mutating it.
# Your own registry.json, rules/orchestra-system.md, and CLAUDE.md customizations win.
# Compatible with bash 3.2+ (macOS default). Reverse everything: ./uninstall.sh (UNINSTALL.md).

set -euo pipefail

# ── constants ────────────────────────────────────────────────────────────────
readonly VERSION="3.0.0"
readonly REPO_URL="https://github.com/Momo2323-ui/claude-orchestra.git"
readonly HOOK_NAME="orchestra-route.sh"
readonly TELEMETRY_NAME="orchestra-telemetry.sh"
readonly HOOK_MARKER="orchestra-route"
readonly TELEMETRY_MARKER="orchestra-telemetry"
readonly RULE_MARKER="Orchestra System (NON-NEGOTIABLE)"
STAMP="$(date +%Y%m%d-%H%M%S)"
readonly STAMP

# Full mode = everything. Minimal = the load-bearing routing + safety trio.
SKILLS_FULL=(orchestra-router orchestra-intake hallucination-guard skill-selector)
SKILLS_MINIMAL=(orchestra-router hallucination-guard)
AGENTS_FULL=(auditor)
AGENTS_MINIMAL=(auditor)

# ── defaults (overridable by flags) ──────────────────────────────────────────
MODE="standard"
PREFIX=""
DRY_RUN=0
NO_HOOK=0
VERBOSE=0
PIPE_MODE=0

REPO_DIR=""
CLAUDE_DIR=""
ORCH_HOME=""
SETTINGS=""

# ── output helpers ───────────────────────────────────────────────────────────
say()  { printf '  %s\n' "$1"; }
ok()   { printf '  ✓ %s\n' "$1"; }
skip() { printf '  • %s\n' "$1"; }
warn() { printf '  ⚠ %s\n' "$1" >&2; }
die()  { printf '\n  ✗ %s\n\n' "$1" >&2; exit 1; }
v()    { [[ $VERBOSE -eq 1 ]] && printf '    %s\n' "$1" || true; }

usage() {
  cat <<EOF
Claude Orchestra installer v$VERSION

Usage:
  ./install.sh [flags]
  curl -fsSL <raw-url>/install.sh | bash               # zero-clone install
  curl -fsSL <raw-url>/install.sh | bash -s -- --minimal

Flags:
  --minimal           Only the load-bearing trio: router, hallucination-guard, auditor
                      (+ engine). Skips skill-selector + orchestra-intake.
  --guided            Interactive mode — prompts before each step.
  --prefix=PATH       Install to PATH/.claude instead of ~/.claude.
  --dry-run           Print every action without touching the filesystem.
  --no-hook           Skip wiring hooks into settings.json (manual wiring only).
  --verbose, -v       Extra log output.
  --help, -h          This help.

Idempotent. Backups go alongside every file touched ('.bak.$STAMP').
What gets touched: SECURITY.md. How to reverse: UNINSTALL.md / ./uninstall.sh.
EOF
}

# ── flag parsing ─────────────────────────────────────────────────────────────
parse_flags() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --minimal)   MODE="minimal"; shift ;;
      --guided)    MODE="guided";  shift ;;
      --prefix=*)  PREFIX="${1#*=}"; shift ;;
      --prefix)    [[ $# -lt 2 ]] && die "--prefix needs a path"; PREFIX="$2"; shift 2 ;;
      --dry-run)   DRY_RUN=1;  shift ;;
      --no-hook)   NO_HOOK=1;  shift ;;
      --verbose|-v) VERBOSE=1; shift ;;
      --help|-h)   usage; exit 0 ;;
      --version)   echo "$VERSION"; exit 0 ;;
      *) die "Unknown flag: $1 (use --help)" ;;
    esac
  done
}

# ── curl-pipe detection + temp-clone ─────────────────────────────────────────
detect_repo_dir() {
  local src="${BASH_SOURCE[0]:-}"
  if [[ -z "$src" || "$src" == "bash" || "$src" == "/dev/stdin" ]]; then
    PIPE_MODE=1
    command -v git >/dev/null 2>&1 || die "curl-pipe mode requires 'git'. Clone the repo and run ./install.sh instead."
    local tmp
    tmp="$(mktemp -d)"
    v "Piped install detected — cloning repo to $tmp"
    if [[ $DRY_RUN -eq 1 ]]; then
      skip "[dry-run] would clone $REPO_URL → $tmp"
      REPO_DIR="$tmp"
    else
      git clone --depth 1 --quiet "$REPO_URL" "$tmp" || die "git clone of $REPO_URL failed"
      REPO_DIR="$tmp"
      ok "cloned repo → $tmp"
    fi
  else
    REPO_DIR="$(cd "$(dirname "$src")" && pwd)"
    v "Sourced install — REPO_DIR=$REPO_DIR"
  fi
}

# ── preflight ────────────────────────────────────────────────────────────────
preflight() {
  command -v jq >/dev/null 2>&1 \
    || die "'jq' is required. brew install jq (macOS) | sudo apt-get install jq (Debian/Ubuntu)"

  CLAUDE_DIR="${PREFIX:+$PREFIX/.claude}"
  CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
  ORCH_HOME="$CLAUDE_DIR/orchestra"
  SETTINGS="$CLAUDE_DIR/settings.json"

  local missing=0 s a
  for s in "${SKILLS_FULL[@]}"; do
    [[ -f "$REPO_DIR/skills/$s/SKILL.md" ]] || { warn "missing source: skills/$s/SKILL.md"; missing=1; }
  done
  for a in "${AGENTS_FULL[@]}"; do
    [[ -f "$REPO_DIR/agents/$a.md" ]] || { warn "missing source: agents/$a.md"; missing=1; }
  done
  [[ -f "$REPO_DIR/hooks/$HOOK_NAME" ]]                     || { warn "missing source: hooks/$HOOK_NAME"; missing=1; }
  [[ -f "$REPO_DIR/hooks/$TELEMETRY_NAME" ]]                || { warn "missing source: hooks/$TELEMETRY_NAME"; missing=1; }
  [[ -f "$REPO_DIR/bin/orchestra" ]]                        || { warn "missing source: bin/orchestra"; missing=1; }
  [[ -f "$REPO_DIR/registry/registry.template.json" ]]      || { warn "missing source: registry/registry.template.json"; missing=1; }
  [[ -f "$REPO_DIR/orchestra-system.md" ]]                  || { warn "missing source: orchestra-system.md"; missing=1; }
  [[ -f "$REPO_DIR/CLAUDE-rule-snippet.md" ]]               || { warn "missing source: CLAUDE-rule-snippet.md"; missing=1; }
  [[ $missing -eq 1 ]] && die "Source files missing from REPO_DIR=$REPO_DIR. Run from the repo root (or pipe from the right branch)."

  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would create $CLAUDE_DIR/{skills,agents,hooks,rules} + $ORCH_HOME/{bin,bench}"
  else
    mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/rules" \
             "$ORCH_HOME/bin" "$ORCH_HOME/bench"
  fi
}

# ── guided mode prompts ──────────────────────────────────────────────────────
guided_confirm() {
  [[ "$MODE" != "guided" ]] && return 0
  printf '  ? %s [Y/n]: ' "$1"
  local answer
  read -r answer
  case "${answer:-y}" in
    [Nn]*) skip "skipped by user"; return 1 ;;
    *) return 0 ;;
  esac
}

# ── backup helper ────────────────────────────────────────────────────────────
backup_if_exists() {
  local f="$1"
  [[ ! -e "$f" ]] && return 0
  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would backup $f → $f.bak.$STAMP"
  else
    cp -p "$f" "$f.bak.$STAMP"
    v "backed up $f → $f.bak.$STAMP"
  fi
}

# ── installers ───────────────────────────────────────────────────────────────
install_skill() {
  local skill="$1" src dst
  src="$REPO_DIR/skills/$skill"
  dst="$CLAUDE_DIR/skills/$skill"
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would install skill: $skill"; return; fi
  # `cp -R src dst` nests on macOS/BSD when dst exists — rm first for deterministic refresh.
  [[ -d "$dst" ]] && rm -rf "$dst"
  cp -R "$src" "$dst"
  ok "skill → skills/$skill"
}

install_agent() {
  local agent="$1" src dst
  src="$REPO_DIR/agents/$agent.md"
  dst="$CLAUDE_DIR/agents/$agent.md"
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would install agent: $agent.md"; return; fi
  backup_if_exists "$dst"
  cp "$src" "$dst"
  ok "agent → agents/$agent.md"
}

install_hooks() {
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would install hooks: $HOOK_NAME, $TELEMETRY_NAME"; return; fi
  local h
  for h in "$HOOK_NAME" "$TELEMETRY_NAME"; do
    backup_if_exists "$CLAUDE_DIR/hooks/$h"
    cp "$REPO_DIR/hooks/$h" "$CLAUDE_DIR/hooks/$h"
    chmod +x "$CLAUDE_DIR/hooks/$h"
  done
  ok "hooks → hooks/{$HOOK_NAME,$TELEMETRY_NAME}"
}

install_engine() {
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would install engine → $ORCH_HOME/bin/orchestra"; return; fi
  backup_if_exists "$ORCH_HOME/bin/orchestra"
  cp "$REPO_DIR/bin/orchestra" "$ORCH_HOME/bin/orchestra"
  chmod +x "$ORCH_HOME/bin/orchestra"
  ok "engine → orchestra/bin/orchestra"
}

install_registry() {
  local dst="$ORCH_HOME/registry.json"
  if [[ -f "$dst" ]]; then
    skip "orchestra/registry.json already exists — left untouched (yours wins)"
    skip "  v3 template: $REPO_DIR/registry/registry.template.json · filled example: examples/registry-filled.json"
    return
  fi
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would install registry → $dst"; return; fi
  cp "$REPO_DIR/registry/registry.template.json" "$dst"
  ok "registry → orchestra/registry.json (fill rosters — see examples/registry-filled.json)"
}

install_constitution() {
  local dst="$CLAUDE_DIR/rules/orchestra-system.md"
  if [[ -f "$dst" ]]; then
    skip "rules/orchestra-system.md already exists — left untouched (your customizations win)"
    skip "  v3 template: $REPO_DIR/orchestra-system.md"
    return
  fi
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would install constitution → $dst"; return; fi
  cp "$REPO_DIR/orchestra-system.md" "$dst"
  ok "constitution → rules/orchestra-system.md (v3 template — fill rosters with your tools)"
}

# ── settings.json wiring (safe jq merges) ────────────────────────────────────
register_hook_entry() { # $1 = settings key, $2 = marker, $3 = command, $4 = optional matcher
  local key="$1" marker="$2" cmd="$3" matcher="${4:-}"
  local already tmp
  already="$(jq --arg k "$key" --arg p "$marker" '
    [.hooks[$k] // [] | .[]? | .hooks[]? | select((.command // "") | test($p))] | length
  ' "$SETTINGS")"
  if [[ "$already" -gt 0 ]]; then
    skip "$key hook already wired in settings.json — skipped"
    return
  fi
  tmp="$(mktemp)" || die "mktemp failed — is /tmp writable?"
  if [[ -n "$matcher" ]]; then
    jq --arg k "$key" --arg c "$cmd" --arg m "$matcher" '
      .hooks //= {} | .hooks[$k] //= [] |
      .hooks[$k] += [ { "matcher": $m, "hooks": [ { "type": "command", "command": $c } ] } ]
    ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  else
    jq --arg k "$key" --arg c "$cmd" '
      .hooks //= {} | .hooks[$k] //= [] |
      .hooks[$k] += [ { "hooks": [ { "type": "command", "command": $c } ] } ]
    ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  fi
  ok "$key hook registered in settings.json"
}

register_hooks() {
  [[ $NO_HOOK -eq 1 ]] && { skip "--no-hook set; skipping settings.json wiring"; return; }
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would register UserPromptSubmit + PostToolUse hooks in $SETTINGS"; return; fi
  [[ -f "$SETTINGS" ]] || echo '{}' > "$SETTINGS"
  backup_if_exists "$SETTINGS"
  register_hook_entry "UserPromptSubmit" "$HOOK_MARKER"      "bash $CLAUDE_DIR/hooks/$HOOK_NAME"
  register_hook_entry "PostToolUse"      "$TELEMETRY_MARKER" "bash $CLAUDE_DIR/hooks/$TELEMETRY_NAME" "Skill|Task|Agent"
}

# ── CLAUDE.md rule (idempotent — match by marker text) ───────────────────────
append_claude_md_rule() {
  local md="$CLAUDE_DIR/CLAUDE.md"
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would append CLAUDE.md rule (if marker not present)"; return; fi
  touch "$md"
  if grep -qF "$RULE_MARKER" "$md"; then
    skip "orchestra rule already in CLAUDE.md — skipped"
    return
  fi
  backup_if_exists "$md"
  {
    printf '\n'
    awk '/^```markdown$/{f=1;next} /^```$/{if(f)exit} f' "$REPO_DIR/CLAUDE-rule-snippet.md"
  } >> "$md"
  ok "orchestra rule appended to CLAUDE.md"
}

# ── scan existing setup → classification manifest for orchestra-intake ───────
scan_existing_setup() {
  local scan="$CLAUDE_DIR/.orchestra-scan.md"
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would write inventory → $scan"; return; fi
  {
    printf '# Orchestra scan — generated %s\n\n' "$STAMP"
    printf 'Inventory of tools detected in `%s`. First-run: ask Claude to run orchestra-intake on this file to classify everything into orchestras and update the constitution + registry.\n\n' "$CLAUDE_DIR"
    printf '## Skills (%s found)\n\n' "$(find "$CLAUDE_DIR/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
    local skill_dir name desc agent_file aname adesc plugin_dir
    for skill_dir in "$CLAUDE_DIR/skills"/*/; do
      [[ ! -d "$skill_dir" ]] && continue
      name="$(basename "$skill_dir")"
      desc="$(awk '/^description:/{sub(/^description:[ ]*/,""); print; exit}' "$skill_dir/SKILL.md" 2>/dev/null || true)"
      printf -- '- **%s** — %s\n' "$name" "${desc:-(no description)}"
    done
    printf '\n## Agents (%s found)\n\n' "$(find "$CLAUDE_DIR/agents" -maxdepth 1 -mindepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
    for agent_file in "$CLAUDE_DIR/agents"/*.md; do
      [[ ! -f "$agent_file" ]] && continue
      aname="$(basename "$agent_file" .md)"
      adesc="$(awk '/^description:/{sub(/^description:[ ]*"?/,""); sub(/"[ ]*$/,""); print; exit}' "$agent_file" 2>/dev/null || true)"
      printf -- '- **%s** — %s\n' "$aname" "${adesc:-(no description)}"
    done
    if [[ -d "$CLAUDE_DIR/plugins" ]]; then
      printf '\n## Plugins (%s found)\n\n' "$(find "$CLAUDE_DIR/plugins" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
      for plugin_dir in "$CLAUDE_DIR/plugins"/*/; do
        [[ ! -d "$plugin_dir" ]] && continue
        printf -- '- **%s**\n' "$(basename "$plugin_dir")"
      done
    fi
  } > "$scan"
  ok "scan manifest → $scan"
}

# ── first index ──────────────────────────────────────────────────────────────
first_index() {
  if [[ $DRY_RUN -eq 1 ]]; then skip "[dry-run] would run first inventory: orchestra index"; return; fi
  if CLAUDE_DIR="$CLAUDE_DIR" "$ORCH_HOME/bin/orchestra" index >/dev/null 2>&1; then
    ok "first inventory built (orchestra index)"
  else
    skip "initial index skipped — run '$ORCH_HOME/bin/orchestra index' after filling the registry"
  fi
}

# ── final messages ───────────────────────────────────────────────────────────
print_first_run() {
  cat <<EOF

  ────────────────────────────────────────────────────────────────────────
  🎼 Claude Orchestra v$VERSION installed.   Mode: $MODE → $CLAUDE_DIR
  ────────────────────────────────────────────────────────────────────────

  NEXT STEPS

  1. Restart Claude Code (new session) so the hooks load. The router fires
     on your next prompt.

  2. First-run classification — in your next Claude session say:

       Use orchestra-intake to classify everything in
       $CLAUDE_DIR/.orchestra-scan.md into the right orchestras,
       creating new orchestras where coherent niches appear, and update
       both rules/orchestra-system.md and orchestra/registry.json.

  3. Health check + rankings:

       $ORCH_HOME/bin/orchestra doctor
       $ORCH_HOME/bin/orchestra board && cat $ORCH_HOME/RANKING_BOARD.md

  4. Optional semantic routing (paraphrase-proof, fully local):

       bun install -g @tobilu/qmd
       $ORCH_HOME/bin/orchestra index && $ORCH_HOME/bin/orchestra qmd on

  Every file touched has a backup ('.bak.$STAMP'). Reverse: ./uninstall.sh
  ────────────────────────────────────────────────────────────────────────

EOF
}

# ── main ─────────────────────────────────────────────────────────────────────
main() {
  parse_flags "$@"

  echo
  echo "🎼 Claude Orchestra installer v$VERSION"
  [[ $DRY_RUN -eq 1 ]] && echo "   (DRY RUN — no filesystem changes will be made)"
  echo

  detect_repo_dir
  preflight

  say "Target: $CLAUDE_DIR  (mode: $MODE)"
  [[ $PIPE_MODE -eq 1 ]] && say "(curl-pipe install — repo cloned to a temp dir)"
  echo

  local skills_to_install agents_to_install s a
  if [[ "$MODE" == "minimal" ]]; then
    skills_to_install=("${SKILLS_MINIMAL[@]}")
    agents_to_install=("${AGENTS_MINIMAL[@]}")
  else
    skills_to_install=("${SKILLS_FULL[@]}")
    agents_to_install=("${AGENTS_FULL[@]}")
  fi

  guided_confirm "Install skills: ${skills_to_install[*]}" || true
  for s in "${skills_to_install[@]}"; do install_skill "$s"; done

  guided_confirm "Install agents: ${agents_to_install[*]}" || true
  for a in "${agents_to_install[@]}"; do install_agent "$a"; done

  guided_confirm "Install hooks (routing + telemetry)"          && install_hooks
  guided_confirm "Install the score engine"                     && install_engine
  guided_confirm "Install registry template (if missing)"       && install_registry
  guided_confirm "Install constitution template (if missing)"   && install_constitution
  guided_confirm "Register hooks in settings.json"              && register_hooks
  guided_confirm "Append orchestra rule to CLAUDE.md (if missing)" && append_claude_md_rule
  guided_confirm "Scan existing setup → classification manifest" && scan_existing_setup
  guided_confirm "Build first inventory (orchestra index)"      && first_index

  print_first_run
}

main "$@"
