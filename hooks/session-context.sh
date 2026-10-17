#!/usr/bin/env bash
# SessionStart hook: plain stdout here is added to Claude's context.
# Per-repo files are keyed by hooks/repo-key.sh (origin repo name, else folder name):
#
#   ~/.claude/context/<key>.md   state, written by /map and /note (injected whole)
#   ~/.claude/worklogs/<key>.md  narrative, written by /log (last entry only, max 40 lines)
#
# Framework rules come from stack-rules.sh, registered as its own SessionStart hook so each output has its own 10,000-character budget.
set -u

[ -n "${CLAUDE_PROJECT_DIR:-}" ] || exit 0
repo_key=$("$HOME/.claude/hooks/repo-key.sh")

context="$HOME/.claude/context/${repo_key}.md"
if [ -f "$context" ]; then
  printf 'Project context for %s:\n' "$repo_key"
  cat "$context"
  printf '\n'
fi

log="$HOME/.claude/worklogs/${repo_key}.md"
if [ -f "$log" ]; then
  printf 'Last worklog entry (full file on disk, grep it rather than reading it whole: %s):\n' "$log"
  entry_start=$(grep -n '^## ' "$log" | tail -n 1 | cut -d: -f1)
  if [ -n "$entry_start" ]; then
    tail -n +"$entry_start" "$log" | head -n 40
  else
    tail -n 20 "$log"
  fi
fi
