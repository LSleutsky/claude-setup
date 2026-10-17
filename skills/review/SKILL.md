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

When the user replies with numbers, apply exactly those items and nothing else. An item that turns out to need more than its fix line says is reported, not expanded. Then run `git diff --stat`, confirm the hooks came back clean, list the touched files, and reply with one one-line commit message for the batch. Stop.

If the user replies "none", say nothing and stop.
