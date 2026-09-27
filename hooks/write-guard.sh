#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|NotebookEdit). Two checks, both exit 2 to block and show stderr to Claude:
#   1. Sensitive files inside the repo (env files, lockfiles, migrations) are never
#      edited unless CLAUDE_WRITE_ALLOW names the file or its directory.
#   2. Writes outside the current repo and ~/.claude are blocked. Other repos are read-only.
# Escape hatch for either, colon-separated paths, exact file or directory:
#   CLAUDE_WRITE_ALLOW=/path/to/other-repo:/path/to/repo/.env.local claude
set -u

block() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

# Resolve `.` and `..` as text, since the file may not exist yet.
normalize() {
  local part
  local -a parts
  local -a kept=()
  IFS='/' read -r -a parts <<<"$1"
  for part in ${parts[@]+"${parts[@]}"}; do
    case "$part" in
      '' | .) ;;
      ..) [ "${#kept[@]}" -gt 0 ] && unset "kept[$((${#kept[@]} - 1))]" ;;
      *) kept+=("$part") ;;
    esac
  done
  [ "${#kept[@]}" -gt 0 ] || { printf '/\n'; return; }
  local IFS=/
  printf '/%s\n' "${kept[*]}"
}

command -v jq >/dev/null 2>&1 || block "jq is missing, so the write guard cannot check this write. Install jq."
input=$(cat)
file_path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // empty' <<<"$input" 2>/dev/null) ||
  block "the hook input is not valid JSON."
project_dir="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$input")}"
[ -n "$file_path" ] && [ -n "$project_dir" ] || block "the hook input has no file path or project directory."

case "$file_path" in
  /*) ;;
  *) file_path="$project_dir/$file_path" ;;
esac
file_path=$(normalize "$file_path")
project_dir=$(normalize "$project_dir")

IFS=':' read -r -a allow_list <<<"${CLAUDE_WRITE_ALLOW:-}"
is_allowed() {
  local allowed
  for allowed in ${allow_list[@]+"${allow_list[@]}"}; do
    [ -n "$allowed" ] || continue
    allowed=$(normalize "$allowed")
    case "$1" in
      "$allowed" | "$allowed"/*) return 0 ;;
    esac
  done
  return 1
}

# 1. Sensitive files, checked on the basename and on any path segment.
base_name=$(basename "$file_path")
sensitive=""
case "$base_name" in
  .env | .env.*) sensitive="environment file" ;;
  package-lock.json | pnpm-lock.yaml | yarn.lock | bun.lock | bun.lockb | Cargo.lock | go.sum | uv.lock | poetry.lock) sensitive="lockfile" ;;
esac
case "$file_path" in
  */migrations/* | */migration/*) sensitive="migration" ;;
esac
if [ -n "$sensitive" ] && ! is_allowed "$file_path"; then
  block "$file_path is a $sensitive. Say what must change and why, and stop; the user edits it or relaunches with CLAUDE_WRITE_ALLOW."
fi

# 2. Location.
tmp_dir=$(normalize "${TMPDIR:-/tmp}")
for allowed in "$project_dir" "$HOME/.claude" "$tmp_dir" "/private$tmp_dir" /tmp /private/tmp; do
  case "$file_path" in
    "$allowed"/*) exit 0 ;;
  esac
done
is_allowed "$file_path" && exit 0

block "$file_path is outside the current repo. Other repos are read-only in this setup. If it truly must change, say so and stop."
