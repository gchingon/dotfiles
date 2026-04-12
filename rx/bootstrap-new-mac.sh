#!/bin/zsh
# ln ~/.config/rx/bootstrap-new-mac.sh ~/.local/bin/bootstrap

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<EOF
Usage: bootstrap

Bootstraps a new Mac by installing Xcode CLT, SSH config, dotfiles, symlinks,
macOS defaults, and Homebrew packages in sequence.
EOF
  exit 0
fi

# Configuration and logging setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/setup.log"
STEPS_FILE="$SCRIPT_DIR/.setup_progress"

# Logging function - writes to both console and log file
log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" | tee -a "$LOG_FILE"
}

# Error handling function - logs errors and exits if fatal
handle_error() {
    local exit_code=$1
    local error_msg=$2
    local fatal=${3:-true}
    
    if [ $exit_code -ne 0 ]; then
        log "ERROR: $error_msg (Exit code: $exit_code)"
        if [ "$fatal" = true ]; then
            exit $exit_code
        fi
        return 1
    fi
    return 0
}

# Function to mark step as completed
mark_complete() {
    echo "$1" >> "$STEPS_FILE"
}

# Function to check if step was completed
is_completed() {
    if [ -f "$STEPS_FILE" ]; then
        grep -q "^$1$" "$STEPS_FILE"
        return $?
    fi
    return 1
}

# Install Command Line Tools - Like laying the foundation before building a house
install_command_line_tools() {
    if ! is_completed "xcode"; then
        log "Installing Command Line Tools..."
        xcode-select --install
        handle_error $? "Failed to install Command Line Tools" || return 1
        mark_complete "xcode"
    else
        log "Command Line Tools already installed"
    fi
}

# Setup SSH - Think of this as creating your digital ID card and key
setup_ssh() {
    if ! is_completed "ssh"; then
        log "Setting up SSH..."
        
        # Generate SSH key if it doesn't exist
        if [ ! -f ~/.ssh/id_ed25519 ]; then
            ssh-keygen -t ed25519 -C "9777026+gallo-s-chingon@users.noreply.github.com"
            handle_error $? "Failed to generate SSH key" || return 1
        fi

        # Configure SSH
        touch ~/.ssh/config
        cat > ~/.ssh/config << EOF
Host github.com
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
EOF
        
        ssh-add --apple-use-keychain ~/.ssh/id_ed25519
        handle_error $? "Failed to add SSH key to keychain" || return 1
        
        mark_complete "ssh"
    else
        log "SSH already configured"
    fi
}

# Clone dotfiles - Like downloading your toolbox blueprints
clone_dotfiles() {
    if ! is_completed "dotfiles"; then
        log "Cloning dotfiles repository..."
        git clone https://github.com/gallo-s-chingon/daught-fylz.git .dotfiles
        handle_error $? "Failed to clone dotfiles repository" || return 1
        mark_complete "dotfiles"
    else
        log "Dotfiles already cloned"
    fi
}

# Create symlinks - Like wiring your house, connecting everything together
create_symlinks() {
    if ! is_completed "symlinks"; then
        log "Creating symlinks..."
        local links=(
            ".dotfiles:.config"
            ".config/zsh/zshrc:.zshrc"
            ".config/zsh/zprofile:.zprofile"
            ".config/zsh/zshenv:.zshenv"
            ".config/wezterm.lua:.wezterm.lua"
        )
        
        for link in "${links[@]}"; do
            local source="${link%%:*}"
            local target="${link#*:}"
            ln -s "$source" "$target"
            handle_error $? "Failed to create symlink: $target" false
        done
        
        mark_complete "symlinks"
    else
        log "Symlinks already created"
    fi
}

# Configure macOS defaults - Like setting up your workshop's default tool positions
configure_macos() {
    if ! is_completed "macos"; then
        log "Configuring macOS defaults..."
        open -a Terminal ~/.config/rx/macos-defaults.sh
        # Note: Can't verify completion as it runs in new terminal
        mark_complete "macos"
    else
        log "macOS already configured"
    fi
}

# Install Homebrew and packages - Like installing your power tools and workbench
setup_homebrew() {
    if ! is_completed "homebrew"; then
        log "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        handle_error $? "Failed to install Homebrew" || return 1
        
        log "Installing Homebrew packages..."
        brew bundle --file ~/.config/Brewfile
        handle_error $? "Failed to install Homebrew packages" || return 1
        
        mark_complete "homebrew"
    else
        log "Homebrew already set up"
    fi
}

# Main execution flow
main() {
    log "Starting macOS setup script..."
    
    install_command_line_tools
    setup_ssh
    clone_dotfiles
    create_symlinks
    configure_macos
    setup_homebrew
    
    log "Setup completed successfully!"
}

main
