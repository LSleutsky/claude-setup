---
name: review
description: Cold review of everything changed since the default branch, defects only, numbered; you approve by number and it applies only those. Manual only.
disable-model-invocation: true
---

Base: !`~/.claude/hooks/base-ref.sh`
Branch: !`git branch --show-current`
Uncommitted: !`git status --short`

## Step 1: review

The range is `<base>...HEAD`, every file changed since the branch left the base, plus uncommitted changes.

Invoke the `reviewer` subagent with exactly this instruction and nothing else from this session, except the requirements: "Review `<base>...HEAD` plus uncommitted changes in the current directory. Requirements: <the acceptance criteria or the approved plan from this session, verbatim, or `none given`>."

Show its numbered list unedited. Add nothing: no commentary, no defense of the code, no recommendation on which to accept. End with one line: "Reply with the numbers to apply, or none."

Stop and wait.

## Step 2: apply

When the user replies with numbers, first run `git status --short`. If anything is uncommitted, stop and ask the user to commit first; the approved state must be recoverable.

Apply exactly those items and nothing else. An item that turns out to need more than its fix line says is reported, not expanded. For idiom, misleading, and excess items, behavior must not change: every export, signature, route, prop, event, rendered output, and return value stays identical. Only bug, incomplete, and security items may change behavior, and only as their fix line states.

Then run the project's own typecheck, lint, and test commands, found in this order: the repo's CLAUDE.md, then its task runner or manifest (`package.json` scripts, `Makefile`, `justfile`, `pyproject.toml`, `Cargo.toml`, `go.mod`), then its CI config. Use only commands that exist there; never invent one. If none exist, say so in one line, leave the changes applied, and stop. If any fail, run `git restore .`, show the failing output, and stop. Otherwise run `git diff --stat`, list the touched files, and reply with one one-line commit message for the batch. Stop.

If the user replies "none", say nothing and stop.
