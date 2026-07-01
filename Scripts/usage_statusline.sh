#!/bin/bash
# Caches Claude Code's real rate-limit usage JSON for ClaudeUsageMenuBar to read,
# and prints a compact status line.
input=$(cat)
echo "$input" > "$HOME/.claude/usage_status_cache.json"

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

out=""
[ -n "$five" ] && out="5h:$(printf '%.0f' "$five")%"
[ -n "$week" ] && out="$out 7d:$(printf '%.0f' "$week")%"
echo "$out"
