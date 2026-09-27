#!/usr/bin/env bash
# PreToolUse hook (Bash). Covers what the Read deny rules and write-guard.sh cannot see inside a shell command:
#   - Any use of a real env file, and shell writes to lockfiles and migrations.
#
# Exit 2 blocks and shows stderr to Claude.
set -u

block() {
  printf 'Blocked: %s\n' "$1" >&2
  exit 2
}

command -v jq >/dev/null 2>&1 || block "jq is missing, so the shell guard cannot check this command. Install jq."
command=$(jq -r '.tool_input.command // empty' 2>/dev/null) || block "the hook input is not valid JSON."
[ -n "$command" ] || exit 0

# Example env files hold no secrets and are meant to be read and copied.
scrubbed=$(printf '%s' "$command" | sed -E 's/\.env\.(example|sample|template)//g')
if printf '%s' "$scrubbed" | grep -Eq '(^|[^[:alnum:]_.-])\.env(\.[[:alnum:]_-]+)?([^[:alnum:]_.-]|$)'; then
  block "env files hold secrets and stay out of the session. Read .env.example for variable names, or ask the user."
fi

protected='(package-lock\.json|pnpm-lock\.yaml|yarn\.lock|bun\.lockb?|Cargo\.lock|go\.sum|uv\.lock|poetry\.lock|/migrations?/)'
writes='(^|[^[:alnum:]_-])(rm|mv|cp|tee|truncate|dd)[[:space:]]|sed[[:space:]]+(-[^[:space:]]+[[:space:]]+)*-[[:alnum:]]*i|perl[[:space:]]+-[[:alnum:]]*i|[^0-9&]>'
if printf '%s' "$command" | grep -Eq "$protected" && printf '%s' "$command" | grep -Eq "$writes"; then
  block "lockfiles and migrations change only through their own tool or by the user. Say what must change and stop."
fi

exit 0
