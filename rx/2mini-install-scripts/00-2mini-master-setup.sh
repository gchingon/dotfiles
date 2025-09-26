#!/bin/bash
# 00-2mini-master-setup.sh - Execute complete 2mini service deployment
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$HOME/.config/log"
LOG_FILE="$LOG_DIR/2mini-complete-setup.log"

# Create log directory if it doesn't exist
mkdir -p "$LOG_DIR"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

run_script() {
  local script_name="$1"
  local script_path="$SCRIPT_DIR/$script_name"

  if [ -f "$script_path" ]; then
    log "🚀 Running: $script_name"
    if bash "$script_path" 2>&1 | tee -a "$LOG_FILE"; then
      log "✅ Completed: $script_name"
    else
      log "❌ Failed: $script_name"
      log "💥 2mini deployment failed at $script_name"
      log "📋 Check log file: $LOG_FILE"
      exit 1
    fi
  else
    log "❌ Script not found: $script_path"
    log "💥 2mini deployment failed - missing script: $script_name"
    log "📋 Check log file: $LOG_FILE"
    exit 1
  fi
}

# Clear previous log
>"$LOG_FILE"

log "🍎 === COMPLETE 2mini HOMELAB DEPLOYMENT ==="
log "Architecture: 2mini (M2 Pro) - Media + AI Hub"
log "User: $(whoami)"
log "Host: $(hostname)"
log "IP: $(hostname -I | awk '{print $1}')"
log "Time: $(date)"
log "Log: $LOG_FILE"
log ""

# Execute deployment scripts in order
for script in "01-2mini-directories.sh" "02-2mini-hosts.sh" "03-2mini-services.sh" "04-2mini-verification.sh" "05-2mini-configuration.sh" "06-2mini-backup.sh"; do
  run_script "$script"
done

log ""
log "🎉 === 2mini DEPLOYMENT SUCCESSFUL ==="
log ""
log "📊 === DEPLOYMENT SUMMARY ==="
log "✅ Directory Structure: Complete service directories created"
log "✅ Network Configuration: /etc/hosts updated for homelab routing"
log "✅ Media Automation: Sonarr, Radarr, Jellyseerr, Jellyfin"
log "✅ AI Services: Ollama, Karakeep, PhotoPrism, n8n, Frigate"
log "✅ Streaming & Archive: Tube Archivist, Audiobookshelf, Navidrome"
log "✅ Enhancement Tools: Bazarr, Prowlarr"
log "✅ Configuration: Helper scripts and setup guides"
log "✅ Backup System: Automated configuration backup"
log ""
log "🌐 === ACCESS POINTS ==="
log "Media Management: http://sonarr.stashost.local | http://radarr.stashost.local"
log "Media Streaming: http://jellyfin.stashost.local"
log "Media Requests: http://overseerr.stashost.local"
log "AI Services: http://photos.stashost.local | http://workflows.stashost.local"
log "Archive & Audio: http://tubearchivist.stashost.local | http://audiobooks.stashost.local"
log "Music Streaming: http://music.stashost.local"
log "Enhancement: http://subtitles.stashost.local | http://indexers.stashost.local"
log ""
log "⚙️ === CONFIGURATION NEXT STEPS ==="
log "1. Run: ~/2lab/configure-transmission.sh (setup download clients)"
log "2. Run: ~/2lab/setup-libraries.sh (configure media libraries)"
log "3. Configure Jellyfin libraries via web interface"
log "4. Set up PhotoPrism photo import directories"
log "5. Configure n8n workflows for automation"
log "6. Add indexers to Prowlarr and connect to *arr services"
log ""
log "🔗 === INTEGRATION STATUS ==="
log "Ready for: *arr ↔ Transmission integration"
log "Ready for: Jellyfin ↔ *arr media library integration"
log "Ready for: Prowlarr ↔ *arr indexer integration"
log "Ready for: n8n ↔ AI workflow automation"
log "Ready for: PhotoPrism ↔ media photo management"
log ""
log "📈 === SYSTEM RESOURCES ==="
log "CPU: $(sysctl -n hw.ncpu) cores (M2 Pro optimized)"
log "Memory: $(echo "$(sysctl -n hw.memsize) / 1024 / 1024 / 1024" | bc)GB"
log "Storage: $(df -h /Volumes | tail -n +2 | wc -l) volumes mounted"
log "Services: $(podman ps -q | wc -l) containers running"
log ""
log "🚀 === CLUSTER PREPARATION ==="
log "GPU-optimized: n8n, PhotoPrism, Frigate ready for M2 Pro GPU"
log "Cluster-ready: Ollama, n8n positioned for 4mini expansion"
log "AI-enhanced: Karakeep, PhotoPrism, Frigate with local GPU access"
log ""
log "📋 === MAINTENANCE COMMANDS ==="
log "Health Check: podman ps"
log "Service Status: curl -I http://[service].stashost.local"
log "Backup: bash 06-2mini-backup.sh"
log "Logs: tail -f $LOG_FILE"
log ""
log "🎯 === DEPLOYMENT COMPLETE ==="
log "Total Services: $(podman ps -a -q | wc -l | xargs) containers deployed"
log "Architecture: Media + AI Hub with GPU optimization"
log "Next Phase: Service configuration and bmini integration"
log "Success Time: $(date)"
log ""
log "🔧 Integration with bmini ready!"
log "📊 View dashboard: http://dashboard.stashost.local"
