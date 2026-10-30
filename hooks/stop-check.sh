#!/usr/bin/env bash
# Stop hook: lint, typecheck, and diff budget for everything this turn changed, whatever tool changed it.
# Changed files are every Edit/Write recorded by post-edit-check.sh, plus every file in the launch repo whose uncommitted
# state differs from the snapshot turn-start.sh took at the prompt, so shell edits count too.
# Lint and format run through post-edit-check.sh for each changed JS/TS file. Typecheck runs once per repo: a `typecheck` script in the launch directory wins, then one at the repo root, else tsc per nearest tsconfig.json.
# Budget: more than 150 lines added, or 3 or more new files, blocks the stop once with an order to delete or justify every addition. Removed lines never count.
# Blocking the stop is what makes the deletion pass happen.
# Exit 2 blocks the stop and feeds stderr to Claude. At most two blocks per turn, so a fix round is re-checked and nothing loops.
# To add a language: one case branch in post-edit-check.sh and one typecheck function here.
set -u

input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
[ -n "$session_id" ] || exit 0
project_dir="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$input")}"
tmp="${TMPDIR:-/tmp}"
marker="$tmp/claude-edits-${session_id}"
snapshot="$tmp/claude-turn-start-${session_id}"
blocks_file="$tmp/claude-stop-blocks-${session_id}"
line_budget=150
new_file_budget=3
hooks_dir=$(cd "$(dirname "$0")" && pwd)

blocks=0
if [ "$(jq -r '.stop_hook_active // false' <<<"$input")" = "true" ]; then
  blocks=$(cat "$blocks_file" 2>/dev/null || printf 0)
fi
if [ "$blocks" -ge 2 ]; then
  rm -f "$marker" "$blocks_file" "$snapshot"
  exit 0
fi

project_root=$(git -C "$project_dir" rev-parse --show-toplevel 2>/dev/null || true)

# Prints "added<TAB>new<TAB>path" per file in the launch repo whose state differs from the turn-start snapshot.
changes_since_snapshot() {
  [ -n "$project_root" ] && [ -f "$snapshot" ] || return 0
  {
    git -C "$project_root" diff --numstat HEAD -- 2>/dev/null
    git -C "$project_root" ls-files --others --exclude-standard | while IFS= read -r path; do
      printf 'U\t%s\t%s\n' "$(wc -l <"$project_root/$path" 2>/dev/null | tr -d ' ')" "$path"
    done
  } | awk -F'\t' -v OFS='\t' -v root="$project_root" '
    function num(value) { return value ~ /^[0-9]+$/ ? value + 0 : 0 }
    FILENAME == ARGV[1] { before_added[$3] = ($1 == "U") ? num($2) : num($1); before_removed[$3] = ($1 == "U") ? 0 : num($2); next }
    {
      added = ($1 == "U") ? num($2) : num($1)
      removed = ($1 == "U") ? 0 : num($2)
      if ($3 in before_added) {
        if (added != before_added[$3] || removed != before_removed[$3]) print (added > before_added[$3] ? added - before_added[$3] : 0), 0, root "/" $3
      } else {
        print added, ($1 == "U") ? 1 : 0, root "/" $3
      }
    }' "$snapshot" -
}

# Prints "added<TAB>new<TAB>path" for a file recorded by post-edit-check.sh that the snapshot cannot see.
change_for_recorded_edit() {
  local path="$1" root
  root=$(git -C "$(dirname "$path")" rev-parse --show-toplevel 2>/dev/null) || return 0
  if git -C "$root" ls-files --error-unmatch -- "$path" >/dev/null 2>&1; then
    read -r added _ < <(git -C "$root" diff --numstat HEAD -- "$path")
    case "$added" in *[!0-9]* | '') added=0 ;; esac
    printf '%s\t0\t%s\n' "$added" "$path"
  else
    printf '%s\t1\t%s\n' "$(wc -l <"$path" 2>/dev/null | tr -d ' ' || printf 0)" "$path"
  fi
}

changes=$(changes_since_snapshot)
if [ -f "$marker" ]; then
  while IFS=$'\t' read -r _ path; do
    [ -n "$path" ] || continue
    case "$path" in
      "$project_root"/*) [ -n "$project_root" ] && [ -f "$snapshot" ] && { printf '%s' "$changes" | grep -qF "	$path" || changes="${changes}"$'\n'"0	0	$path"; } ;;
      *) changes="${changes}"$'\n'"$(change_for_recorded_edit "$path")" ;;
    esac
  done <"$marker"
fi
changes=$(printf '%s\n' "$changes" | awk -F'\t' 'NF == 3 && !seen[$3]++')
if [ -z "$changes" ]; then
  rm -f "$marker" "$blocks_file" "$snapshot"
  exit 0
fi

failed=0
message=""

# Lint and format, through the same script the PostToolUse hook runs, for every changed JS/TS file.
while IFS=$'\t' read -r _ _ path; do
  case "${path##*.}" in ts | tsx | mts | cts | js | jsx | mjs | cjs) ;; *) continue ;; esac
  [ -f "$path" ] || continue
  lint_output=$(jq -cn --arg f "$path" --arg s "$session_id" '{tool_input: {file_path: $f}, session_id: $s}' | "$hooks_dir/post-edit-check.sh" 2>&1 >/dev/null)
  if [ $? -ne 0 ]; then
    failed=1
    message="${message}${lint_output}"$'\n'
  fi
done <<<"$changes"

# Nearest directory, from the path up to the given root, that holds the named file. Empty when none.
nearest_dir_with() {
  local dir
  dir=$(dirname "$1")
  while :; do
    if [ -f "$dir/$2" ]; then
      printf '%s\n' "$dir"
      return
    fi
    if [ "$dir" = "$3" ] || [ "$dir" = "/" ]; then
      return
    fi
    dir=$(dirname "$dir")
  done
}

has_typecheck_script() {
  [ -f "$1/package.json" ] && jq -e '.scripts.typecheck' "$1/package.json" >/dev/null 2>&1
}

# Runs the typecheck script in directory $1 with the package manager of repo $2.
run_typecheck_script() {
  local package_manager="npm"
  [ -f "$2/pnpm-lock.yaml" ] && package_manager="pnpm"
  [ -f "$2/yarn.lock" ] && package_manager="yarn"
  { [ -f "$2/bun.lock" ] || [ -f "$2/bun.lockb" ]; } && package_manager="bun"
  # Yarn Berry has no --silent on run; the others use it to drop their script banners.
  case "$package_manager" in
    yarn) (cd "$1" && yarn run typecheck 2>&1) ;;
    *) (cd "$1" && "$package_manager" run --silent typecheck 2>&1) ;;
  esac
}

# $1 is the repo root, stdin lists the JS/TS files changed under it.
run_js_typecheck() {
  local root="$1"
  case "$project_dir" in
    "$root" | "$root"/*)
      if has_typecheck_script "$project_dir"; then
        run_typecheck_script "$project_dir" "$root"
        return
      fi
      ;;
  esac
  if has_typecheck_script "$root"; then
    run_typecheck_script "$root" "$root"
    return
  fi
  local path config_dir tsc_dir status=0
  local -a config_dirs=()
  while IFS= read -r path; do
    config_dir=$(nearest_dir_with "$path" tsconfig.json "$root")
    [ -n "$config_dir" ] || continue
    case " ${config_dirs[*]:-} " in
      *" $config_dir "*) ;;
      *) config_dirs+=("$config_dir") ;;
    esac
  done
  for config_dir in ${config_dirs[@]+"${config_dirs[@]}"}; do
    tsc_dir=$(nearest_dir_with "$config_dir/tsconfig.json" node_modules/.bin/tsc "$root")
    [ -n "$tsc_dir" ] || continue
    "$tsc_dir/node_modules/.bin/tsc" --noEmit --pretty false -p "$config_dir" 2>&1 || status=1
  done
  return "$status"
}

# Group changed JS/TS files by the repo they live in and typecheck each repo once.
located=""
while IFS=$'\t' read -r _ _ path; do
  case "${path##*.}" in ts | tsx | mts | cts | js | jsx | mjs | cjs) ;; *) continue ;; esac
  root=$(git -C "$(dirname "$path")" rev-parse --show-toplevel 2>/dev/null) || continue
  located="${located}${root}"$'\t'"${path}"$'\n'
done <<<"$changes"
for root in $(printf '%s' "$located" | cut -f1 | sort -u); do
  js_paths=$(printf '%s' "$located" | awk -F'\t' -v root="$root" '$1 == root { print $2 }')
  output=$(run_js_typecheck "$root" <<<"$js_paths")
  if [ $? -ne 0 ]; then
    failed=1
    error_count=$(printf '%s' "$output" | grep -c 'error')
    message="${message}Typecheck failed in $root ($error_count error lines, first 60 below). Fix every error you introduced before finishing:"$'\n'
    message="${message}$(printf '%s' "$output" | head -n 60)"$'\n'
  fi
done

# The budget runs once per turn, on the first stop.
if [ "$blocks" -eq 0 ]; then
  read -r lines new_files files < <(printf '%s\n' "$changes" | awk -F'\t' '{ lines += $1; new += $2; files++ } END { print lines + 0, new + 0, files + 0 }')
  if [ "$lines" -gt "$line_budget" ] || [ "$new_files" -ge "$new_file_budget" ]; then
    failed=1
    message="${message}This turn added $lines lines across $files files, $new_files of them new. The budget is $line_budget added lines and fewer than $new_file_budget new files. Read \`git diff\` and the new files. Delete everything the task does not need: every file, abstraction, option, fallback, defensive check, comment, and reformatted line without a requirement behind it. Each new thing you keep gets one line in your reply naming the requirement that needs it. Then stop again."$'\n'
  fi
fi

rm -f "$marker"
if [ "$failed" -ne 0 ]; then
  printf '%s' "$((blocks + 1))" >"$blocks_file"
  printf '%s' "$message" >&2
  exit 2
fi

rm -f "$blocks_file" "$snapshot"
exit 0
