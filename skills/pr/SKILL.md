---
name: pr
description: Write a short, human PR description for the current branch. A subagent reads the diff, so it never enters this session. Manual only.
disable-model-invocation: true
---

Base: !`~/.claude/hooks/base-ref.sh`
Branch: !`git branch --show-current`

Invoke the `pr-writer` subagent with exactly this instruction and nothing else from this session: "Write the PR description for branch `<branch>` against base `<base>` in the current directory."

Reply with its description exactly as returned and nothing else: no preface, no fence, no commentary, no follow-up. The reply is what `/copy` copies.
