#!/usr/bin/env bash
# ln ~/.config/rx/video-converter.sh ~/.local/bin/vidcon
# A robust, intelligent video processing script for macOS.
# Consolidates transcoding and remuxing logic.

FFMPEG_BIN="/opt/homebrew/bin/ffmpeg"

# --- HELPER FUNCTIONS (from your script) ---

_check_dependencies() {
    command -v "$FFMPEG_BIN" &> /dev/null || { echo "ffmpeg not found at $FFMPEG_BIN"; exit 1; }
    command -v "mediainfo" &> /dev/null || { echo "mediainfo not found, please run: brew install mediainfo"; exit 1; }
}

_check_videotoolbox() {
    "$FFMPEG_BIN" -hide_banner -encoders 2>/dev/null | grep -q "hevc_videotoolbox"
}

# --- MAIN PROCESSING LOGIC ---

# Determines if a file needs transcoding, remuxing, or nothing.
_needs_processing() {
    local file="$1"
    # Use mediainfo for reliable data
    local width=$(mediainfo --Inform="Video;%Width%" "$file")
    local height=$(mediainfo --Inform="Video;%Height%" "$file")
    local codec=$(mediainfo --Inform="Video;%Format%" "$file")
    local pix_fmt=$(mediainfo --Inform="Video;%ChromaSubsampling%" "$file")
    local container_ext="${file##*.}"

    echo "Info: ${codec} ${width}x${height} Chroma(${pix_fmt}) in .${container_ext}"

    # Convert to lowercase for comparison
    codec=$(echo "$codec" | tr '[:upper:]' '[:lower:]')
    container_ext=$(echo "$container_ext" | tr '[:upper:]' '[:lower:]')
    
    # HEVC is often reported as 'HEVC' or 'Main 10'. We check for its presence.
    if [[ "$codec" != *"hevc"* ]]; then
        echo "transcode,codec"
    elif [[ $width -gt 1920 || $height -gt 1080 ]]; then
        echo "transcode,resolution"
    elif [[ "$pix_fmt" != "4:2:0" ]]; then
        echo "transcode,pixfmt"
    elif [[ "$container_ext" != "mp4" ]]; then
        echo "remux,container"
    else
        echo "none"
    fi
}

# Transcodes a video file to h.265 with appropriate settings.
_transcode_video() {
    local input_file="$1"
    local output_file="${input_file%.*}_transcoded.mp4"
    local width=$(mediainfo --Inform="Video;%Width%" "$1")
    local height=$(mediainfo --Inform="Video;%Height%" "$1")

    local scale_filter=""
    if [[ $width -gt 1920 || $height -gt 1080 ]]; then
        scale_filter="-vf scale=1920:-2" # Scale to 1080p width, keeping aspect ratio
    fi
    
    local encoder_opts
    if _check_videotoolbox; then
        echo "Using hardware encoder: hevc_videotoolbox"
        # For videotoolbox, quality is set with -q:v. 55-75 is a good range. Let's aim for high quality.
        encoder_opts=("-c:v" "hevc_videotoolbox" "-q:v" "70")
    else
        echo "Using software encoder: libx265"
        encoder_opts=("-c:v" "libx265" "-crf" "23" "-preset" "medium")
    fi

    echo "Transcoding '$input_file'..."
    "$FFMPEG_BIN" -i "$input_file" \\
        "${encoder_opts[@]}" \\
        -pix_fmt yuv420p \\
        -tag:v hvc1 \\
        -c:a aac -b:a 192k \\
        -c:s copy \\
        -movflags +faststart \\
        $scale_filter \\
        -y "$output_file"

    [[ $? -eq 0 ]] && echo "Success: $output_file" || echo "Failure: $input_file"
}

# Remuxes a video file into an MP4 container, tagging for QuickLook.
_remux_video() {
    local input_file="$1"
    local output_file="${input_file%.*}_remuxed.mp4"

    echo "Remuxing '$input_file'..."
    "$FFMPEG_BIN" -i "$input_file" -c copy -tag:v hvc1 -movflags +faststart -f mp4 -y "$output_file"
    [[ $? -eq 0 ]] && echo "Success: $output_file" || echo "Failure: $input_file"
}


# --- SCRIPT ENTRY POINT ---

main() {
    _check_dependencies

    if [ "$#" -eq 0 ]; then
        echo "Usage: $(basename "$0") <file_or_directory> [file2...]"
        echo "Processes video files, intelligently deciding whether to transcode or remux."
        exit 1
    fi

    for arg in "$@"; do
        if [ -f "$arg" ]; then
            process_logic "$arg"
        elif [ -d "$arg" ]; then
            echo "--- Processing Directory: $arg ---"
            find "$arg" -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" \) | while read -r file; do
                process_logic "$file"
            done
        fi
    done
}

process_logic() {
    local file="$1"
    echo -e "\n--- Analyzing: $(basename "$file") ---"
    
    local size_bytes=$(stat -f%z "$file")
    if [[ $size_bytes -lt 500000000 ]]; then
        echo "Skip: File is smaller than 500MB."
        return
    fi
    
    local processing_info=$(_needs_processing "$file")
    local action=$(echo "$processing_info" | cut -d',' -f1)
    local reason=$(echo "$processing_info" | cut -d',' -f2)

    case "$action" in
        "transcode")
            echo "Action: Transcode. Reason: $reason."
            _transcode_video "$file"
            ;;
        "remux")
            echo "Action: Remux. Reason: container needs hvc1 tag for QuickLook."
            _remux_video "$file"
            ;;
        "none")
            echo "Action: Skip. File is already compliant."
            ;;
    esac
}

# Run the main function with all provided arguments
main "$@"
