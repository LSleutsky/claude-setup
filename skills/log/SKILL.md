---
name: log
description: Append a dated entry for this session's work to the repo's worklog kept outside the repo. Manual only.
disable-model-invocation: true
argument-hint: "[optional one-line focus]"
allowed-tools: Read Edit Write Bash(~/.claude/hooks/repo-key.sh) Bash(date *) Bash(echo *) Bash(git branch --show-current) Bash(git status *) Bash(git log *)
---

## Context

- Worklog file: !`echo "$HOME/.claude/worklogs/$(~/.claude/hooks/repo-key.sh).md"`
- Date: !`date +%Y-%m-%d`
- Branch: !`git branch --show-current`
- Uncommitted: !`git status --short`
- Commits since midnight: !`git log --since=midnight --oneline`

## Task

Append one entry to the worklog file above. It lives outside the repository on purpose; never create a worklog inside the project. Create the file with a `# Worklog: <repo name>` heading if it does not exist. Newest entry goes at the bottom.

Entry format:

```markdown
## <date> <branch> $ARGUMENTS
- Done: what changed, one line per item
- Decided: decisions and the reason, only if one was made
- Encountered: problems hit and how they were resolved
- Open: anything unfinished or blocked, including any handoff to another repo
```

Rules:
- Facts from this session only. No speculation, no summaries of things you did not do.
- Drop any heading with nothing under it.
- Do not restate what `git log` already records; capture the why, the gotchas, and the loose ends.
- ASCII only, no em dashes.
- Write the file, then reply with the entry only.
