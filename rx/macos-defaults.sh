#!/usr/bin/env bash
# ln ~/.config/rx/macos-defaults.sh ~/.local/bin/macdefaults

set -euo pipefail

show_usage() {
  cat <<EOF
Usage: macdefaults [-h|--help]

Applies the opinionated macOS defaults defined in this script.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  show_usage
  exit 0
fi

check_environment() {
  local os_type architecture
  os_type="$(uname -s)"
  [[ "$os_type" == "Darwin" ]] || {
    echo "This script only applies macOS defaults."
    return 1
  }

  architecture="$(uname -m)"
  case "$architecture" in
    x86_64) export MAC_TYPE="INTEL" ;;
    arm64) export MAC_TYPE="SILICON" ;;
    *) export MAC_TYPE="UNKNOWN" ;;
  esac

  echo "macOS $(sw_vers -productVersion) on $architecture"
}

get_sudo_access() {
  [[ -n "${TRAVIS_JOB_ID:-}" ]] && return 0
  sudo -v
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
}

write_default() {
  local domain="$1" key="$2" type="$3" value="$4"
  case "$type" in
    bool) defaults write "$domain" "$key" -bool "$value" ;;
    int) defaults write "$domain" "$key" -int "$value" ;;
    string) defaults write "$domain" "$key" -string "$value" ;;
    float) defaults write "$domain" "$key" -float "$value" ;;
    *) echo "Unknown type '$type' for $domain:$key" >&2; return 1 ;;
  esac
}

apply_user_defaults() {
  echo "Applying NSGlobalDomain defaults..."
  write_default NSGlobalDomain ApplePressAndHoldEnabled bool true
  write_default NSGlobalDomain AppleInterfaceStyle string Dark
  write_default NSGlobalDomain AppleShowScrollBars string Always
  write_default NSGlobalDomain NSAutomaticSpellingCorrectionEnabled bool false

  echo "Applying Finder defaults..."
  write_default com.apple.finder FXPreferredViewStyle string Nlsv
  write_default com.apple.finder ShowExternalHardDrivesOnDesktop bool true
  write_default com.apple.finder ShowPathbar bool true
  write_default com.apple.finder ShowStatusBar bool true
  write_default com.apple.finder FXEnableExtensionChangeWarning bool false

  echo "Applying Dock defaults..."
  write_default com.apple.dock tilesize int 25
  write_default com.apple.dock autohide bool true
  write_default com.apple.dock autohide-delay float 0
  write_default com.apple.dock autohide-time-modifier float 0
  write_default com.apple.dock launchanim bool false
  write_default com.apple.dock mru-spaces bool false
  write_default com.apple.dock orientation string right

  echo "Applying Safari defaults..."
  write_default com.apple.Safari ShowFavoritesBar bool false
  write_default com.apple.Safari IncludeDevelopMenu bool true
  write_default com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey bool true
}

apply_system_defaults() {
  echo "Applying Disk Arbitration defaults..."
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.DiskArbitration.diskarbitrationd DADisableEjectNotification -bool true
}

handle_ssd_optimizations() {
  if diskutil info disk0 | grep -q SSD >/dev/null 2>&1; then
    echo "Applying SSD optimizations..."
    if pmset -g batt 2>/dev/null | grep -q "InternalBattery"; then
      echo "Laptop detected; leaving hibernatemode unchanged."
    else
      echo "Desktop detected; setting hibernatemode 0."
      sudo pmset -a hibernatemode 0 || true
    fi
  fi
}

cleanup() {
  echo "Restarting affected services..."
  local apps=("Finder" "Dock" "SystemUIServer" "Safari")
  for app in "${apps[@]}"; do
    killall "$app" >/dev/null 2>&1 || true
  done
  sudo killall diskarbitrationd >/dev/null 2>&1 || true
}

main() {
  check_environment || exit 1
  get_sudo_access
  apply_user_defaults
  apply_system_defaults
  handle_ssd_optimizations
  cleanup
  echo "macOS defaults applied."
}

main "$@"
