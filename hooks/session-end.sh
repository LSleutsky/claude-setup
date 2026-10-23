#!/usr/bin/env bash
# SessionEnd hook: delete this session's temp tree (scratchpad, task output) and this repo's per-session files.
# With transcripts off, the retention sweep never reaches the temp tree, so this is the only thing that removes it.
set -u

command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
scratchpad_dir=$(jq -r '.scratchpad_dir // empty' <<<"$input")
[ -n "$session_id" ] || exit 0

rm -f "${TMPDIR:-/tmp}"/claude-*-"${session_id}"
# Only the documented shape <tmp>/claude-<uid>/<project>/<session>/scratchpad earns an rm -rf of its session directory.
case "$scratchpad_dir" in
  */claude-*/*/"$session_id"/scratchpad) rm -rf "${scratchpad_dir%/scratchpad}" ;;
esac
