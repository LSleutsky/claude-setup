---
name: audit
description: Cold architecture audit of a module or the whole repo. Findings only, no changes. Manual only.
disable-model-invocation: true
argument-hint: "[path, default the repo root]"
---

Scope: !`echo "${ARGUMENTS:-.}"`
Files in scope: !`git ls-files ${ARGUMENTS:-.} | wc -l`

Invoke the `architect` subagent with exactly this instruction and nothing else from this session: "Audit the architecture under `<scope>` in the current directory."

Show its numbered list unedited. Add nothing: no commentary, no defense, no plan. End with one line: "Each item is a ticket or a /note. Reply with a number to turn it into a plan, or none."

If the user replies with a number, treat that item as a task: give a phased plan for it as `/ac` would, and stop for approval. Never start fixing.
