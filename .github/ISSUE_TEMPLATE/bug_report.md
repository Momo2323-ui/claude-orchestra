---
name: Bug report
about: Something doesn't work as documented
title: "[bug] "
labels: ["bug", "triage"]
assignees: []
---

<!-- Thanks for taking the time to file this. The more specific, the faster we can fix. -->

## What happened

<!-- Plain-English description of the bug. -->

## What you expected

<!-- What the README, SECURITY.md, UNINSTALL.md, or a skill's SKILL.md said should happen. -->

## Steps to reproduce

```
1. clone the repo at commit <SHA>
2. ./install.sh
3. open a new Claude Code session
4. send the prompt: "..."
5. observe: ...
```

## Environment

| | |
|---|---|
| OS + version | <!-- macOS 14.5 / Ubuntu 22.04 / WSL2 / ... --> |
| Claude Code version | <!-- run `claude --version` --> |
| `bash --version` | <!-- first line --> |
| `jq --version` | |
| Install method | <!-- fresh / re-install / git pull then re-install --> |
| `~/.claude/` previously customized? | <!-- yes (significant) / yes (minor) / no --> |

## Relevant output

<details>
<summary>install.sh output (or skill execution output)</summary>

```
paste output here — redact anything sensitive
```

</details>

<details>
<summary>~/.claude/settings.json diff against the backup (if relevant)</summary>

```diff
paste diff here
```

</details>

## Have you tried

- [ ] Reading the [README](../README.md) install section
- [ ] Reading [SECURITY.md](../SECURITY.md) for what install.sh actually does
- [ ] Reading [UNINSTALL.md](../UNINSTALL.md) (if the bug is around removal)
- [ ] Reading [docs/SETUP.md](../docs/SETUP.md) Troubleshooting section
- [ ] Searching open + closed issues for a duplicate

## Anything else

<!-- Screenshots, hypotheses, related issues, anything that helps. -->
