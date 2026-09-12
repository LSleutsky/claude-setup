---
name: review
description: Cold review of the current branch's diff by a reviewer with no memory of this session. Run before opening a PR. Manual only.
disable-model-invocation: true
argument-hint: [base ref, default main]
---

Base ref: !`echo "${ARGUMENTS:-main}"`
Branch: !`git branch --show-current`
Changed files: !`git diff --stat $(git merge-base HEAD ${ARGUMENTS:-main})...HEAD | tail -n 1`

Invoke the `reviewer` subagent with exactly this instruction and nothing else from this
session: "Review `git diff <base>...HEAD` in the current directory. Base ref: <base>."

Show its report unedited. Do not add your own review, do not defend the code, do not
fix anything. If the user then asks for fixes, treat each finding as a small task with
its own commit message. Stop.
