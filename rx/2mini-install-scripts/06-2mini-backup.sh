#!/bin/bash
# 06-2mini-backup.sh - Backup 2mini configurations
set -e

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

BACKUP_DIR="~/2lab/backups/$(date +%Y%m%d_%H%M%S)"

log "💾 Creating 2mini backup in $BACKUP_DIR..."

mkdir -p "$BACKUP_DIR"/{configs,databases,compose-files}

# Backup configurations
log "📋 Backing up configurations..."
cp -r ~/.config/sonarr "$BACKUP_DIR/configs/" 2>/dev/null || true
cp -r ~/.config/radarr "$BACKUP_DIR/configs/" 2>/dev/null || true
cp -r ~/.config/jellyseerr "$BACKUP_DIR/configs/" 2>/dev/null || true
cp -r ~/.config/jellyfin "$BACKUP_DIR/configs/" 2>/dev/null || true
cp -r ~/.config/bazarr "$BACKUP_DIR/configs/" 2>/dev/null || true
cp -r ~/.config/prowlarr "$BACKUP_DIR/configs/" 2>/dev/null || true

# Backup container data
log "📦 Backing up container data..."
cp -r ~/2lab/containers "$BACKUP_DIR/containers/" 2>/dev/null || true

# Backup compose files
log "🐳 Backing up compose files..."
find ~/2lab/containers -name "docker-compose.yml" -exec cp {} "$BACKUP_DIR/compose-files/" \; 2>/dev/null || true

# Create service list
log "📊 Creating service inventory..."
podman ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}" >"$BACKUP_DIR/service-inventory.txt"

log "✅ Backup completed: $BACKUP_DIR"
