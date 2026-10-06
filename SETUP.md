# Setup & Maintenance Guide

---

## 🚀 Initial Setup

### First-Time Setup
```bash
# 1. Clone omarchy4mac if needed
git clone https://github.com/yourusername/omarchy4mac ~/code/omarchy4mac

# 2. Link omarchy components
ln -sf ~/code/omarchy4mac/omarchy ~/.config/omarchy
ln -sf ~/code/omarchy4mac/sketchybar ~/.config/sketchybar
ln -sf ~/code/omarchy4mac/borders ~/.config/borders

# 3. Install dependencies (via Brewfile or manually)
brew install zsh nvim kitty yabai kanata raycast atuin rclone

# 4. Verify setup
make test  # (runs syntax checks on zsh files)
```

### What Happens on Shell Startup
1. System loads `zshenv` (environment variables)
2. Shell sources omarchy4mac defaults (`omarchy.zsh`)
3. Shell sources your modules (`~/.config/zsh/modules/*.zsh`)
4. Your aliases override omarchy's (same-name functions re-source last)

---

## 📋 Daily Workflow

### Common Commands
```bash
# Open config files
open-zshrc      # Edit shell config
open-nvim-init  # Edit Neovim config
open-kitty      # Edit terminal config
open-aliases    # Edit aliases

# Sync your dotfiles repo
dots-sync       # Push changes to git

# Refresh shell after changes
source-zshrc    # Reload config + clean compiled files

# View startup time
time zsh -i -c exit  # Should be ~0.5s
```

### System Shortcuts
```bash
yabai-restart          # Restart tiling WM after config change
system-toggle          # Toggle system settings (Do Not Disturb, etc.)
macos-defaults         # Apply macOS preferences
clean-memory           # Free up system RAM
```

### Note-Taking
```bash
daily-notes     # Create/open today's note
new-note        # Create new note with template
obsidian-open   # Open Obsidian vault folder
```

### Media & Files
```bash
video-converter [file]     # Convert video formats
dedupe-mp3                 # Remove duplicate .mp3 files
find-and-do [pattern]      # Find files matching pattern
save-thumb                 # Screenshot thumbnail to clipboard
slugged [text]             # Create URL-safe filename
```

### Development
```bash
repo-sync-peers            # Sync git repos from peer machines
setup_ssh                  # Configure SSH keys
kitty-session              # Create persistent kitty session
```

---

## 🔄 Syncing & Backup

### Dotfiles Backup
```bash
# Push local changes to dotfiles repo
dots-sync

# View what changed
git -C ~/.config status
git -C ~/.config log --oneline -10
```

### Cloud Backup (rclone)
```bash
# Configured in ~/.config/rclone/
# Sync to configured remote storage
rclone sync ~/.config remote:config-backup
```

### History Sync (atuin)
```bash
# Zsh history syncs across machines via atuin
# Stored in ~/.config/zsh/.zsh_history (XDG compliant)
# Search: Ctrl+R in zsh
```

---

## 🛠️ Troubleshooting

### Slow Shell Startup
```bash
# Profile which module is slow
time zsh -i -c exit

# Individual module timing
for f in ~/.config/zsh/modules/*.zsh; do
  echo "Timing $(basename $f)..."
  time zsh -c "source $f"
done
```

### Alias Not Working
- Ensure your alias is in `~/.config/zsh/modules/aliases.zsh`
- Re-source: `source-zshrc`
- Check for conflict: `alias | grep your_alias_name`
- Omarchy might have same alias (yours loads last, so should override)

### Script Not Found
```bash
# Check if linked to ~/.local/bin
ls -la ~/.local/bin/script_name

# Create symlink if missing
ln -s ~/.config/rx/script-name.sh ~/.local/bin/script-name

# Or add ~/.config/rx to PATH
export PATH="$PATH:$HOME/.config/rx"
```

### Secrets Not Loading
```bash
# Check .secrets/ directory exists
ls -la ~/.config/.secrets/

# Verify sourced in zshenv
grep ".secrets" ~/.config/zsh/zshenv

# Source manually
source ~/.config/.secrets/machine.env
```

---

## 🧹 Maintenance

### Weekly
- Review new script files in `rx/`
- Check for unused aliases (clean up if possible)

### Monthly
- Sync omarchy4mac updates: `cd ~/code/omarchy4mac && git pull`
- Update Homebrew: `brew update && brew upgrade`
- Backup dotfiles: `dots-sync`

### As-Needed
- Add new aliases to `modules/aliases.zsh`
- Create new scripts in `rx/` (document in `rx/README.md`)
- Update Neovim plugins: `:Lazy update` in nvim

---

## 📚 Documentation

- [STRUCTURE.md](STRUCTURE.md) — Explains every directory
- [rx/README.md](rx/README.md) — Documents all 50 scripts
- [Makefile](Makefile) — Common automation tasks

---

## Performance Targets

| Metric | Target | Current |
|--------|--------|---------|
| Zsh startup | <0.6s | ~0.5s |
| Kitty launch | <1s | ✓ |
| Yabai restart | <2s | ✓ |
| Sync dotfiles | <30s | ✓ |

---

## Emergency Recovery

### Restore from backup
```bash
cd ~/.config
git checkout HEAD -- .  # Discard all local changes
git pull origin main    # Pull latest from remote
source-zshrc           # Reload everything
```

### Hard reset (nuclear option)
```bash
cd ~/.config
git reset --hard HEAD~5  # Go back 5 commits
git clean -fd            # Remove untracked files
source-zshrc
```

---

## See Also

- [STRUCTURE.md](STRUCTURE.md) — Config organization
- [rx/README.md](rx/README.md) — Script reference
- [Makefile](Makefile) — Automation
- `~/.config/zsh/zshrc` — Shell startup order
