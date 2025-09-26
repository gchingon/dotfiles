#!/bin/bash
# 01-2mini-directories.sh - Create all service directories for 2mini
set -e

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "📁 Creating 2mini service directories..."

# Base directory
mkdir -p ~/2lab/containers

# Current services
mkdir -p ~/2lab/containers/{sonarr,radarr,jellyseerr,jellyfin,ollama,karakeep,photoprism,n8n,frigate}/{config,data}

# Planned services
mkdir -p ~/2lab/containers/{tube-archivist,audiobookshelf,navidrome,bazarr,prowlarr,whisper,stable-diffusion}/{config,data}

# Service-specific directories
mkdir -p ~/2lab/containers/jellyfin/{config,cache}
mkdir -p ~/2lab/containers/photoprism/{storage,originals,import}
mkdir -p ~/2lab/containers/karakeep/{database,uploads}
mkdir -p ~/2lab/containers/tube-archivist/{cache,media}
mkdir -p ~/2lab/containers/audiobookshelf/{audiobooks,podcasts,metadata}
mkdir -p ~/2lab/containers/navidrome/{music,playlists}
mkdir -p ~/2lab/containers/stable-diffusion/{models,outputs}
mkdir -p ~/2lab/containers/whisper/{models,temp}

# Tend directories (watch folders)
mkdir -p ~/2lab/tend/{movies,shows,music,youtube}

# Backup directory
mkdir -p ~/2lab/backups/{configs,databases,media}

log "🔐 Setting permissions..."
chmod -R 755 ~/2lab/containers
chmod -R 755 ~/2lab/tend
chmod -R 755 ~/2lab/backups

log "✅ 2mini directory structure created"
