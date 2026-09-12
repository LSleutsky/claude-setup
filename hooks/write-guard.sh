#!/usr/bin/env bash
# PreToolUse hook (Edit|Write). Two checks, both exit 2 to block and show stderr to Claude:
#   1. Sensitive files inside the repo (env files, lockfiles, migrations) are never
#      edited unless CLAUDE_WRITE_ALLOW names the file or its directory.
#   2. Writes outside the current repo and ~/.claude are blocked. Other repos are read-only.
# Escape hatch for either, colon-separated paths, exact file or directory:
#   CLAUDE_WRITE_ALLOW=/path/to/other-repo:/path/to/repo/.env.local claude
set -u

input=$(cat)
file_path=$(jq -r '.tool_input.file_path // empty' <<<"$input")
project_dir="${CLAUDE_PROJECT_DIR:-}"

[ -n "$file_path" ] && [ -n "$project_dir" ] || exit 0

IFS=':' read -r -a allow_list <<<"${CLAUDE_WRITE_ALLOW:-}"
is_allowed() {
  local allowed
  for allowed in "${allow_list[@]}"; do
    [ -n "$allowed" ] || continue
    case "$1" in
      "$allowed"|"$allowed"/*) return 0 ;;
    esac
  done
  return 1
}

# 1. Sensitive files, checked on the basename and on any path segment.
base_name=$(basename "$file_path")
sensitive=""
case "$base_name" in
  .env|.env.*) sensitive="environment file" ;;
  package-lock.json|pnpm-lock.yaml|yarn.lock|Cargo.lock|go.sum|uv.lock|poetry.lock) sensitive="lockfile" ;;
esac
case "$file_path" in
  */migrations/*|*/migration/*) sensitive="migration" ;;
esac
if [ -n "$sensitive" ] && ! is_allowed "$file_path"; then
  printf 'Blocked: %s is a %s. Say what must change and why, and stop; the user edits it or relaunches with CLAUDE_WRITE_ALLOW.\n' "$file_path" "$sensitive" >&2
  exit 2
fi

# 2. Location.
case "$file_path" in
  [!/]*) exit 0 ;;
  "$project_dir"/*) exit 0 ;;
  "$HOME/.claude"/*) exit 0 ;;
  "${TMPDIR:-/tmp}"/*|/tmp/*) exit 0 ;;
esac
is_allowed "$file_path" && exit 0

printf 'Blocked: %s is outside the current repo. Other repos are read-only in this setup. If it truly must change, say so and stop.\n' "$file_path" >&2
exit 2
