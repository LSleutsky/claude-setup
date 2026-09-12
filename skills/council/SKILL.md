---
name: council
description: Three isolated advisors argue a decision, then a verdict. For architecture and process decisions, never for anything with a diff. Manual only.
disable-model-invocation: true
argument-hint: <the decision, as a yes/no or A/B question>
---

Decision under review:

$ARGUMENTS

Run the three advisor subagents `contrarian`, `first-principles`, and `executor` in
parallel. Give each one only the decision text above, nothing else. They must not see
each other's output; that isolation is the point.

When all three have returned, show their answers unedited under their names. Then, as
chairman, deliver the verdict in exactly this shape:

- Decision: one sentence, yes or no or A or B, no hedging.
- Biggest risk: one sentence, drawn from the advisors, not new.
- First step: one action, with the file, command, or person it involves.
- Where the advisors disagreed: one line, only if they did.

No other commentary. Do not implement anything. Stop.
