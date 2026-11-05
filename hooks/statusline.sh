#!/usr/bin/env bash
# Status line: model + effort | dir + branch | context bar, cache hit, tokens | 5h limit | 7d limit.
# Icons are literal Nerd Font glyphs, so the terminal needs a Nerd Font to render them.
IFS=$'\x1f' read -r model dir effort pct hit tin tout h5 h5r d7 d7r < <(jq -r '
  def p: if . == null then "" else floor end;
  [ .model.display_name, .workspace.current_dir, (.effort.level // ""),
    (.context_window.used_percentage // 0 | floor),
    (.prompt_cache.hit_ratio | if . == null then "" else . * 100 | floor end),
    (.context_window.total_input_tokens // 0), (.context_window.total_output_tokens // 0),
    (.rate_limits.five_hour.used_percentage | p), (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage | p), (.rate_limits.seven_day.resets_at // "")
  ] | map(tostring) | join("\u001f")')

R=$'\e[0m' DIM=$'\e[2m' BLU=$'\e[34m' MAG=$'\e[35m' GRN=$'\e[32m' YEL=$'\e[33m' RED=$'\e[31m' CYN=$'\e[36m'
col() { (( $1 >= 90 )) && echo "$RED" || { (( $1 >= 70 )) && echo "$YEL" || echo "$GRN"; }; }
k() { awk -v n="$1" 'BEGIN{ if (n >= 1000) printf "%.1fk", n/1000; else printf "%d", n }'; }
at() { date -d "@$1" "$2" 2>/dev/null || date -r "$1" "$2"; }
# bash 3.2 corrupts a multibyte glyph inside `${out:+...}`, so the separator lives in a variable.
sep="│"

parts=("${CYN}󰚩 $model$R")

case $effort in low) n=1;; medium) n=2;; high) n=3;; xhigh) n=4;; max) n=5;; *) n=0;; esac
if (( n )); then
  bars=(▂ ▃ ▅ ▆ █) s=""
  for i in 0 1 2 3 4; do if (( i < n )); then s+="$YEL${bars[i]}$R"; else s+="$DIM${bars[i]}$R"; fi; done
  parts[0]+=" $s"
fi

seg="${BLU} ${dir##*/}$R"
branch=$(git --no-optional-locks -C "$dir" branch --show-current 2>/dev/null)
if [[ -n $branch ]]; then
  [[ -n $(git --no-optional-locks -C "$dir" status --porcelain 2>/dev/null | head -1) ]] && branch+="*"
  seg+=" ${MAG} $branch$R"
fi
parts+=("$seg")

f=$((pct / 10)); printf -v a "%${f}s"; printf -v b "%$((10 - f))s"
seg="$(col "$pct")${a// /▓}$DIM${b// /░}$R $pct%"
[[ -n $hit ]] && seg+="  ${GRN}●$hit%$R"
seg+="  ↓$(k "$tin") ${YEL}↑$(k "$tout")$R"
parts+=("$seg")

if [[ -n $h5 ]]; then t=$(at "$h5r" '+%-l:%M%P'); parts+=("$(col "$h5") $h5%$R ↻ ${t%m}"); fi
if [[ -n $d7 ]]; then t=$(at "$d7r" '+%a %-l%P'); parts+=("$(col "$d7") $d7%$R ↻ ${t%m}"); fi

out=""; for p in "${parts[@]}"; do out+="${out:+ $DIM$sep$R }$p"; done
printf '%s\n' "$out"
