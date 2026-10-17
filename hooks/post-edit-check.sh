#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): format and lint only the file Claude just touched.
# Language is chosen by extension; each tool runs only if the repo has it, so a repo without the tool is silently untouched.
# Tools are found in the nearest node_modules/.bin from the file up to the repo root, so monorepo packages with their own tools work.
# The first formatter found wins (oxfmt, biome, prettier); every linter found runs (oxlint, eslint, else biome).
# Exit 2 shows stderr to Claude so it fixes the errors itself.
# Also records the language family and path of every edit so the Stop hook knows which typecheck to run and where.
# To add a language: one case branch below, plus one in typecheck-on-stop.sh.
set -u

input=$(cat)
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
session_id=$(jq -r '.session_id // empty' <<<"$input")
project_dir="${CLAUDE_PROJECT_DIR:-}"

[ -n "$file_path" ] && [ -n "$project_dir" ] || exit 0
repo_root=$(git -C "$project_dir" rev-parse --show-toplevel 2>/dev/null || printf '%s' "$project_dir")
case "$file_path" in
  "$repo_root"/* | "$project_dir"/*) ;;
  *) exit 0 ;;
esac

case "${file_path##*.}" in
  ts | tsx | mts | cts | js | jsx | mjs | cjs) family="js" ;;
  *) exit 0 ;;
esac

printf '%s\t%s\n' "$family" "$file_path" >>"${TMPDIR:-/tmp}/claude-needs-typecheck-${session_id}"

# Prints the nearest executable node_modules/.bin/<tool> from the file up to the repo root. Empty when none.
find_tool() {
  local dir
  dir=$(dirname "$file_path")
  while :; do
    if [ -x "$dir/node_modules/.bin/$1" ]; then
      printf '%s\n' "$dir/node_modules/.bin/$1"
      return
    fi
    if [ "$dir" = "$repo_root" ] || [ "$dir" = "/" ]; then
      return
    fi
    dir=$(dirname "$dir")
  done
}

# Runs a tool from the package that owns it, so its config resolves the way it does on the command line.
run_tool() {
  local tool="$1"
  shift
  (cd "${tool%/node_modules/.bin/*}" && "$tool" "$@")
}

formatter=$(find_tool oxfmt)
if [ -n "$formatter" ]; then
  run_tool "$formatter" "$file_path" >/dev/null 2>&1
elif formatter=$(find_tool biome) && [ -n "$formatter" ]; then
  run_tool "$formatter" format --write "$file_path" >/dev/null 2>&1
elif formatter=$(find_tool prettier) && [ -n "$formatter" ]; then
  run_tool "$formatter" --write "$file_path" >/dev/null 2>&1
fi

linters=()
oxlint=$(find_tool oxlint)
eslint=$(find_tool eslint)
[ -n "$oxlint" ] && linters+=("$oxlint")
[ -n "$eslint" ] && linters+=("$eslint")
if [ "${#linters[@]}" -eq 0 ]; then
  biome=$(find_tool biome)
  [ -n "$biome" ] && linters+=("$biome lint")
fi
[ "${#linters[@]}" -gt 0 ] || exit 0

for linter in "${linters[@]}"; do
  tool="${linter%% *}"
  subcommand="${linter#"$tool"}"
  # shellcheck disable=SC2086
  lint_output=$(run_tool "$tool" $subcommand "$file_path" 2>&1)
  lint_status=$?
  if [ "$lint_status" -ne 0 ]; then
    printf 'Lint failed for %s. Fix these before continuing:\n%s\n' "$file_path" "$lint_output" | head -n 60 >&2
    exit 2
  fi
done

exit 0
