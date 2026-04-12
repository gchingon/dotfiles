#!/bin/bash
# ln ~/.config/rx/bak.sh ~/.local/bin/bak
#
# bak - Backup File Toggle Script
# Usage: ./bak.sh [-c|--copy] <filename>
# Toggles .bak extension on files (adds if missing, removes if present)
# With -c/--copy flag: creates copy instead of moving (preserves original)

set -euo pipefail # Exit on error, undefined vars, pipe failures

# Global variable to control copy vs move behavior
USE_COPY=false

# Function to toggle backup extension
toggle_backup_extension() {
  local file="$1"
  local filename="${file%.*}"
  local extension="${file##*.}"

  # Validate file exists
  if [ ! -e "$file" ]; then
    echo "❌ Error: File '$file' does not exist"
    return 1
  fi

  # Check if file has .bak extension
  if [[ "$extension" == "bak" ]]; then
    # Remove .bak extension (always moves, copy doesn't apply to restoration)
    remove_backup_extension "$file" "$filename"
  else
    # Add .bak extension (respects copy/move mode)
    add_backup_extension "$file"
  fi
}

# Function to remove .bak extension
remove_backup_extension() {
  local file="$1"
  local filename="$2"

  # Handle edge case where filename might be just .bak
  if [ -z "$filename" ] || [ "$filename" == "$file" ]; then
    echo "⚠️  Warning: Cannot determine original filename for '$file'"
    echo "   File appears to be named just '.bak' or has unusual structure"
    return 1
  fi

  # Check if target file already exists
  if [ -e "$filename" ]; then
    echo "⚠️  Warning: Target file '$filename' already exists"
    echo "   Cannot restore '$file' - would overwrite existing file"
    echo "   Please resolve the conflict manually"
    return 1
  fi

  echo "🔄 Removing .bak extension from: $file"

  if mv "$file" "$filename"; then
    echo "✅ Successfully restored: $file → $filename"
    echo "📁 File is now active (no longer a backup)"
  else
    echo "❌ Failed to remove .bak extension from: $file"
    return 1
  fi
}

# Function to add .bak extension
add_backup_extension() {
  local file="$1"
  local new_filename="${file}.bak"

  # Check if backup already exists
  if [ -e "$new_filename" ]; then
    echo "⚠️  Warning: Backup file '$new_filename' already exists"
    echo "   (눈︿눈) Cannot create backup - file already backed up"

    # Show file details for comparison
    echo ""
    echo "📋 File comparison:"
    echo "   Original: $(ls -lh "$file" 2>/dev/null | awk '{print $5, $6, $7, $8}')"
    echo "   Backup:   $(ls -lh "$new_filename" 2>/dev/null | awk '{print $5, $6, $7, $8}')"

    return 1
  fi

  if [ "$USE_COPY" = true ]; then
    echo "📄 Creating backup copy of: $file"

    if cp "$file" "$new_filename"; then
      echo "✅ Successfully copied: $file → $new_filename"
      echo "🔒 Original file preserved, backup copy created"
    else
      echo "❌ Failed to create backup copy of: $file"
      return 1
    fi
  else
    echo "💾 Creating backup of: $file"

    if mv "$file" "$new_filename"; then
      echo "✅ Successfully backed up: $file → $new_filename"
      echo "🔒 Original file is now safely backed up"
    else
      echo "❌ Failed to create backup of: $file"
      return 1
    fi
  fi
}

# Function to show usage information
show_usage() {
  echo "Usage: $0 [-c|--copy] <filename> [filename2] [...]"
  echo ""
  echo "Toggles .bak extension on files:"
  echo "  • If file has .bak extension → removes it (restores original)"
  echo "  • If file lacks .bak extension → adds it (creates backup)"
  echo ""
  echo "Options:"
  echo "  -c, --copy    Create copy instead of moving file (preserves original)"
  echo "  -h, --help    Show this help message"
  echo ""
  echo "Examples:"
  echo "  $0 config.txt           # Moves config.txt to config.txt.bak"
  echo "  $0 -c config.txt        # Copies config.txt to config.txt.bak (keeps both)"
  echo "  $0 config.txt.bak       # Restores config.txt.bak to config.txt"
  echo "  $0 --copy script.sh     # Creates script.sh.bak copy"
  echo "  $0 -c file1 file2 file3 # Copy mode for multiple files"
  echo ""
  echo "Copy vs Move mode:"
  echo "  • Move mode (default): Original file becomes the backup"
  echo "  • Copy mode (-c/--copy): Original file stays, backup is a copy"
  echo "  • Restoration always moves (copy mode doesn't apply)"
  echo ""
  echo "Safety features:"
  echo "  • Won't overwrite existing files"
  echo "  • Shows file details when conflicts occur"
  echo "  • Validates file existence before processing"
}

# Function to handle multiple files
process_multiple_files() {
  local files=("$@")
  local processed=0
  local failed=0

  local mode_desc="moving"
  [ "$USE_COPY" = true ] && mode_desc="copying"

  echo "📁 Processing ${#files[@]} file(s) in $mode_desc mode..."
  echo ""

  for file in "${files[@]}"; do
    echo "🔄 Processing: $file"
    if toggle_backup_extension "$file"; then
      ((processed++))
    else
      ((failed++))
    fi
    echo ""
  done

  echo "📊 Summary:"
  echo "   Successfully processed: $processed files"
  [ "$failed" -gt 0 ] && echo "   Failed to process: $failed files"
}

FILES=()

parse_arguments() {
  FILES=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      -c|--copy) USE_COPY=true; shift ;;
      -h|--help) show_usage; exit 0 ;;
      -*) echo "❌ Error: Unknown option '$1'"; echo ""; show_usage; exit 1 ;;
      *) FILES+=("$1"); shift ;;
    esac
  done
}

# Main execution function
main() {
  echo "💾 Backup File Toggle (bak)"
  echo "==========================="

  parse_arguments "$@"

  # Check if any files provided
  if [ ${#FILES[@]} -eq 0 ]; then
    echo "❌ Error: Missing filename"
    echo ""
    show_usage
    exit 1
  fi

  # Show mode information
  if [ "$USE_COPY" = true ]; then
    echo "📄 Running in COPY mode - original files will be preserved"
  else
    echo "💾 Running in MOVE mode - files will become backups"
  fi
  echo ""

  # Handle multiple files
  if [ ${#FILES[@]} -gt 1 ]; then
    process_multiple_files "${FILES[@]}"
  else
    # Single file processing
    toggle_backup_extension "${FILES[0]}"
  fi
}

# Run main function with all arguments
main "$@"
