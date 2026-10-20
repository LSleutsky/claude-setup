---
name: continue
description: Write the document that lets a fresh session resume this work tomorrow with nothing missing. Manual only.
disable-model-invocation: true
argument-hint: "<absolute path to write, e.g. ~/Obsidian/handoffs/ABC-123.md>"
allowed-tools: Read Write Bash(git *) Bash(ls *) Bash(date *) Bash(~/.claude/hooks/repo-key.sh) Bash(~/.claude/hooks/base-ref.sh)
---

Write to: $ARGUMENTS

## Facts from git, take these as true

- Repo: !`~/.claude/hooks/repo-key.sh`
- Path: !`git rev-parse --show-toplevel`
- Branch: !`git branch --show-current`
- HEAD: !`git rev-parse --short HEAD`
- Base: !`~/.claude/hooks/base-ref.sh`
- Date: !`date +%Y-%m-%d`
- Uncommitted: !`git status --short`
- Changed on this branch: !`git diff --stat origin/HEAD...HEAD`
- Commits on this branch: !`git log --oneline origin/HEAD..HEAD`
- Plan files, newest first: !`ls -t ~/.claude/plans`

## Task

Write one markdown document at the path above so that a new Claude Code session, with none of this conversation, pastes it into `/ac` and starts at the exact right spot without a single question. Everything it needs is in the document or reachable by a path the document names.

Source of truth, in order: this conversation (the task, the approved plan, what was done, every decision), then the git facts above, then the plan file if this conversation used one. Nothing from memory of other sessions, nothing speculative.

Shape, every section present, in this order:

```markdown
# Continue: <ticket id or one-line task name>

Written <date>. Repo `<key>` at `<absolute path>`. Branch `<branch>`. HEAD `<sha>`. Base `<base>`.
Ticket: <ABC-123 or none>. Commit messages: `type(scope): what changed (ABC-123)`, one line, no body; the user commits.

## Start here
1. `cd <absolute path>` and `git switch <branch>`. If `git rev-parse --short HEAD` is not `<sha>`, read `git log <sha>..HEAD --oneline` first; the user committed or changed something after this was written.
2. Uncommitted at pause: <none | one line per file, and the commit message they were handed>. If `git status` is clean now, the user committed them.
3. Next action: <phase N, step M: the file, the exact change, and the check that proves it>. Do not re-plan. Do not read beyond the files named here. Do not ask anything this document answers; every default below is a decision.

## Task
<the acceptance criteria verbatim, or the handoff verbatim>

## Plan (approved <date>)
### Phase 1: <name>  DONE (commit <sha>)
- <files and what changed>
### Phase 2: <name>  IN PROGRESS
- done: <what, by file>
- remaining: <what, by file, in order>
### Phase 3: <name>  NOT STARTED
- <files and what changes>

## Decisions
- <decision>: <why>. One per line, including answers the user gave and assumptions they accepted.

## Not doing
- <out of scope, and anything deliberately left as it is>

## Verified
- typecheck: <pass or fail at sha>; lint: <pass or fail>; tests: <command and result, or not run>; manual: <what was checked by eye>

## Gotchas
- <what bit this session: a flaky command, a surprising API, a file that must not change>

## References
- `path:line` <what it is>, one per line, only paths that exist on disk now
```

Rules:
- Every path is checked to exist before it is written. Every claim about state matches the git facts above.
- No code blocks except a contract (request, response, type) the next session codes against.
- Anything undecided becomes a stated default under Decisions, never an open question.
- Under 150 lines. ASCII only.
- Write the file, then reply with its path and the `Next action` line, nothing else.
- If the guard blocks the write, print the whole document in one fenced block tagged `markdown` opened with four backticks, and say: "Run `/add-dir <folder>` once per session, or add the folder to `permissions.additionalDirectories` in `~/.claude/settings.json`, to let me write there."
