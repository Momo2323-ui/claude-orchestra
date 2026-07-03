#!/usr/bin/env python3
"""
build-skill-index.py — Single source of truth for the Claude Code skill catalog.

What it does:
  1. Scans all SKILL.md files (local ~/.claude/skills/ + plugin ~/.claude/plugins/)
  2. Writes compact discovery stubs to ~/.claude/.skill-index/
     (name + description only — keeps qmd matching on discoverability text)
  3. Registers/updates the qmd "skills" collection (local GPU, zero API token cost)
  4. Regenerates ~/.claude/.orchestra-scan.md (full, untruncated, all classes)
  5. Writes a signature file so the freshness guard can detect changes cheaply

Usage:
  build-skill-index.py             — full build
  build-skill-index.py --dry-run   — show counts, don't write anything
  build-skill-index.py --scan-only — regenerate .orchestra-scan.md only (no qmd)
  build-skill-index.py --no-embed  — write stubs + update index but skip qmd embed step

Called by:
  - orchestra-intake skill (after filing a new install)
  - skill-index-refresh.js SessionStart hook (when signature changed)
  - Manually: ~/.claude/scripts/build-skill-index.sh
"""

import os
import sys
import re
import shutil
import subprocess
import hashlib
import datetime
from pathlib import Path
from typing import Optional

# ── Config ────────────────────────────────────────────────────────────────────
CLAUDE_DIR = Path(os.environ.get("CLAUDE_DIR", Path.home() / ".claude"))
SKILL_INDEX_DIR = CLAUDE_DIR / ".skill-index"
SCAN_FILE = CLAUDE_DIR / ".orchestra-scan.md"
SIG_FILE = SKILL_INDEX_DIR / ".signature"

DRY_RUN    = "--dry-run"   in sys.argv
SCAN_ONLY  = "--scan-only" in sys.argv
NO_EMBED   = "--no-embed"  in sys.argv

# ── Helpers ───────────────────────────────────────────────────────────────────
def log(msg):  print(f"  [skill-index] {msg}", flush=True)
def ok(msg):   print(f"  ✓ [skill-index] {msg}", flush=True)
def warn(msg): print(f"  ⚠ [skill-index] {msg}", file=sys.stderr, flush=True)


def extract_description(skill_md: Path) -> str:
    """
    Extract the `description:` field from YAML frontmatter.
    Handles single-line, quoted, and block-scalar (|/>) forms.
    Returns '(no description)' if not found.
    """
    try:
        text = skill_md.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return "(no description)"

    lines = text.splitlines()
    # Find frontmatter block (between first two ---'s)
    if not lines or lines[0].strip() != "---":
        return "(no description)"

    in_front = False
    front_lines = []
    for i, line in enumerate(lines):
        if i == 0:
            in_front = True
            continue
        if line.strip() == "---":
            break
        if in_front:
            front_lines.append(line)

    front = "\n".join(front_lines)

    # Try block scalar first (must precede plain-line match, which would
    # otherwise capture the bare |/> indicator as the value)
    m = re.search(r'^description:\s*[|>][+\-]?\s*\n((?:[ \t]+.+\n?)+)', front, re.MULTILINE)
    if m:
        block = m.group(1)
        # Strip common leading whitespace
        stripped_lines = [l.strip() for l in block.splitlines() if l.strip()]
        return " ".join(stripped_lines)

    # Plain or quoted single line — tolerates embedded double quotes
    # (trigger phrases like: Triggers on "deep research") — plus indented
    # YAML plain-scalar continuation lines
    m = re.search(r'^description:[ \t]*(\S.*)$((?:\n[ \t]+\S.*)*)', front, re.MULTILINE)
    if m:
        first = m.group(1).strip()
        cont = [l.strip() for l in m.group(2).splitlines() if l.strip()]
        value = " ".join([first] + cont).strip()
        # Strip only symmetric surrounding quotes, never embedded ones
        if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
            value = value[1:-1].strip()
        if value:
            return value

    return "(no description)"


def parse_version(version_str: str):
    """Parse semver-like version string into comparable tuple."""
    parts = re.split(r'[.\-]', version_str)
    result = []
    for p in parts:
        try:
            result.append(int(p))
        except ValueError:
            result.append(0)
    return tuple(result)


# ── Phase 1: Scan all SKILL.md files ─────────────────────────────────────────
log("Scanning skill catalog…")

# skills dict: key → {name, description, source_path, namespace, display_key}
# key is the stub filename (without .md)
skills = {}

# --- 1a. Local skills (folder-based) ---
# Only go maxdepth 2 to get skills/*/SKILL.md — avoids flat *.md duplicates at root
local_count = 0
skills_dir = CLAUDE_DIR / "skills"
if skills_dir.exists():
    for skill_md in sorted(skills_dir.glob("*/SKILL.md")):
        name = skill_md.parent.name
        desc = extract_description(skill_md)
        key = f"local__{name}"
        skills[key] = {
            "name": name,
            "description": desc,
            "source_path": str(skill_md),
            "namespace": "local",
            "display_key": name,
        }
        local_count += 1

# --- 1b. Plugin skills (cache) ---
# Path: .../plugins/cache/<marketplace>/<plugin>/<version>/skills/<skill>/SKILL.md
# Deduplicate by (plugin, skill) keeping highest semver version.
plugin_cache_dir = CLAUDE_DIR / "plugins" / "cache"
plugin_cache_best = {}  # (plugin, skill) → (version_tuple, skill_md, marketplace)

if plugin_cache_dir.exists():
    for skill_md in plugin_cache_dir.rglob("skills/*/SKILL.md"):
        parts = skill_md.relative_to(plugin_cache_dir).parts
        # parts: marketplace / plugin / version / skills / skill_name / SKILL.md
        if len(parts) < 6:
            continue
        marketplace, plugin_name, version_str = parts[0], parts[1], parts[2]
        skill_name = parts[4]
        ver = parse_version(version_str)
        k = (plugin_name, skill_name)
        existing = plugin_cache_best.get(k)
        if existing is None or ver > existing[0]:
            plugin_cache_best[k] = (ver, skill_md, marketplace)

plugin_cache_count = 0
for (plugin_name, skill_name), (_, skill_md, marketplace) in sorted(plugin_cache_best.items()):
    desc = extract_description(skill_md)
    key = f"{plugin_name}__{skill_name}"
    # If local skill has same key, plugin variant wins (plugin is more specific)
    skills[key] = {
        "name": skill_name,
        "description": desc,
        "source_path": str(skill_md),
        "namespace": f"plugin:{marketplace}",
        "display_key": f"{plugin_name}:{skill_name}",
    }
    plugin_cache_count += 1

# --- 1c. Plugin marketplace skills ---
# Path: .../plugins/marketplaces/<owner>/<repo>/skills/<skill>/SKILL.md
plugin_mkt_dir = CLAUDE_DIR / "plugins" / "marketplaces"
plugin_mkt_count = 0
if plugin_mkt_dir.exists():
    for skill_md in sorted(plugin_mkt_dir.rglob("skills/*/SKILL.md")):
        parts = skill_md.relative_to(plugin_mkt_dir).parts
        # parts: owner / repo / skills / skill_name / SKILL.md
        if len(parts) < 5:
            continue
        repo_name = parts[1]
        skill_name = parts[3]
        desc = extract_description(skill_md)
        key = f"{repo_name}__{skill_name}"
        if key not in skills:  # don't clobber cache (versioned) entries
            skills[key] = {
                "name": skill_name,
                "description": desc,
                "source_path": str(skill_md),
                "namespace": "plugin:marketplace",
                "display_key": f"{repo_name}:{skill_name}",
            }
            plugin_mkt_count += 1

total = len(skills)
log(f"Found: {local_count} local + {plugin_cache_count} plugin-cache + {plugin_mkt_count} plugin-marketplace = {total} unique skills")

if DRY_RUN:
    log(f"[dry-run] would write {total} stubs → {SKILL_INDEX_DIR}")
    sys.exit(0)

# ── Phase 2: Write discovery stubs ───────────────────────────────────────────
if not SCAN_ONLY:
    SKILL_INDEX_DIR.mkdir(parents=True, exist_ok=True)

    # Prune stubs for removed skills
    pruned = 0
    for existing_stub in SKILL_INDEX_DIR.glob("*.md"):
        if existing_stub.name == ".signature":
            continue
        stub_key = existing_stub.stem
        if stub_key not in skills:
            existing_stub.unlink()
            pruned += 1
    if pruned:
        log(f"Pruned {pruned} stale stubs")

    # Write/update stubs (only if content changed → stable mtime → stable signature)
    written = 0
    for key, info in skills.items():
        stub = SKILL_INDEX_DIR / f"{key}.md"
        content = (
            f"# {info['name']}\n"
            f"Source: {info['source_path']}\n"
            f"Namespace: {info['namespace']}\n\n"
            f"{info['description']}\n"
        )
        existing = stub.read_text(encoding="utf-8") if stub.exists() else ""
        if content != existing:
            stub.write_text(content, encoding="utf-8")
            written += 1

    ok(f"Stubs: {written} written/updated, {total - written} unchanged → {SKILL_INDEX_DIR}")

    # ── Phase 3: Register qmd collection and update index ──────────────────
    # Resolve qmd robustly — hook environments may have a trimmed PATH
    qmd = shutil.which("qmd") or "/usr/local/bin/qmd"
    qmd_config = Path.home() / ".config" / "qmd" / "index.yml"
    qmd_available = Path(qmd).is_file()

    if qmd_available:
        # Register collection by directly writing to qmd config YAML.
        # We do NOT use `qmd collection add` because it resolves hidden paths incorrectly
        # (e.g. drops ".claude" from the path on macOS).
        needs_register = True
        if qmd_config.exists():
            config_text = qmd_config.read_text(encoding="utf-8")
            needs_register = "skills:" not in config_text

        if needs_register:
            log("Registering qmd 'skills' collection in config YAML…")
            # Append skills collection entry to existing config
            collection_entry = (
                f"  skills:\n"
                f"    path: {SKILL_INDEX_DIR}\n"
                f"    pattern: \"*.md\"\n"
            )
            config_text = qmd_config.read_text(encoding="utf-8") if qmd_config.exists() else "collections:\n"
            if "collections:" not in config_text:
                config_text = "collections:\n" + config_text
            config_text = config_text.rstrip() + "\n" + collection_entry
            qmd_config.write_text(config_text, encoding="utf-8")
            ok(f"qmd collection 'skills' registered → {SKILL_INDEX_DIR}")
        else:
            # Ensure the path is correct even if it was registered before
            config_text = qmd_config.read_text(encoding="utf-8")
            correct_path = str(SKILL_INDEX_DIR)
            if correct_path not in config_text:
                log("Fixing qmd 'skills' collection path…")
                # Replace any existing skills path line
                config_text = re.sub(
                    r'(  skills:\n    path: )[^\n]+',
                    f'\\g<1>{correct_path}',
                    config_text
                )
                qmd_config.write_text(config_text, encoding="utf-8")
                ok(f"qmd 'skills' collection path corrected → {correct_path}")
            else:
                log("qmd 'skills' collection already registered (path OK)")

        if not NO_EMBED:
            log("Running qmd update (incremental re-index)…")
            try:
                result = subprocess.run(
                    [qmd, "update"],
                    capture_output=True, text=True, timeout=1800
                )
                # Show last few lines of output
                output_lines = (result.stdout + result.stderr).strip().splitlines()
                for line in output_lines[-4:]:
                    if line.strip():
                        print(f"    {line}")
                if result.returncode == 0:
                    ok("qmd index updated")
                else:
                    warn(f"qmd update exited {result.returncode} — vector index stale; run 'qmd update' manually")
                # `qmd update` refreshes the BM25/document index only — embeddings
                # (the semantic half of retrieval) require a separate embed pass
                log("Running qmd embed (vector embeddings)…")
                result = subprocess.run(
                    [qmd, "embed"],
                    capture_output=True, text=True, timeout=1800
                )
                if result.returncode == 0:
                    ok("qmd embeddings updated")
                else:
                    warn(f"qmd embed exited {result.returncode} — semantic search stale; run 'qmd embed' manually")
            except subprocess.TimeoutExpired:
                warn("qmd update/embed timed out after 30 min — vector index stale; run 'qmd embed' manually")
        else:
            log("--no-embed: skipping qmd embed step (run 'qmd update' manually)")
    else:
        warn("qmd not found in PATH — skipping vector index update")
        warn("Install: npm install -g @tobilu/qmd")

    # ── Phase 4: Write signature ────────────────────────────────────────────
    # Compute the RAW file counts using `find` (no -L, no symlink follow) — exactly what
    # the JS freshness hook computes at session start. Keeps the stored count comparable.
    def count_via_find(directory: Path, *args) -> int:
        """Run `find <directory> <args> -name SKILL.md` and count lines."""
        if not directory.exists():
            return 0
        try:
            result = subprocess.run(
                ["find", str(directory)] + list(args) + ["-name", "SKILL.md"],
                capture_output=True, text=True, timeout=30
            )
            return len([l for l in result.stdout.strip().split("\n") if l])
        except Exception:
            return 0

    raw_local = count_via_find(CLAUDE_DIR / "skills", "-maxdepth", "2")
    raw_plugin_cache = count_via_find(CLAUDE_DIR / "plugins" / "cache")
    raw_plugin_mkt = count_via_find(CLAUDE_DIR / "plugins" / "marketplaces")
    raw_total = raw_local + raw_plugin_cache + raw_plugin_mkt

    sig_parts = [str(raw_total)]
    all_sources = [info["source_path"] for info in skills.values()]
    for path in sorted(all_sources):
        try:
            mtime = os.path.getmtime(path)
            sig_parts.append(f"{path} {mtime:.0f}")
        except OSError:
            pass

    sig_hash = hashlib.sha256("\n".join(sig_parts).encode()).hexdigest()
    # Line 1: hash (for future exact comparison)
    # Line 2: raw_total (what JS hook compares against — raw SKILL.md file count)
    # Line 3: unique_total (deduped stubs written)
    SIG_FILE.write_text(f"{sig_hash}\n{raw_total}\n{total}\n", encoding="utf-8")
    ok(f"Signature written → {SIG_FILE} (raw={raw_total}, unique={total})")

# ── Phase 5: Regenerate .orchestra-scan.md (full, untruncated) ──────────────
log("Regenerating .orchestra-scan.md…")
stamp = datetime.datetime.utcnow().strftime("%Y%m%d-%H%M%S")

lines = [
    f"# Orchestra scan — generated {stamp}",
    "",
    "Auto-generated by build-skill-index.sh. DO NOT edit — overwritten on each rebuild.",
    "Source of truth: ~/.claude/.skill-index/ (full catalog with descriptions).",
    "",
    f"## Skills — local ({local_count})",
    "",
]

for key, info in sorted(skills.items()):
    if info["namespace"] == "local":
        lines.append(f"- **{info['name']}** — {info['description']}")

plugin_keys = {k: v for k, v in skills.items() if not v["namespace"].startswith("local")}
lines += [
    "",
    f"## Skills — plugins ({len(plugin_keys)})",
    "",
]
for key, info in sorted(plugin_keys.items()):
    lines.append(f"- **{info['display_key']}** [{info['namespace']}] — {info['description']}")

# Agents
agents_dir = CLAUDE_DIR / "agents"
agent_lines = []
if agents_dir.exists():
    for agent_file in sorted(agents_dir.glob("*.md")):
        aname = agent_file.stem
        adesc = extract_description(agent_file)
        agent_lines.append(f"- **{aname}** — {adesc}")

lines += [
    "",
    f"## Agents ({len(agent_lines)})",
    "",
] + agent_lines

SCAN_FILE.write_text("\n".join(lines) + "\n", encoding="utf-8")
ok(f"Orchestra scan → {SCAN_FILE} ({total} skills, {len(agent_lines)} agents)")

print()
print(f"  🎼 build-skill-index complete — {total} skills indexed")
print(f"  Skill stubs: {SKILL_INDEX_DIR}")
print(f"  Orchestra scan: {SCAN_FILE}")
print(f"  Timestamp: {stamp}Z")
