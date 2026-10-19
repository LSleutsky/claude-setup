---
name: pr
description: Write a short, human PR description for the current branch. Runs in a side context so the diff never enters the main session. Output only. Manual only.
disable-model-invocation: true
context: fork
agent: general-purpose
background: false
effort: medium
allowed-tools: Read Bash(git diff *) Bash(git log *) Bash(git branch --show-current) Bash(~/.claude/hooks/base-ref.sh)
---

You are writing a pull request description. You have no memory of how this code was written; work only from the branch.

Branch: !`git branch --show-current`
Base: !`~/.claude/hooks/base-ref.sh`
Commits: !`git log --oneline $(~/.claude/hooks/base-ref.sh)..HEAD`
Files: !`git diff --stat $(~/.claude/hooks/base-ref.sh)...HEAD`

The ticket id is the first `ABC-123` style token in the branch name or the commit messages above, else none.

Read `git diff <base>...HEAD` only as far as needed to know what changed and why. Then write the description and stop. Do not edit anything.

## Shape

- Under about 120 words for a small PR, 200 for a large one.
- Small PR: one paragraph, two to four sentences.
- Large PR: one opening sentence, then a short list of the meaningful changes, one line each. Meaningful means a reader would care; never one bullet per file.
- Plain text only. No headers, no bold, no emoji, no checklists, no template sections.
- Written the way you would explain it to a teammate at their desk. Present tense, active voice.
- Say what changed and why, in that order. Say what a reviewer should look at if one thing needs attention. Say what was deliberately left out if the ticket might make someone expect it.
- If a ticket id is known, it is the first line by itself.

## Never

- "This PR", "This pull request", "In this PR". Start with the change.
- "Summary", "Changes", "Testing", "Notes" as headings or labels.
- "comprehensive", "robust", "seamless", "enhance", "leverage", "ensure", "streamline", "improve the overall", "various".
- Listing every file, function, or type touched. The diff already does that.
- Explaining how the code works line by line. Explain what it does for the user or the system.
- Describing tests unless something about them is unusual.
- Filler openers ("As part of our ongoing effort...") and filler closers ("Let me know if you have any questions").

## Bad

```
## Summary
This PR implements comprehensive enrollment date support for the participant list view. The changes include adding a new `enrolledAt` column to the participants table component, updating the `ParticipantSummary` type to include the new field, and modifying the sort logic to default to descending order by enrollment date.

## Changes
- Added `enrolledAt` column to `ParticipantTable.tsx`
- Updated `ParticipantSummary` interface in `types.ts`
- Modified `useParticipantSort` hook to support the new column
...
```

## Good

```
AC-412

Adds an Enrolled column to the participant list, sorted newest first by default. The date comes from the BFF's new enrolledAt field and shows a dash for participants who have not consented yet.

Filtering and export are out of scope for this ticket and untouched. Worth a look: the empty state now renders when a study has no participants, which it did not before.
```

Return the description inside one fenced block and nothing else. It is the only thing the user will see.
