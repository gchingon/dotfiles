# ~/.config/nushell/env.nu
# Defines global environment variables for all Nushell sessions

# --- Host-Specific Variable (HL) ---
# This block checks the hostname and sets the HL environment variable accordingly.
if ((sys).host.name | str starts-with "2mini") {
    let-env HL = $"($env.RP)/2lab"
} else if ((sys).host.name | str starts-with "4mini") {
    let-env HL = $"($env.RP)/4lab"
}

# Base directories
let-env HOME = (tilde)
let-env XDG_CONFIG_HOME = $"($env.HOME)/.config"  # Symlinked from ~/.config where possible
let-env CAPTURE_FOLDER = $"($env.HOME)/Pictures"
let-env CF = $env.XDG_CONFIG_HOME
let-env DN = $"($env.HOME)/Downloads"
let-env DX = $"($env.HOME)/Documents"
let-env DZ = $"($env.CF)/zsh"                     # Real files in ~/.config/zsh
let-env NT = $"($env.DX)/notes"
let-env NV = $"($env.CF)/nvim"
let-env RP = $"($env.HOME)/repos"
let-env RX = $"($env.CF)/rx"                      # Real files in ~/.config/rx
let-env WC = $"($env.DX)/widows-club"
let-env WP = $"($env.DX)/webpage"

# Tool-specific settings
$env.PATH = (
    $env.PATH | 
    prepend "/opt/homebrew/opt/ruby/bin" |
    prepend $"($env.HOME)/.cargo/bin" |
    prepend $"($env.HOME)/.local/bin" |
    prepend $env.RX
)

$env.FZF_DEFAULT_OPTS = '--height=20% --cycle --info=hidden --tabstop=4 --black'
$env.CLICOLOR = 1
$env.EDITOR = 'nvim'

# Set MAKEFLAGS based on system type
# if (sys).host.name == "Darwin" {
#     if (run-external "sysctl" "-n" "hw.cputype" | str trim) == "16777228" {
#         # Apple Silicon
#         $env.MAKEFLAGS = $"-j(run-external "sysctl" "-n" "hw.ncpu" | str trim)"
#     } else {
#         # Intel
#         $env.MAKEFLAGS = $"-j(run-external "sysctl" "-n" "hw.ncpu" | str trim)"
#     }
# } else if (sys).host.name == "Linux" {
#     $env.MAKEFLAGS = $"-j(run-external "nproc" | str trim)"
# }

$env.FUNCNEST = 25000

# Homebrew path
$env.PATH = ($env.PATH | prepend "/opt/homebrew/bin")

# Golang settings
$env.GOROOT = "/opt/homebrew/opt/go/libexec"
$env.GOPATH = $"($env.HOME)/go"
$env.PATH = (
    $env.PATH | 
    prepend $"($env.GOPATH)/bin" | 
    prepend $"($env.GOROOT)/bin"
)

# Source carapace completions - may require additional setup in Nushell
# Equivalent might be: use ~/.config/nushell/completions/carapace.nu
# Note: Specific implementation depends on carapace's Nushell support
