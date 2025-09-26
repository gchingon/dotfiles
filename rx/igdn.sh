#!/bin/zsh
# ln ~/.config/rx/igdn.sh ~/.local/bin/instadl

export PATH=/opt/homebrew/bin/:$PATH
igdown () {
    cd /Volumes/armor/didact/IG
    instaloader --cookiefile $HOME/Desktop/cookies.txt --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps $HOME/.config/instaloader/latest-stamps.ini ignorancebegone
    instaloader --cookiefile $HOME/Desktop/cookies.txt --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps $HOME/.config/instaloader/latest-stamps.ini paths2frdm2022
    instaloader --cookiefile $HOME/Desktop/cookies.txt --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps $HOME/.config/instaloader/latest-stamps.ini receiptdropper
    instaloader --cookiefile $HOME/Desktop/cookies.txt --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps $HOME/.config/instaloader/latest-stamps.ini yusef_el_19
    instaloader --cookiefile $HOME/Desktop/cookies.txt --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps $HOME/.config/instaloader/latest-stamps.ini amyr_law
    instaloader --cookiefile $HOME/Desktop/cookies.txt --no-video-thumbnails --no-profile-pic --no-captions --no-metadata-json --latest-stamps $HOME/.config/instaloader/latest-stamps.ini equitablesociety
}

igdown
