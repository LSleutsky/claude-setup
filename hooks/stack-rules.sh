#!/usr/bin/env bash
# Prints the framework rules under ~/.claude/stacks that this repo's package.json dependencies call for.
# Path-scoped rules cannot tell an Expo screen from a web component; the dependency list can.
# Used by session-context.sh at session start and by the reviewer agent.

set -u

project_dir="${CLAUDE_PROJECT_DIR:-$PWD}"
stacks="$HOME/.claude/stacks"
command -v jq >/dev/null 2>&1 || exit 0
cd "$project_dir" || exit 0

# Root, the launch directory, and every tracked workspace package, so monorepos are covered.
manifests=()
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
[ -f "$repo_root/package.json" ] && manifests+=("$repo_root/package.json")
[ -f package.json ] && manifests+=("$PWD/package.json")
while IFS= read -r manifest; do
  [ -n "$manifest" ] && manifests+=("$PWD/$manifest")
done < <(git ls-files -- '*/package.json' 2>/dev/null)
[ "${#manifests[@]}" -gt 0 ] || exit 0

dependencies=$(jq -r '(.dependencies // {}) + (.devDependencies // {}) + (.peerDependencies // {}) | keys[]' "${manifests[@]}" 2>/dev/null | sort -u)
has() { printf '%s\n' "$dependencies" | grep -qxF -- "$1"; }

selected=()
has expo && selected+=(expo)
has next && selected+=(nextjs)
has @nestjs/core && selected+=(nestjs)
{ has @tanstack/react-router || has @tanstack/react-start; } && selected+=(tanstack-router)
has @tanstack/react-query && selected+=(tanstack-query)
[ "${#selected[@]}" -gt 0 ] || exit 0

printf 'Framework rules for this repo, chosen from its package.json dependencies. They apply to every file, like a rule file:\n\n'
for stack in "${selected[@]}"; do
  [ -f "$stacks/$stack.md" ] || continue
  cat "$stacks/$stack.md"
  printf '\n'
done
