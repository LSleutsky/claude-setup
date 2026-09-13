---
name: map
description: Explore this repo once and write its context file outside the repo. Manual only.
disable-model-invocation: true
argument-hint: "[facts Claude cannot discover, e.g. backend is ../med-router]"
allowed-tools: Read Glob Grep Write Edit Bash(~/.claude/hooks/repo-key.sh) Bash(echo *) Bash(ls *) Bash(git ls-files *)
---

Context file to write: !`echo "$HOME/.claude/context/$(~/.claude/hooks/repo-key.sh).md"`
Repo: !`~/.claude/hooks/repo-key.sh`
Top level: !`ls -a`

Facts supplied by the user, take these as true: $ARGUMENTS

## Purpose

Build the context file for this repo. It lives outside the repo, is injected at every session start, and every line costs tokens forever. Hard cap: 40 lines. Its job is to save future sessions from rediscovering the same things, not to describe the repo.

## Read, in this order, and stop as soon as each section can be filled

1. The manifest (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, or equivalent): scripts, dependencies. The lockfile name.
2. `README` and any `CLAUDE.md`, `AGENTS.md`, or `docs/` that exist.
3. The tree two levels deep.
4. The entry point and the router or main loop.
5. The API client or data layer: how the code reaches its backend or its data.
6. Shared types and where state lives.

Do not read component internals, tests, or generated code.

## Write, one line per item, omit any section with nothing certain

```markdown
# <repo>

## Commands
- lint / typecheck / format / test / dev, exactly as the manifest defines them

## Stack
- language, framework, routing, data access, state, styling: only what is actually used

## Layout
- where routes, API calls, shared types, state live, paths in backticks

## Backend
- the single client or base URL the code talks through
- repos outside this one it depends on, from the user's facts only, paths in backticks

## Conventions
- patterns the code clearly follows that differ from tool defaults

## Notes
- durable facts added later with /note; keep these lines exactly as they are
```

## Rules

- Only what you verified in the code or the user stated. Unsure means leave it out.
- No narrative, no history, no opinions, no recommendations.
- If the file already exists, rewrite it in full but carry every line under `## Notes` over unchanged.
- The file is outside the repo on purpose. Never write a `CLAUDE.md` into the repo.
- When done, show the file and stop.
