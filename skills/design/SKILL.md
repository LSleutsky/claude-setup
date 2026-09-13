---
name: design
description: One-page design for a greenfield system or feature, before any code. Manual only.
disable-model-invocation: true
argument-hint: "<what you want to build, in a few sentences>"
---

Design request:

$ARGUMENTS

You are designing, not building. No code, no file structure, no library picks beyond what the constraints force. Everything below is one line each unless a line cannot hold it. The whole answer fits on one screen.

## Step 1: questions

Ask only what changes the design: who uses it, what must never happen, what already exists that this must fit, what scale is real (not imagined). One batched message. If the request already answers these, skip to step 2 and say so.

## Step 2: the page

```
Problem      what this exists to do, one sentence
Non-goals    three things someone might expect that this will not do
Constraints  hard limits: platform, data residency, offline, budget, existing systems
Data         the entities, their identities, and which one is the source of truth for what
Boundaries   where data crosses a trust or system boundary, and what is validated there
Flow         the main path, request to response, in five lines or fewer
Failure      the three most likely failures and what the user sees for each
Slice 1      the smallest vertical slice that proves the design end to end
Open         decisions deliberately deferred, with what would force each
```

## Rules

- Every line is a decision or a fact, never an option list. If two designs are viable, present the fork as one line under Open, or run `/council` on it.
- No pattern appears without the constraint that earns it. "Event-driven" needs the line that says why a direct call will not do.
- Non-goals are mandatory and specific. "Out of scope: auth" is fine; "keep it simple" is not a non-goal.
- Slice 1 is buildable with `/ac` as written. If it is not, it is too big.
- Stop after the page. When the user approves, tell them which lines belong in the context file via `/note`, and stop again.
