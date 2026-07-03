# Orchestra rule — paste this into your ~/.claude/CLAUDE.md

Add the block below to your global `CLAUDE.md` so the orchestra system applies to every session.
(The installer does this for you; this file is for manual setups or reference.)

```markdown
## Orchestra System

Every skill, agent, MCP, plugin, and connector belongs to one of the orchestras defined in
`~/.claude/rules/orchestra-system.md`. This is how a large ecosystem gets used at full efficiency.

- **Route silently; announce only delegation, in one line** (e.g. `→ search-agent: competitor
  pricing sweep`). No ensemble blocks, no ceremony — the work leads the reply, not the routing.
- **Pick tools via retrieval, not memorization:** use the `skill-selector` skill (backed by the
  optional local qmd `skills` index if installed). If a skill clearly fits, use it — don't narrate it.
- **Capability gap → recommend, don't improvise.** If no installed tool fits the task
  (skill-selector score < 0.5), run its Gap → Recommend protocol: search the skills.sh registry
  (`find-skills`) and the MCP registry, present vetted install candidates, and file approved
  installs via `orchestra-intake`.
- **File new installs into orchestras — NEVER archive.** When you install ANY new skill, plugin,
  MCP, connector, or agent, run the `orchestra-intake` skill: security-scan → classify → file into
  the right orchestra with usage notes → log it. Off-domain tools go to the dormant Reserve Bench.
- **Create new orchestras when needed.** If newly installed tools form a coherent area no existing
  orchestra covers, CREATE a new orchestra, add it to `orchestra-system.md`, and announce it.
- **One conductor per orchestra.** The conductor sequences its players.
- **High-stakes output** (shipped code, money, infra, hooks/secrets/CI, security) → `auditor`
  agent gate: defaults to NEEDS WORK, requires fresh evidence, max 3 bounce-backs.
```
