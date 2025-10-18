# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles repository that manages macOS development environment configuration. The repository uses symbolic links to connect configurations from multiple locations into `~/.config`.

### Repository Structure

This repository is part of a multi-repo dotfiles setup:
- **dots** (this repo): Main configuration files
- **private** (separate repo): Private/sensitive configurations
- **lua-is-the-devil**: Neovim configuration (symlinked into nvim directory)

All configs are symlinked to `~/.config` via:
```bash
cd ~/.config
ln -s ~/.dotfiles/* .
```

## Key Directories

### rx/
Custom utility scripts that are hardlinked to `~/.local/bin/shortScriptName` and often aliased with 3-5 letter shortcuts.

Important scripts:
- `bootstrap-new-mac.sh`: Bootstrap script for setting up new macOS machines
- `youtube-downloader-utility.py`: Downloads opus files from YouTube with metadata and thumbnails
- `image-tool.py`: Image manipulation utilities
- `trans-pull.py`: Translation/transcription utility
- `slugged.sh`: URL slug generation
- `clipboard-to-file-operations.sh`: Clipboard utilities
- `make-script-and-open.sh`: Script creation helper
- `meta_helper.sh`: Metadata management
- Various note-taking utilities (`new_note.sh`, `note_link_finder.sh`, `note_move.sh`)

### nushell/
Nushell configuration (primary shell).

Files:
- `config.nu`: Main nushell configuration
- `env.nu`: Environment variables
- `aliases.nu`: Command aliases
- `startup.nu`: Startup scripts
- `modules/`: Custom nushell modules

### nvim/
Neovim configuration using vim-plug as plugin manager.

Structure:
- `init.lua`: Main entry point, bootstraps vim-plug
- `lua/core/`: Core settings
- `lua/plugins/`: Plugin configurations
- `lua/themes/`: Theme configurations
- Uses mini.nvim, LSP (nvim-lspconfig), blink.cmp for completion

### zsh/
Zsh configuration files (legacy, transitioning to nushell).

Files:
- `zshenv`: Environment variables
- `zshrc`: Main zsh configuration
- `zprofile`: Profile settings
- `modules/`: Modular zsh configurations

### Other Config Directories
- `atuin/`: Shell history sync
- `ghostty/`, `wezterm/`: Terminal emulator configs
- `btop/`: System monitor config
- `lazygit/`: Git TUI config
- `yazi/`: File manager config
- `kanata/`, `karabiner/`: Keyboard customization
- `fabric/`: AI prompt patterns
- `rclone/`: Cloud storage sync (for local NAS deduplication)

## Common Development Tasks

### Package Management
The repository uses Homebrew for package management. All packages are declared in `Brewfile`.

**Install packages from Brewfile:**
```bash
brew bundle install --file=~/repos/dots/Brewfile
```

**Update Brewfile with currently installed packages:**
```bash
brew bundle dump --file=~/repos/dots/Brewfile --force
```

### Bootstrap New Mac
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/gallo-s-chingon/dotfiles/main/rx/bootstrap-new-mac.sh)"
```

### Multi-Repo Sync
When making changes across the three repositories (dots, private, lua-is-the-devil), you need to:

1. Make changes in the respective local repo
2. Commit and push from each repo directory:
```bash
cd ~/.dotfiles && git pull origin main
cd ~/.private && git pull origin main
cd ~/.lua-is-the-devil && git pull origin main
```

### Working with Scripts
Scripts in `rx/` follow a pattern of being linked to `~/.local/bin/` with shortened names and aliased in shell config.

When adding new scripts:
1. Create script in `rx/`
2. Make executable: `chmod +x rx/script-name.sh`
3. Hardlink to local bin: `ln rx/script-name.sh ~/.local/bin/shortname`
4. Add alias in nushell `aliases.nu` or zsh modules

## Architecture Notes

### Shell Transition
The setup is transitioning from Zsh to Nushell as the primary shell. Both configurations are maintained but Nushell is preferred for new development.

### Neovim Plugin Strategy
- Uses vim-plug (not lazy.nvim or packer)
- Bootstraps automatically on first run
- Follows modular structure with separate plugin config files
- Uses `setup_plugin()` helper function for safe plugin loading

### Fabric Integration
Includes extensive AI prompt patterns from the Fabric project (`fabric/patterns/`). These are pre-built prompts for common tasks like analyzing code, creating summaries, etc.

### macOS-Specific
Many scripts and configurations are macOS-specific, particularly:
- Keyboard remapping (Kanata, Karabiner)
- macOS defaults configuration
- Homebrew bundle management
- Terminal emulator configs (Ghostty, WezTerm)

## Important Conventions

### File Naming
- Shell scripts: `kebab-case.sh`
- Python scripts: `kebab-case.py`
- Config files: Follow tool conventions (`.nu`, `.lua`, etc.)

### Documentation
The repository maintains `README.md` and `in-case-i-forget.md` for setup instructions. When updating setup procedures, update both files as appropriate.

### Symbolic Links
Configurations are meant to be symlinked to `~/.config`, not copied. Always verify symlinks are working correctly when making structural changes.
