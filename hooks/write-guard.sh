#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|NotebookEdit). Three outcomes:
#
#   1. Blocked (exit 2, stderr to Claude): env files, lockfiles, anything under .git/, and Claude Code settings files.
#      These change only by the user's hand or their own tool.
#   2. Asked (JSON permissionDecision "ask", reason shown in the prompt): a migration, a file under the installed setup
#      in ~/.claude, or a path outside the working directories. The user approves once in the prompt; /add-dir <path>
#      stops the prompts for a directory for the rest of the session, permissions.additionalDirectories for good.
#   3. Allowed: the current repo, the temp dir, the machine-local folders under ~/.claude (context, worklogs, docs,
#      plans, projects), every path in permissions.additionalDirectories (user, project and local settings), and every
#      directory added with /add-dir this session (recorded by add-dir.sh).
set -u

block() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

ask() {
  jq -cn --arg reason "$1" '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "ask", permissionDecisionReason: $reason}}'
  exit 0
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
case "$base_name" in
  .env.example | .env.sample | .env.template) ;;
  .env | .env.*) block "$file_path is an environment file. Say what must change and why, then stop; the user edits it." ;;
  package-lock.json | pnpm-lock.yaml | yarn.lock | bun.lock | bun.lockb | Cargo.lock | go.sum | uv.lock | poetry.lock) block "$file_path is a lockfile. It changes only through the package manager; say what must change and stop." ;;
esac
case "$file_path" in
  */.git/*) block "$file_path is inside .git. Say what must change and stop." ;;
  */.claude/settings.json | */.claude/settings.local.json) block "$file_path is a Claude Code settings file. Say what must change and why, then stop; the user edits it." ;;
  */migrations/* | */migration/*) ask "$file_path is a migration. Approve only if you asked for this migration." ;;
esac

# 2. Location.
case "$file_path" in
  "$HOME/.claude"/context/* | "$HOME/.claude"/worklogs/* | "$HOME/.claude"/docs/* | "$HOME/.claude"/plans/* | "$HOME/.claude"/projects/*) exit 0 ;;
  "$HOME/.claude"/*) ask "$file_path is part of the installed setup; the next bash install.sh overwrites it. Approve for a one-off, or change it in the setup repo." ;;
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

ask "$file_path is outside the working directories. Approve this write, or run /add-dir $(dirname "$file_path") to allow the directory for this session."
