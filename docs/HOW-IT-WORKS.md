# How it works

Claude Orchestra has four moving parts. Together they turn a pile of installed tools into a
coordinated system.

## 1. The constitution — `~/.claude/rules/orchestra-system.md`

The single source of truth. It defines each orchestra using ten fields (mission, conductor, first
chair, section, triggers, process, allowances, harness, handoff, quality gate). Because it's loaded
into context every session, the model always knows the full roster and what each orchestra is for.

## 2. The routing hook — `~/.claude/hooks/orchestra-route.sh`

A `UserPromptSubmit` hook. Claude Code runs it on **every** prompt, and it injects a short routing
directive into the model's context for that turn. The hook itself contains no logic — it just
reminds the model to route, stack, and announce. (Hooks run deterministically; the model doesn't
have to "remember" to route.)

## 3. The router skill — `skills/orchestra-router`

Reads the user's intent, matches it to one or more orchestras (using the trigger table + the full
constitution), and **announces** the activation:

```
🎼 BUILD active · Conductor: architect · Using: code-reviewer, debugger, tdd-guide
```

Compound requests stack multiple orchestras ("build a landing page" → PLANNING → DESIGN → BUILD).

## 4. The intake skill — `skills/orchestra-intake`

The self-organizing layer. Whenever you install something new, intake runs a security scan,
classifies the tool, files it into the right orchestra (updating the constitution), and logs it.
If a new tool doesn't fit any existing orchestra, intake proposes a brand-new one. **Nothing is
ever archived on install — it's filed.**

## The flow

```
prompt → hook injects routing directive → router matches intent
       → announces orchestra(s) → conductor sequences it's players → work happens
```

## Why a "conductor" per orchestra?

Activating five skills at once is noise. A conductor is one lead agent that *sequences* the
orchestra's players — plan before build, research before write, design before implement. It's the
difference between an orchestra and everyone playing at once.
