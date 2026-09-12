#!/usr/bin/env bash
# SessionStart hook: plain stdout here is added to Claude's context.
# Per-repo files are keyed by the repo folder name and live under ~/.claude only:
#   ~/.claude/context/<repo>.md   state, written by /map and /note (injected whole)
#   ~/.claude/worklogs/<repo>.md  narrative, written by /log (last 3 entries, max 80 lines)
set -u

project_dir="${CLAUDE_PROJECT_DIR:-}"
[ -n "$project_dir" ] || exit 0
repo_name=$(basename "$project_dir")

context="$HOME/.claude/context/${repo_name}.md"
if [ -f "$context" ]; then
  printf 'Project context for %s:\n' "$repo_name"
  cat "$context"
  printf '\n'
fi

log="$HOME/.claude/worklogs/${repo_name}.md"
if [ -f "$log" ]; then
  printf 'Last worklog entries (full file on disk, grep it rather than reading it whole: %s):\n' "$log"
  entry_start=$(grep -n '^## ' "$log" | tail -n 3 | head -n 1 | cut -d: -f1)
  if [ -n "$entry_start" ]; then
    tail -n +"$entry_start" "$log" | tail -n 80
  else
    tail -n 40 "$log"
  fi
fi
