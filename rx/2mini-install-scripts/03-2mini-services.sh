#!/bin/bash
# 03-2mini-services.sh - Install all 2mini services
set -e

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "🐳 Installing 2mini services..."

# Change to containers directory
cd ~/2lab/containers

# ===== MEDIA AUTOMATION SERVICES =====

log "📺 Installing Sonarr..."
podman run -d \
  --name sonarr \
  -p 8989:8989 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/.config/sonarr:/config:Z \
  -v /Volumes/shows:/tv:Z \
  -v ~/2lab/tend/shows:/watch:Z \
  --restart unless-stopped \
  docker.io/linuxserver/sonarr

log "🎥 Installing Radarr..."
podman run -d \
  --name radarr \
  -p 7878:7878 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/.config/radarr:/config:Z \
  -v /Volumes/movies:/movies:Z \
  -v /Volumes/cinema:/cinema:Z \
  -v ~/2lab/tend/movies:/watch:Z \
  --restart unless-stopped \
  docker.io/linuxserver/radarr

log "🎭 Installing Jellyseerr..."
podman run -d \
  --name jellyseerr \
  -p 5055:5055 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/.config/jellyseerr:/app/config:Z \
  --restart unless-stopped \
  docker.io/fallenbagel/jellyseerr

log "🍿 Installing Jellyfin..."
podman run -d \
  --name jellyfin \
  -p 8096:8096 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/.config/jellyfin:/config:Z \
  -v ~/2lab/containers/jellyfin/cache:/cache:Z \
  -v /Volumes/movies:/media/movies:Z \
  -v /Volumes/shows:/media/shows:Z \
  -v /Volumes/cinema:/media/cinema:Z \
  -v /Volumes/delta/music:/media/music:Z \
  --restart unless-stopped \
  docker.io/jellyfin/jellyfin

# ===== AI SERVICES =====

log "🧠 Installing Ollama..."
cd ollama
podman-compose up -d
cd ..

log "🔖 Installing Karakeep..."
cd karakeep
podman-compose up -d
cd ..

log "📸 Installing PhotoPrism..."
podman run -d \
  --name photoprism \
  -p 2342:2342 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -e PHOTOPRISM_ADMIN_PASSWORD=admin123 \
  -e PHOTOPRISM_SITE_URL=http://photos.stashost.local \
  -e PHOTOPRISM_DATABASE_DRIVER=sqlite \
  -v ~/2lab/containers/photoprism/storage:/photoprism/storage:Z \
  -v ~/2lab/containers/photoprism/originals:/photoprism/originals:Z \
  -v ~/2lab/containers/photoprism/import:/photoprism/import:Z \
  --restart unless-stopped \
  docker.io/photoprism/photoprism

log "🔄 Installing n8n..."
podman run -d \
  --name n8n \
  -p 5678:5678 \
  -e TZ=America/Los_Angeles \
  -e N8N_BASIC_AUTH_ACTIVE=true \
  -e N8N_BASIC_AUTH_USER=admin \
  -e N8N_BASIC_AUTH_PASSWORD=admin123 \
  -e N8N_SECURE_COOKIE=false \
  -e WEBHOOK_URL=http://workflows.stashost.local \
  -v ~/2lab/containers/n8n/data:/home/node/.n8n:Z \
  --restart unless-stopped \
  docker.io/n8nio/n8n

log "👁️ Installing Frigate..."
# Create config file
cat >~/2lab/containers/frigate/config/config.yml <<'FRIGATE_CONFIG'
mqtt:
  enabled: false

database:
  path: /db/frigate.db

model:
  model: yolov8n.pt
  width: 640
  height: 640

detect:
  enabled: true
  width: 1280
  height: 720
  fps: 5

objects:
  track:
    - person
    - car
    - bicycle
    - motorcycle
    - bus
    - truck
    - cat
    - dog

cameras:
  dummy_camera:
    enabled: false
    ffmpeg:
      inputs:
        - path: rtsp://dummy
          roles:
            - detect
FRIGATE_CONFIG

podman run -d \
  --name frigate \
  -p 5000:5000 \
  -p 8554:8554 \
  -p 8555:8555/tcp \
  -p 8555:8555/udp \
  -e TZ=America/Los_Angeles \
  -v ~/2lab/containers/frigate/config:/config:Z \
  -v ~/2lab/containers/frigate/storage:/media/frigate:Z \
  -v type=tmpfs,target=/tmp/cache,tmpfs-size=1000000000 \
  --restart unless-stopped \
  ghcr.io/blakeblackshear/frigate:stable

# ===== PLANNED SERVICES =====

log "📺 Installing Tube Archivist..."
podman run -d \
  --name tube-archivist \
  -p 8000:8000 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/2lab/containers/tube-archivist/cache:/cache:Z \
  -v /Volumes/armor/didact/YT:/youtube:Z \
  --restart unless-stopped \
  docker.io/bbilly1/tubearchivist

log "📚 Installing Audiobookshelf..."
podman run -d \
  --name audiobookshelf \
  -p 13378:80 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/2lab/containers/audiobookshelf/audiobooks:/audiobooks:Z \
  -v ~/2lab/containers/audiobookshelf/podcasts:/podcasts:Z \
  -v ~/.config/audiobookshelf:/config:Z \
  -v ~/2lab/containers/audiobookshelf/metadata:/metadata:Z \
  --restart unless-stopped \
  docker.io/advplyr/audiobookshelf

log "🎵 Installing Navidrome..."
podman run -d \
  --name navidrome \
  -p 4533:4533 \
  -e TZ=America/Los_Angeles \
  -e ND_MUSICFOLDER=/music \
  -e ND_DATAFOLDER=/data \
  -v /Volumes/delta/music:/music:Z \
  -v ~/2lab/containers/navidrome/data:/data:Z \
  --restart unless-stopped \
  docker.io/deluan/navidrome

log "📝 Installing Bazarr..."
podman run -d \
  --name bazarr \
  -p 6767:6767 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/.config/bazarr:/config:Z \
  -v /Volumes/movies:/movies:Z \
  -v /Volumes/cinema:/cinema:Z \
  -v /Volumes/shows:/tv:Z \
  --restart unless-stopped \
  docker.io/linuxserver/bazarr

log "🔍 Installing Prowlarr..."
podman run -d \
  --name prowlarr \
  -p 9696:9696 \
  -e TZ=America/Los_Angeles \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ~/.config/prowlarr:/config:Z \
  --restart unless-stopped \
  docker.io/linuxserver/prowlarr

log "✅ All 2mini services installed"
