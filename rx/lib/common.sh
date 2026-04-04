#!/bin/bash
# ~/.config/rx/lib/common.sh — Shared functions for RX scripts
# Source with: source "$(dirname "$0")/lib/common.sh"

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

# Check dependencies
check_deps() {
  local missing=()
  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "${RED}Missing: ${missing[*]}${NC}" >&2
    exit 1
  fi
}

# Confirm action
confirm() {
  local prompt="${1:-Confirm?}"
  read -r -p "$prompt [y/N] " response
  [[ "$response" =~ ^[Yy]$ ]]
}

# Safe move with backup
safe-move() {
  local src="$1" dst="$2"
  [[ -e "$src" ]] || { echo "Source missing: $src"; return 1; }
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" ]]; then
    mv "$dst" "$dst.bak.$(date +%s)"
  fi
  mv "$src" "$dst"
}

# Log with timestamp
log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

# Error exit
die() {
  echo -e "${RED}Error: $*${NC}" >&2
  exit 1
}
