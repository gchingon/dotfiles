# ~/.config/zsh/modules/sync.zsh
# Repo sync functions that coordinate local git state with peer machines.

_confsync_message() {
  local git_status="$1" added modified deleted renamed message

  if [[ -z "$git_status" ]]; then
    printf '%s\n' "config sync"
    return 0
  fi

  added="$(printf '%s\n' "$git_status" | grep -Ec '^\?\?|^A|^[ MARC]A' || true)"
  modified="$(printf '%s\n' "$git_status" | grep -Ec '^ M|^M |^MM|^AM|^RM|^CM' || true)"
  deleted="$(printf '%s\n' "$git_status" | grep -Ec '^ D|^D |^MD|^AD|^RD|^CD' || true)"
  renamed="$(printf '%s\n' "$git_status" | grep -Ec '^R|^.R' || true)"

  message="config sync:"
  (( modified > 0 )) && message+=" ${modified} modified;"
  (( added > 0 )) && message+=" ${added} added;"
  (( deleted > 0 )) && message+=" ${deleted} removed;"
  (( renamed > 0 )) && message+=" ${renamed} renamed;"
  printf '%s\n' "${message%;}"
}

confsync() {
  local repo branch upstream remote remote_branch
  local git_status ahead behind message

  repo="$HOME/.config"
  if ! git -C "$repo" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Not inside the config git repository."
    return 1
  fi

  setup-ssh

  branch="$(git -C "$repo" rev-parse --abbrev-ref HEAD)" || return 1
  upstream="$(git -C "$repo" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
  remote="${upstream%%/*}"
  remote_branch="${upstream#*/}"
  [[ -n "$remote" && -n "$remote_branch" ]] || {
    echo "No upstream configured for $repo."
    return 1
  }

  git -C "$repo" fetch -q "$remote" "$remote_branch" || return 1
  git_status="$(git -C "$repo" status --short)"

  read -r ahead behind < <(
    git -C "$repo" rev-list --left-right --count "${remote}/${remote_branch}...HEAD" 2>/dev/null \
      | awk '{print $2" "$1}'
  )
  ahead="${ahead:-0}"
  behind="${behind:-0}"

  if [[ -z "$git_status" && "$ahead" == "0" && "$behind" == "0" ]]; then
    "$RX/repo-pull-peers.sh" config "$@"
    return $?
  fi

  if [[ -z "$git_status" && "$ahead" == "0" && "$behind" -gt "0" ]]; then
    git -C "$repo" pull --ff-only -q "$remote" "$branch" || return 1
    "$RX/repo-pull-peers.sh" config "$@"
    return $?
  fi

  if [[ -z "$git_status" && "$ahead" -gt "0" && "$behind" == "0" ]]; then
    git -C "$repo" push -q "$remote" "$branch" || return 1
    "$RX/repo-pull-peers.sh" config "$@"
    return $?
  fi

  if [[ -z "$git_status" && "$ahead" -gt "0" && "$behind" -gt "0" ]]; then
    echo "Local .config and ${remote}/${remote_branch} have diverged. Resolve that before confsync."
    return 1
  fi

  message="$(_confsync_message "$git_status")"
  (
    cd "$repo" || exit 1
    git-add-commit-push "$message"
  ) || return 1

  "$RX/repo-pull-peers.sh" config "$@"
}
