# Jev model router — on/off switch and usage status
# Router itself lives in ~/.claude/jev-router/ (route.sh runs as a global
# Claude Code UserPromptSubmit hook, see ~/.claude/settings.json)

JEV_ROUTER_DIR="$HOME/.claude/jev-router"

jev-router-on() {
  mkdir -p "$JEV_ROUTER_DIR"
  echo "1" > "$JEV_ROUTER_DIR/enabled"
  echo "Jev router ON — your messages now pass through TypeSafe (the company behind Jev) for sizing. Turn it off before anything private: jev-router-off"
}

jev-router-off() {
  mkdir -p "$JEV_ROUTER_DIR"
  echo "0" > "$JEV_ROUTER_DIR/enabled"
  echo "Jev router OFF."
}

jev-router-status() {
  local enabled_file="$JEV_ROUTER_DIR/enabled"
  local log_file="$JEV_ROUTER_DIR/log.jsonl"
  local state="OFF"
  [ -f "$enabled_file" ] && [ "$(cat "$enabled_file" 2>/dev/null)" = "1" ] && state="ON"
  echo "Jev router: $state"
  if [ -f "$log_file" ] && [ -s "$log_file" ]; then
    echo "Messages routed by size:"
    jq -s 'group_by(.size) | map("  \(.[0].size): \(length)") | .[]' -r "$log_file"
    total_in=$(jq -s '[.[].input_tokens] | add' "$log_file")
    cost=$(echo "$total_in * 0.042 / 1000000" | bc -l 2>/dev/null)
    printf "Total Jev cost so far: \$%.6f (%s input tokens, output is free)\n" "${cost:-0}" "$total_in"
  else
    echo "No messages routed yet."
  fi
}
