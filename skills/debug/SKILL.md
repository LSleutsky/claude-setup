---
name: debug
description: Fix a bug by sequence, not by guessing. Manual only.
disable-model-invocation: true
argument-hint: <the symptom, with the trace or the file if known>
---

Bug:

$ARGUMENTS

Recent changes: !`git log --oneline -10`

Sequence. Do not skip a step or reorder them.

1. Reproduce, or state precisely why you cannot. No fix without a reproduction or an explicit reason.
2. Read the trace or symptom and name the failing line. If there is no trace, name the boundary where the wrong value first appears.
3. Check whether a recent change above touched that path.
4. State one hypothesis for the root cause, in one sentence, before touching code.
5. Change one thing that tests the hypothesis. If it was wrong, say so and return to step 4. Never stack changes.
6. Fix the root cause, not the symptom. If the real fix is out of scope, say so and stop; do not patch around it.
7. Reply with a semantic commit message whose body states the root cause in one sentence.

Do not add logging that outlives the fix. Do not write or run tests unless told to. Do not remove error handling to make something pass.
