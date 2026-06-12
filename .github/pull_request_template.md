<!-- Thanks for the PR. Fill in every section below. Empty PRs are easier to close than review. -->

## What

<!-- One paragraph, high-level. What changed? -->

## Why

<!-- What failure mode or use case prompted this? Link issues with `Fixes #123` / `Refs #123`. -->

## How tested

<!-- The actual commands you ran + their output. "Works on my machine" isn't tested.
     If you changed install.sh / a hook, show: shellcheck, bash -n, idempotency proof.
     If you changed a skill, show: frontmatter validates, no doctrinal collision.
     If docs only, say so. -->

```bash
# paste real commands + output here
```

## Security scan (if applicable)

<!-- Required for any PR that adds a new skill, agent, hook, MCP reference, or external link.
     See CONTRIBUTING.md → "The security-scan-first rule" for the 5-step procedure. -->

- [ ] Not applicable — this PR adds no new external dependency
- [ ] Scan completed — result: `SAFE` / `CAUTION` / `REJECT`
- [ ] Scan output included below

<details>
<summary>Scan output</summary>

```
paste 5-step scan output here
```

</details>

## Docs updated

- [ ] README.md
- [ ] SECURITY.md
- [ ] UNINSTALL.md
- [ ] CONTRIBUTING.md
- [ ] ROADMAP.md
- [ ] docs/*.md
- [ ] examples/*.md
- [ ] N/A — code-only / installer-only change

## Checklist before merge

- [ ] `shellcheck` CI passes
- [ ] Tested locally per CONTRIBUTING.md
- [ ] One logical change per PR (small + focused)
- [ ] No `sudo`, no network calls, no telemetry introduced
- [ ] If AI-assisted, every command / package / feature in this PR has been verified to actually exist in this repo (no hallucinated APIs)

---

<!-- If AI-assisted, include the Co-Authored-By line in your commit messages, e.g.:
     Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com> -->
