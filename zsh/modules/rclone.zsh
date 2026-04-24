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
