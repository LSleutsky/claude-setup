#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|NotebookEdit). Two checks, both exit 2 to block and show stderr to Claude:
#
#   1. Sensitive files are never written: env files, lockfiles, migrations, anything under .git/,
#      and Claude Code settings files. The user edits them.
#   2. Writes land only in the working directories: the current repo, the temp dir, the machine-local
#      folders under ~/.claude (context, worklogs, docs, plans, projects), every path in
#      permissions.additionalDirectories (user, project and local settings), and every directory
#      added with /add-dir this session (recorded by add-dir.sh). The installed setup under ~/.claude
#      changes only through the setup repo and install.sh.
set -u

block() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

# Resolve a leading `~`, `.` and `..` as text, since the file may not exist yet.
normalize() {
  local path="$1"
  case "$path" in
    "~" | "~/"*) path="$HOME${path#\~}" ;;
  esac
  local part
  local -a parts
  local -a kept=()
  IFS='/' read -r -a parts <<<"$path"
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
session_id=$(jq -r '.session_id // empty' <<<"$input")
project_dir="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // empty' <<<"$input")}"
[ -n "$file_path" ] && [ -n "$project_dir" ] || block "the hook input has no file path or project directory."

case "$file_path" in
  /*) ;;
  *) file_path="$project_dir/$file_path" ;;
esac
file_path=$(normalize "$file_path")
project_dir=$(normalize "$project_dir")

# 1. Sensitive files, checked on the basename and on any path segment. Example env files hold no secrets.
base_name=$(basename "$file_path")
sensitive=""
case "$base_name" in
  .env.example | .env.sample | .env.template) ;;
  .env | .env.*) sensitive="an environment file" ;;
  package-lock.json | pnpm-lock.yaml | yarn.lock | bun.lock | bun.lockb | Cargo.lock | go.sum | uv.lock | poetry.lock) sensitive="a lockfile" ;;
esac
case "$file_path" in
  */migrations/* | */migration/*) sensitive="a migration" ;;
  */.git/*) sensitive="inside .git" ;;
  */.claude/settings.json | */.claude/settings.local.json) sensitive="a Claude Code settings file" ;;
esac
[ -z "$sensitive" ] || block "$file_path is $sensitive. Say what must change and why, then stop; the user edits it."

# 2. Location.
case "$file_path" in
  "$HOME/.claude"/context/* | "$HOME/.claude"/worklogs/* | "$HOME/.claude"/docs/* | "$HOME/.claude"/plans/* | "$HOME/.claude"/projects/*) exit 0 ;;
  "$HOME/.claude"/*) block "$file_path is part of the installed setup. It changes in the setup repo, then bash install.sh; the user does that." ;;
esac
tmp_dir=$(normalize "${TMPDIR:-/tmp}")
allowed_dirs=("$project_dir" "$tmp_dir" "/private$tmp_dir" /tmp /private/tmp)
# A session launched in a monorepo package may still edit the repo root.
repo_root=$(git -C "$project_dir" rev-parse --show-toplevel 2>/dev/null || true)
[ -n "$repo_root" ] && allowed_dirs+=("$(normalize "$repo_root")")

add_allowed() {
  local dir="$1"
  [ -n "$dir" ] || return 0
  case "$dir" in
    /* | "~" | "~/"*) ;;
    *) dir="$project_dir/$dir" ;;
  esac
  allowed_dirs+=("$(normalize "$dir")")
}

for settings in "$HOME/.claude/settings.json" "$project_dir/.claude/settings.json" "$project_dir/.claude/settings.local.json"; do
  [ -f "$settings" ] || continue
  while IFS= read -r dir; do
    add_allowed "$dir"
  done < <(jq -r '.permissions.additionalDirectories // [] | .[]' "$settings" 2>/dev/null)
done

added_this_session="${TMPDIR:-/tmp}/claude-write-allow-${session_id}"
if [ -n "$session_id" ] && [ -f "$added_this_session" ]; then
  while IFS= read -r dir; do
    add_allowed "$dir"
  done <"$added_this_session"
fi

for allowed in "${allowed_dirs[@]}"; do
  case "$file_path" in
    "$allowed" | "$allowed"/*) exit 0 ;;
  esac
done

block "$file_path is outside the working directories; other repos are read-only. The user unlocks a directory with /add-dir <path>, or permanently in permissions.additionalDirectories. Say what must change and stop."
