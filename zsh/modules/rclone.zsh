# ~/.config/zsh/modules/rclone.zsh
# Rclone functions + rc* aliases
#
# Performance profiles:
#   large  — fewer big files:   --transfers 2 --checkers 4 --multi-thread-streams 8 --multi-thread-cutoff 256M
#   small  — many small files:  --transfers 8 --checkers 8

# Base opts as a proper array — bare string was the original bug (all opts became one arg)
_rc_base=(-P --exclude ".DS_Store" --fast-list)
_rc_move_extra=(--delete-empty-src-dirs)
_rc_profile_large=(--transfers 2 --checkers 4 --multi-thread-streams 8 --multi-thread-cutoff 256M)
_rc_profile_small=(--transfers 8 --checkers 8)

# Internal: strip .DS_Store then run rclone
_rc_run() {
  local src="$1"; shift
  [[ -e "$src" ]] || { echo "(눈︿눈) Source '$src' not found."; return 1; }
  [[ -d "$src" ]] && find "$src" -type f -name ".DS_Store" -delete 2>/dev/null
  rclone "$@" "$src"
}

# ── named functions (scriptable, tab-completable) ───────────────────────────

rclone-copy()       { _rc_run "$1" copy       "${_rc_base[@]}" "${_rc_profile_small[@]}" "$2"; }
rclone-copy-large() { _rc_run "$1" copy       "${_rc_base[@]}" "${_rc_profile_large[@]}" "$2"; }
rclone-move()       { _rc_run "$1" move       "${_rc_base[@]}" "${_rc_profile_small[@]}" "${_rc_move_extra[@]}" "$2"; }
rclone-move-large() { _rc_run "$1" move       "${_rc_base[@]}" "${_rc_profile_large[@]}" "${_rc_move_extra[@]}" "$2"; }
rclone-sync()       { _rc_run "$1" sync       "${_rc_base[@]}" "${_rc_profile_small[@]}" "$2"; }
rclone-sync-large() { _rc_run "$1" sync       "${_rc_base[@]}" "${_rc_profile_large[@]}" "$2"; }
rclone-dedupe-new() { _rc_run "$1" dedupe     "${_rc_base[@]}" --dedupe-mode newest --by-hash; }
rclone-dedupe-old() { _rc_run "$1" dedupe     "${_rc_base[@]}" --dedupe-mode oldest --by-hash; }

# ── rc* short aliases ────────────────────────────────────────────────────────
# copy
alias rccl='rclone-copy-large'   # copy  — large profile (big files, multi-thread)
alias rccs='rclone-copy'         # copy  — small profile (many small files)
# move
alias rcml='rclone-move-large'   # move  — large profile
alias rcms='rclone-move'         # move  — small profile
# sync
alias rcsl='rclone-sync-large'   # sync  — large profile
alias rcss='rclone-sync'         # sync  — small profile
# dedupe
alias rcdn='rclone-dedupe-new'   # dedupe — keep newest
alias rcdo='rclone-dedupe-old'   # dedupe — keep oldest

# ── config sync (local → external volumes via rsync) ───────────────────────
# Syncs ~/.config to one or more external volumes.
# Default targets: /Volumes/g2mini and /Volumes/salvajechingon
# Usage: confsync              — sync to all default targets
#        confsync g2mini       — sync to specific target
#        confsync x y          — sync to /Volumes/x and /Volumes/y
_confsync_targets=(g2mini salvajechingon)

confsync() {
  local names=("${@:-${_confsync_targets[@]}}")
  local src="${CF:-$HOME/.config}"
  local failed=0

  for name in "${names[@]}"; do
    local dest="/Volumes/$name"
    if [[ ! -d "$dest" ]]; then
      echo "⏭  $dest not mounted, skipping"
      continue
    fi

    echo "🔄 syncing $src → $dest/.config"
    rsync -av --delete \
      --exclude '*.env' \
      --exclude '.DS_Store' \
      "$src/" "$dest/.config/"

    if (( $? == 0 )); then
      echo "✅ $dest/.config done"
    else
      echo "❌ $dest/.config failed"
      (( failed++ ))
    fi
    echo
  done

  return $failed
}
