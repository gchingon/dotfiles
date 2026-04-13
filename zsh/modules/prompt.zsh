# ~/.config/zsh/modules/prompt.zsh
# Native Zsh prompt modeled after ~/.config/starship.toml

setopt prompt_subst
autoload -Uz add-zsh-hook colors
colors

zmodload zsh/datetime 2>/dev/null || true

typeset -g _prompt_cmd_start=0
typeset -g _prompt_cmd_duration_ms=0
typeset -g _prompt_last_status=0
typeset -g _prompt_local_ip_cache=""
typeset -g _prompt_local_ip_cache_at=0

_prompt_preexec() {
  _prompt_cmd_start=${EPOCHSECONDS:-0}
}

_prompt_precmd() {
  _prompt_last_status=$?
  local now=${EPOCHSECONDS:-0}
  if (( _prompt_cmd_start > 0 && now >= _prompt_cmd_start )); then
    _prompt_cmd_duration_ms=$(( (now - _prompt_cmd_start) * 1000 ))
  else
    _prompt_cmd_duration_ms=0
  fi
  _prompt_cmd_start=0
  PROMPT='$(_prompt_stacked_prompt)'
  RPROMPT=''
}

_prompt_is_ssh() {
  [[ -n "${SSH_CONNECTION:-}" || -n "${SSH_TTY:-}" ]]
}

_prompt_local_ip() {
  local now=${EPOCHSECONDS:-0}
  if (( now - _prompt_local_ip_cache_at < 60 )) && [[ -n "$_prompt_local_ip_cache" ]]; then
    print -r -- "$_prompt_local_ip_cache"
    return
  fi

  local ip=""
  ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
  [[ -n "$ip" ]] || ip="$(ipconfig getifaddr en1 2>/dev/null || true)"
  [[ -n "$ip" ]] || ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
  [[ -n "$ip" ]] || ip="$(ifconfig 2>/dev/null | awk '/inet / && $2 != "127.0.0.1" {print $2; exit}' || true)"

  _prompt_local_ip_cache="$ip"
  _prompt_local_ip_cache_at=$now
  print -r -- "$ip"
}

_prompt_fmt_ms() {
  local ms="${1:-0}"
  if (( ms >= 60000 )); then
    printf '%dm%02ds' $((ms / 60000)) $(((ms % 60000) / 1000))
  elif (( ms >= 1000 )); then
    awk "BEGIN { printf \"%.2fs\", ${ms}/1000 }"
  else
    printf '%dms' "$ms"
  fi
}

_prompt_git_segment() {
  command -v git >/dev/null 2>&1 || return 0
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0

  local modified added deleted numstat
  modified=$(git status --porcelain 2>/dev/null | grep -vc '^??' || true)
  numstat="$(git diff --numstat --ignore-submodules=all 2>/dev/null || true)"
  added=$(printf '%s\n' "$numstat" | awk '{a += $1} END {print a+0}')
  deleted=$(printf '%s\n' "$numstat" | awk '{d += $2} END {print d+0}')

  (( added > 0 )) && printf '%%F{green}+%s%%f ' "$added"
  (( deleted > 0 )) && printf '%%F{red}-%s%%f ' "$deleted"
  (( modified > 0 )) && printf '%%F{yellow}~%s%%f ' "$modified"
}

_prompt_character() {
  local keymap="${KEYMAP:-viins}"
  if [[ "$keymap" == "vicmd" ]]; then
    print -r -- '%F{green}⊻%f '
  elif (( _prompt_last_status == 0 )); then
    print -r -- '%F{yellow}%f '
  else
    print -r -- '%F{red}Ⅹ%f '
  fi
}

_prompt_directory() {
  local path="${PWD/#$HOME/∽}"
  local -a parts
  local prefix="" tail=""

  parts=("${(@s:/:)path}")
  if [[ "$path" == ∽* ]]; then
    prefix="∽"
    parts=("${parts[@]:1}")
  fi

  if (( ${#parts[@]} > 2 )); then
    tail="${(j:/:)parts[-2,-1]}"
    [[ -n "$prefix" ]] && path="${prefix}/…/${tail}" || path="…/${tail}"
  elif (( ${#parts[@]} > 0 )); then
    tail="${(j:/:)parts}"
    [[ -n "$prefix" ]] && path="${prefix}/${tail}" || path="${tail}"
  else
    path="${prefix:-/}"
  fi

  print -r -- "%F{blue}${path}%f"
}

_prompt_battery() {
  command -v pmset >/dev/null 2>&1 || return 0
  local batt pct symbol color
  batt="$(pmset -g batt 2>/dev/null | tail -1)"
  [[ "$batt" == *"InternalBattery"* ]] || return 0
  pct="$(printf '%s\n' "$batt" | grep -Eo '[0-9]{1,3}%' | head -1 | tr -d '%')"
  [[ -n "$pct" ]] || return 0

  if [[ "$batt" == *"; charging;"* ]]; then
    symbol="↑"
    color="green"
  else
    symbol="↓"
    if (( pct <= 20 )); then
      color="red"
    elif (( pct <= 50 )); then
      color="magenta"
    else
      color="yellow"
    fi
  fi

  print -r -- "%F{${color}} ${pct}%% ${symbol}%f"
}

_prompt_sudo() {
  sudo -n true >/dev/null 2>&1 || return 0
  print -r -- '%F{magenta}%f'
}

_prompt_left_prompt() {
  local out="" host ip user git_seg=""
  (( _prompt_cmd_duration_ms > 0 )) && out+="%F{white}⏲ $(_prompt_fmt_ms "$_prompt_cmd_duration_ms") %f"

  if _prompt_is_ssh; then
    host="${HOST%%.*}"
    ip="$(_prompt_local_ip)"
    out+="%F{green} ${host}%f "
    [[ -n "$ip" ]] && out+="@ %F{magenta}${ip}%f "
    out+="%F{yellow}${USER}%f "
  elif (( EUID == 0 )); then
    out+="%F{magenta}${USER}%f "
  fi

  git_seg="$(_prompt_git_segment)"
  [[ -n "$git_seg" ]] && out+="$git_seg"
  out+="$(_prompt_character)"
  print -r -- "$out"
}

_prompt_stacked_prompt() {
  local top="" bottom="" battery_seg="" sudo_seg="" git_seg="" prompt_seg=""

  battery_seg="$(_prompt_battery)"
  sudo_seg="$(_prompt_sudo)"
  git_seg="$(_prompt_git_segment)"
  prompt_seg="$(_prompt_character)"

  top+="%F{white}$(date +%T)%f"
  [[ -n "$battery_seg" ]] && top+=" ${battery_seg}"

  [[ -n "$git_seg" ]] && bottom+="$git_seg"
  bottom+="$(_prompt_directory)"
  [[ -n "${DOCKER_HOST:-}" ]] && bottom+=" %F{cyan}docker%f"
  (( _prompt_last_status != 0 )) && bottom+=" %F{red}${_prompt_last_status}%f"
  [[ -n "$sudo_seg" ]] && bottom+=" ${sudo_seg}"
  bottom+=" ${prompt_seg}"

  print -r -- "
${top}
${bottom}"
}

add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd
_prompt_precmd
