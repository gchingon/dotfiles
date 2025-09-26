# ~/.config/nushell/aliases.nu

# --- Legacy Alias Map ---
# ... (rest of the comment block is unchanged) ...

# --- Custom Commands (defs for complex logic) ---
def cdc [] { cd ~; clear }
def dt [] { date now | format date '%Y-%m-%d' }
def d [] { glob **/.DS_Store | rm -rf }
def bu [] { brew update; brew upgrade; brew cleanup }
def mkd [dirname: string] { mkdir $dirname; cd $dirname }
def pag [pattern: string] { ps aux | grep $pattern }

# --- General Aliases ---
alias c = clear
alias c- = cd -
alias e = exit
alias ex = expand
alias grep = grep --color=auto
alias ln = ln -i
alias mnf = mediainfo
alias o. = ^open .
alias sv = sudo nvim
alias podi = podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
alias w2b = bash ($env.RX | path join "wrap2block.sh") # Added w2b

# --- Color Scheme Aliases ---
alias cs = bash ($env.RX | path join "colorselector.sh")
# ... (rest are unchanged) ...

# --- Consolidated Tool: Clipboard Operations (clipops) ---
alias clipops = bash ($env.RX | path join "clipboard-to-file-operations.sh")
# ... (rest are unchanged) ...

# --- Consolidated Tool: File Management (filemgr) ---
alias filemgr = file-finder-and-mover-utility # Assuming it's a compiled binary in PATH
# ... (rest are unchanged) ...

# --- Consolidated Tool: Image Processing (imt) ---
alias imt = python ($env.RX | path join "image-tool.py")
# ... (rest are unchanged) ...

# --- Consolidated Tool: Rclone Wrapper (rct) ---
alias rct = bash ($env.RX | path join 'rclone-tool.sh')
# ... (rest are unchanged) ...

# --- Consolidated Tool: Git Wrapper (gtool) ---
alias gtool = bash ($env.RX | path join 'git-tool.sh')
# ... (rest are unchanged) ...

# --- Neovim Aliases ---
alias v = nvim
alias vn = v ($env.XDG_CONFIG_HOME | path join "nushell" "config.nu")
alias va = v ($env.XDG_CONFIG_HOME | path join "nushell" "aliases.nu")
alias ve = v ($env.XDG_CONFIG_HOME | path join "nushell" "env.nu")
alias vf = v ~/.config/zsh/modules/*.zsh
alias vm = v ($env.XDG_CONFIG_HOME | path join "nvim" "init.lua")
alias vg = v ($env.XDG_CONFIG_HOME | path join "ghostty" "config")

# --- eza (ls alternative) ---
alias ls = eza --color=always --icons --git
alias la = ls -a
alias lt = ls --tree --level=2

# --- Directory Navigation ---
alias .. = cd ..
alias ... = cd ../..
alias .... = cd ../../..

# --- Other System Aliases ---
alias bi = brew install
alias ci = cargo install
alias t = tmux
alias ta = "tmux a -t"
alias tl = tmux ls

print "✓ Sourced aliases.nu"
