#!/bin/bash
# 04-2mini-verification.sh - Verify 2mini service installation
set -e

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "🔍 Verifying 2mini service installation..."

# Function to check service
check_service() {
  local service_name=$1
  local port=$2
  local expected_status=${3:-200}

  local status=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://localhost:$port" 2>/dev/null)

  if [ "$status" = "$expected_status" ]; then
    echo "  ✅ $service_name (Port $port)"
    return 0
  elif [ "$status" = "401" ] || [ "$status" = "307" ]; then
    echo "  ✅ $service_name (Port $port) - Auth required"
    return 0
  elif [ "$status" = "000" ]; then
    echo "  ❌ $service_name (Port $port) - Service not responding"
    return 1
  else
    echo "  ⚠️  $service_name (Port $port) - Status: $status"
    return 1
  fi
}

# Check container status
echo "📦 Container Status:"
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "🌐 Service Accessibility:"

# Current services
check_service "Sonarr" "8989"
check_service "Radarr" "7878"
check_service "Jellyseerr" "5055"
check_service "Jellyfin" "8096"
check_service "Karakeep" "3000"
check_service "PhotoPrism" "2342"
check_service "n8n" "5678"
check_service "Frigate" "5000"

# Planned services
check_service "Tube Archivist" "8000"
check_service "Audiobookshelf" "13378"
check_service "Navidrome" "4533"
check_service "Bazarr" "6767"
check_service "Prowlarr" "9696"

echo ""
echo "📊 Summary:"
running_containers=$(podman ps -q | wc -l)
total_containers=$(podman ps -a -q | wc -l)
echo "  Containers: $running_containers/$total_containers running"

echo ""
echo "🌐 Web Access URLs:"
echo "  Media: http://sonarr.stashost.local | http://radarr.stashost.local"
echo "  Streaming: http://jellyfin.stashost.local"
echo "  Requests: http://overseerr.stashost.local"
echo "  AI: http://photos.stashost.local | http://workflows.stashost.local"
echo "  Archive: http://tubearchivist.stashost.local"
echo "  Audio: http://audiobooks.stashost.local | http://music.stashost.local"

log "✅ 2mini verification complete"
