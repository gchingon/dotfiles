# ~/.config/zsh/modules/aliases.zsh
# Command aliases grouped by category for quick reference and use

# ===== General Aliases =====
alias c='clear'                          # Clear terminal screen
alias c-='cd -'                          # Go back to previous directory
alias cdc='cd && c'                      # Go to home directory and clear screen
alias dt='date "+%F"'                    # Show date in YYYY-MM-DD format
alias e='exit 0'                         # Exit shell with success status
alias ex='expand'                        # Expand tabs to spaces (uses `expand` command)
alias ffav='ffmpeg-remux-audio-video'    # Remux audio and video with FFmpeg
alias grep='grep --color=auto'           # Grep with colored output
alias lock='chflags uchg '               # Lock a file (macOS: make unchangeable)
alias ln='ln -i'                         # Create symbolic links with overwrite prompt
alias mnf='mediainfo'                    # Show media file info (uses `mediainfo` tool)
alias o.='open .'                        # Open current directory in Finder (macOS)
alias ptc='paste-output-to-clipboard'    # Copy command output to clipboard
alias nowrap='setterm --linewrap off'    # Disable line wrapping in terminal
alias wrap='setterm --linewrap on'       # Enable line wrapping in terminal
alias sv='sudo nvim '
alias dcd='docker-compose down'
alias dcu='docker-compose up -d'
alias cs='colorswitch'                   # colorselector script to switch colorschemes for yazi, neovim, ghostty, & starship
alias csd='cs deepdark'
alias cst='cs tokyodarknite'          # switch to tokyonight colorscheme
alias csn='cs niteblossom'      # switch to nightblossom
alias cso='cs nightowl'                  # switch to nightowl colorscheme
alias csg='cs nugotham'                  # switch to nugotham colorscheme
alias cse='cs eldritch'           # switch to eldritch-darker colorscheme
alias csv='cs vague'              # switch to onedark-deep
alias ytv='ytd video'
alias oct='openclaw tui'
alias occ='openclaw configure'
alias ocd='openclaw doctor'

# ===== Git Aliases =====
alias g='git'                            # Shortcut for git
alias gac='git-add-commit-push'          # Add, commit, and push in one go
alias gfh='git fetch'                    # Fetch updates from remote
alias gpl='git-pull'                     # Pull changes from remote
alias gph='git-push'                     # Push changes to remote
alias gst='git status'                   # Show git status

# ===== File Management Aliases =====
alias d='fd -H -t f .DS_Store -X rm -frv'  # Remove .DS_Store files (macOS)
alias f='fzf '                           # Fuzzy finder with space for args
alias ft='fd-type'                       # List file types by extension
alias mk='mkdir -pv'                     # Make directories with parents, verbose
alias mkd='source $RX/cd-into-made-dir.sh'      # Make directory with parent and cd into created directory
alias mia='move-ipa-to-target-directory' # Move .ipa files to target dir
alias mio='move-iso'                     # Move ISO-like files
alias mtt='sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv $HOME/.Trash'  # Empty all trashes
alias rm='rm -rfv'                       # Remove recursively, forcefully, verbose
alias srm='sudo rm -rfv'                 # Remove with sudo, verbose

# ===== Blog Aliases =====
alias blog='$RX/blog.sh blog'            # Run blog script with 'blog' arg
alias epi='$RX/blog.sh epi'              # Run blog script with 'epi' arg
alias feat='$RX/blog.sh feat'            # Run blog script with 'feat' arg

# ===== Transcript =====
alias vtm='tsp vtm'             # convert existing vtt file | vtm path/to/filename.vtt
alias stm='tsp stm'             # convert existing srt file | stm path/to/filename.srt
alias cl='clear; ls'

# ===== Scripts =====
alias fdm='filemgr move'         # Move files matching pattern to dir $RX/fd-move-files-to-dir.sh
alias fdd='filemgr exclude'  # Move files excluding a dir $RX/move-files-to-excluded-folder.sh
alias fdf='filemgr find'     # Find files in current dir (`fd` = fast find) $RX/find-files-in-dir.sh
alias pof='clipops paste' # paste and overwrite file with clipboard contents essentially `pbpaste > $1` $RX/paste-overwrite-to-file.sh
alias paf='clipops append'    # paste to end of file with clipboard content `pbpaste >> $1` $RX/paste-append-to-file.sh
alias ctc='clipops copy'  # Copy file contents to clipboard -- hard linked to $RX/copy-file-content-to-clipboard.sh
alias w2b='clipops wcpcmd' # copy command and output to markdown code block
alias wob='clipops wcmd' # Copy command output only to markdown code block

# alias pafi='clipops append $NT_INBOX'

# ==== No Longer Aliased ====
# instead of hardlinking $RX/script-name.sh -> ~/.local/bin/scriptname and aliasing "sn" (short for scriptname) I decided to cut out the middleman and just hardlink to the "sn/shortname" below is just a reminder of what the script does based on the former alias
# ========

# mkrx -> $RX/make-script-and-open.sh ; Create chmod and open a script in neovim
# slug -> $RX/slugged.sh ; a script to slugify filenames ONLY allowing alphanumeric and dash `azAZ09-`
# bydate -> $RX/sort-file-by-date.sh ; Sort files by date (custom script)
# tsp -> $RX/trans-pull.sh ; pull transcript of video to clipboard unless path and filename is given
# instadl -> $RX/igdn.sh ; Instagram download script

# ===== Image Management Aliases =====
alias 50p='imagemagick-resize-50'        # Resize image to 50%
alias 500='imagemagick-resize-500'       # Resize image to 500 pixels
alias 720='imagemagick-resize-720'       # Resize image to 720 pixels
alias coltxt='pick-color-fill-text'      # Create colored text image
alias mpx='move-download-pix-to-pictures-dir'  # Move pics to Pictures dir
alias rpx='remove-pix'                   # Remove image files
alias shave='imagemagick-shave'          # Shave edges off image
alias ytt='youtube-thumbnail'            # Create YouTube thumbnail

# ===== Miscellaneous Aliases =====
alias clock='tty-clock -B -C 5 -c'       # Show terminal clock (`-B` = big, `-C 5` = color)
alias or='open /Volumes/hold/ulto/'      # Open specific volume in Finder
alias oss='open -a ScreenSaverEngine'    # Start screensaver (macOS)
alias res="source $HOME/.zshenv && szr"  # Reload zshenv and zshrc
alias szr='source-zshrc'                 # Reload zshrc
alias trv='trim-video'                   # Trim video with FFmpeg
alias pag='ps aux | grep '               # prefix to avoid typing repetitive commands
alias sl='sudo ls -la '                  # another prefix because I'm lazy

# ===== eza (ls alternative) Aliases =====
alias ls='eza --color=always --icons --git'  # Modern ls with icons and git status
alias la='ls -a --git'                   # List all with git status
alias ldn='ls $HOME/Downloads'           # List Downloads dir
alias lsd='ls -D'                        # List dirs only
alias lsf='ls -f'                        # List files only
alias lt='ls --tree --level=3'           # Tree view, 2 levels
alias lta='ls --tree --level=3 --long --git'  # Detailed tree, 3 levels
alias lx='ls -lbhHgUmuSa@'               # Detailed list with all options

# ===== Directory Navigation Aliases =====
alias ...='../..'                        # Go up 2 directories
alias ....='../../..'                    # Go up 3 directories

# ===== Brew Aliases =====
alias bi='brew install '                 # Install Homebrew package
alias bl='brew list'                     # List installed packages
alias bri='brew reinstall'               # Reinstall package
alias brm='brew uninstall --force --zap' # Uninstall and remove all data
alias bu='brew update; brew upgrade; brew cleanup'  # Update, upgrade, clean
alias bci='brew install --cask '         # Install cask (GUI app)
alias bs='brew search '                  # Search for package

# ===== YouTube-DL Aliases =====
# alias ytd='yt-dlp-download'              # Download video with yt-dlp
# alias ytx='$RX/yt-dlp-extract-audio.sh'         # Extract audio from video
# alias ytf="yt-dlp-extract-audio-from-file"  # Extract audio from URL file
# alias yta='yt-dlp-download-with-aria2c'  # Download with aria2c support

# ===== Neovim Aliases =====
alias v='nvim'                           # Launch Neovim
alias va='open-aliases'                  # Edit aliases.zsh
alias vd='dreams_md_shortcut'            # Quick dream journal entry
alias vf='open-functions'                # Edit functions.zsh
alias vm='open-nvim-init'                # Edit Neovim init.lua
alias vs='open-secrets'                  # Edit secrets (assumes file)
alias vz='open-zshrc'                    # Edit zshrc
alias vh='open-zsh-history'              # Edit zsh history
alias vg='v $CF/ghostty/config'          # Edit Ghostty config
alias vw='v $CF/wezterm/wezterm.lua'     # Edit wezterm config

# ===== Rclone Aliases =====
alias rcm='rclone-move'                  # Move files with rclone
alias rcc='rclone-copy'                  # Copy files with rclone
alias rdo='rclone-dedupe-old'            # Dedupe, keep oldest
alias rdn='rclone-dedupe-new'            # Dedupe, keep newest


