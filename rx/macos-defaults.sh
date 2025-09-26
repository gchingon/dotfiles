#!/bin/bash
# ln ~/.config/rx/macos-defaults.sh ~/.local/bin/macdefaults

check_environment() {
  # First, detect what kind of workshop we're in
  local os_type
  os_type="$(uname -s)"

  if [[ "$os_type" != "Darwin" ]]; then
    echo "🔧 This isn't a Mac workshop - skipping Mac-specific configurations"
    echo "✨ But don't worry, we can still set up your general tools via Homebrew!"
    return 1 # Return instead of exit - like passing the work to another tool
  fi

  # If we're here, we're in a Mac workshop - let's identify which kind
  local architecture
  architecture="$(uname -m)"

  case "$architecture" in
  "x86_64")
    echo "🛠 Intel Mac detected - running with the classic power tools"
    export MAC_TYPE="INTEL"
    ;;
  "arm64")
    echo "🛠 Apple Silicon Mac detected - running with the new power tools"
    export MAC_TYPE="SILICON"
    ;;
  *)
    echo "⚠️ Unknown Mac architecture: $architecture"
    echo "🤔 We'll try to continue, but some tools might not work right..."
    export MAC_TYPE="UNKNOWN"
    ;;
  esac

  # Log some useful system info for troubleshooting
  echo "📊 Workshop Details:"
  echo "   - OS Type: $os_type"
  echo "   - macOS Version: $(sw_vers -productVersion)"
  echo "   - Architecture: $architecture"
  echo "   - Machine: $(sysctl -n machdep.cpu.brand_string)"

  return 0 # Explicitly return success if we're on a Mac
}

get_sudo_access() {
  # Asking for the master key to the workshop
  if [[ -z "$TRAVIS_JOB_ID" ]]; then
    sudo -v
    # Keep our workshop pass active
    while true; do
      sudo -n true
      sleep 60
      kill -0 "$$" || exit
    done 2>/dev/null &
  fi
}

load_system_defaults() {
  # Loading our system toolbox - each tool has its purpose
  SYSTEM_DEFAULTS=(
    ["ApplePressAndHoldEnabled"]="false"
    ["KeyRepeat"]="1.1"
    ["InitialKeyRepeat"]="10"
    ["AppleInterfaceStyle"]="Dark"
    ["AppleShowScrollBars"]="Always"
    ["NSAutomaticSpellingCorrectionEnabled"]="false"
  )
}

load_finder_defaults() {
  # Setting up our workbench just right
  FINDER_DEFAULTS=(
    ["FXPreferredViewStyle"]="Nlsv"
    ["ShowExternalHardDrivesOnDesktop"]="true"
    ["ShowPathbar"]="true"
    ["ShowStatusBar"]="true"
    ["FXEnableExtensionChangeWarning"]="false"
  )
}

load_dock_defaults() {
  # Arranging our dock like tools on a pegboard - neat and accessible
  DOCK_DEFAULTS=(
    ["tilesize"]="36"
    ["autohide"]="true"
    ["autohide-delay"]="0"
    ["autohide-time-modifier"]="0"
    ["launchanim"]="false"
    ["mru-spaces"]="false"
    ["orientation"]="right"
  )
}

load_browser_defaults() {
  # Fine-tuning our web browsing tools like adjusting router blade depth
  BROWSER_DEFAULTS=(
    ["ShowFavoritesBar"]="false"
    ["IncludeDevelopMenu"]="true"
    ["WebKitDeveloperExtrasEnabledPreferenceKey"]="true"
    # ["com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled"]="true"
  )
}

apply_defaults() {
  local domain="$1"
  local defaults_array="$2[@]"
  local defaults=(${!defaults_array})

  # Like measuring twice, cutting once
  echo "📏 Applying $domain settings..."
  for key in "${!defaults[@]}"; do
    defaults write "$domain" "$key" "${defaults[$key]}" ||
      echo "Failed to set $key for $domain - might need different measurements"
  done
}

handle_ssd_optimizations() {
  # SSDs need different care than old spinning rust
  if diskutil info disk0 | grep SSD >/dev/null 2>&1; then
    echo "🧰 Tuning up your SSD..."
    sudo pmset -a hibernatemode 0
    sudo tmutil disablelocal
    # More SSD optimizations...
  fi
}

cleanup() {
  # Clean up our workspace
  echo "🧹 Sweeping up the sawdust..."
  local apps=("Finder" "Dock" "SystemUIServer" "Terminal" "Mail" "Safari")
  for app in "${apps[@]}"; do
    killall "$app" >/dev/null 2>&1 || true
  done
}

main() {
  check_environment
  get_sudo_access

  # Load all our settings blueprints
  load_system_defaults
  load_finder_defaults
  load_dock_defaults    # Added
  load_browser_defaults # Added
  load_mail_defaults    # Added

  # Time to start building - now applying all our settings
  apply_defaults "NSGlobalDomain" SYSTEM_DEFAULTS
  apply_defaults "com.apple.finder" FINDER_DEFAULTS
  apply_defaults "com.apple.dock" DOCK_DEFAULTS      # Added
  apply_defaults "com.apple.Safari" BROWSER_DEFAULTS # Added
  apply_defaults "com.apple.mail" MAIL_DEFAULTS      # Added

  handle_ssd_optimizations
  cleanup

  echo "🎉 Workshop's clean and tools are sharp - ready for work!"
}

# Fire up the power tools
main "$@"
