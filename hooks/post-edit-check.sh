#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): format and lint only the file Claude just touched, wherever it is.
# Language is chosen by extension; each tool runs only if the file's repo has it, so a repo without the tool is silently untouched.
# Tools are found in the nearest node_modules/.bin from the file up to its repo root, so monorepo packages and other repos work.
# The first formatter found wins (oxfmt, biome, prettier); every linter found runs (oxlint, eslint, else biome).
# Exit 2 shows stderr to Claude so it fixes the errors itself.
# Also records every edit as "family<TAB>path" so stop-check.sh knows what to typecheck and what to measure.
# stop-check.sh runs this script itself for files a shell command changed, so lint has one implementation.
# To add a language: one case branch below, plus one in stop-check.sh.
set -u

input=$(cat)
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
session_id=$(jq -r '.session_id // empty' <<<"$input")
[ -n "$file_path" ] && [ -n "$session_id" ] || exit 0

case "${file_path##*.}" in
  ts | tsx | mts | cts | js | jsx | mjs | cjs) family="js" ;;
  *) family="other" ;;
esac
printf '%s\t%s\n' "$family" "$file_path" >>"${TMPDIR:-/tmp}/claude-edits-${session_id}"
[ "$family" = "js" ] || exit 0

repo_root=$(git -C "$(dirname "$file_path")" rev-parse --show-toplevel 2>/dev/null || printf '/')

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

# Prints the nearest directory from the file up to the repo root whose package.json has a `format` script. Empty when none.
find_format_script_root() {
  local dir
  dir=$(dirname "$file_path")
  while :; do
    if [ -f "$dir/package.json" ] && jq -e '.scripts.format' "$dir/package.json" >/dev/null 2>&1; then
      printf '%s\n' "$dir"
      return
    fi
    if [ "$dir" = "$repo_root" ] || [ "$dir" = "/" ]; then
      return
    fi
    dir=$(dirname "$dir")
  done
}

# The repo's own `format` script wins, because a formatter configured by flags cannot discover that config from the file alone.
format_root=$(find_format_script_root)
if [ -n "$format_root" ]; then
  (cd "$format_root" && npm run --silent format -- "$file_path") >/dev/null 2>&1
elif formatter=$(find_tool oxfmt) && [ -n "$formatter" ]; then
  run_tool "$formatter" "$file_path" >/dev/null 2>&1
elif formatter=$(find_tool biome) && [ -n "$formatter" ]; then
  run_tool "$formatter" format --write "$file_path" >/dev/null 2>&1
elif formatter=$(find_tool prettier) && [ -n "$formatter" ]; then
  run_tool "$formatter" --write "$file_path" >/dev/null 2>&1
fi

# Each entry is "<tool path><TAB><subcommand or empty>", so a repo path with spaces survives.
linters=()
oxlint=$(find_tool oxlint)
eslint=$(find_tool eslint)
[ -n "$oxlint" ] && linters+=("$oxlint"$'\t')
[ -n "$eslint" ] && linters+=("$eslint"$'\t')
if [ "${#linters[@]}" -eq 0 ]; then
  biome=$(find_tool biome)
  [ -n "$biome" ] && linters+=("$biome"$'\t'lint)
fi
[ "${#linters[@]}" -gt 0 ] || exit 0

for linter in "${linters[@]}"; do
  tool="${linter%%$'\t'*}"
  subcommand="${linter#*$'\t'}"
  if [ -n "$subcommand" ]; then
    lint_output=$(run_tool "$tool" "$subcommand" "$file_path" 2>&1)
  else
    lint_output=$(run_tool "$tool" "$file_path" 2>&1)
  fi
  lint_status=$?
  if [ "$lint_status" -ne 0 ]; then
    printf 'Lint failed for %s. Fix these before continuing:\n%s\n' "$file_path" "$lint_output" | head -n 60 >&2
    exit 2
  fi
done

exit 0
