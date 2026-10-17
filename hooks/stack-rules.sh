#!/usr/bin/env bash
# Prints the framework rules under ~/.claude/stacks that this repo's package.json dependencies call for.
# Path-scoped rules cannot tell a React Native screen from a web component; the dependency list can.
# Registered as its own SessionStart hook so its output has its own character budget.

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
has react-native && selected+=(react-native)
has next && selected+=(nextjs)
has @nestjs/core && selected+=(nestjs)
{ has @tanstack/react-router || has @tanstack/react-start; } && selected+=(tanstack-router)
has @tanstack/react-query && selected+=(tanstack-query)
[ "${#selected[@]}" -gt 0 ] || exit 0

printf 'Framework rules for this repo, chosen from its package.json dependencies. Like a rule file, they constrain the code you write and are never a reason to change untouched code:\n\n'
for stack in "${selected[@]}"; do
  [ -f "$stacks/$stack.md" ] || continue
  cat "$stacks/$stack.md"
  printf '\n'
done
