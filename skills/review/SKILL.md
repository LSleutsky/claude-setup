---
name: review
description: Cold review of the branch diff with numbered proposals; you approve by number, then it applies only those. No changes without approval. Manual only.
disable-model-invocation: true
argument-hint: "[base ref, default main]"
---

Base ref: !`echo "${ARGUMENTS:-main}"`
Branch: !`git branch --show-current`
Changed: !`git diff --stat main...HEAD | tail -n 1`

## Step 1: review

Invoke the `reviewer` subagent with exactly this instruction and nothing else from this session: "Review `git diff <base>...HEAD` in the current directory. Base ref: <base>."

Show its numbered list unedited. Add nothing: no commentary, no defense of the code, no recommendation on which to accept. End with one line: "Reply with the numbers to apply, or none."

Stop and wait.

## Step 2: apply

When the user replies with numbers, apply exactly those items and nothing else. An item that turns out to need more than its two lines described is reported, not expanded. Then run `git diff --stat`, list the touched files, and reply with one one-line commit message for the batch. Stop.

If the user replies "none", say nothing and stop.
