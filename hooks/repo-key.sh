#!/usr/bin/env bash
# Prints the key that names this repo's context and worklog files under ~/.claude.
# Uses the origin remote's repo name so every clone and worktree of a repo shares
# one set of files. Falls back to the folder name when there is no remote.
set -u

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
remote_url=$(git -C "$project_dir" remote get-url origin 2>/dev/null || true)

if [ -n "$remote_url" ]; then
  key=$(basename "$remote_url")
  key="${key%.git}"
else
  key=$(basename "$project_dir")
fi

printf '%s\n' "$key"
