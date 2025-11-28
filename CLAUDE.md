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

### Shell History: Atuin Integration
Atuin (`atuin/config.toml`) provides cross-session shell history sync:
- **Sync v2 Records**: Enabled by default (`records = true`)
- **Features**: Fuzzy search, host/directory/session filtering, secrets filtering
- **Keybindings**: Ctrl+R for interactive search, Up arrow for shell up-key binding
- **Configuration**:
  - `enter_accept = true`: Execute immediately on Enter
  - `sync_frequency`: How often history syncs (default 10m, syncs on command execution)
  - `filter_mode`: Global (default), host-specific, session, or directory-scoped
  - `search_mode`: Fuzzy (default), prefix, fulltext, or skim
- **Integration**: Automatically hooked into Nushell config.nu via `pre_execution` and `pre_prompt` hooks
- **Database**: Stored in `~/.local/share/atuin/history.db` (SQLite)

### Shell Completions: Carapace
Carapace (`carapace/`) provides context-aware command completion:
- **Purpose**: Dynamic completions for CLI tools (like kubectl, docker, git subcommands)
- **Integration**: Bridges between shell and completion engine (completion data as YAML/JSON)
- **Status**: Partially integrated, Nushell support may require custom bridge setup
- **Features**:
  - Context-aware suggestions based on previous arguments
  - Works with any command via completion spec files
  - Can be extended with custom completions
- **Configuration**: Located in `~/.config/carapace/`, includes zsh bridge for reference

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

## Per-App CLAUDE.md Guide

Each major configuration directory has its own specialized CLAUDE.md file for focused guidance:

### Core Development Tools
- **[nvim/CLAUDE.md](nvim/CLAUDE.md)**: Neovim editor configuration
  - Plugin architecture (vim-plug), LSP setup, themes, custom utilities
  - Markdown frontmatter generation, snippet system, keybindings

- **[nushell/CLAUDE.md](nushell/CLAUDE.md)**: Primary shell configuration
  - Modular structure (config.nu, env.nu, modules/), Atuin integration
  - Aliases, functions, environment variables, auto-CD hooks

- **[kanata/CLAUDE.md](kanata/CLAUDE.md)**: Keyboard remapping
  - Tap-hold mechanics, layers, hyper key system
  - macOS 77-key layout, tap-dance sequences

- **[wezterm/CLAUDE.md](wezterm/CLAUDE.md)**: Terminal emulator
  - Lua configuration modules, dynamic theming, workspace management
  - Appearance detection, project picker, zen mode

### Utilities & Scripts
- **[rx/CLAUDE.md](rx/CLAUDE.md)**: Custom utility scripts
  - Script patterns (Bash/Python), hardlinking convention
  - Content generation, media processing, file operations
  - Bootstrap and installation scripts

## Multi-Repo Structure

This dotfiles setup spans three repositories:
1. **dots** (this repo): Main configuration files, scripts, aliases
2. **private** (separate): Private/sensitive configurations (excluded from public view)
3. **lua-is-the-devil**: Dedicated Neovim configuration (can be showcased separately)

All repos are symlinked to `~/.config` for unified configuration management. When making changes across repos, remember to commit and push from each repo separately.

## Claude Code Workflow & Delegation Pattern

See [Delegation Pattern](.claude/DELEGATION_PATTERN.md) for details on planning, context management, and delegation strategies used across all configuration files.
