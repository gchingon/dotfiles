# ~/.config/zsh/modules/config.zsh
# Zsh configuration utilities

# Source zshrc and update compiled files
source-zshrc() {
  update-zwc
  source "$HOME/.config/zsh/zshrc" >/dev/null
}

# Compile zsh files for faster loading
# `zcompile` creates .zwc files to speed up sourcing
update-zwc() {
  local file
  for file in "$DZ"/modules/*.zsh "$DZ"/z*; do
    [[ -f "$file" ]] || continue
    zcompile "$file" && echo "Compiled $file"
  done
}

# Open config files in Neovim
open-zshrc() { nvim "$DZ/zshrc"; }
open-zsh-history() { nvim "$HOME/.zsh_history"; }
open-aliases() { nvim "$DZ/modules/aliases.zsh"; }
open-functions() { nvim "$DZ/modules/functions.zsh"; }
open-nvim-init() { nvim "$NV/init.lua"; }
open-wezterm() { nvim "$CF/wezterm/wezterm.lua"; }
open-ghostty() { nvim "$CF/ghostty/config"; }

open-secrets() {
  local target="${1:-}"
  local tmp_file encrypted_tmp target_dir editor_status=0

  [[ -n "$target" ]] || {
    echo "Usage: open-secrets <file>"
    return 1
  }
  command -v gpg >/dev/null 2>&1 || { echo "Missing: gpg"; return 1; }
  command -v nvim >/dev/null 2>&1 || { echo "Missing: nvim"; return 1; }

  case "$target" in
    ~/*) target="${HOME}/${target#~/}" ;;
  esac
  [[ "$target" = /* ]] || target="$PWD/$target"

  target_dir="$(dirname "$target")"
  mkdir -p "$target_dir" || return 1

  umask 077
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/open-secrets.XXXXXX")" || return 1
  encrypted_tmp="$(mktemp "${TMPDIR:-/tmp}/open-secrets.enc.XXXXXX")" || {
    rm -f "$tmp_file"
    return 1
  }
  rm -f "$encrypted_tmp"

  if [[ -f "$target" ]]; then
    if gpg --quiet --list-packets "$target" >/dev/null 2>&1; then
      gpg --quiet --decrypt --output "$tmp_file" "$target" || {
        rm -f "$tmp_file"
        return 1
      }
    else
      cp "$target" "$tmp_file" || {
        rm -f "$tmp_file"
        return 1
      }
    fi
  fi

  nvim "$tmp_file" || editor_status=$?
  if [[ "$editor_status" -ne 0 ]]; then
    echo "Editor exited with status $editor_status; plaintext left at $tmp_file"
    return "$editor_status"
  fi

  gpg --yes --symmetric --cipher-algo AES256 --output "$encrypted_tmp" "$tmp_file" || {
    echo "Encryption failed; plaintext left at $tmp_file"
    return 1
  }

  mv "$encrypted_tmp" "$target" || return 1
  rm -f "$tmp_file"
}
