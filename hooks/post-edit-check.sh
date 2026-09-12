#!/usr/bin/env bash
# PostToolUse hook (Edit|Write): format and lint only the file Claude just touched.
# Language is chosen by extension; each tool runs only if the repo has it, so a repo
# without the tool is silently untouched. Exit 2 shows stderr to Claude so it fixes the
# errors itself. Also records which language family was edited so the Stop hook knows
# which typecheck to run.
# To add a language: one case branch below, plus one in typecheck-on-stop.sh.
set -u

input=$(cat)
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
session_id=$(jq -r '.session_id // empty' <<<"$input")
project_dir="${CLAUDE_PROJECT_DIR:-}"

[ -n "$file_path" ] && [ -n "$project_dir" ] || exit 0
case "$file_path" in
  "$project_dir"/*) ;;
  *) exit 0 ;;
esac

case "${file_path##*.}" in
  ts|tsx|mts|cts|js|jsx|mjs|cjs)
    family="js"
    formatter=(node_modules/.bin/prettier --write)
    linter=(node_modules/.bin/eslint)
    ;;
  *) exit 0 ;;
esac

cd "$project_dir" || exit 0
echo "$family" >> "${TMPDIR:-/tmp}/claude-needs-typecheck-${session_id}"

if [ -x "${formatter[0]}" ]; then
  "${formatter[@]}" "$file_path" >/dev/null 2>&1
fi

[ -x "${linter[0]}" ] || exit 0
lint_output=$("${linter[@]}" "$file_path" 2>&1)
lint_status=$?
if [ "$lint_status" -ne 0 ]; then
  printf 'Lint failed for %s. Fix these before continuing:\n%s\n' "$file_path" "$lint_output" >&2
  exit 2
fi

exit 0
