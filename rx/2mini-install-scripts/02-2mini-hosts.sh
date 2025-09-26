#!/bin/bash
# 02-2mini-hosts.sh - Update /etc/hosts for 2mini
set -e

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "🌐 Updating /etc/hosts for 2mini..."

# Backup existing hosts file
sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)

# Add homelab domains
sudo tee -a /etc/hosts >/dev/null <<'HOSTS_2MINI'

# Homelab domains for 2mini (all route through Traefik on bmini)
192.168.1.39 transmission.stashost.local
192.168.1.39 pihole.stashost.local
192.168.1.39 homeassistant.stashost.local
192.168.1.39 traefik.stashost.local
192.168.1.39 paperless.stashost.local
192.168.1.39 pdf.stashost.local
192.168.1.39 rss.stashost.local
192.168.1.39 blog.stashost.local
192.168.1.39 calendar.stashost.local
192.168.1.39 grafana.stashost.local
192.168.1.39 prometheus.stashost.local
192.168.1.39 uptime.stashost.local
192.168.1.39 dashboard.stashost.local
192.168.1.39 containers.stashost.local
192.168.1.39 vault.stashost.local
192.168.1.39 notifications.stashost.local
192.168.1.39 paste.stashost.local
192.168.1.39 git.stashost.local
192.168.1.39 tools.stashost.local
192.168.1.39 speed.stashost.local
192.168.1.39 tasks.stashost.local
192.168.1.39 wiki.stashost.local
192.168.1.39 finance.stashost.local
192.168.1.39 foundry.stashost.local

# 2mini services (routed through bmini Traefik)
192.168.1.39 sonarr.stashost.local
192.168.1.39 radarr.stashost.local
192.168.1.39 overseerr.stashost.local
192.168.1.39 jellyfin.stashost.local
192.168.1.39 bookmarks.stashost.local
192.168.1.39 photos.stashost.local
192.168.1.39 workflows.stashost.local
192.168.1.39 surveillance.stashost.local
192.168.1.39 tubearchivist.stashost.local
192.168.1.39 audiobooks.stashost.local
192.168.1.39 music.stashost.local
192.168.1.39 subtitles.stashost.local
192.168.1.39 indexers.stashost.local
HOSTS_2MINI

log "✅ /etc/hosts updated for 2mini"
