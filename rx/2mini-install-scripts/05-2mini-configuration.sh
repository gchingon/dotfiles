#!/bin/bash
# 05-2mini-configuration.sh - Post-installation configuration helper
set -e

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "⚙️ 2mini post-installation configuration..."

# Create transmission credentials helper
log "🔑 Creating transmission configuration helper..."
cat >~/2lab/configure-transmission.sh <<'TRANSMISSION_CONFIG'
#!/bin/bash
# Configure *arr services with Transmission
echo "🔗 Transmission Configuration for *arr services"
echo ""
echo "Transmission Server: 192.168.1.39"
echo "Port: 9091"
echo "URL Base: /transmission/"
echo "Username: [Get from bmini ~/.mealilo]"
echo "Password: [Get from bmini ~/.mealilo]"
echo ""
echo "Configure in each service:"
echo "  Sonarr: Settings → Download Clients → Add Transmission"
echo "  Radarr: Settings → Download Clients → Add Transmission"
echo "  Bazarr: Settings → Download Clients → Add Transmission"
echo ""
echo "Remote Path Mappings:"
echo "  Host: 192.168.1.39"
echo "  Remote Path: /Volumes/kalisma/done"
echo "  Local Path: /Volumes/kalisma/done"
TRANSMISSION_CONFIG

chmod +x ~/2lab/configure-transmission.sh

# Create media library setup helper
log "📚 Creating media library setup helper..."
cat >~/2lab/setup-libraries.sh <<'LIBRARY_SETUP'
#!/bin/bash
# Media library setup helper
echo "📚 Media Library Configuration"
echo ""
echo "Sonarr Root Folders:"
echo "  /tv/TV (maps to /Volumes/shows/TV)"
echo ""
echo "Radarr Root Folders:"
echo "  /movies (maps to /Volumes/movies)"
echo "  /cinema (maps to /Volumes/cinema)"
echo ""
echo "Jellyfin Libraries:"
echo "  Movies: /media/movies"
echo "  TV Shows: /media/shows"
echo "  Cinema: /media/cinema"
echo "  Music: /media/music"
echo ""
echo "Navidrome:"
echo "  Music folder: /music (maps to /Volumes/delta/music)"
echo ""
echo "Audiobookshelf:"
echo "  Audiobooks: /audiobooks"
echo "  Podcasts: /podcasts"
LIBRARY_SETUP

chmod +x ~/2lab/setup-libraries.sh

log "✅ Configuration helpers created"
log "📋 Run ~/2lab/configure-transmission.sh for *arr setup"
log "📋 Run ~/2lab/setup-libraries.sh for media library setup"
