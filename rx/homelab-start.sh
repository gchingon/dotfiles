#!/bin/bash
# Wait for podman machine to be ready
while ! podman system info >/dev/null 2>&1; do
  echo "Waiting for podman machine..."
  sleep 5
done

# Navigate to compose directory and start services
cd ~/.config/2mini-homelab
podman-compose up -d

echo "2mini homelab started successfully"
