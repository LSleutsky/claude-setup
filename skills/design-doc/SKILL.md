---
name: design-doc
description: Create or update this repo's technical design document from the code. The doc lives under ~/.claude/docs, never in the repo, and is never read into sessions. Manual only.
disable-model-invocation: true
argument-hint: "[only for facts not in the branch, commits, or worklog]"
---

Doc path: !`echo "$HOME/.claude/docs/$(~/.claude/hooks/repo-key.sh)/design.md"`
Exists: !`test -f "$HOME/.claude/docs/$(~/.claude/hooks/repo-key.sh)/design.md" && echo yes || echo no`
Feature (branch): !`git branch --show-current`
Changed on this branch: !`git diff --name-only $(git merge-base HEAD main)...HEAD`
Ticket ids in branch and commits: !`{ git branch --show-current; git log --format=%s $(git merge-base HEAD main)..HEAD; } | grep -oE '[A-Z]{2,}-[0-9]+' | sort -u | tr '\n' ' '`
Commits: !`git log --oneline $(git merge-base HEAD main)..HEAD`
Decided since branch start: !`f="$HOME/.claude/worklogs/$(~/.claude/hooks/repo-key.sh).md"; test -f "$f" && grep -E '^- Decided:' "$f" | tail -n 20 || true`

Extra facts from the user, if any: $ARGUMENTS

Invoke the `docwriter` subagent with exactly this instruction and nothing else from this session: "Maintain the technical design document at <doc path>. Repo: <repo>. Exists: <yes/no>. Feature: <branch name, without the type prefix>. Scope: the changed files listed, plus any paths in the user's facts. Requirements: the ticket ids listed, plus any in the user's facts. Decisions: the Decided lines listed. User facts: <arguments or none>."

Show its two-line reply unedited. Do not summarize the document, do not read it into this session, do not offer to. Stop.
