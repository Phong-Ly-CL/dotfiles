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

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cost=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
in_tok=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')

line=$(printf '[%s] $%.2f | ctx %s %s%% (%sk)' \
  "$model" "$cost" "$(bar "$ctx_pct")" "$ctx_pct" "$((in_tok / 1000))")

# Rate limits are only present on Pro/Max/Team subscriptions
five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)
[ -n "$five" ] && line="$line | 5h $(bar "$five") ${five}%"
[ -n "$week" ] && line="$line | 7d $(bar "$week") ${week}%"

echo "$line"
