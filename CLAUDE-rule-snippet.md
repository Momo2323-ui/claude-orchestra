# Orchestra rule — paste this into your ~/.claude/CLAUDE.md

Add the block below to your global `CLAUDE.md` so the orchestra system applies to every session.
(The installer does this for you; this file is for manual setups or reference.)

```markdown
## Orchestra System (NON-NEGOTIABLE)

Every skill, agent, MCP, plugin, and connector belongs to one of the orchestras defined in
`~/.claude/rules/orchestra-system.md`. This is how the full ecosystem gets used at 100% efficiency.

- **Route every task.** A UserPromptSubmit hook injects the routing directive each turn. Match
  intent → activate the orchestra(s) via the `orchestra-router` skill → **announce** which fired
  (`🎼 <ORCHESTRA> active · Conductor: <agent> · Using: <tools>`). Auto-activate; always announce.
- **NEXUS is the meta-conductor.** Any idea/business-planning signal fires NEXUS, which sequences
  orchestras across the lifecycle.
- **File new installs into orchestras — NEVER archive.** When you install ANY new skill, plugin,
  MCP, connector, or agent, run the `orchestra-intake` skill: security-scan → classify → file into
  the right orchestra with usage notes → log it. Off-domain tools go to the dormant Reserve Bench.
- **Create new orchestras when needed.** If newly installed tools form a coherent area no existing
  orchestra covers, CREATE a new orchestra, add it to `orchestra-system.md`, and announce it.
- **One conductor per orchestra.** The conductor sequences it's players.
```
