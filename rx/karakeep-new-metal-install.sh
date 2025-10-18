#!/bin/bash

# Karakeep Installation Script for Apple Container
# Requires: macOS 26, Apple Silicon, and Apple's container tool installed

set -e  # Exit on error

KARAKEEP_DIR="$HOME/karakeep-app"
ENV_FILE="$KARAKEEP_DIR/.env"

echo "=== Karakeep Installation Script for Apple Container ==="
echo ""

# Create directory if it doesn't exist
mkdir -p "$KARAKEEP_DIR"

# Function to load env variables from file
load_env() {
    if [ -f "$ENV_FILE" ]; then
        echo "Loading existing .env file..."
        export $(grep -v '^#' "$ENV_FILE" | xargs)
        return 0
    else
        return 1
    fi
}

# Function to create .env file
create_env() {
    echo "Creating new .env file..."
    
    # Generate random keys
    NEXTAUTH_SECRET=$(openssl rand -base64 36)
    MEILI_MASTER_KEY=$(openssl rand -base64 36)
    
    echo "Generated keys:"
    echo "  NEXTAUTH_SECRET: ${NEXTAUTH_SECRET:0:20}..."
    echo "  MEILI_MASTER_KEY: ${MEILI_MASTER_KEY:0:20}..."
    echo ""
    
    # Ask about OpenAI/Raycast Relay configuration
    read -p "Do you want to configure AI for automatic tagging? (y/n): " configure_ai
    
    # Create base .env
    cat > "$ENV_FILE" << EOF
KARAKEEP_VERSION=release
NEXTAUTH_SECRET=$NEXTAUTH_SECRET
MEILI_MASTER_KEY=$MEILI_MASTER_KEY
NEXTAUTH_URL=http://localhost:3000
EOF
    
    if [[ $configure_ai == "y" || $configure_ai == "Y" ]]; then
        read -p "Enter your API key (OpenAI or Raycast Relay): " OPENAI_API_KEY
        read -p "Enter API base URL (press Enter for default OpenAI): " OPENAI_BASE_URL
        read -p "Enter text model (default: gpt-4o-mini): " INFERENCE_TEXT_MODEL
        INFERENCE_TEXT_MODEL=${INFERENCE_TEXT_MODEL:-gpt-4o-mini}
        
        cat >> "$ENV_FILE" << EOF
OPENAI_API_KEY=$OPENAI_API_KEY
EOF
        
        if [ -n "$OPENAI_BASE_URL" ]; then
            cat >> "$ENV_FILE" << EOF
OPENAI_BASE_URL=$OPENAI_BASE_URL
EOF
        fi
        
        cat >> "$ENV_FILE" << EOF
INFERENCE_TEXT_MODEL=$INFERENCE_TEXT_MODEL
EOF
    fi
    
    echo ".env file created at: $ENV_FILE"
    echo ""
    
    # Load the newly created env
    load_env
}

# Check if .env exists, if not create it
if ! load_env; then
    create_env
else
    echo "Using existing .env file from: $ENV_FILE"
    echo ""
    read -p "Do you want to reconfigure? (y/n): " reconfigure
    if [[ $reconfigure == "y" || $reconfigure == "Y" ]]; then
        create_env
    fi
fi

# Function to check if container exists
container_exists() {
    container list --all 2>/dev/null | grep -q "$1"
}

# Function to check if container is running
container_running() {
    container list 2>/dev/null | grep -q "$1"
}

# Function to ensure network exists
ensure_network() {
    if container network list 2>/dev/null | grep -q "karakeep-net"; then
        echo "Network karakeep-net already exists"
    else
        echo "Creating network karakeep-net..."
        container network create karakeep-net 2>/dev/null || echo "Network creation skipped (may already exist)"
    fi
}

# Function to ensure volume exists
ensure_volume() {
    if container volume list 2>/dev/null | grep -q "$1"; then
        echo "Volume $1 already exists"
    else
        echo "Creating volume $1..."
        container volume create "$1" 2>/dev/null || echo "Volume creation skipped (may already exist)"
    fi
}

# Function to pull image if not present
ensure_image() {
    local image=$1
    # Extract just the image name without tag for checking
    local image_name=$(echo "$image" | cut -d: -f1)
    if container image list 2>/dev/null | grep -q "$image_name"; then
        echo "Image $image already exists"
    else
        echo "Pulling image $image..."
        container image pull "$image"
    fi
}

# Function to start or create container
start_meilisearch() {
    # Always remove and recreate to ensure proper network connection
    if container_exists "meilisearch"; then
        echo "Removing existing Meilisearch container..."
        container stop meilisearch 2>/dev/null || true
        container rm meilisearch 2>/dev/null || true
    fi
    
    echo "Creating and starting Meilisearch..."
    container run -d \
      --name meilisearch \
      --network karakeep-net \
      -v meilisearch-data:/meili_data \
      -e MEILI_MASTER_KEY="$MEILI_MASTER_KEY" \
      getmeili/meilisearch:v1.10
}

start_chrome() {
    # Always remove and recreate to ensure proper network connection
    if container_exists "chrome"; then
        echo "Removing existing Chrome container..."
        container stop chrome 2>/dev/null || true
        container rm chrome 2>/dev/null || true
    fi
    
    echo "Creating and starting Chrome..."
    container run -d \
      --name chrome \
      --network karakeep-net \
      -e CHROME_FLAGS="--disable-gpu,--disable-dev-shm-usage,--no-sandbox" \
      gcr.io/zenika-hub/alpine-chrome:123 \
      chromium-browser --headless --disable-gpu --disable-dev-shm-usage --no-sandbox --remote-debugging-address=0.0.0.0 --remote-debugging-port=9222 --hide-scrollbars
}

start_karakeep() {
    # Always remove and recreate to ensure proper network connection and env vars
    if container_exists "karakeep"; then
        echo "Removing existing Karakeep container..."
        container stop karakeep 2>/dev/null || true
        container rm karakeep 2>/dev/null || true
    fi
    
    echo "Creating and starting Karakeep..."
    
    # Get IP addresses of meilisearch and chrome (Apple container doesn't have DNS)
    MEILI_IP=$(container list | grep meilisearch | awk '{print $6}')
    CHROME_IP=$(container list | grep chrome | awk '{print $6}')
    
    echo "Detected Meilisearch IP: $MEILI_IP"
    echo "Detected Chrome IP: $CHROME_IP"
    
    # Build environment variables
    ENV_VARS="-e MEILI_ADDR=http://${MEILI_IP}:7700 \
              -e MEILI_MASTER_KEY=$MEILI_MASTER_KEY \
              -e NEXTAUTH_SECRET=$NEXTAUTH_SECRET \
              -e NEXTAUTH_URL=$NEXTAUTH_URL \
              -e BROWSER_WEB_URL=http://${CHROME_IP}:9222 \
              -e DATA_DIR=/data"
    
    # Add OpenAI/AI config if present
    if [ -n "$OPENAI_API_KEY" ]; then
        ENV_VARS="$ENV_VARS -e OPENAI_API_KEY=$OPENAI_API_KEY"
    fi
    
    if [ -n "$OPENAI_BASE_URL" ]; then
        ENV_VARS="$ENV_VARS -e OPENAI_BASE_URL=$OPENAI_BASE_URL"
    fi
    
    if [ -n "$INFERENCE_TEXT_MODEL" ]; then
        ENV_VARS="$ENV_VARS -e INFERENCE_TEXT_MODEL=$INFERENCE_TEXT_MODEL"
    fi
    
    if [ -n "$INFERENCE_IMAGE_MODEL" ]; then
        ENV_VARS="$ENV_VARS -e INFERENCE_IMAGE_MODEL=$INFERENCE_IMAGE_MODEL"
    fi
    
    # Run container
    container run -d \
      --name karakeep \
      --network karakeep-net \
      -p 3000:3000 \
      -v karakeep-data:/data \
      $ENV_VARS \
      ghcr.io/karakeep-app/karakeep:${KARAKEEP_VERSION:-release}
}

echo "Setting up infrastructure..."
echo ""

# Ensure network and volumes exist
ensure_network
ensure_volume "karakeep-data"
ensure_volume "meilisearch-data"
echo ""

# Ensure images are pulled
echo "Checking images..."
ensure_image "ghcr.io/karakeep-app/karakeep:${KARAKEEP_VERSION:-release}"
ensure_image "getmeili/meilisearch:v1.10"
ensure_image "gcr.io/zenika-hub/alpine-chrome:123"
echo ""

# Start services
echo "Starting services..."
echo ""

start_meilisearch
echo ""

start_chrome
echo ""

# Wait for dependencies
echo "Waiting for dependencies to initialize..."
sleep 3
echo ""

start_karakeep
echo ""

# Display status
echo "=== Setup Complete! ==="
echo ""
echo "Services status:"
container list 2>/dev/null | grep -E "karakeep|meilisearch|chrome" || echo "No containers found"
echo ""
echo "Access Karakeep at: http://localhost:3000"
echo ""
echo "Configuration file: $ENV_FILE"
echo ""
echo "Useful commands:"
echo "  View logs:        container logs karakeep -f"
echo "  Stop services:    container stop karakeep chrome meilisearch"
echo "  Start services:   container start meilisearch chrome karakeep"
echo "  Remove services:  container rm -f karakeep chrome meilisearch"
echo "  Restart script:   bash $0"
echo ""