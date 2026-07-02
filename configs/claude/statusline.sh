#!/bin/bash
input=$(cat)

RESET=$'\033[0m'
DIM=$'\033[2m'

# Draw a bar like ███░░░░░░░ for a 0-100 percentage,
# colored green (<50), yellow (50-79), or red (>=80)
bar() {
  local pct=$1 width=${2:-10}
  [ "$pct" -gt 100 ] && pct=100
  local color=$'\033[32m'
  (( pct >= 50 )) && color=$'\033[33m'
  (( pct >= 80 )) && color=$'\033[31m'
  local filled=$(( pct * width / 100 ))
  local full="" empty=""
  for ((i = 0; i < filled; i++)); do full+="█"; done
  for ((i = filled; i < width; i++)); do empty+="░"; done
  echo "${color}${full}${RESET}${DIM}${empty}${RESET}"
}

# Time remaining until a unix epoch timestamp, like 2h13m or 6d4h
countdown() {
  local diff=$(( $1 - $(date +%s) ))
  (( diff < 0 )) && diff=0
  local d=$(( diff / 86400 )) h=$(( diff % 86400 / 3600 )) m=$(( diff % 3600 / 60 ))
  if (( d > 0 )); then echo "${d}d${h}h"
  elif (( h > 0 )); then echo "${h}h${m}m"
  else echo "${m}m"
  fi
}

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
in_tok=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')

line=$(printf '[%s] $%.2f | ctx %s %s%% (%sk)' \
  "$model" "$cost" "$(bar "$ctx_pct")" "$ctx_pct" "$((in_tok / 1000))")

# Rate limits are only present on Pro/Max/Team subscriptions
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty' | cut -d. -f1)
week_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty' | cut -d. -f1)
if [ -n "$five" ]; then
  line="$line | 5h $(bar "$five") ${five}%"
  [ -n "$five_reset" ] && line="$line ${DIM}↻$(countdown "$five_reset")${RESET}"
fi
if [ -n "$week" ]; then
  line="$line | 7d $(bar "$week") ${week}%"
  [ -n "$week_reset" ] && line="$line ${DIM}↻$(countdown "$week_reset")${RESET}"
fi

echo "$line"
