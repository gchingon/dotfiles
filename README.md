---
title: README
date: 2024-04-18
---
# README

to install run
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/gchingon/dotfiles/main/rx/bootstrap-new-mac.sh)`
## ~Why the weird name for *dotfiles*~ Why did I go back to dotfiles?

Everyone uses dotfiles, I wanted to be ***special*** but typing out `daught-fylz` grew to be cumbersome and annoying.

## the Dots
### rclone

config ~~has personal stuff for my Gdrive, keeping this repo secret until I can figure out this whole `secrets` file and do gitignore or host it elsewhere as private. Until then, this repo will remain private. likely in perpetuity, until I learn the `secrets` thing and re upload this repo without the first few commits with rclone exposed~~ no more unlimited Gdrive so rclone is just to move and dedupe across local NAS directories

### rx

folder for custom shell scripts which are then hardlinked to `~/.local/bin/shortScriptName` and in a lot of cases aliased with a 3-5 letter shortcut. eg `$RX/wrap-output-to-md-block.sh` -> `$LB/wrap2block` with `alias w2b = wrap2block`

### youtube-dl

~config for highest quality video and audio, write subs and use `aria2c` as downloader~ made into a script so I can use an alias like `ytdx` to download opus files from YouTube videos, embed thumbnails, embed metadata, and a few other things that escape me at the moment. 

### zsh

the impetus to make dotfiles after customizing `.zshrc` ~eventually switching over to nushell~ Changed my mind, nushell too much work to try to configure and I don't mess with "data" in the terminal enough to be worthwhile.

## everything else

~all~ most other configs in `dotfiles` are defaults, I only really use nvim
