---
name: ac
description: Implement acceptance criteria in reviewed phases. Manual only.
disable-model-invocation: true
argument-hint: [paste the acceptance criteria]
---

Acceptance criteria for this session:

$ARGUMENTS

## Standing rules for the rest of this session

- Scope is the AC above. Touch nothing outside it unless the AC cannot work otherwise, and say so when that happens.
- Smallest diff that satisfies the AC and is verified. Anything on the Earn-it list appears in the plan with its justification or not at all.
- Never stage or commit. After each phase, and after any further change to an already reviewed phase, reply with one one-line commit message covering exactly those changes, then stop and wait for review.
- Before every commit message, run `git diff --stat` and list each touched file. Any file not named in the approved plan is called out with the reason it was needed.
- Do not begin the next phase until told to.
- Anything that affects architecture, data contracts, or user-visible behavior is a question, not a decision.
- If the AC needs a change in another repo, do not make it. Write a handoff instead: the repo, what must change, the exact contract (route, request, response types), and why. The user takes that to a session in that repo. Code this repo against the contract only after the user confirms it.
- Code outside this repo is read only through the `explorer` subagent, which returns locations and contracts, never code. Commands with long output (tests, builds) run through the `runner` subagent, which returns only the outcome.

## Now

1. Read only what the AC touches: the relevant files in this repo, then the backend endpoint they call (the injected context names the client and any sibling repos), then anything behind that endpoint only if its response shape is unclear. Anything outside this repo goes through `explorer`.
2. List the `TODO` markers the AC covers, with file and line. Leave every other `TODO` alone.
3. Put every open question into one message. If there are none, say so.
4. Give a phased plan. Each phase is a vertical slice that leaves the build green on its own. Per phase: the files touched, what changes in each, the justification for anything on the Earn-it list, and an estimate of lines added and removed. A phase over about 150 lines is split or justified. For any phase that introduces a new data flow, name the source of truth, the boundary it crosses, and what the user sees when it fails. No code yet. Stop and wait for approval.
