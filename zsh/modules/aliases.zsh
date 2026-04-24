# ~/.config/zsh/modules/aliases.zsh
# Central alias registry.
# Each alias comment explains what it does and where the target lives.

# ===== General Aliases =====
alias c='clear'                           # Clear the terminal screen; source: clear -- shell builtin / CLI tool
alias c-='cd -'                           # Jump to the previous directory; source: cd -- shell builtin
alias cdc='cd && c'                       # Go to $HOME and clear the screen; source: cd -- shell builtin, c alias above
alias dt='date "+%F"'                     # Print YYYY-MM-DD date; source: date -- CLI tool
alias e='exit 0'                          # Exit the current shell successfully; source: exit -- shell builtin
alias ex='expand'                         # Expand tabs to spaces; source: expand -- CLI tool
alias grep='grep --color=auto'            # Grep with colored matches; source: grep -- CLI tool
alias lock='chflags uchg '                # Lock a file on macOS; source: chflags -- macOS CLI tool
alias ln='ln -i'                          # Interactive symlink / link creation; source: ln -- CLI tool
alias mnf='mediainfo'                     # Show media metadata; source: mediainfo -- brew formula / CLI tool
alias o.='open .'                         # Open the current directory in Finder; source: open -- macOS CLI tool
alias nowrap='setterm --linewrap off'     # Disable terminal line wrapping; source: setterm -- CLI tool
alias wrap='setterm --linewrap on'        # Enable terminal line wrapping; source: setterm -- CLI tool
alias sv='sudo nvim '                     # Open a file in Neovim with sudo; source: sudo -- CLI tool, nvim -- CLI tool
alias dcd='docker-compose down'           # Stop docker-compose services; source: docker-compose -- CLI tool
alias dcu='docker-compose up -d'          # Start docker-compose services in background; source: docker-compose -- CLI tool
alias theme='${HOME}/.config/rx/theme'    # Run theme switcher; source: theme -- /Users/schingon/.config/rx/theme
alias t='theme'                           # Short alias for theme switcher; source: theme alias above
alias tn='theme'                          # Cycle or run theme with default behavior; source: theme alias above
alias tl='theme --list'                   # List available themes; source: theme -- /Users/schingon/.config/rx/theme
alias tc='theme --current'                # Show current theme; source: theme -- /Users/schingon/.config/rx/theme
alias ytv='ytd video'                     # Download video format via ytd helper; source: ytd -- ~/.local/bin/ytd
alias dots='dots-sync'                    # Run dotfiles sync helper; source: dots-sync() -- /Users/schingon/.config/zsh/modules/functions.zsh
alias d4d='defaults delete com.charliemonroe.Downie-4'

# ===== Git and Sync Aliases =====
alias g='git'                             # Short alias for git; source: git -- CLI tool
alias gac='git-add-commit-push'           # Stage, commit, and push current repo; source: git-add-commit-push() -- /Users/schingon/.config/zsh/modules/git.zsh
alias gfh='git fetch'                     # Fetch from current git remote; source: git -- CLI tool
alias gpl='git-pull'                      # Pull current branch with rebase; source: git-pull() -- /Users/schingon/.config/zsh/modules/git.zsh
alias gph='git-push'                      # Push current branch; source: git-push() -- /Users/schingon/.config/zsh/modules/git.zsh
alias gst='git status'                    # Show git working tree status; source: git -- CLI tool
alias notesync='$RX/repo-sync-peers.sh notes' # Direct-push notes repo to peer working trees; source: repo-sync-peers.sh -- /Users/schingon/.config/rx/repo-sync-peers.sh
alias podsync='$RX/repo-sync-peers.sh pod-content' # Direct-push pod-content repo to peer working trees; source: repo-sync-peers.sh -- /Users/schingon/.config/rx/repo-sync-peers.sh
alias cfs='confsync'                      # Sync ~/.config via origin then peer pulls; source: confsync() -- /Users/schingon/.config/zsh/modules/sync.zsh
alias cts='cryptsync'                     # Sync crypt / agent vault repo; source: cryptsync() -- /Users/schingon/.config/zsh/modules/agent_vault.zsh
alias nts='notesync'                      # Short alias for notes peer sync; source: notesync alias above
alias pds='podsync'                       # Short alias for pod-content peer sync; source: podsync alias above

# ===== Agent / Vault Aliases =====
alias av='cd "$AGENT_VAULT_PATH"'         # Enter the agent vault repo; source: AGENT_VAULT_PATH env -- /Users/schingon/.config/agent-vault.env
alias crypt='cd "$AGENT_VAULT_PATH"'      # Enter the crypt repo; source: AGENT_VAULT_PATH env -- /Users/schingon/.config/agent-vault.env
alias avi='agent-vault-init'              # Initialize the agent vault repo; source: agent-vault-init -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-init.sh
alias avs='agent-vault-status'            # Show agent vault status; source: agent-vault-status -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-status.sh
alias avsync='agent-vault-sync'           # Sync agent vault with origin and peers; source: agent-vault-sync -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-sync.sh
alias avc='agent-vault-checkpoint'        # Write a checkpoint and sync vault; source: agent-vault-checkpoint -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-checkpoint.sh
alias avh='agent-vault-handoff'           # Create an agent handoff note; source: agent-vault-handoff -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-handoff.sh
alias avm='agent-vault-monitor'           # Generate an agent vault monitor report; source: agent-vault-monitor -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-monitor.sh
alias avb='agent-vault-memory-backup'     # Save memory backup note into vault; source: agent-vault-memory-backup -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-memory-backup.sh
alias cryptstatus='agent-vault-status'    # Show crypt / vault status; source: agent-vault-status -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-status.sh
alias cryptcheck='agent-vault-checkpoint' # Checkpoint crypt / vault state; source: agent-vault-checkpoint -- ~/.local/bin -> /Users/schingon/.config/rx/agent-vault-checkpoint.sh
alias obs='obsidian'                      # Launch the Obsidian app; source: obsidian -- /Applications/Obsidian.app/Contents/MacOS/obsidian
alias obsidian_search='vault_search'      # Search markdown content in the vault; source: vault_search() -- /Users/schingon/.config/zsh/modules/agent_vault.zsh
alias vault_grep='vault_search'           # Short alias for vault search; source: vault_search() -- /Users/schingon/.config/zsh/modules/agent_vault.zsh

# ===== Hermes / Skills Aliases =====
alias hsl='hermes sessions list'          # List Hermes sessions; source: hermes -- ~/.local/bin/hermes
alias hsb='hermes sessions browse'        # Browse Hermes sessions; source: hermes -- ~/.local/bin/hermes
alias hu='hermes update'                  # Update Hermes; source: hermes -- ~/.local/bin/hermes
alias hrm='hermes sessions delete'        # Delete Hermes sessions; source: hermes -- ~/.local/bin/hermes
alias skills-list="python3 ${HOME}/.hermes/scripts/skill-adopt.py list"   # List adoptable Hermes skills; source: skill-adopt.py -- ${HOME}/.hermes/scripts/skill-adopt.py
alias skills-adopt="python3 ${HOME}/.hermes/scripts/skill-adopt.py adopt" # Adopt a Hermes skill; source: skill-adopt.py -- ${HOME}/.hermes/scripts/skill-adopt.py
alias skills-sync="python3 ${HOME}/.hermes/scripts/skill-adopt.py sync"   # Sync Hermes skills registry; source: skill-adopt.py -- ${HOME}/.hermes/scripts/skill-adopt.py

# ===== File Management Aliases =====
alias d='fd -H -t f .DS_Store -X rm -frv' # Delete .DS_Store files recursively; source: fd -- brew formula / CLI tool, rm -- CLI tool
alias f='fzf '                            # Launch fzf with room for arguments; source: fzf -- brew formula / CLI tool
alias ft='fd-types'                       # List file extensions per directory; source: fd-types() -- /Users/schingon/.config/zsh/modules/file_management.zsh
alias mk='mkdir -pv'                      # Make directories verbosely with parents; source: mkdir -- CLI tool
alias mio='move-iso'                      # Move ISO / DMG / PKG files to backup target; source: move-iso() -- /Users/schingon/.config/zsh/modules/file_management.zsh
alias mtt='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv $HOME/.Trash' # Empty mounted-volume and user trash; source: rm -- CLI tool
alias rm='rm -rfv'                        # Remove recursively and verbosely; source: rm -- CLI tool
alias srm='sudo rm -rfv'                  # Remove recursively with sudo; source: rm -- CLI tool
alias mpx='move-pix'                      # Move image files to Pictures; source: move-pix() -- /Users/schingon/.config/zsh/modules/file_management.zsh
alias rpx='rm-pix'                        # Remove image files from a directory; source: rm-pix() -- /Users/schingon/.config/zsh/modules/file_management.zsh

# ===== Blog / Notes / Transcript Aliases =====
alias blog='$RX/blog.sh blog'             # Create or manage a blog post; source: blog.sh -- /Users/schingon/.config/rx/blog.sh
alias epi='$RX/blog.sh epi'               # Create or manage an episode post; source: blog.sh -- /Users/schingon/.config/rx/blog.sh
alias feat='$RX/blog.sh feat'             # Create or manage a feature post; source: blog.sh -- /Users/schingon/.config/rx/blog.sh
alias vtm='tsp vtm'                       # Convert an existing VTT transcript; source: tsp -- ~/.local/bin/tsp
alias stm='tsp stm'                       # Convert an existing SRT transcript; source: tsp -- ~/.local/bin/tsp
alias cl='clear; ls'                      # Clear the screen and list current directory; source: clear -- shell builtin / CLI, ls alias below

# ===== Local Script Wrapper Aliases =====
alias fdm='filemgr move'                  # File-manager move mode; source: filemgr -- ~/.local/bin/filemgr
alias fdd='filemgr exclude'               # File-manager exclude mode; source: filemgr -- ~/.local/bin/filemgr
alias fdf='filemgr find'                  # File-manager find mode; source: filemgr -- ~/.local/bin/filemgr
alias pof='clipops paste'                 # Paste clipboard into file; source: clipops -- ~/.local/bin/clipops
alias paf='clipops append'                # Append clipboard to file; source: clipops -- ~/.local/bin/clipops
alias ctc='clipops copy'                  # Copy file contents to clipboard; source: clipops -- ~/.local/bin/clipops
alias w2b='clipops wcpcmd'                # Copy command and output as markdown block; source: clipops -- ~/.local/bin/clipops
alias wob='clipops wcmd'                  # Copy command output as markdown block; source: clipops -- ~/.local/bin/clipops

# ===== Image Management Aliases =====
alias ffav='ffmpeg-remux-audio-video'     # Remux audio and video without re-encoding; source: ffmpeg-remux-audio-video() -- /Users/schingon/.config/zsh/modules/media.zsh
alias 50p='imagemagick-resize-50'         # Resize an image to 50 percent; source: imagemagick-resize-50() -- /Users/schingon/.config/zsh/modules/imagemagick.zsh
alias 500='imagemagick-resize-500'        # Resize an image to width 500; source: imagemagick-resize-500() -- /Users/schingon/.config/zsh/modules/imagemagick.zsh
alias 720='imagemagick-resize-720'        # Resize an image to width 720; source: imagemagick-resize-720() -- /Users/schingon/.config/zsh/modules/imagemagick.zsh
alias coltxt='pick-color-fill-text'       # Render colored text into an image; source: pick-color-fill-text() -- /Users/schingon/.config/zsh/modules/imagemagick.zsh
alias shave='imagemagick-shave'           # Shave pixels from image edges; source: imagemagick-shave() -- /Users/schingon/.config/zsh/modules/imagemagick.zsh
alias ytt='youtube-thumbnail'             # Generate a YouTube thumbnail image; source: youtube-thumbnail() -- /Users/schingon/.config/zsh/modules/imagemagick.zsh

# ===== Miscellaneous Aliases =====
alias clock='tty-clock -B -C 5 -c'        # Show a big terminal clock; source: tty-clock -- brew formula / CLI tool
alias or='open /Volumes/hold/ulto/'       # Open the ulto volume in Finder; source: open -- macOS CLI tool
alias oss='open -a ScreenSaverEngine'     # Start the macOS screensaver; source: open -- macOS CLI tool
alias res="rm $DZ/z*.zwc && source $HOME/.zshenv && szr"   # Reload zshenv then zshrc; source: source -- shell builtin, szr alias below
alias szr='source-zshrc'                  # Re-source zsh config and compile zwc files; source: source-zshrc() -- /Users/schingon/.config/zsh/modules/config.zsh
alias pag='ps aux | grep '                # Start a ps/grep process search; source: ps and grep -- CLI tools
alias sl='sudo ls -la '                   # Run ls -la with sudo; source: ls -- CLI tool, sudo -- CLI tool
alias ssh2='ssh-2mini'                    # SSH into 2mini with TERM fix; source: ssh-2mini() -- /Users/schingon/.config/zsh/modules/functions.zsh
alias ssh4='ssh-4mini'                    # SSH into 4mini with TERM fix; source: ssh-4mini() -- /Users/schingon/.config/zsh/modules/functions.zsh

# ===== eza Aliases =====
alias ls='eza --color=always --icons --git'      # List files with icons and git status; source: eza -- brew formula / CLI tool
alias la='ls -a --git'                           # List all files with git status; source: ls alias above
alias ldn='ls $HOME/Downloads'                   # List Downloads; source: ls alias above
alias lsd='ls -D'                                # List directories only; source: ls alias above
alias lsf='ls -f'                                # List files only; source: ls alias above
alias lt='ls --tree --level=3'                   # Tree view to depth 3; source: ls alias above
alias lta='ls --tree --level=3 --long --git'     # Long tree view with git info; source: ls alias above
alias lx='ls -lbhHgUmuSa@'                        # Detailed long listing; source: ls alias above

# ===== Directory Navigation Aliases =====
alias ...='../..'                         # Move up two directories; source: cd target shortcut
alias ....='../../..'                     # Move up three directories; source: cd target shortcut

# ===== Brew Aliases =====
alias bi='brew install '                  # Install a Homebrew package; source: brew -- CLI tool
alias bl='brew list'                      # List installed Homebrew packages; source: brew -- CLI tool
alias bri='brew reinstall'                # Reinstall a Homebrew package; source: brew -- CLI tool
alias brm='brew uninstall --force --zap'  # Uninstall and zap a Homebrew package; source: brew -- CLI tool
alias bu='brew update; brew upgrade; brew cleanup' # Update, upgrade, and clean Homebrew; source: brew -- CLI tool
alias bci='brew install --cask '          # Install a Homebrew cask app; source: brew -- CLI tool
alias bs='brew search '                   # Search Homebrew formulas and casks; source: brew -- CLI tool

# ===== Neovim / Editor Aliases =====
alias v='nvim'                            # Open Neovim; source: nvim -- CLI tool
alias nv='neovide'                        # Open Neovide GUI; source: neovide -- CLI tool
alias dly='daily'                         # Open today's daily note; source: daily -- ~/.local/bin/daily
alias pdi='podidea'                       # Open or create pod-content idea note; source: podidea -- ~/.local/bin/podidea
alias va='open-aliases'                   # Edit aliases.zsh; source: open-aliases() -- /Users/schingon/.config/zsh/modules/config.zsh
alias vd='dreams_md_shortcut'             # Append a dream note skeleton; source: dreams_md_shortcut() -- /Users/schingon/.config/zsh/modules/functions.zsh
alias vf='open-functions'                 # Edit functions.zsh; source: open-functions() -- /Users/schingon/.config/zsh/modules/config.zsh
alias vm='open-nvim-init'                 # Edit Neovim init.lua; source: open-nvim-init() -- /Users/schingon/.config/zsh/modules/config.zsh
alias vs='open-secrets'                   # Edit a plaintext temp copy in Neovim, then encrypt on exit; source: open-secrets() -- /Users/schingon/.config/zsh/modules/config.zsh
alias vz='open-zshrc'                     # Edit zshrc; source: open-zshrc() -- /Users/schingon/.config/zsh/modules/config.zsh
alias vh='open-zsh-history'               # Edit zsh history; source: open-zsh-history() -- /Users/schingon/.config/zsh/modules/config.zsh
alias vg='v $CF/ghostty/config'           # Edit Ghostty config; source: v alias above, file path target
alias vw='v $CF/wezterm/wezterm.lua'      # Edit WezTerm config; source: v alias above, file path target

# ===== Rclone Aliases =====
alias rccl='rclone-copy-large'            # Copy with rclone large-file profile; source: rclone-copy-large() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rccs='rclone-copy'                  # Copy with rclone small-file profile; source: rclone-copy() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcml='rclone-move-large'            # Move with rclone large-file profile; source: rclone-move-large() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcms='rclone-move'                  # Move with rclone small-file profile; source: rclone-move() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcsl='rclone-sync-large'            # Sync with rclone large-file profile; source: rclone-sync-large() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcss='rclone-sync'                  # Sync with rclone small-file profile; source: rclone-sync() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcdn='rclone-dedupe-new'            # Dedupe with rclone, keep newest; source: rclone-dedupe-new() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcdo='rclone-dedupe-old'            # Dedupe with rclone, keep oldest; source: rclone-dedupe-old() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcm='rclone-move'                   # Move files with rclone; source: rclone-move() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rcc='rclone-copy'                   # Copy files with rclone; source: rclone-copy() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rdo='rclone-dedupe-old'             # Dedupe and keep oldest; source: rclone-dedupe-old() -- /Users/schingon/.config/zsh/modules/rclone.zsh
alias rdn='rclone-dedupe-new'             # Dedupe and keep newest; source: rclone-dedupe-new() -- /Users/schingon/.config/zsh/modules/rclone.zsh
