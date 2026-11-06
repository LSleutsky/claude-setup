#!/usr/bin/env bash
# Status line: model, effort, modes | dir, branch, worktree, ahead/behind, dirty | lines | context, cache, tokens | cost, time | 5h | 7d.
# Icons are literal Nerd Font glyphs, so the terminal needs a Nerd Font to render them.
IFS=$'\x1f' read -r model dir effort pct hit warm tin tout h5 h5r d7 d7r add rem cost dur wt sname fast think vim < <(jq -r '
  def p: if . == null then "" else floor end;
  [ .model.display_name, .workspace.current_dir, (.effort.level // ""),
    (.context_window.used_percentage // 0 | floor),
    (.prompt_cache.hit_ratio | if . == null then "" else . * 100 | floor end),
    (.prompt_cache.warm // false),
    (.context_window.total_input_tokens // 0), (.context_window.total_output_tokens // 0),
    (.rate_limits.five_hour.used_percentage | p), (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage | p), (.rate_limits.seven_day.resets_at // ""),
    (.cost.total_lines_added // 0), (.cost.total_lines_removed // 0),
    (.cost.total_cost_usd // 0), (.cost.total_duration_ms // 0 | . / 60000 | floor),
    (.workspace.git_worktree // ""), (.session_name // ""),
    (.fast_mode // false), (.thinking.enabled // false), (.vim.mode // "")
  ] | map(tostring) | join("\u001f")')

# Inside a pill only foreground codes are used; a full reset would drop the background.
R=$'\e[0m' DIM=$'\e[2m' UND=$'\e[22m'
WHT=$'\e[38;5;255m' GRY=$'\e[38;5;245m' GRN=$'\e[38;5;114m' YEL=$'\e[38;5;221m' RED=$'\e[38;5;203m'
col() { (( $1 >= 90 )) && echo "$RED" || { (( $1 >= 70 )) && echo "$YEL" || echo "$GRN"; }; }
k() { awk -v n="$1" 'BEGIN{ if (n >= 1000) printf "%.1fk", n/1000; else printf "%d", n }'; }
hm() { (( $1 >= 60 )) && printf '%dh%02dm' $(( $1 / 60 )) $(( $1 % 60 )) || printf '%dm' "$1"; }
left() { local s=$(( $1 - $(date +%s) )); (( s < 0 )) && s=0
  (( s >= 86400 )) && printf '%dd%dh' $(( s / 86400 )) $(( s % 86400 / 3600 )) || hm $(( s / 60 )); }
# bash 3.2 corrupts multibyte glyphs inside `${x:+...}`, so caps and glyphs live in variables.
LC="" RC=""
pill() { printf '\e[38;5;%sm%s\e[48;5;%sm%s %s \e[0m\e[38;5;%sm%s\e[0m' "$1" "$LC" "$1" "$WHT" "$2" "$1" "$RC"; }

seg="󰚩 $model"
case $effort in low) n=1;; medium) n=2;; high) n=3;; xhigh) n=4;; max) n=5;; *) n=0;; esac
if (( n )); then
  bars=(▂ ▃ ▅ ▆ █) s=""
  for i in 0 1 2 3 4; do if (( i < n )); then s+="$YEL${bars[i]}"; else s+="$DIM${bars[i]}$UND"; fi; done
  seg+=" $s$WHT"
fi
[[ $fast == true ]] && seg+=" $YEL$WHT"
[[ $think == true ]] && seg+=" $YEL$WHT"
[[ -n $vim ]] && seg+="  ${vim:0:1}"
parts=("$(pill 30 "$seg")")
[[ -n $sname ]] && parts+=("$(pill 240 " $sname")")

seg=" ${dir##*/}"
branch=$(git --no-optional-locks -C "$dir" branch --show-current 2>/dev/null)
if [[ -n $branch ]]; then
  seg+="  $branch"
  [[ -n $wt ]] && seg+="  $wt"
  read -r behind ahead < <(git --no-optional-locks -C "$dir" rev-list --left-right --count '@{u}...HEAD' 2>/dev/null)
  (( ahead )) && seg+=" $GRN↑$ahead$WHT"
  (( behind )) && seg+=" $RED↓$behind$WHT"
  read -r staged modified untracked < <(git --no-optional-locks -C "$dir" status --porcelain 2>/dev/null |
    awk '{ x = substr($0, 1, 1); y = substr($0, 2, 1); if (x == "?") u++; else { if (x != " ") s++; if (y != " ") m++ } }
         END { print s + 0, m + 0, u + 0 }')
  (( staged )) && seg+=" $GRN●$staged$WHT"
  (( modified )) && seg+=" $YEL✚$modified$WHT"
  (( untracked )) && seg+=" $GRY…$untracked$WHT"
fi
parts+=("$(pill 25 "$seg")")

(( add || rem )) && parts+=("$(pill 236 " $GRN+$add $RED-$rem$WHT")")

(( pct > 100 )) && pct=100
hue=(114 114 150 186 221 221 215 209 203 203 196)
eighths=("" ▏ ▎ ▍ ▌ ▋ ▊ ▉)
e=$(( pct * 80 / 100 )) full=$(( e / 8 )) part=$(( e % 8 ))
printf -v a "%${full}s"; printf -v b "%$(( 10 - full - (part > 0) ))s"
seg="$(printf '\e[38;5;%sm' "${hue[pct / 10]}")${a// /█}${eighths[part]}$DIM${b// /░}$UND$WHT $pct%"
if [[ -n $hit ]]; then
  if [[ $warm == true ]]; then seg+="  $GRN●$WHT$hit%"; else seg+="  $DIM●$UND$hit%"; fi
fi
seg+="  $GRY↓$(k "$tin") $YEL↑$(k "$tout")$WHT"
parts+=("$(pill 236 "$seg")")

parts+=("$(pill 236 "$(printf '$%.2f' "$cost")  $GRY $(hm "$dur")$WHT")")

[[ -n $h5 ]] && parts+=("$(pill 236 " $(col "$h5")$h5%$WHT $GRY↻ $(left "$h5r")$WHT")")
[[ -n $d7 ]] && parts+=("$(pill 236 " $(col "$d7")$d7%$WHT $GRY↻ $(left "$d7r")$WHT")")

out=""; for p in "${parts[@]}"; do out+="${out:+ }$p"; done
# Claude Code trims each line and collapses zero-width rows, so the spacer is a space wrapped in reset codes.
printf '%s\n%s\n%s\n' "$R $R" "$out" "$R $R"
