#!/usr/bin/env bash
# Stop hook: one typecheck per turn, per language family that was edited this turn.
# The marker written by post-edit-check.sh lists the families. Exit 2 blocks the stop
# and feeds the errors back to Claude; exit 0 lets the turn end.
# To add a language: one case branch in run_typecheck.
set -u

input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
project_dir="${CLAUDE_PROJECT_DIR:-}"
marker="${TMPDIR:-/tmp}/claude-needs-typecheck-${session_id}"

# True when this stop was already blocked once. Bail to avoid an infinite loop.
if [ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ]; then
  rm -f "$marker"
  exit 0
fi

[ -f "$marker" ] || exit 0
families=$(sort -u "$marker")
rm -f "$marker"
[ -n "$project_dir" ] && cd "$project_dir" || exit 0

package_manager="npm"
[ -f pnpm-lock.yaml ] && package_manager="pnpm"
[ -f yarn.lock ] && package_manager="yarn"

run_typecheck() {
  case "$1" in
    js)
      [ -f tsconfig.json ] || return 0
      if [ -f package.json ] && jq -e '.scripts.typecheck' package.json >/dev/null 2>&1; then
        "$package_manager" run --silent typecheck 2>&1
      elif [ -x node_modules/.bin/tsc ]; then
        node_modules/.bin/tsc --noEmit --pretty false 2>&1
      fi
      ;;
  esac
}

failed=0
all_output=""
for family in $families; do
  output=$(run_typecheck "$family")
  status=$?
  if [ "$status" -ne 0 ]; then
    failed=1
    all_output="${all_output}${output}"$'\n'
  fi
done

if [ "$failed" -ne 0 ]; then
  printf 'Typecheck failed. Fix every error you introduced before finishing:\n%s' "$all_output" >&2
  exit 2
fi

exit 0
