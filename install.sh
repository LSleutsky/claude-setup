#!/usr/bin/env bash
# Builds ~/.claude from this repo. Run after cloning, and again after any change here.
#
# Owned by this repo, replaced every run:
#   1. ~/.claude/CLAUDE.md  rules/  hooks/
#   2. ~/.claude/skills/<name> and ~/.claude/agents/<name>.md for every name in this repo
#   3. The "permissions.allow", "permissions.ask", "permissions.deny" and "hooks" keys of ~/.claude/settings.json
#
# Machine-local, never touched:
#   1. ~/.claude/context/, worklogs/ and docs/ (written by /map, /note, /log, /design-doc)
#   2. ~/.claude/skills/synced and any other skill or agent not from this repo
#   3. ~/.claude/projects/ (transcripts, auto memory), credentials, everything else every other key in settings.json, including permissions.additionalDirectories

set -eu

repo_dir=$(cd "$(dirname "$0")" && pwd)
target="$HOME/.claude"
backups="$HOME/.claude-setup-backups"
manifest="$target/.claude-setup-manifest"

command -v jq >/dev/null 2>&1 || { echo "jq is required. Install it and rerun." >&2; exit 1; }
[ -f "$repo_dir/CLAUDE.md" ] || { echo "run this from the setup repo" >&2; exit 1; }

mkdir -p "$target/rules" "$target/hooks" "$target/skills" "$target/agents" "$target/context" "$target/worklogs" "$target/docs" "$backups"

backup="$backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup"
for owned in CLAUDE.md settings.json rules hooks skills agents; do
  [ ! -e "$target/$owned" ] || cp -R "$target/$owned" "$backup/"
done
find "$backups" -mindepth 1 -maxdepth 1 -type d | sort -r | tail -n +6 | while IFS= read -r old_backup; do
  rm -rf "$old_backup"
done

# Remove what the last run installed, so a skill or agent deleted from this repo is deleted here too.
if [ -f "$manifest" ]; then
  while IFS= read -r owned; do
    case "$owned" in
      *..* | skills/synced | skills/*/*) ;;
      skills/?* | agents/?*.md) rm -rf "${target:?}/$owned" ;;
    esac
  done <"$manifest"
fi

rm -rf "$target/rules" "$target/hooks"
mkdir -p "$target/rules" "$target/hooks"
cp "$repo_dir/CLAUDE.md" "$target/CLAUDE.md"
cp "$repo_dir"/rules/*.md "$target/rules/"
cp "$repo_dir"/hooks/*.sh "$target/hooks/"
chmod +x "$target"/hooks/*.sh

: >"$manifest.tmp"
for skill_dir in "$repo_dir"/skills/*/; do
  skill_dir="${skill_dir%/}"
  skill_name=$(basename "$skill_dir")
  rm -rf "${target:?}/skills/$skill_name"
  cp -R "$skill_dir" "$target/skills/$skill_name"
  echo "skills/$skill_name" >>"$manifest.tmp"
done
for agent_file in "$repo_dir"/agents/*.md; do
  agent_name=$(basename "$agent_file")
  cp "$agent_file" "$target/agents/$agent_name"
  echo "agents/$agent_name" >>"$manifest.tmp"
done
mv "$manifest.tmp" "$manifest"
find "$target/skills" "$target/agents" -name .DS_Store -delete

# settings.json: replace only the keys this repo owns. jq's * is a recursive object
# merge, so machine-local keys such as permissions.additionalDirectories survive.
existing="{}"
[ -f "$target/settings.json" ] && existing=$(jq 'del(.permissions.allow, .permissions.ask, .permissions.deny, .hooks)' "$target/settings.json")
jq -s '.[0] * .[1]' <(echo "$existing") "$repo_dir/settings.json" >"$target/settings.json.tmp"
mv "$target/settings.json.tmp" "$target/settings.json"

echo "installed into $target (backup: $backup)"
echo "verify in a repo: /context  /hooks  /permissions  /agents"
