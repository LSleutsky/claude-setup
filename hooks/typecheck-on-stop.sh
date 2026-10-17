#!/usr/bin/env bash
# Stop hook: one typecheck per turn for the code edited this turn.
# The marker written by post-edit-check.sh lists "family<TAB>path" per edit.
# A `typecheck` script in the launch directory wins, then one at the repo root; otherwise tsc runs once per nearest tsconfig.json, so monorepo packages work.
# Exit 2 blocks the stop and feeds the errors back to Claude; exit 0 lets the turn end.
# To add a language: one run_<family>_typecheck function and one case branch at the bottom.
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
edits=$(sort -u "$marker")
rm -f "$marker"
[ -n "$project_dir" ] && cd "$project_dir" || exit 0
repo_root=$(git rev-parse --show-toplevel 2>/dev/null || printf '%s' "$project_dir")

package_manager="npm"
[ -f "$repo_root/pnpm-lock.yaml" ] && package_manager="pnpm"
[ -f "$repo_root/yarn.lock" ] && package_manager="yarn"
{ [ -f "$repo_root/bun.lock" ] || [ -f "$repo_root/bun.lockb" ]; } && package_manager="bun"

# Nearest directory, from the path up to the repo root, that holds the named file. Empty when none.
nearest_dir_with() {
  local dir
  dir=$(dirname "$1")
  while :; do
    if [ -f "$dir/$2" ]; then
      printf '%s\n' "$dir"
      return
    fi
    if [ "$dir" = "$repo_root" ] || [ "$dir" = "/" ]; then
      return
    fi
    dir=$(dirname "$dir")
  done
}

has_typecheck_script() {
  [ -f "$1/package.json" ] && jq -e '.scripts.typecheck' "$1/package.json" >/dev/null 2>&1
}

run_typecheck_script() {
  # Yarn Berry rejects --silent on run; the others use it to drop their script banners.
  case "$package_manager" in
    yarn) (cd "$1" && yarn run typecheck 2>&1) ;;
    *) (cd "$1" && "$package_manager" run --silent typecheck 2>&1) ;;
  esac
}

run_js_typecheck() {
  if has_typecheck_script "$project_dir"; then
    run_typecheck_script "$project_dir"
    return
  fi
  if has_typecheck_script "$repo_root"; then
    run_typecheck_script "$repo_root"
    return
  fi
  local family path config_dir tsc_dir status=0
  local -a config_dirs=()
  while IFS=$'\t' read -r family path; do
    [ "$family" = "js" ] && [ -n "$path" ] || continue
    config_dir=$(nearest_dir_with "$path" tsconfig.json)
    [ -n "$config_dir" ] || continue
    case " ${config_dirs[*]:-} " in
      *" $config_dir "*) ;;
      *) config_dirs+=("$config_dir") ;;
    esac
  done <<<"$edits"
  for config_dir in ${config_dirs[@]+"${config_dirs[@]}"}; do
    tsc_dir=$(nearest_dir_with "$config_dir/tsconfig.json" node_modules/.bin/tsc)
    [ -n "$tsc_dir" ] || continue
    "$tsc_dir/node_modules/.bin/tsc" --noEmit --pretty false -p "$config_dir" 2>&1 || status=1
  done
  return "$status"
}

families=$(printf '%s\n' "$edits" | cut -f1 | sort -u)
failed=0
all_output=""
for family in $families; do
  case "$family" in
    js) output=$(run_js_typecheck) ;;
    *) continue ;;
  esac
  status=$?
  if [ "$status" -ne 0 ]; then
    failed=1
    all_output="${all_output}${output}"$'\n'
  fi
done

if [ "$failed" -ne 0 ]; then
  error_count=$(printf '%s' "$all_output" | grep -c 'error')
  {
    printf 'Typecheck failed (%s error lines, first 60 below). Fix every error you introduced before finishing:\n' "$error_count"
    printf '%s' "$all_output" | head -n 60
  } >&2
  exit 2
fi

exit 0
