#!/usr/bin/env bash
# DirectoryAdded hook (/add-dir): records the directory so write-guard.sh allows writes there for the rest of this session.
set -u

command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
directory=$(jq -r '.directory // empty' <<<"$input")
[ -n "$session_id" ] && [ -n "$directory" ] || exit 0

printf '%s\n' "$directory" >>"${TMPDIR:-/tmp}/claude-write-allow-${session_id}"
