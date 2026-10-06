# ~/.config Structure

This document explains the purpose and organization of every directory in `~/.config`.

---

## 🔧 Core System Configuration

### **zsh/** — Shell environment & configuration
- `zshenv` — Environment variables (sourced before anything)
- `zprofile` — Login shell initialization
- `zshrc` — Interactive shell config (aliases, functions, keybindings)
- `modules/` — Modularized shell config (split by concern)
  - `aliases.zsh` — Command aliases
  - `functions.zsh` — Shell functions
  - `config.zsh` — Configuration utilities (open-* functions)
  - `git.zsh` — Git aliases & shortcuts
  - `prompt.zsh` — Prompt/theme config
  - `vi-cursor.zsh` — Vi-mode cursor styling
  - `plugins.zsh` — Plugin integrations (atuin, zoxide, etc.)
  - `skills.zsh` — Claude Code & workflow commands
  - `sync.zsh` — Sync/backup commands
  - `file_management.zsh` — File operations
  - `media.zsh` — Media & torrent tools
  - `agent_vault.zsh` — Agent vault commands
  - `torrent.zsh` — Torrent management
  - `imagemagick.zsh` — ImageMagick shortcuts
  - `rclone.zsh` — Rclone sync
  - `jev-router.zsh` — Router/network management

**Sourcing order:**
1. `zshenv` (always)
2. `omarchy4mac/zsh/omarchy.zsh` (baseline aliases)
3. `modules/*.zsh` (your overrides)

---

### **nvim/** — Neovim editor config
- Primary editor for all text/code editing
- Structured with `lua/` modules for plugins, keymaps, options

### **kitty/** — Terminal emulator (primary terminal)
- `kitty.conf` — Colors, fonts, keybindings
- Only terminal referenced; wezterm/ghostty removed

---

## 🎛️ System & Window Management

### **yabai/** — Tiling window manager
- Workspace management (5 workspaces)
- Window focus/move/resize controls
- Integrated with kanata keybindings

### **kanata/** — System-wide keybinding layer
- Keyboard remapping at OS level
- Aliases for common key combos
- Files:
  - `kanata.kbd` — Main config
  - `aliases-*.kbd` — Grouped aliases (apps, system, emoji, etc.)

### **raycast/** — App launcher & scripts
- Quick app switching
- Custom scripts via Raycast API
- Clipboard history integration

---

## 🎨 Visual & UI

### **omarchy/** → Symlink to `~/code/omarchy4mac/omarchy`
- Brand guidelines (colors, themes)
- Used by nvim, kitty, btop for consistent theming

### **sketchybar/** → Symlink to `~/code/omarchy4mac/sketchybar`
- macOS top status bar
- Shows workspaces, clock, battery, app name

### **borders/** → Symlink to `~/code/omarchy4mac/borders`
- Active window borders
- Visual window focus indicator

---

## 📊 Data & Sync Tools

### **atuin/** — Shell history search
- Cross-machine history sync
- Encrypted history storage
- Fuzzy search integration

### **rclone/** — Remote storage sync
- Cloud backup configuration
- Multiple storage providers

### **.secrets/** (git-ignored) — Private configuration
- `machine.env` — Machine-specific env vars
- `agent-vault.env` — Vault credentials
- `whatserver.env` — Server configs
- **Never commit these files**

---

## 🔨 Scripts & Tools

### **rx/** — Global executable scripts (50 scripts)
- Mounted at `~/.local/bin/` via symlinks
- Organized by category:
  - **System**: `yabai-restart.sh`, `system-toggle.sh`, `macos-defaults.sh`
  - **Notes**: `daily-notes.sh`, `new-note.sh`, `obsidian-open.sh`
  - **Media**: `video-converter.sh`, `dedupe-mp3.sh`, `save-thumb.sh`
  - **Backup**: `dots-sync.sh`, `agent-vault-*.sh`, `bak.sh`
  - **Dev**: `repo-sync-peers.sh`, `setup_ssh.sh`, `kitty-session.sh`
  - **Utilities**: `expand.sh`, `slugged.sh`, `find-and-do.sh`, etc.

See [rx/README.md](rx/README.md) for full documentation.

---

## 🛠️ Development & Config Tools

### **git/** — Git configuration
- Global gitconfig settings
- Git hooks or aliases

### **gh/** — GitHub CLI config
- Authentication tokens (git-ignored)
- GitHub API settings

### **atuin/** — History management
- Shell history sync across machines

### **templates/** — File templates
- Blueprints for new files (scripts, configs, etc.)

---

## 📦 Optional/Archived

### **vim/** — Legacy Vim config
- Kept for reference (nvim is primary)
- Not actively maintained

### **instaloader/** — Instagram downloader config
- Credentials for Instagram account scraping
- Specialized tool (not in daily workflow)

### **.archive/** (git-ignored) — Deprecated configs
- `theme-switcher/` — Superseded by omarchy4mac's `theme` command
- `swiftpm/` — Swift Package Manager (unused)
- Other one-off tools or experiments

---

## Other Directories

### **btop/** — System monitor config (colors)
- Inherits theme from omarchy4mac

### **lazygit/** — Git UI config
- Keybindings, colors

### **starship.toml** — Shell prompt (now superseded by omarchy4mac's prompt)

### **homebrew/**, **youtube-dl/**, **rclone/** — Tool-specific configs
- Kept for reference/setup

---

## Quick Reference

| Category | Key Files | Purpose |
|----------|-----------|---------|
| Shell | `zsh/zshrc`, `zsh/modules/` | Shell aliases, functions, prompt |
| Editor | `nvim/init.lua` | Text/code editor config |
| Terminal | `kitty/kitty.conf` | Terminal emulator config |
| WM | `yabai/yabairc` | Window tiling & management |
| Launcher | `raycast/` | App launcher integration |
| Scripts | `rx/*.sh` | Automation & utility scripts |
| Secrets | `.secrets/` (git-ignored) | Private env vars & credentials |
| Theme | `omarchy/` (symlink) | Colors & brand guidelines |

---

## Setup Notes

1. **First time:** Clone/symlink `~/code/omarchy4mac` if not present
2. **Daily:** All modules auto-source on shell startup
3. **Maintenance:** Use `dots-sync.sh` to push config changes to repo
4. **Performance:** Zsh startup ~0.5s (no compilation, optimized sourcing)

---

## See Also

- [SETUP.md](SETUP.md) — Onboarding & maintenance guide
- [rx/README.md](rx/README.md) — Script documentation
- [Makefile](Makefile) — Common automation tasks
