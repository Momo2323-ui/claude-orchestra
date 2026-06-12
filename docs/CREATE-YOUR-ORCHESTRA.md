# Create your own orchestras

The shipped `orchestra-system.md` is a template. Here's how to make it yours in ~10 minutes.

## 1. Inventory your tools

```bash
ls ~/.claude/skills/        # your skills
ls ~/.claude/agents/        # your agents
# plus your plugins, MCP servers, and connectors
```

## 2. Group by purpose, not by source

Don't organize by where a tool came from — organize by **what job it does**. A Figma MCP, a UI
design skill, and a brand agent all belong in DESIGN even though they're different types.

Use the starter taxonomy in the template (BUILD, DESIGN, RESEARCH, …) and adjust:
- **Merge** orchestras you don't need (e.g. fold PAID ADS into MARKETING).
- **Rename** to fit your work.
- **Add** a new one when a cluster of tools fits nowhere — that's encouraged (see step 5).

## 3. Pick one conductor per orchestra

The conductor is the single lead agent that sequences the others. Pick the most "senior" /
coordinating agent for that domain (e.g. an `architect` agent conducts BUILD).

## 4. Fill the 10 fields

For each orchestra you keep, fill:

```markdown
### ① BUILD — *Ship working, reviewed code.*
- **Conductor:** my-architect-agent
- **First Chair:** code-reviewer, debugger, my-test-agent
- **Section:** deploy-skill, perf-skill, security-review
- **Triggers:** build, fix bug, refactor, implement, deploy, ship
- **Allowances:** edit code freely; ASK before schema changes / prod deploy
- **Quality Gate:** builds clean, tested, reviewed
```

Then mirror the **Triggers** and roster into the machine registry
(`~/.claude/orchestra/registry.json` — start from `examples/registry-filled.json`) and run
`~/.claude/orchestra/bin/orchestra index`. The registry is what the engine actually routes
from; `orchestra doctor` will tell you if the two files drift apart (unfiled tools, collisions).

## 5. The Always-Rule: create orchestras as you grow

When you install new tools that form a coherent area no orchestra covers, **create a new
orchestra** (full 10 fields), add it to the constitution, and bump the count. The roster is living.
Run the `orchestra-intake` skill on every new install and it'll do this for you.

## 6. Move off-domain tools to the Reserve Bench

Installed something niche you rarely use (a game-engine skill, a vertical-industry agent)? Put it
on the **Reserve Bench** — it stays installed and callable by name, but never auto-fires and never
clutters routing.

## Tips

- Keep the constitution under ~200 lines of *index*; push long detail into per-orchestra notes.
- A tool can live in **multiple** orchestras — list it in each.
- Re-read your constitution occasionally; prune tools you never use.
