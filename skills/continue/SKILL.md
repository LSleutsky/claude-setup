---
name: continue
description: Write the document that lets a fresh session resume this work tomorrow with nothing missing. Manual only.
disable-model-invocation: true
argument-hint: "[absolute path to write, e.g. ~/Obsidian/handoffs/ABC-123.md; omit to print the document in the reply]"
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
- Changed on this branch: !`git diff --stat "$(~/.claude/hooks/base-ref.sh)"...HEAD || true`
- Commits on this branch: !`git log --format='%h %ad %s' --date=short "$(~/.claude/hooks/base-ref.sh)"..HEAD || true`
- Plan files, newest first: !`ls -t ~/.claude/plans 2>/dev/null || true`

## Task

Write one markdown document, at the path above when one is given, so that a new Claude Code session, with none of this conversation, pastes it into `/ac` and starts at the exact right spot without a single question. Everything it needs is in the document or reachable by a path the document names.

Source of truth, in order: this conversation (the task, the approved plan, what was done, every decision), then the git facts above, then the plan file if this conversation used one. Nothing from memory of other sessions, nothing speculative.

Shape, every section present, in this order:

```markdown
# Continue: <ticket id or one-line task name>

Written <date>. Repo `<key>` at `<absolute path>`. Branch `<branch>`. HEAD `<sha>`. Base `<base>`.
Ticket: <ABC-123 or none>. Commit messages: `type(scope): what changed (ABC-123)`, one line, no body; the user commits.

## Start here
1. `cd <absolute path>` and `git switch <branch>`. If `git rev-parse --short HEAD` is not `<sha>`, read `git log <sha>..HEAD --oneline` first; the user committed or changed something after this was written.
2. Uncommitted at pause: <none | one line per file saying what is in it and whether it is finished, and the commit message they were handed, if any>. If `git status` is clean now and HEAD moved, the user committed them. If it is clean and HEAD is still `<sha>`, that work is not in this working tree: stop and say so.
3. Next action: <phase N, step M: the file, the exact change, and the check that proves it | what the user owes before more code: approval of the plan below, or the numbers under Review>. Do not re-plan. Do not read beyond the files named here. Do not ask anything this document answers; every default below is a decision.

## Task
<the acceptance criteria as they stand now, every criterion added or changed mid-session included, or the handoff, or the request, verbatim>

## Plan (<approved <date> | NOT APPROVED: shown to the user, no answer yet>)
<every phase's entry from the plan, verbatim, with its files, the criterion each change satisfies, and its check; the status goes on the heading>
### Phase 1: <name>  DONE <date> (commit <sha>)
### Phase 2: <name>  IN PROGRESS
- done: <what, by file>
- remaining: <what, by file, in order>
### Phase 3: <name>  NOT STARTED
Later pull requests: <one line each, as the plan lists them, or none>

## Review
<none pending | the reviewer's numbered list for phase N, verbatim, and per number: applied, declined, or unanswered>

## Waiting on other repos
<none | per handoff: its title, the target repo, the contract verbatim, and landed or not landed as the user last said>

## Decisions
- <decision>: <why>. One per line, including answers the user gave, corrections they made, and assumptions they accepted.

## Not doing
- <out of scope, and anything deliberately left as it is>

## Verified
- typecheck: <pass or fail at sha>; lint: <pass or fail>; tests: <command and result, or not run>; manual: <what was checked by eye>

## Gotchas
- <what bit this session: a flaky command, a surprising API, a file that must not change, an approach tried and dropped and why>

## References
- `path:line` <what it is>, one per line, only paths that exist on disk now
```

Rules:
- Every path is checked to exist before it is written. Every claim about state matches the git facts above.
- No code blocks except a contract (request, response, type) the next session codes against.
- Anything undecided becomes a stated default under Decisions, never an open question.
- A fact the template asks for that this conversation and git cannot supply is asked of the user now, once, before writing; never guessed, never left blank.
- Under 150 lines, not counting the text the template marks verbatim. ASCII only.
- With a path: write the file, then reply with its path and the `Next action` line, nothing else.
- With no path: write no file. Reply with the whole document in one fenced block tagged `markdown` opened with four backticks, nothing else.
- If the guard blocks the write, print the whole document in one fenced block tagged `markdown` opened with four backticks, and say: "Run `/add-dir <folder>` once per session, or add the folder to `permissions.additionalDirectories` in `~/.claude/settings.json`, to let me write there."
