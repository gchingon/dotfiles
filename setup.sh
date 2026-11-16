#!/bin/bash
# setup.sh — one-command bootstrap for this dotfiles repo (lives at ~/.config).
#
#   git clone https://github.com/gallo-s-chingon/dotfiles.git ~/.config
#   ~/.config/setup.sh              # core: everything Hammerspoon/kanata/yabai/sketchybar need
#   ~/.config/setup.sh --full       # core + the whole Brewfile (apps, casks, cargo, mas)
#   ~/.config/setup.sh --dry-run    # show what would happen, change nothing
#
# Idempotent: re-run any time. It verifies each piece, only installs/links what
# is missing, and ends with a status report + the manual macOS permission steps
# no script can click for you. Written for bash 3.2 (macOS system bash) because
# it runs before Homebrew's bash exists.

set -u

CF="${XDG_CONFIG_HOME:-$HOME/.config}"
LB="$HOME/.local/bin"
LA="$HOME/Library/LaunchAgents"
UID_NUM="$(id -u)"
OLD_HOME="/Users/""schingon"     # path baked into kanata/*.kbd + zsh/zshrc (split so the sed below skips this file)

DRY=0; FULL=0; ASSUME_YES=0; DO_KANATA=1; DO_PATHFIX=1; DO_THEMES=1; DO_NVIM=1
for a in "$@"; do
  case "$a" in
    -n|--dry-run)     DRY=1 ;;
    --full)           FULL=1 ;;
    -y|--yes)         ASSUME_YES=1 ;;
    --skip-kanata)    DO_KANATA=0 ;;
    --no-path-fix)    DO_PATHFIX=0 ;;
    --skip-themes)    DO_THEMES=0 ;;
    --skip-nvim)      DO_NVIM=0 ;;
    -h|--help)        sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; echo "flags: --full --dry-run --yes --skip-kanata --no-path-fix --skip-themes --skip-nvim"; exit 0 ;;
    *) echo "unknown flag: $a (try --help)"; exit 2 ;;
  esac
done

# ── output helpers ───────────────────────────────────────────────────────────
if [ -t 1 ]; then B=$'\033[1m'; G=$'\033[32m'; Y=$'\033[33m'; R=$'\033[31m'; D=$'\033[2m'; Z=$'\033[0m'; else B='' G='' Y='' R='' D='' Z=''; fi
step() { printf '\n%s▸ %s%s\n' "$B" "$*" "$Z"; }
ok()   { printf '  %s✓%s %s\n' "$G" "$Z" "$*"; }
warn() { printf '  %s!%s %s\n' "$Y" "$Z" "$*"; WARNINGS="${WARNINGS}  - $*"$'\n'; }
bad()  { printf '  %s✗%s %s\n' "$R" "$Z" "$*"; }
note() { printf '  %s%s%s\n' "$D" "$*" "$Z"; }
WARNINGS=""

run() {  # run a command, or just print it under --dry-run
  if [ "$DRY" = 1 ]; then printf '  %s[dry-run]%s %s\n' "$D" "$Z" "$*"; return 0; fi
  "$@"
}
confirm() {  # confirm "question" → 0 if yes. --yes auto-accepts; no tty → no.
  [ "$ASSUME_YES" = 1 ] && return 0
  [ "$DRY" = 1 ] && return 0
  [ -t 0 ] || return 1
  printf '  %s?%s %s [y/N] ' "$Y" "$Z" "$1"; read -r ans; case "$ans" in y|Y|yes) return 0 ;; *) return 1 ;; esac
}
have() { command -v "$1" >/dev/null 2>&1; }

[ "$(uname)" = "Darwin" ] || { echo "macOS only (this config is yabai/kanata/Hammerspoon)."; exit 1; }
[ -d "$CF/.git" ] || warn "$CF is not a git checkout — fine if you copied it, but 'dots-sync' won't work"
[ "$DRY" = 1 ] && printf '%sDRY RUN — nothing will be changed%s\n' "$B" "$Z"

# ── 1. Xcode Command Line Tools ──────────────────────────────────────────────
step "Xcode Command Line Tools"
if xcode-select -p >/dev/null 2>&1; then ok "installed"
else
  run xcode-select --install
  warn "CLT install started in a GUI dialog — finish it, then re-run setup.sh"
  [ "$DRY" = 1 ] || exit 0
fi

# ── 2. Homebrew ──────────────────────────────────────────────────────────────
step "Homebrew"
BREW=/opt/homebrew/bin/brew
[ -x "$BREW" ] || { have brew && BREW="$(command -v brew)"; }
if [ -x "$BREW" ]; then ok "found at $BREW"
else
  run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  BREW=/opt/homebrew/bin/brew
fi
if [ -x "$BREW" ]; then eval "$("$BREW" shellenv)"; fi
if ! [ -x "$BREW" ] && [ "$DRY" = 0 ]; then bad "Homebrew install failed"; exit 1; fi

# ── 3. Packages ──────────────────────────────────────────────────────────────
step "Taps"
if [ -x "$BREW" ]; then
  TAPS_HAVE="$("$BREW" tap 2>/dev/null)"
  for t in asmvik/formulae felixkratz/formulae; do
    if echo "$TAPS_HAVE" | grep -qx "$t"; then ok "$t"; else run "$BREW" tap "$t" && ok "tapped $t"; fi
  done
fi

# formula [tap-qualified name] → checked/installed by its short name
CORE_FORMULAE="
asmvik/formulae/yabai
felixkratz/formulae/sketchybar
coreutils git gh jq fzf ripgrep fd bat eza zoxide starship atuin
neovim lazygit yazi btop tree wget curl lua
rustup bun node
zsh-autosuggestions zsh-syntax-highlighting zsh-completions zsh-autopair
"
# cask → app bundle (so a hand-installed app isn't reinstalled)
CORE_CASKS="
hammerspoon:Hammerspoon
kitty:kitty
karabiner-elements:Karabiner-Elements
raycast:Raycast
font-hack-nerd-font:
font-meslo-lg-nerd-font:
font-sketchybar-app-font:
"

step "Core formulae"
if [ -x "$BREW" ]; then
  F_HAVE="$("$BREW" list --formula -1 2>/dev/null)"
  for f in $CORE_FORMULAE; do
    short="${f##*/}"
    if echo "$F_HAVE" | grep -qx "$short"; then ok "$short"
    else run "$BREW" install "$f" && ok "installed $short" || bad "failed: $f"; fi
  done
fi

step "Core casks (Hammerspoon, kitty, Karabiner driver, Raycast, fonts)"
if [ -x "$BREW" ]; then
  C_HAVE="$("$BREW" list --cask -1 2>/dev/null)"
  for entry in $CORE_CASKS; do
    c="${entry%%:*}"; app="${entry#*:}"
    if echo "$C_HAVE" | grep -qx "$c" || { [ -n "$app" ] && [ -d "/Applications/$app.app" ]; }; then ok "$c"
    else run "$BREW" install --cask "$c" && ok "installed $c" || bad "failed: $c"; fi
  done
fi

if [ "$FULL" = 1 ]; then
  step "Full Brewfile ($CF/Brewfile) — this takes a while"
  run "$BREW" bundle --file="$CF/Brewfile" || warn "brew bundle reported failures (private tap, mas not signed in, …) — re-run to retry"
else
  note "skipping the full Brewfile — run with --full for every app/CLI in $CF/Brewfile"
fi

# ── 4. kanata binary (cargo) ─────────────────────────────────────────────────
step "kanata binary"
KANATA=""
for p in "$LB/kanata" "$HOME/.cargo/bin/kanata" /opt/homebrew/bin/kanata; do [ -x "$p" ] && { KANATA="$p"; break; }; done
if [ -n "$KANATA" ]; then ok "$KANATA"
else
  if ! have cargo && [ ! -x "$HOME/.cargo/bin/cargo" ]; then
    if have rustup-init || [ -x /opt/homebrew/opt/rustup/bin/rustup-init ]; then
      run "${BREW%/brew}/rustup-init" -y --no-modify-path 2>/dev/null || run /opt/homebrew/opt/rustup/bin/rustup-init -y --no-modify-path
    fi
  fi
  export PATH="$HOME/.cargo/bin:/opt/homebrew/opt/rustup/bin:$PATH"
  run cargo install kanata && ok "built kanata via cargo" || bad "cargo install kanata failed"
  KANATA="$HOME/.cargo/bin/kanata"
fi

# ── 5. Portable paths (config hardcodes /Users/schingon) ─────────────────────
step "Paths: $OLD_HOME → $HOME"
if [ "$HOME" = "$OLD_HOME" ]; then ok "same username as the original machine, nothing to rewrite"
elif [ "$DO_PATHFIX" = 0 ]; then note "skipped (--no-path-fix)"
else
  FILES="$(grep -rIl --exclude='*.zwc*' --exclude=.claude "$OLD_HOME" "$CF/kanata" "$CF/zsh" "$CF/rx" 2>/dev/null | grep -v '/\.claude/')"
  if [ -z "$FILES" ]; then ok "already rewritten"
  else
    n=0; for f in $FILES; do run sed -i '' "s#$OLD_HOME#$HOME#g" "$f"; n=$((n+1)); done
    ok "rewrote $n file(s) (kanata/, zsh/, rx/) — these show up in 'git diff'; don't commit them back if your other Macs use $OLD_HOME"
  fi
fi
run find "$CF/zsh" -name '*.zwc*' -delete 2>/dev/null   # stale compiled caches

# ── 6. Symlinks ──────────────────────────────────────────────────────────────
link() {  # link <target> <linkpath> — idempotent, backs up real files
  local target="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$target" ]; then ok "$dest"; return; fi
  [ -e "$target" ] || { warn "missing target $target (for $dest)"; return; }
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ]; then run rm "$dest"; else run mv "$dest" "$dest.bak.$(date +%Y%m%d%H%M%S)"; warn "backed up existing $dest"; fi
  fi
  [ -d "$(dirname "$dest")" ] || run mkdir -p "$(dirname "$dest")"
  run ln -s "$target" "$dest" && ok "$dest → $target"
}

step "Shell dotfiles"
link "$CF/zsh/zshenv"   "$HOME/.zshenv"
link "$CF/zsh/zprofile" "$HOME/.zprofile"
link "$CF/zsh/zshrc"    "$HOME/.zshrc"

step "Hammerspoon"
link "$CF/hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"   # init.lua resolves this symlink to find the repo
HS_CLI=/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
[ -x "$HS_CLI" ] && link "$HS_CLI" "$LB/hs" || note "hs CLI appears once Hammerspoon.app is installed"

step "Scripts in ~/.local/bin (from $CF/bin)"
run mkdir -p "$LB"
for f in "$CF"/bin/*; do
  case "$f" in *.swift) continue ;; esac
  [ -f "$f" ] && { run chmod +x "$f"; link "$f" "$LB/$(basename "$f")"; }
done
run chmod +x "$CF"/rx/*.sh "$CF/yabai/yabairc" "$CF/sketchybar/sketchybarrc" "$CF"/sketchybar/plugins/* 2>/dev/null
note "rx/ scripts are on PATH via zshenv (\$RX); nothing to link"

# ── 7. Machine-local env (gitignored) ────────────────────────────────────────
step "machine.env"
if [ -f "$CF/machine.env" ]; then ok "present"
else
  if [ "$DRY" = 1 ]; then note "[dry-run] would write a stub $CF/machine.env"
  else
    cat > "$CF/machine.env" <<EOF
# Machine-local env, sourced by zsh/zshenv. Gitignored (*.env) — fill in per machine.
# zshenv also switches on \$(hostname): 2mini*, 4mini*, mbp*/Mac* get a repo root (\$RP);
# any other hostname leaves \$RP unset — add a case in zsh/zshenv for this machine ($(hostname -s)).
export MACHINE_NAME="$(hostname -s)"
export MACHINE_USER="$USER"
# export NOTES_ROOT=
# export OC_VAULT_ROOT=
# export OC_SHARED_ROOT=
# export OC_PRIVATE_ROOT=
EOF
    ok "wrote stub machine.env"
  fi
  warn "machine.env is a stub — copy NOTES_ROOT/OC_* values from your other Mac"
fi

# ── 8. launchd user agents: yabai, brew services ─────────────
agent_load() {  # agent_load <plist path> <label>
  run launchctl bootout "gui/$UID_NUM/$2" 2>/dev/null
  run launchctl bootstrap "gui/$UID_NUM" "$1" && ok "loaded $2" || warn "could not load $2 (check: launchctl print gui/$UID_NUM/$2)"
}

step "yabai service"
run mkdir -p "$LA"
# yabai --restart-service hardcodes the FILENAME com.asmvik.yabai.plist; the internal
# Label is com.schingon.yabai (see the comment inside the plist). rx/yabai-restart.sh kickstarts that label.
if [ -f "$CF/yabai/com.asmvik.yabai.plist" ]; then
  run cp "$CF/yabai/com.asmvik.yabai.plist" "$LA/com.asmvik.yabai.plist"
  agent_load "$LA/com.asmvik.yabai.plist" com.schingon.yabai
fi

step "brew services (sketchybar)"
if [ -x "$BREW" ]; then
  for s in sketchybar; do
    if "$BREW" services list 2>/dev/null | awk -v s="$s" '$1==s && $2=="started"{f=1} END{exit !f}'; then ok "$s running"
    elif "$BREW" list --formula -1 2>/dev/null | grep -qx "$s"; then run "$BREW" services start "$s" && ok "started $s" || warn "could not start $s"
    else note "$s not installed"; fi
  done
fi

# ── 9. kanata LaunchDaemon (root) + Karabiner virtual-keyboard driver ────────
if [ "$DO_KANATA" = 1 ]; then
  step "kanata keyboard daemon (needs sudo)"
  LABEL="com.$USER.kanata"; DAEMON="/Library/LaunchDaemons/$LABEL.plist"
  VHID=/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager
  if [ -x "$KANATA" ] && "$KANATA" --cfg "$CF/kanata/kanata.kbd" --check >/dev/null 2>&1; then ok "kanata.kbd parses"
  else warn "kanata.kbd failed '--check' (or kanata missing) — daemon would crash-loop; fix before enabling"; fi

  TMP="$(mktemp)"
  cat > "$TMP" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>$LABEL</string>
  <key>ProgramArguments</key><array>
    <string>$KANATA</string><string>--cfg</string><string>$CF/kanata/kanata.kbd</string>
  </array>
  <key>RunAtLoad</key><true/>
  <key>KeepAlive</key><true/>
  <key>StandardOutPath</key><string>/var/log/kanata-$USER.log</string>
  <key>StandardErrorPath</key><string>/var/log/kanata-$USER.err</string>
</dict></plist>
EOF
  # (re)install when missing OR stale — an old plist pointing at a deleted macos.kbd crash-loops silently
  if [ -f "$DAEMON" ] && cmp -s "$TMP" "$DAEMON" && launchctl print "system/$LABEL" >/dev/null 2>&1; then ok "daemon $LABEL installed and current (starts at boot)"
  elif confirm "Install/update kanata root LaunchDaemon ($LABEL) so it starts at boot?"; then
    if [ -x "$VHID" ]; then run sudo "$VHID" activate || warn "driver activate failed"; else warn "Karabiner VirtualHID manager not found — install karabiner-elements first"; fi
    run sudo launchctl bootout "system/$LABEL" 2>/dev/null
    run sudo install -m 644 -o root -g wheel "$TMP" "$DAEMON"
    run sudo launchctl bootstrap system "$DAEMON" && ok "kanata daemon loaded" || warn "daemon not loaded — approve the permissions below, then: sudo launchctl bootstrap system $DAEMON"
  else warn "kanata daemon skipped — re-run with --yes (or in a terminal) to install it"; fi
  rm -f "$TMP"
fi

# ── 10. Themes (feeds Hammerspoon's theme chooser, kitty, nvim, sketchybar) ──
if [ "$DO_THEMES" = 1 ]; then
  step "Themes (theme --sync)"
  if [ -d "$CF/theme-switcher/cache" ] && [ -n "$(ls -A "$CF/theme-switcher/cache" 2>/dev/null)" ]; then ok "theme cache populated"
  elif [ -x "$LB/theme" ]; then
    run "$LB/theme" --sync && ok "themes synced" || warn "theme --sync failed (network?) — run: theme --sync"
    run "$LB/theme" --seed-custom 2>/dev/null || true
  fi
fi

# ── Dark mode, always ────────────────────────────────────────────────────────
# `theme` never consults macOS appearance (it is dark-only). Set the system to
# dark too, via defaults (no Automation popup); takes full effect at next login.
step "Force dark mode"
if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then ok "system already dark"
else run defaults write -g AppleInterfaceStyle -string Dark && ok "system set to dark (log out/in to apply everywhere)"; fi
if [ "$DO_THEMES" = 1 ] && [ -x "$LB/theme" ] && [ ! -s "$CF/theme-switcher/current" ]; then
  run "$LB/theme" random && ok "picked a dark theme" || warn "theme random failed — run: theme random"
fi

# ── 11. Neovim plugins ───────────────────────────────────────────────────────
if [ "$DO_NVIM" = 1 ] && have nvim; then
  step "Neovim plugins (LazyVim restore)"
  run nvim --headless "+Lazy! restore" +qa 2>/dev/null && ok "plugins restored from lazy-lock.json" || warn "nvim plugin restore failed — open nvim and run :Lazy sync"
fi

# ── 12. Launch Hammerspoon ───────────────────────────────────────────────────
step "Hammerspoon"
if [ -d /Applications/Hammerspoon.app ]; then
  if pgrep -x Hammerspoon >/dev/null; then run "$LB/hs" -c 'hs.reload()' 2>/dev/null; ok "running (reloaded config)"
  else run open -a Hammerspoon && ok "launched"; fi
else bad "Hammerspoon.app not installed"; fi

# ── Verification report ──────────────────────────────────────────────────────
step "Verification"
export PATH="$LB:$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"
MISSING=0
for b in brew git nvim yabai sketchybar kanata jq fzf rg fd bat eza zoxide starship atuin lazygit yazi btop lua cargo bun; do
  if have "$b"; then ok "$b"; else bad "$b not on PATH"; MISSING=$((MISSING+1)); fi
done
for app in Hammerspoon kitty Karabiner-Elements Raycast; do
  [ -d "/Applications/$app.app" ] && ok "$app.app" || { bad "$app.app missing"; MISSING=$((MISSING+1)); }
done
for l in "$HOME/.zshenv" "$HOME/.zshrc" "$HOME/.hammerspoon/init.lua"; do [ -e "$l" ] && ok "$l" || { bad "$l missing/broken"; MISSING=$((MISSING+1)); }; done
launchctl print "gui/$UID_NUM/com.schingon.yabai" >/dev/null 2>&1 && ok "yabai agent loaded" || warn "yabai agent not loaded"
launchctl print "system/com.$USER.kanata" >/dev/null 2>&1 && ok "kanata daemon loaded" || warn "kanata daemon not loaded"

[ -n "$WARNINGS" ] && { printf '\n%sWarnings:%s\n%s' "$Y" "$Z" "$WARNINGS"; }

cat <<EOF

${B}Manual steps macOS won't let a script do${Z} (System Settings → Privacy & Security):
  1. Accessibility:      Hammerspoon, yabai, Raycast
  2. Input Monitoring:   kanata ($KANATA)  and Karabiner-Elements
  3. Allow the Karabiner-DriverKit-VirtualHIDDevice system extension when prompted
     (General → Login Items & Extensions → Driver Extensions), then:
       sudo launchctl kickstart -k system/com.$USER.kanata
  4. Hammerspoon → Preferences → tick "Launch Hammerspoon at login"
  5. Optional yabai scripting-addition features need SIP partly disabled; this config doesn't require them.
  6. Open a new terminal (or: exec zsh -l) so zshenv/zshrc take effect. Check hostname case in zsh/zshenv for \$RP.
EOF
[ "$MISSING" = 0 ] && printf '\n%sAll required pieces present.%s\n' "$G" "$Z" || printf '\n%s%s required piece(s) missing — see ✗ above.%s\n' "$R" "$MISSING" "$Z"
