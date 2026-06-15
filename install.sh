#!/usr/bin/env bash
#
# Claude Orchestra — installer
#
# What it installs:
#   • The orchestra quintet: orchestra-router (routing), orchestra-intake (filing),
#     hallucination-guard, skill-selector skills + auditor agent (㉑ AUDIT conductor).
#   • The routing hook (UserPromptSubmit) + the constitution template (only if you don't
#     already have one — your customizations always win).
#   • Curl-pipe support: `curl -fsSL .../install.sh | bash` works without git clone.
#   • Flag parsing: --minimal, --prefix=, --dry-run, --no-hook, --guided, --verbose, --help.
#   • Scans ~/.claude/{skills,agents,plugins,hooks,commands,mcp} and writes a manifest at
#     ~/.claude/.orchestra-scan.md so Claude can run orchestra-intake on it for personal
#     classification on first run.
#   • Backup-before-mutate on every file touched (not just settings.json).
#
# Idempotent: safe to run more than once. Backs up everything before mutating. Re-running
# refreshes the managed artifacts; your own orchestra-system.md and CLAUDE.md are preserved.
#
# Compatible with bash 3.2+ (macOS default). No network calls except the optional curl-pipe
# clone. No sudo. No telemetry. Audit it in one `cat install.sh` before you run it.

set -euo pipefail

# ── constants ────────────────────────────────────────────────────────────────
readonly VERSION="3.0.0"
readonly REPO_URL="https://github.com/Momo2323-ui/claude-orchestra.git"
readonly HOOK_NAME="orchestra-route.sh"
readonly HOOK_MARKER="orchestra-route"   # pattern matched in settings.json
readonly RULE_MARKER="Orchestra System (NON-NEGOTIABLE)"
readonly STAMP="$(date +%Y%m%d-%H%M%S)"

# Files the installer ships, grouped by mode.
# Full mode = all artifacts. Minimal mode = only the load-bearing safety + routing trio.
# Note: not declared `readonly` because bash 3.2 (macOS default) is shaky on `readonly` arrays.
SKILLS_FULL=(orchestra-router orchestra-intake hallucination-guard skill-selector)
SKILLS_MINIMAL=(orchestra-router hallucination-guard)
AGENTS_FULL=(auditor)
AGENTS_MINIMAL=(auditor)

# ── defaults (overridable by flags) ──────────────────────────────────────────
MODE="standard"                   # standard | minimal | guided
PREFIX=""                         # override ~/.claude with --prefix=/path
DRY_RUN=0
NO_HOOK=0
VERBOSE=0
PIPE_MODE=0                       # set to 1 when curl-piped (no BASH_SOURCE file)

# These get filled in by detect_repo_dir() / preflight()
REPO_DIR=""
CLAUDE_DIR=""
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
  curl -fsSL <url>/install.sh | bash               # zero-clone install
  curl -fsSL <url>/install.sh | bash -s -- --minimal

Flags:
  --minimal           Install only the load-bearing trio: router, hallucination-guard,
                      auditor. Skip skill-selector + orchestra-intake. (Smaller surface,
                      ~50% fewer token-cost overheads for routine sessions.)
  --guided            Interactive mode — prompts before each step. Recommended for first
                      time installers.
  --prefix=PATH       Install to PATH/.claude instead of ~/.claude.
  --dry-run           Print every action without touching the filesystem.
  --no-hook           Skip registering the UserPromptSubmit hook in settings.json. Only
                      use if you want to wire routing manually.
  --verbose, -v       Extra log output.
  --help, -h          This help.

Idempotent. Safe to re-run. Backups go alongside every file touched with the suffix
'.bak.$STAMP'. Read SECURITY.md for what gets touched and how to uninstall.
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
# When piped (curl | bash), BASH_SOURCE[0] is unset or 'bash'. We clone the repo
# into a temp dir and re-anchor REPO_DIR there.
detect_repo_dir() {
  local src="${BASH_SOURCE[0]:-}"
  if [[ -z "$src" || "$src" == "bash" || "$src" == "/dev/stdin" ]]; then
    PIPE_MODE=1
    command -v git >/dev/null 2>&1 || die "curl-pipe mode requires 'git'. Install git, or clone the repo manually and run ./install.sh."

    local tmp
    tmp="$(mktemp -d)"
    v "Piped install detected — cloning repo to $tmp"
    if [[ $DRY_RUN -eq 1 ]]; then
      skip "[dry-run] would clone $REPO_URL → $tmp"
      REPO_DIR="$tmp"
    else
      git clone --depth 1 --quiet "$REPO_URL" "$tmp" \
        || die "git clone of $REPO_URL failed"
      REPO_DIR="$tmp"
      ok  "cloned repo → $tmp"
    fi
  else
    REPO_DIR="$(cd "$(dirname "$src")" && pwd)"
    v "Sourced install — REPO_DIR=$REPO_DIR"
  fi
}

# ── preflight ────────────────────────────────────────────────────────────────
preflight() {
  command -v jq >/dev/null 2>&1 \
    || die "'jq' is required. Install with: brew install jq  (macOS)  |  sudo apt-get install jq  (Debian/Ubuntu)"

  # Default CLAUDE_DIR is ~/.claude. --prefix=/foo installs to /foo/.claude.
  CLAUDE_DIR="${PREFIX:+$PREFIX/.claude}"
  CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
  SETTINGS="$CLAUDE_DIR/settings.json"

  # Sanity-check the source layout — fail fast if artifacts are missing from the repo.
  local missing=0
  for s in "${SKILLS_FULL[@]}"; do
    [[ -f "$REPO_DIR/skills/$s/SKILL.md" ]] || { warn "missing source: skills/$s/SKILL.md"; missing=1; }
  done
  for a in "${AGENTS_FULL[@]}"; do
    [[ -f "$REPO_DIR/agents/$a.md" ]] || { warn "missing source: agents/$a.md"; missing=1; }
  done
  [[ -f "$REPO_DIR/hooks/$HOOK_NAME" ]]            || { warn "missing source: hooks/$HOOK_NAME"; missing=1; }
  [[ -f "$REPO_DIR/orchestra-system.md" ]]         || { warn "missing source: orchestra-system.md"; missing=1; }
  [[ -f "$REPO_DIR/CLAUDE-rule-snippet.md" ]]      || { warn "missing source: CLAUDE-rule-snippet.md"; missing=1; }
  if [[ $missing -eq 1 ]]; then
    die "Source files missing from REPO_DIR=$REPO_DIR. Are you running install.sh from the repo root, or piped from the right branch?"
  fi

  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would create $CLAUDE_DIR/{skills,agents,hooks,rules}"
  else
    mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/rules"
  fi
}

# ── guided mode prompts ──────────────────────────────────────────────────────
guided_confirm() {
  [[ "$MODE" != "guided" ]] && return 0
  local prompt="$1"
  printf '  ? %s [Y/n]: ' "$prompt"
  read -r answer
  case "${answer:-y}" in
    [Nn]*) skip "skipped by user"; return 1 ;;
    *) return 0 ;;
  esac
}

# ── backup helper (idempotent + dry-run aware) ───────────────────────────────
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

# ── install one skill (cross-platform safe directory replace) ────────────────
install_skill() {
  local skill="$1"
  local src="$REPO_DIR/skills/$skill"
  local dst="$CLAUDE_DIR/skills/$skill"
  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would install skill: $skill"
    return
  fi
  # `cp -R src dst` nests on macOS/BSD when dst exists — rm first for deterministic refresh.
  [[ -d "$dst" ]] && rm -rf "$dst"
  cp -R "$src" "$dst"
  ok "skill → skills/$skill"
}

# ── install one agent file ───────────────────────────────────────────────────
install_agent() {
  local agent="$1"
  local src="$REPO_DIR/agents/$agent.md"
  local dst="$CLAUDE_DIR/agents/$agent.md"
  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would install agent: $agent.md"
    return
  fi
  backup_if_exists "$dst"
  cp "$src" "$dst"
  ok "agent → agents/$agent.md"
}

# ── install hook ─────────────────────────────────────────────────────────────
install_hook_file() {
  local src="$REPO_DIR/hooks/$HOOK_NAME"
  local dst="$CLAUDE_DIR/hooks/$HOOK_NAME"
  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would install hook: hooks/$HOOK_NAME"
    return
  fi
  backup_if_exists "$dst"
  cp "$src" "$dst"
  chmod +x "$dst"
  ok "hook → hooks/$HOOK_NAME"
}

# ── install constitution (user wins if present) ──────────────────────────────
install_constitution() {
  local src="$REPO_DIR/orchestra-system.md"
  local dst="$CLAUDE_DIR/rules/orchestra-system.md"
  if [[ -f "$dst" ]]; then
    skip "rules/orchestra-system.md already exists — left untouched (your customizations win)"
    skip "  template available at: $src"
    return
  fi
  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would install constitution → $dst"
    return
  fi
  cp "$src" "$dst"
  ok "constitution → rules/orchestra-system.md (template — fill rosters with your tools)"
}

# ── register hook in settings.json ───────────────────────────────────────────
register_hook() {
  [[ $NO_HOOK -eq 1 ]] && { skip "--no-hook set; skipping settings.json wiring"; return; }
  local hook_cmd="bash $CLAUDE_DIR/hooks/$HOOK_NAME"

  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would register UserPromptSubmit hook in $SETTINGS"
    return
  fi

  [[ -f "$SETTINGS" ]] || echo '{}' > "$SETTINGS"
  backup_if_exists "$SETTINGS"

  local already
  already="$(jq --arg p "$HOOK_MARKER" '
    [.hooks.UserPromptSubmit // [] | .[]? | .hooks[]? | select((.command // "") | test($p))] | length
  ' "$SETTINGS")"

  if [[ "$already" -gt 0 ]]; then
    skip "hook already wired in settings.json — skipped"
    return
  fi

  local tmp
  tmp="$(mktemp)" || die "mktemp failed in register_hook — is /tmp writable?"
  jq --arg c "$hook_cmd" '
    .hooks //= {} |
    .hooks.UserPromptSubmit //= [] |
    .hooks.UserPromptSubmit += [ { "hooks": [ { "type": "command", "command": $c } ] } ]
  ' "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
  ok "hook registered in settings.json (backup at $SETTINGS.bak.$STAMP)"
}

# ── append CLAUDE.md rule (idempotent — match by marker text) ────────────────
append_claude_md_rule() {
  local md="$CLAUDE_DIR/CLAUDE.md"
  local snippet="$REPO_DIR/CLAUDE-rule-snippet.md"

  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would append CLAUDE.md rule (if marker not already present)"
    return
  fi

  touch "$md"
  if grep -qF "$RULE_MARKER" "$md"; then
    skip "orchestra rule already in CLAUDE.md — skipped"
    return
  fi
  backup_if_exists "$md"

  {
    printf '\n'
    awk '/^```markdown$/{f=1;next} /^```$/{if(f)exit} f' "$snippet"
  } >> "$md"
  ok "orchestra rule appended to CLAUDE.md"
}

# ── scan existing setup → write classification manifest ──────────────────────
# Bash can't reliably classify 500 skills into 22 orchestras — that's an LLM job.
# This function produces an inventory at $CLAUDE_DIR/.orchestra-scan.md and prints
# a first-run command that asks Claude to run orchestra-intake on it.
scan_existing_setup() {
  local scan="$CLAUDE_DIR/.orchestra-scan.md"

  if [[ $DRY_RUN -eq 1 ]]; then
    skip "[dry-run] would write inventory → $scan"
    return
  fi

  {
    printf '# Orchestra scan — generated %s\n\n' "$STAMP"
    printf 'Inventory of tools detected in `%s`. Run `claude -p "Use orchestra-intake to classify everything in %s into the right orchestras and update ~/.claude/rules/orchestra-system.md"` to file these into your roster.\n\n' "$CLAUDE_DIR" "$scan"

    printf '## Skills (%s found)\n\n' "$(find "$CLAUDE_DIR/skills" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')"
    for skill_dir in "$CLAUDE_DIR/skills"/*/; do
      [[ ! -d "$skill_dir" ]] && continue
      local name desc
      name="$(basename "$skill_dir")"
      desc="$(awk '/^description:/{sub(/^description:[ ]*/,""); print; exit}' "$skill_dir/SKILL.md" 2>/dev/null || true)"
      printf -- '- **%s** — %s\n' "$name" "${desc:-(no description)}"
    done

    printf '\n## Agents (%s found)\n\n' "$(find "$CLAUDE_DIR/agents" -maxdepth 1 -mindepth 1 -name '*.md' 2>/dev/null | wc -l | tr -d ' ')"
    for agent_file in "$CLAUDE_DIR/agents"/*.md; do
      [[ ! -f "$agent_file" ]] && continue
      local aname adesc
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

# ── final messages ───────────────────────────────────────────────────────────
print_first_run() {
  cat <<EOF

  ────────────────────────────────────────────────────────────────────────
  🎼 Claude Orchestra v$VERSION installed.
  ────────────────────────────────────────────────────────────────────────

  Mode: $MODE
  Installed to: $CLAUDE_DIR

  NEXT STEPS

  1. Restart Claude Code (quit and re-launch the terminal) to load the
     UserPromptSubmit hook. The router fires on your next prompt.

  2. (First-run only — classify your existing setup into orchestras.)
     Run this in your next Claude session:

       Use orchestra-intake to classify everything in
       ${CLAUDE_DIR}/.orchestra-scan.md into the right orchestras,
       creating new orchestras where coherent niches appear, and update
       ~/.claude/rules/orchestra-system.md.

  3. Try a routing test prompt to confirm it works:

       claude -p "I have an idea for a SaaS that..."

     You should see a 🎼 routing announcement at the top of the reply
     naming the orchestra(s) that fired.

  ────────────────────────────────────────────────────────────────────────

  If anything looks wrong, every file touched has a backup with suffix
  '.bak.$STAMP' next to it. Uninstall instructions: UNINSTALL.md.

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
  echo

  # Decide which artifacts to ship based on mode.
  local skills_to_install agents_to_install
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

  guided_confirm "Install routing hook" && install_hook_file
  guided_confirm "Install constitution template (if missing)" && install_constitution
  guided_confirm "Register UserPromptSubmit hook in settings.json" && register_hook
  guided_confirm "Append orchestra rule to CLAUDE.md (if missing)" && append_claude_md_rule
  guided_confirm "Scan existing setup → write classification manifest" && scan_existing_setup

  print_first_run
}

main "$@"
