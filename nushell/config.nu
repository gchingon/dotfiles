# ~/.config/nushell/config.nu
# Main Nushell configuration file

# --- Auto-CD Hook ---
# Intercepts commands that are not found and checks if they are directories.
$env.hooks.command_not_found = { |command, args|
    # Check if the command is a valid, existing directory and no arguments were passed.
    if ($command | path exists) and ($command | path type) == "dir" and ($args | is-empty) {
        # If it is, change into that directory.
        cd $command
    }
}

# Load environment
source ~/.config/nushell/env.nu
let-env HOME = (tilde)
let-env XDG_CONFIG_HOME = $"($env.HOME)/.config"
let-env CF = $env.XDG_CONFIG_HOME
let-env CAPTURE_FOLDER = $"($env.HOME)/Pictures"
let-env DN = $"($env.HOME)/Downloads"
let-env DX = $"($env.HOME)/Documents"
let-env NT = $"($env.DX)/notes"      # git repo for notes
let-env DZ = $"($env.CF)/zsh"          # zsh config stuff (legacy, for reference)
let-env NV = $"($env.CF)/nvim"         # Real Neovim repo
let-env RX = $"($env.CF)/rx"           # shortcut to global scripts
let-env RP = $"($env.HOME)/repos"     # podcast ideas, etc.
let-env WP = $"($env.DX)/webpage"
let-env WC = $"($env.DX)/widows-club"

# History settings
$env.config = {
    history: {
        max_size: 5000                  # Max history entries
        file_format: "sqlite"           # History file format
        sync_on_enter: true             # Sync on each command
        isolation: false                # Share history across sessions
    }
    # History filtering (equivalent to HISTORY_IGNORE)
    # Note: Nushell handles history filtering differently from zsh
    # You may need to use hooks for more complex filtering
}

# Load modules - Nushell equivalent of sourcing zsh modules
# You'll need to convert each zsh module to a Nushell module
# Example:
source ~/.config/nushell/modules/aliases.nu
source ~/.config/nushell/modules/functions.nu

# minimum supported version = 0.93.0
module compat {
  export def --wrapped "random uuid -v 7" [...rest] { atuin uuid }
}
use (if not (
    (version).major > 0 or
    (version).minor >= 103
) { "compat" }) *

$env.ATUIN_SESSION = (random uuid -v 7 | str replace -a "-" "")
hide-env -i ATUIN_HISTORY_ID

# Magic token to make sure we don't record commands run by keybindings
let ATUIN_KEYBINDING_TOKEN = $"# (random uuid)"

let _atuin_pre_execution = {||
    if ($nu | get history-enabled?) == false {
        return
    }
    let cmd = (commandline)
    if ($cmd | is-empty) {
        return
    }
    if not ($cmd | str starts-with $ATUIN_KEYBINDING_TOKEN) {
        $env.ATUIN_HISTORY_ID = (atuin history start -- $cmd)
    }
}

let _atuin_pre_prompt = {||
    let last_exit = $env.LAST_EXIT_CODE
    if 'ATUIN_HISTORY_ID' not-in $env {
        return
    }
    with-env { ATUIN_LOG: error } {
        if (version).minor >= 104 or (version).major > 0 {
            job spawn -t atuin {
                ^atuin history end $'--exit=($env.LAST_EXIT_CODE)' -- $env.ATUIN_HISTORY_ID | complete
            } | ignore
        } else {
            do { atuin history end $'--exit=($last_exit)' -- $env.ATUIN_HISTORY_ID } | complete
        }

    }
    hide-env ATUIN_HISTORY_ID
}

def _atuin_search_cmd [...flags: string] {
    [
        $ATUIN_KEYBINDING_TOKEN,
        ([
            `with-env { ATUIN_LOG: error, ATUIN_QUERY: (commandline) } {`,
                'commandline edit',
                '(run-external atuin search',
                    ($flags | append [--interactive] | each {|e| $'"($e)"'}),
                ' e>| str trim)',
            `}`,
        ] | flatten | str join ' '),
    ] | str join "\n"
}

$env.config = ($env | default {} config).config
$env.config = ($env.config | default {} hooks)
$env.config = (
    $env.config | upsert hooks (
        $env.config.hooks
        | upsert pre_execution (
            $env.config.hooks | get pre_execution? | default [] | append $_atuin_pre_execution)
        | upsert pre_prompt (
            $env.config.hooks | get pre_prompt? | default [] | append $_atuin_pre_prompt)
    )
)

$env.config = ($env.config | default [] keybindings)

$env.config = (
    $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
            name: atuin
            modifier: control
            keycode: char_r
            mode: [emacs, vi_normal, vi_insert]
            event: { send: executehostcommand cmd: (_atuin_search_cmd) }
        }
    )
)

$env.config = (
    $env.config | upsert keybindings (
        $env.config.keybindings
        | append {
            name: atuin
            modifier: none
            keycode: up
            mode: [emacs, vi_normal, vi_insert]
            event: {
                until: [
                    {send: menuup}
                    {send: executehostcommand cmd: (_atuin_search_cmd '--shell-up-key-binding') }
                ]
            }
        }
    )
)

$env.config.show_banner = false
