---
name: ac
description: Implement acceptance criteria in reviewed phases, or resume from a Continue or Handoff document. Manual only.
disable-model-invocation: true
argument-hint: "[ABC-123 ticket:] <acceptance criteria, or a pasted Continue or Handoff document>"
---

Input for this session:

$ARGUMENTS

Branch: !`git branch --show-current`

## Ticket

The ticket id is the first `ABC-123` style token in the input, else the first one in the branch name, else none. With a ticket id, every commit message this session ends with it in parentheses.

## Which kind of input

- Starts with `# Continue:`: a paused session. Follow its `## Start here` section exactly: switch to the branch, confirm HEAD (if it moved, read `git log <sha>..HEAD --oneline` and carry on), read only the files the next action names, then do the next action under the standing rules below. Do not re-plan, do not re-read the repo, do not ask anything the document answers; its defaults are decisions.
- Starts with `# Handoff:`: a change another repo needs from this one. Its `## Contract` is the spec and `## Done when` is the acceptance criteria; plan against them under "Fresh criteria".
- Anything else: fresh acceptance criteria. Go to "Fresh criteria".

## Standing rules for the rest of this session

- Scope is the input above. Touch nothing outside it unless the criteria cannot work otherwise, and say so when that happens.
- Smallest diff that satisfies the criteria and is verified. Anything shared and new (helper, wrapper, interface, option, hook, store, file) appears in the plan with the real uses that earn it (a third call site for a helper, a second for everything else), or not at all.
- Never stage or commit. After each phase, and after any further change to a reviewed phase: run `git diff --stat`, list each touched file and call out any not in the approved plan with the reason, confirm the hooks came back clean, run the existing tests for the touched code through `runner`, state what ran and the result, reply with one one-line commit message covering exactly those changes, then stop and wait.
- Do not begin the next phase until told to.
- Anything that affects architecture, data contracts, or user-visible behavior is a question, not a decision.
- A change another repo must make is never made here. Run `/handoff` for it, and code against the contract only after the user confirms it landed.
- Code outside this repo is read only through `explorer`. Commands with long output run through `runner`. Facts about a library, platform, or API that are not in the repo or `node_modules` come from `researcher`, never from memory.

## Fresh criteria

1. Read only what the criteria touch: the relevant files here, the nearest existing example of each kind of thing the criteria need (a similar screen, component, hook, endpoint, query, form, test) so the new code matches it, then the backend endpoint they call (the injected context names the client and any sibling repos), then anything behind that endpoint only if its response shape is unclear.
2. List the `TODO` markers the criteria cover, with file and line. Leave every other `TODO` alone.
3. Put every open question into one message, with the default you would take for each. If there are none, say so.
4. Give a phased plan. Each phase is a vertical slice that leaves the build green on its own. Per phase: the files touched and what changes in each, the justification for anything shared and new, an estimate of lines added and removed, and the check that proves the phase (typecheck, a named test, a screen to open). A phase over about 150 lines is split or justified. For any phase that introduces a new data flow, name the source of truth, the boundary it crosses, and what the user sees when it fails. End with one `Not doing:` line. No code yet. No open question survives into the plan. Stop and wait for approval.
