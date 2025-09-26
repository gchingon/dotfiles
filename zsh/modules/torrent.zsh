# ~/.config/zsh/modules/torrent.zsh
# Torrent management functions

TORRENT_DIR="/Volumes/kalisma/torrent"
BACKUP_DIR="/Volumes/armor"
REPOS=("$HOME/.dotfiles" "$HOME/.lua-is-the-devil" "$HOME/.noktados" "$DX/widclub" "$HOME/notes")

open-downloaded-torrents() {
  open "$DN"/*.torrent
  open -a wezterm
}

move-emp-torrents() {
  fd -e torrent -i empornium --search-path "$DN" -X mv -v {} "$TORRENT_DIR/EMP"
}

move-mam-torrents() {
  fd -e torrent "[^[0-9]{6,6}]" --search-path "$DN" -X mv -v {} "$TORRENT_DIR/MAM"
}

move-btn-torrents() {
  local destination="$TORRENT_DIR/BTN" torrents=("$DN"/*.torrent(N))
  for torrent in "${torrents[@]}"; do
    transmission-show "$torrent" | grep -q "landof" && mv -v "$torrent" "$destination"
  done
}

open-btn-torrents-in-transmission() {
  local torrents=("$DN"/*.torrent(N))
  for torrent in "${torrents[@]}"; do
    transmission-show "$torrent" | grep -q "landof" && open -a "Transmission" "$torrent"
  done
}

move-ptp-torrents() {
  local destination="$TORRENT_DIR/PTP" torrents=("$DN"/*.torrent(N))
  for torrent in "${torrents[@]}"; do
    transmission-show "$torrent" | grep -q "passthepopcorn" && mv -v "$torrent" "$destination"
  done
}

open-ptp-torrents-in-deluge() {
  local torrents=("$DN"/*.torrent(N))
  for torrent in "${torrents[@]}"; do
    transmission-show "$torrent" | grep -q "passthepopcorn" && open -a "Deluge" "$torrent"
  done
}

move-all-torrents() {
  move-emp-torrents
  move-mam-torrents
  move-btn-torrents
  move-ptp-torrents
  open -a wezterm
}