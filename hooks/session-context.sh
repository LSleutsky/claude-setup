#!/usr/bin/env bash
# SessionStart hook: plain stdout here is added to Claude's context.
# Per-repo files are keyed by hooks/repo-key.sh (origin repo name, else folder name):
#   ~/.claude/context/<key>.md   state, written by /map and /note (injected whole)
#   ~/.claude/worklogs/<key>.md  narrative, written by /log (last 3 entries, max 80 lines)
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
  printf 'Last worklog entries (full file on disk, grep it rather than reading it whole: %s):\n' "$log"
  entry_start=$(grep -n '^## ' "$log" | tail -n 3 | head -n 1 | cut -d: -f1)
  if [ -n "$entry_start" ]; then
    tail -n +"$entry_start" "$log" | tail -n 80
  else
    tail -n 40 "$log"
  fi
fi
