#!/usr/bin/env bash
# Builds ~/.claude from this repo. Run after cloning, and again after any change here.
#
# Owned by this repo, deleted and rebuilt every run:
#   ~/.claude/CLAUDE.md  rules/  hooks/  skills/  agents/
#   the "permissions.allow", "permissions.ask" and "hooks" keys of ~/.claude/settings.json
#
# Machine-local, never touched:
#   ~/.claude/context/ and worklogs/ (written by /map, /note, /log)
#   ~/.claude/projects/ (transcripts, auto memory), credentials, everything else
#   every other key in settings.json, including permissions.additionalDirectories
#
# Usage: bash install.sh
set -eu

repo_dir=$(cd "$(dirname "$0")" && pwd)
target="$HOME/.claude"

command -v jq >/dev/null 2>&1 || { echo "jq is required. Install it and rerun." >&2; exit 1; }
[ -f "$repo_dir/CLAUDE.md" ] || { echo "run this from the setup repo" >&2; exit 1; }

mkdir -p "$target"
backup="$target.backup-$(date +%Y%m%d-%H%M%S)"
cp -r "$target" "$backup"

rm -rf "$target/rules" "$target/hooks" "$target/skills" "$target/agents"
mkdir -p "$target/rules" "$target/hooks" "$target/skills" "$target/agents" "$target/context" "$target/worklogs" "$target/docs"

cp "$repo_dir/CLAUDE.md" "$target/CLAUDE.md"
cp "$repo_dir"/rules/*.md "$target/rules/"
cp "$repo_dir"/hooks/*.sh "$target/hooks/"
cp -r "$repo_dir"/skills/* "$target/skills/"
cp "$repo_dir"/agents/*.md "$target/agents/"
chmod +x "$target"/hooks/*.sh

# settings.json: replace only the keys this repo owns. jq's * is a recursive object
# merge, so machine-local keys such as permissions.additionalDirectories survive.
existing="{}"
[ -f "$target/settings.json" ] && existing=$(jq 'del(.permissions.allow, .permissions.ask, .hooks)' "$target/settings.json")
jq -s '.[0] * .[1]' <(echo "$existing") "$repo_dir/settings.json" > "$target/settings.json.tmp"
mv "$target/settings.json.tmp" "$target/settings.json"

echo "installed into $target (backup: $backup)"
echo "verify in a repo: /context  /hooks  /permissions  /agents"
