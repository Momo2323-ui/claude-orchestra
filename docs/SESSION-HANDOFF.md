# Session Handoff — v3.0 launch state (2026-06-12)

> For the next session (Moksh's Mac). Read this first, then execute "What's left" in order.
> Written by the cloud session that built v2 and merged v3.0. Public-safe: no personal/business
> content (that lives only on the Mac in `goal/`, `codex/` — gitignored, never push them).

---

## Where everything is

| Thing | Location | State |
|---|---|---|
| **v3.0 (the merged system)** | branch `claude/tender-brahmagupta-xx1ems`, tip `361b15c` | ✅ complete, tested, pushed |
| **Moksh's local snapshot** | Mac: `~/Projects/claude-orchestra`, branch `local-v2-work`, commit `a7db607` (amended — private files stripped from history) | ⚠️ NOT pushed yet (dispatch sandbox had no git creds) |
| **`assets/demo.gif`** (2.7 MB) | only inside `local-v2-work` on the Mac | arrives when that branch is pushed |
| **Private files** | Mac only: `goal/`, `codex/`, `CODEX-FIXES.md`, HANDOFF/DISCOVERY/V2*-DESIGN docs | gitignored on both sides — keep it that way |
| **Moksh's live `~/.claude` inventory** | Mac only | never captured live — first `orchestra index` on the Mac is the real one |

## What v3.0 contains (already on the branch)

- **Score engine** `bin/orchestra`: index · route · board · doctor (prints exact bench fixes) ·
  bench/promote · log · qmd on/off · upkeep · cron
- **Hooks**: prompt-aware `orchestra-route.sh` (reads stdin, injects matched slice, static
  fallback) + `orchestra-telemetry.sh` (PostToolUse → local usage log → rankings)
- **Brain layer** (from Moksh's local work, transferred via manifest-verified text export):
  `skills/hallucination-guard`, `skills/skill-selector`, `agents/auditor.md`
- **Constitution v3**: 22 orchestras (㉑ AUDIT w/ auditor conductor, ㉒ CYBERSECURITY), NEXUS
  7-phase map, Harmony 3-layer ensemble (0.70/0.55 thresholds), Rule 14 internal-first ladder,
  Calibration Loop, Chain Protocol (shapes · cycle detection · Result-object handoffs),
  Reasoning Escalation (ultrathink/ultraplan/ultracode/ultrareview), registry-twin doctrine
- **Registries**: `registry/registry.template.json` (fresh-install clean) +
  `examples/registry-filled.json` (~90-tool real stack) — v3 trigger vocab incl. plurals
- **Unified `install.sh` v3.0.0** (local skeleton: --guided/--dry-run/--minimal/--prefix/
  --no-hook, curl-pipe, scan manifest, backup-everything + engine wiring) and `uninstall.sh`
  (+ `UNINSTALL.md`) covering the full surface
- **Community layer**: ROADMAP, TROUBLESHOOTING, CONTRIBUTING v2, PR/issue templates,
  CODEOWNERS, dependabot, asciinema script
- **Docs**: README (unified, plain-language), HOW-IT-WORKS (7 parts), AUDIT-2026-06 (the v1
  audit), SCALING-SKILLS (the "too many skills" fix), MERGE-PLAN (executed), examples
  (01-real-prompts + live-engine appendix, RANKING-BOARD regenerated)

**Verified**: shellcheck clean (CI-equivalent find incl. `bin/*`) · both JSONs valid · double
install idempotent · doctor all-clear on fresh install · uninstall round-trips (benched skills
restored, settings surgically cleaned) · routes: BUILD/CYBERSEC/AUDIT+PLANNING/NEXUS/DESIGN all
correct · hook fallback works without engine.

## What's left — execute in this order

```bash
# 1. Push the local snapshot (brings demo.gif + Moksh's git history)
cd ~/Projects/claude-orchestra
git push -u origin local-v2-work --force-with-lease

# 2. Get the merged v3 and re-verify on the Mac
git fetch origin && git checkout claude/tender-brahmagupta-xx1ems
shellcheck --severity=warning install.sh uninstall.sh hooks/*.sh bin/orchestra
T=$(mktemp -d) && ./install.sh --prefix="$T" && ./install.sh --prefix="$T" \
  && CLAUDE_DIR="$T/.claude" "$T/.claude/orchestra/bin/orchestra" doctor

# 3. Bring the GIF onto the v3 branch
git checkout local-v2-work -- assets/demo.gif
git commit -m "assets: demo gif from local-v2-work"

# 4. CI tweak (needs Moksh's credentials — blocked for automation tokens):
#    in .github/workflows/shellcheck.yml change the find to:
#    find . -type f \( -name '*.sh' -o -path './bin/*' \) -not -path './.git/*' -print0
#    (see IMPROVEMENT_PLAN.md § P1.5)

# 5. Launch: merge to main + tag (after Moksh eyeballs the README)
git checkout main && git merge --no-ff claude/tender-brahmagupta-xx1ems
git tag -a v3.0.0 -m "Claude Orchestra v3.0 — score engine + brain layer"
git push origin main --tags

# 6. Dogfood on the Mac (the REAL inventory at last)
./install.sh --guided
~/.claude/orchestra/bin/orchestra index && ~/.claude/orchestra/bin/orchestra doctor
~/.claude/orchestra/bin/orchestra board && cat ~/.claude/orchestra/RANKING_BOARD.md
# bench whatever doctor prescribes → this is what kills the "skills are too much" warning
# qmd is already installed on this Mac → orchestra qmd on
# first-run classification: run orchestra-intake on ~/.claude/.orchestra-scan.md
```

Then — and only then — marketing (Moksh's explicit ordering). Asciinema recording
(`assets/asciinema-script.md`) is Moksh's to record before/after tag.

## v3.1 backlog (agreed priority)

1. **Routing eval set** — ~30 golden prompts → expected orchestra, run in CI (top leverage)
2. Per-skill metadata (`best-for`, `complexity-fit`, `cost-profile`) added by intake on filing
3. Learnings log (selector decisions + audit verdicts) feeding `orchestra board` scoring
4. `orchestra-coverage-audit` skill (from ROADMAP) — prove every tool has a seat after installs
5. Fold ADS into MARKETING in the template (single-tool orchestra)

## Cautions for the next session

- `goal/`, `codex/`, `CODEX-FIXES.md` must NEVER be committed — verify `git show --stat` before
  any push from the Mac (the amended `a7db607` is clean; the working tree still has the files).
- `local-v2-work` and the v3 branch share ancestry but the v3 branch supersedes it everywhere
  except `assets/demo.gif` — do NOT merge `local-v2-work` wholesale (it would resurrect the old
  README/installer); cherry-pick the GIF only (step 3).
- The auditor's own calibration rule applies: claims about the Mac's `~/.claude` in this repo's
  examples are reconstructions until step 6's live `orchestra index` runs.
