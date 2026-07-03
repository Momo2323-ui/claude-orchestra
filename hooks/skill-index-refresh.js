#!/usr/bin/env node
/**
 * skill-index-refresh.js — SessionStart hook.
 *
 * Cheaply checks whether the skill catalog has changed since the last build.
 * If yes, rebuilds the skill index in the background (never blocks session start).
 * If no, exits immediately with no cost.
 *
 * Registered in settings.json SessionStart hooks.
 */

const { spawnSync, spawn } = require('child_process');
const { createHash } = require('crypto');
const fs = require('fs');
const path = require('path');
const os = require('os');

const CLAUDE_DIR = process.env.CLAUDE_DIR || path.join(os.homedir(), '.claude');
const SKILL_INDEX_DIR = path.join(CLAUDE_DIR, '.skill-index');
const SIG_FILE = path.join(SKILL_INDEX_DIR, '.signature');
const BUILD_SCRIPT = path.join(CLAUDE_DIR, 'scripts', 'build-skill-index.sh');

function log(msg) { process.stdout.write(`  [skill-refresh] ${msg}\n`); }

// ── Compute current skill count (fast, cheap) ─────────────────────────────────
// We compare total skill counts rather than replicating the full Python hash.
// Count mismatches reliably detect installs/removals; mtime changes are caught
// when the build script regenerates and updates the stored count.
function computeSkillCount() {
  let total = 0;

  // Local skills
  const skillsDir = path.join(CLAUDE_DIR, 'skills');
  if (fs.existsSync(skillsDir)) {
    for (const entry of fs.readdirSync(skillsDir, { withFileTypes: true })) {
      if (!entry.isDirectory()) continue;
      const skillMd = path.join(skillsDir, entry.name, 'SKILL.md');
      if (fs.existsSync(skillMd)) total++;
    }
  }

  // Plugin paths (count only — walk is done properly by the Python build script)
  const pluginDirs = [
    path.join(CLAUDE_DIR, 'plugins', 'cache'),
    path.join(CLAUDE_DIR, 'plugins', 'marketplaces'),
  ];
  for (const pluginBase of pluginDirs) {
    if (!fs.existsSync(pluginBase)) continue;
    // Use spawnSync with argument array — no shell, no injection risk
    const findResult = spawnSync(
      'find', [pluginBase, '-name', 'SKILL.md'],
      { encoding: 'utf8', timeout: 15000 }
    );
    if (findResult.status === 0 && findResult.stdout) {
      total += findResult.stdout.trim().split('\n').filter(Boolean).length;
    }
  }

  return total;
}

// ── Main ──────────────────────────────────────────────────────────────────────
const sigExists = fs.existsSync(SIG_FILE);
if (!sigExists) {
  log('No signature file — triggering initial build in background…');
} else {
  // Signature file format (build-skill-index.py):
  //   line 1: sha256 hash (for future exact comparison)
  //   line 2: raw SKILL.md file count (pre-dedup) — what this hook compares against
  //   line 3: unique stub count (deduped, informational)
  const sigLines = fs.readFileSync(SIG_FILE, 'utf8').trim().split('\n');
  const storedCount = parseInt(sigLines[1] || '0', 10);
  const currentCount = computeSkillCount();

  if (currentCount === storedCount) {
    // No change — exit silently (the common path, zero noise)
    process.exit(0);
  }
  log(`Skill count changed (${storedCount} → ${currentCount}) — rebuilding index in background…`);
}

// Trigger rebuild in the background (non-blocking)
if (!fs.existsSync(BUILD_SCRIPT)) {
  log(`Build script not found: ${BUILD_SCRIPT}`);
  process.exit(0);
}

// Full build including qmd embed — runs detached so it never blocks session
// start. (--no-embed here was the root cause of a 30-day-stale vector index:
// stubs refreshed but nothing ever re-embedded them. Fixed 2026-07-03.)
const child = spawn(BUILD_SCRIPT, [], {
  detached: true,
  stdio: ['ignore', 'ignore', 'ignore'],
  env: { ...process.env, CLAUDE_DIR },
});
child.unref();

log('Background rebuild started (skills will be available shortly)');
process.exit(0);
