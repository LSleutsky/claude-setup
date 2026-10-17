---
name: handoff
description: Print the standalone handoff for every other repo this work needs a change in, each to paste into /ac in a session there. Manual only.
disable-model-invocation: true
---

- This repo: !`~/.claude/hooks/repo-key.sh`
- Path: !`git rev-parse --show-toplevel`
- Branch: !`git branch --show-current`

## Task

This session already knows which repos must change and what each must provide: the acceptance criteria, the approved plan, and every point where this repo's work cannot proceed without a change elsewhere. Write one handoff per target repo from that. Never ask which repo or what it must provide.

For each target, read it through `explorer` until every field below is filled from its code and from this session. If a field still cannot be filled, ask the user once, in one message covering every target, with your default for each; never guess in a handoff.

Shape, every section present:

````markdown
# Handoff: <one-line change>
Target repo: `<name>` at `<absolute path>`, base branch `<its default branch>`
Requested by: `<this repo>` for <ticket id or none>: <one-line task summary>
Commit messages: `type(scope): what changed (<ticket id>)`, one line, no body

## Why
<what this repo needs and cannot do without it, two sentences max>

## Contract
<method and route, or function, or event name>
```ts
<request, response and error types, verbatim as this repo will code against them>
```
<auth, status codes, pagination, nullability, ordering: whatever the caller depends on, one line each>

## Current state in the target
- `<path:line>`: <what exists now that this touches or extends>

## Done when
- <checkable criterion, one per line, including the test or call that proves it>

## Out of scope
- <what the target must not change, including every other consumer of this contract>
````

Rules:
- Every `path:line` is confirmed by `explorer` in the target as it is now.
- The contract is complete: the target implements it without opening this repo, and this repo codes against it without opening the target.
- Reply with each handoff as its own fenced block tagged `markdown` and opened with four backticks, so the inner `ts` block survives the paste. Nothing else in the reply.
- After the handoffs, do not code against a contract until the user confirms it landed in its target.
