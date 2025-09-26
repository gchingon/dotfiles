# ~/.config/nushell/startup.nu
# Similar to zprofile functionality

# Get CPU architecture and set Homebrew path
let arch = (run-external "sysctl" "-n" "hw.cputype" | str trim)
let brew_path = if $arch == "16777228" {
    # Apple Silicon: Homebrew in /opt/homebrew
    "/opt/homebrew/bin/brew"
} else {
    # Intel: Homebrew in /usr/local/Homebrew
    "/usr/local/Homebrew/bin/brew"
}

# Initialize Homebrew environment
# Note: We need to run the brew shellenv command and parse its output
# This is a bit more complex in Nushell than in zsh
let brew_env = (run-external $brew_path "shellenv" | lines | parse "{key}={value}")
for item in $brew_env {
    $env.($item.key) = $item.value
}

# Ensure Homebrew is in PATH
$env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")