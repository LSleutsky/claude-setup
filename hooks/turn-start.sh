#!/usr/bin/env bash
# UserPromptSubmit hook: snapshot the repo's uncommitted state so stop-check.sh can measure only this turn's changes,
# whatever tool made them (Edit, Write, or a shell command), and put the one rule that keeps diffs small at the end of
# the context where it weighs most. Stdout here is added to Claude's context.
# Snapshot lines: "added<TAB>removed<TAB>path" from git numstat for tracked files, "U<TAB>lines<TAB>path" for untracked ones.
set -u

input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
project_dir="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$input")}"
[ -n "$session_id" ] && [ -n "$project_dir" ] || exit 0

snapshot="${TMPDIR:-/tmp}/claude-turn-start-${session_id}"
rm -f "$snapshot"
if root=$(git -C "$project_dir" rev-parse --show-toplevel 2>/dev/null); then
  {
    git -C "$root" diff --numstat HEAD -- 2>/dev/null
    git -C "$root" ls-files --others --exclude-standard | while IFS= read -r path; do
      printf 'U\t%s\t%s\n' "$(wc -l <"$root/$path" 2>/dev/null | tr -d ' ')" "$path"
    done
  } >"$snapshot"
fi

printf 'Reminder: the deliverable is the smallest diff that does exactly this task. No new file, abstraction, option, fallback, or check without naming its reason first. Before you stop, read the diff and delete what the task did not need.\n'
