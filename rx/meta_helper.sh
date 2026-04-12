#!/bin/bash

# Meta.app Automation Helper
# Prepares matched opus/webp files for processing with Meta.app
# Usage: ./meta_helper.sh [directory] [mode]
# Modes: list, organize, applescript

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<EOF
Usage: meta_helper.sh [directory] [mode]

Modes:
  list|-l
  organize|-o
  applescript|-a
EOF
    exit 0
fi

# Set the target directory (default to current if not provided)
TARGET_DIR="${1:-.}"
MODE="${2:-list}"
case "$MODE" in
    -l) MODE="list" ;;
    -o) MODE="organize" ;;
    -a) MODE="applescript" ;;
esac

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Meta.app Automation Helper${NC}"
echo -e "${BLUE}Working directory: ${TARGET_DIR}${NC}"
echo -e "${BLUE}Mode: ${MODE}${NC}"
echo ""

# Initialize counters
matched=0
unmatched_opus=0
unmatched_webp=0

# Function to check if Meta.app supports AppleScript
check_meta_applescript() {
    echo -e "${YELLOW}Checking if Meta.app supports AppleScript...${NC}"

    if osascript -e 'tell application "System Events" to get name of every process whose name contains "Meta"' 2>/dev/null | grep -q "Meta"; then
        echo -e "${GREEN}Meta.app is running${NC}"
    else
        echo -e "${YELLOW}Meta.app is not currently running${NC}"
    fi

    # Try to get Meta's AppleScript dictionary
    if osascript -e 'tell application "Meta" to get version' 2>/dev/null; then
        echo -e "${GREEN}Meta.app responds to AppleScript commands!${NC}"
        return 0
    else
        echo -e "${RED}Meta.app does not appear to support AppleScript${NC}"
        return 1
    fi
}

# Function to create an AppleScript for automation
create_applescript() {
    local opus_file="$1"
    local webp_file="$2"

    cat << EOF
tell application "Meta"
    activate
    -- Try to open the opus file
    try
        open POSIX file "$opus_file"
        delay 2
        -- This would need to be customized based on Meta's actual AppleScript dictionary
        -- set artwork to load image from POSIX file "$webp_file"
    on error
        display dialog "Could not process $opus_file"
    end try
end tell
EOF
}

# Function to organize files for easier manual processing
organize_files() {
    local temp_dir="$TARGET_DIR/meta_processing"
    mkdir -p "$temp_dir"

    echo -e "${YELLOW}Creating organized workspace at: $temp_dir${NC}"

    # Find all .opus files and look for matching .webp
    while IFS= read -r -d '' opus_file; do
        basename=$(basename "$opus_file" .opus)
        dir=$(dirname "$opus_file")
        webp_file="$dir/$basename.webp"

        if [[ -f "$webp_file" ]]; then
            # Create a subfolder for this pair
            pair_dir="$temp_dir/$(printf "%03d" $((matched + 1)))_${basename// /_}"
            mkdir -p "$pair_dir"

            # Create symlinks to the original files
            ln -sf "$(realpath "$opus_file")" "$pair_dir/"
            ln -sf "$(realpath "$webp_file")" "$pair_dir/"

            echo -e "${GREEN}Organized: $basename${NC}"
            ((matched++))
        fi
    done < <(find "$TARGET_DIR" -name "*.opus" -type f -print0)

    echo ""
    echo -e "${BLUE}=== Organization Complete ===${NC}"
    echo -e "Matched pairs organized in: ${GREEN}$temp_dir${NC}"
    echo -e "You can now process each folder in Meta.app:"
    echo -e "1. Open Meta.app"
    echo -e "2. Drag the .opus file to Meta.app"
    echo -e "3. Drag the .webp file to the artwork area"
    echo -e "4. Save and move to next folder"
}

# Function to create a batch processing script
create_batch_script() {
    local script_file="$TARGET_DIR/process_with_meta.sh"

    cat << 'EOF' > "$script_file"
#!/bin/bash
# Batch processor for Meta.app
# This script will open each opus file in Meta.app automatically

echo "Starting batch processing..."
echo "Make sure Meta.app is installed and you're ready to manually add artwork"
echo ""
read -p "Press Enter to continue, or Ctrl+C to cancel..."

for folder in meta_processing/*/; do
    if [[ -d "$folder" ]]; then
        opus_file=$(find "$folder" -name "*.opus" -type l | head -1)
        webp_file=$(find "$folder" -name "*.webp" -type l | head -1)

        if [[ -n "$opus_file" && -n "$webp_file" ]]; then
            echo "Processing: $(basename "$folder")"
            echo "  Audio: $opus_file"
            echo "  Cover: $webp_file"

            # Open the opus file in Meta.app
            open -a Meta "$opus_file"

            # Open the webp file in Preview for easy dragging
            open -a Preview "$webp_file"

            echo "  Meta.app and Preview should now be open"
            echo "  Drag the image from Preview to Meta.app's artwork area"
            read -p "  Press Enter when done with this file..."

            # Close Preview
            osascript -e 'tell application "Preview" to quit'

            echo ""
        fi
    fi
done

echo "Batch processing complete!"
EOF

    chmod +x "$script_file"
    echo -e "${GREEN}Created batch processing script: $script_file${NC}"
    echo -e "${YELLOW}This script will open each file pair in Meta.app and Preview${NC}"
    echo -e "${YELLOW}You can then drag and drop the artwork manually${NC}"
}

# Main processing based on mode
case "$MODE" in
    "list")
        echo -e "${YELLOW}Scanning for matching opus/webp pairs...${NC}"
        echo ""

        # Find all .opus files and look for matching .webp
        while IFS= read -r -d '' opus_file; do
            basename=$(basename "$opus_file" .opus)
            dir=$(dirname "$opus_file")
            webp_file="$dir/$basename.webp"

            if [[ -f "$webp_file" ]]; then
                echo -e "${GREEN}✓ Match found: $basename${NC}"
                echo "  Audio: $opus_file"
                echo "  Cover: $webp_file"
                ((matched++))
            else
                echo -e "${RED}✗ No cover: $basename${NC}"
                ((unmatched_opus++))
            fi
            echo ""
        done < <(find "$TARGET_DIR" -name "*.opus" -type f -print0)
        ;;

    "organize")
        organize_files
        create_batch_script
        ;;

    "applescript")
        if check_meta_applescript; then
            echo -e "${GREEN}AppleScript automation might be possible!${NC}"
            echo -e "${YELLOW}You would need to examine Meta's AppleScript dictionary${NC}"
            echo -e "${YELLOW}Run: osascript -e 'tell application \"Meta\" to get AppleScript dictionary'${NC}"
        else
            echo -e "${RED}AppleScript automation not available${NC}"
            echo -e "${YELLOW}Falling back to organization mode...${NC}"
            organize_files
            create_batch_script
        fi
        ;;

    *)
        echo -e "${RED}Unknown mode: $MODE${NC}"
        echo -e "${YELLOW}Available modes: list, organize, applescript${NC}"
        exit 1
        ;;
esac

# Summary
echo -e "${BLUE}=== Summary ===${NC}"
echo -e "Matched pairs: ${GREEN}$matched${NC}"
echo -e "Unmatched opus files: ${RED}$unmatched_opus${NC}"

if [[ $matched -eq 0 ]]; then
    echo -e "${YELLOW}No matching opus/webp pairs found in $TARGET_DIR${NC}"
fi
