#!/usr/bin/env bash
# Prints the branch this repo's work is compared against: origin's default branch, else the first of main, master, develop that exists, else main.
# Used by the review, pr, continue and design-doc skills so repos based on develop or master work unchanged.
set -u

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
base=$(git -C "$project_dir" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || true)
base="${base#origin/}"

if [ -z "$base" ]; then
  for candidate in main master develop; do
    if git -C "$project_dir" show-ref --verify --quiet "refs/heads/$candidate"; then
      base="$candidate"
      break
    fi
  done
fi

printf '%s\n' "${base:-main}"
