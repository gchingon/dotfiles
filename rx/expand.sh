#!/bin/bash
# ln ~/.config/rx/expand.sh ~/.local/bin/expand

# expand - Universal Archive Extractor
# Usage: ./expand.sh <archive_file(s)>
# Automatically detects and extracts various archive formats

set -euo pipefail # Exit on error, undefined vars, pipe failures

# Color codes for better output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Function to check if required tools are installed
check_dependencies() {
  local missing_tools=()

  # Check for common extraction tools
  command -v tar >/dev/null || missing_tools+=("tar")
  command -v unzip >/dev/null || missing_tools+=("unzip")
  command -v gunzip >/dev/null || missing_tools+=("gzip")
  command -v bunzip2 >/dev/null || missing_tools+=("bzip2")

  # Optional tools (warn but don't fail)
  local optional_missing=()
  command -v unrar >/dev/null || optional_missing+=("unrar")
  command -v 7z >/dev/null || optional_missing+=("p7zip")
  command -v uncompress >/dev/null || optional_missing+=("ncompress")

  if [ ${#missing_tools[@]} -gt 0 ]; then
    echo -e "${RED}❌ Error: Missing required tools:${NC}"
    printf '   %s\n' "${missing_tools[@]}"
    echo ""
    echo "Install missing tools:"
    echo "  macOS: brew install ${missing_tools[*]}"
    echo "  Ubuntu/Debian: sudo apt install ${missing_tools[*]}"
    exit 1
  fi

  if [ ${#optional_missing[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: Optional tools not found:${NC}"
    printf '   %s\n' "${optional_missing[@]}"
    echo "   Some archive formats may not be supported"
    echo ""
  fi
}

# Function to get file size in human readable format
get_file_size() {
  local file="$1"
  if command -v stat >/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      stat -f%z "$file" | numfmt --to=iec 2>/dev/null || echo "unknown"
    else
      stat -c%s "$file" | numfmt --to=iec 2>/dev/null || echo "unknown"
    fi
  else
    echo "unknown"
  fi
}

# Function to extract a single archive
extract_archive() {
  local filename="$1"
  local file_size
  file_size=$(get_file_size "$filename")

  echo -e "${BLUE}📦 Processing:${NC} $filename (${file_size})"

  # Check if file exists
  if [ ! -f "$filename" ]; then
    echo -e "${RED}❌ Error:${NC} '$filename' not found"
    return 1
  fi

  # Check if file is readable
  if [ ! -r "$filename" ]; then
    echo -e "${RED}❌ Error:${NC} '$filename' is not readable"
    return 1
  fi

  # Create extraction directory based on archive name (without extension)
  local base_name="${filename%.*}"
  local extract_dir=""

  # For multi-part extensions, handle them properly
  case "$filename" in
  *.tar.bz2 | *.tar.gz | *.tar.xz)
    base_name="${filename%.tar.*}"
    ;;
  *.tbz2 | *.tgz)
    base_name="${filename%.*}"
    ;;
  esac

  # Ask user if they want to extract to a subdirectory
  if [ -t 0 ]; then # Only ask if running interactively
    echo -n "Extract to subdirectory '$base_name'? [Y/n]: "
    read -r response
    case "$response" in
    [nN] | [nN][oO]) extract_dir="" ;;
    *) extract_dir="$base_name" ;;
    esac
  else
    extract_dir="$base_name" # Default to subdirectory in non-interactive mode
  fi

  # Create extraction directory if specified
  if [ -n "$extract_dir" ]; then
    if [ -d "$extract_dir" ]; then
      echo -e "${YELLOW}⚠️  Warning:${NC} Directory '$extract_dir' already exists"
      echo -n "Continue extraction? [y/N]: "
      read -r response
      case "$response" in
      [yY] | [yY][eE][sS]) ;;
      *)
        echo "Extraction cancelled"
        return 1
        ;;
      esac
    else
      mkdir -p "$extract_dir"
      echo -e "${GREEN}📁 Created directory:${NC} $extract_dir"
    fi
    cd "$extract_dir"
  fi

  # Extract based on file extension
  echo -e "${BLUE}🔄 Extracting...${NC}"

  case "$filename" in
  *.tar.bz2 | *.tbz2)
    if tar -tf "$filename" >/dev/null 2>&1; then
      tar xjf "$filename" && echo -e "${GREEN}✅ Successfully extracted tar.bz2${NC}"
    else
      echo -e "${RED}❌ Error: Invalid or corrupted tar.bz2 file${NC}"
      return 1
    fi
    ;;
  *.tar.gz | *.tgz)
    if tar -tf "$filename" >/dev/null 2>&1; then
      tar xzf "$filename" && echo -e "${GREEN}✅ Successfully extracted tar.gz${NC}"
    else
      echo -e "${RED}❌ Error: Invalid or corrupted tar.gz file${NC}"
      return 1
    fi
    ;;
  *.tar.xz)
    if tar -tf "$filename" >/dev/null 2>&1; then
      tar xJf "$filename" && echo -e "${GREEN}✅ Successfully extracted tar.xz${NC}"
    else
      echo -e "${RED}❌ Error: Invalid or corrupted tar.xz file${NC}"
      return 1
    fi
    ;;
  *.bz2)
    if bunzip2 -t "$filename" 2>/dev/null; then
      bunzip2 "$filename" && echo -e "${GREEN}✅ Successfully extracted bz2${NC}"
    else
      echo -e "${RED}❌ Error: Invalid or corrupted bz2 file${NC}"
      return 1
    fi
    ;;
  *.rar)
    if command -v unrar >/dev/null; then
      if unrar t "$filename" >/dev/null 2>&1; then
        unrar x "$filename" && echo -e "${GREEN}✅ Successfully extracted rar${NC}"
      else
        echo -e "${RED}❌ Error: Invalid or corrupted rar file${NC}"
        return 1
      fi
    else
      echo -e "${RED}❌ Error: unrar not installed${NC}"
      return 1
    fi
    ;;
  *.gz)
    if gunzip -t "$filename" 2>/dev/null; then
      gunzip "$filename" && echo -e "${GREEN}✅ Successfully extracted gz${NC}"
    else
      echo -e "${RED}❌ Error: Invalid or corrupted gz file${NC}"
      return 1
    fi
    ;;
  *.tar)
    if tar -tf "$filename" >/dev/null 2>&1; then
      tar xf "$filename" && echo -e "${GREEN}✅ Successfully extracted tar${NC}"
    else
      echo -e "${RED}❌ Error: Invalid or corrupted tar file${NC}"
      return 1
    fi
    ;;
  *.zip)
    if unzip -t "$filename" >/dev/null 2>&1; then
      unzip "$filename" && echo -e "${GREEN}✅ Successfully extracted zip${NC}"
    else
      echo -e "${RED}❌ Error: Invalid or corrupted zip file${NC}"
      return 1
    fi
    ;;
  *.Z)
    if command -v uncompress >/dev/null; then
      uncompress "$filename" && echo -e "${GREEN}✅ Successfully extracted Z${NC}"
    else
      echo -e "${RED}❌ Error: uncompress not installed${NC}"
      return 1
    fi
    ;;
  *.7z)
    if command -v 7z >/dev/null; then
      if 7z t "$filename" >/dev/null 2>&1; then
        7z x "$filename" && echo -e "${GREEN}✅ Successfully extracted 7z${NC}"
      else
        echo -e "${RED}❌ Error: Invalid or corrupted 7z file${NC}"
        return 1
      fi
    else
      echo -e "${RED}❌ Error: 7z not installed${NC}"
      return 1
    fi
    ;;
  *)
    echo -e "${RED}❌ Error:${NC} (눈︿눈) '$filename' format not supported"
    echo "Supported formats: .tar.bz2, .tar.gz, .tar.xz, .bz2, .rar, .gz, .tar, .zip, .Z, .7z"
    return 1
    ;;
  esac

  # Return to original directory if we created a subdirectory
  if [ -n "$extract_dir" ]; then
    cd ..
    echo -e "${GREEN}📂 Extraction completed in:${NC} $extract_dir"

    # Show contents summary
    local item_count
    item_count=$(find "$extract_dir" -mindepth 1 -maxdepth 1 | wc -l)
    echo -e "${BLUE}📋 Extracted ${item_count} item(s)${NC}"
  fi

  return 0
}

# Function to show usage information
show_usage() {
  echo "Usage: $0 <archive_file(s)>"
  echo ""
  echo "Universal archive extractor that automatically detects and extracts various formats."
  echo ""
  echo "Supported formats:"
  echo "  • .tar.bz2, .tbz2  - Bzip2 compressed tar archives"
  echo "  • .tar.gz, .tgz    - Gzip compressed tar archives"
  echo "  • .tar.xz          - XZ compressed tar archives"
  echo "  • .bz2             - Bzip2 compressed files"
  echo "  • .rar             - RAR archives (requires unrar)"
  echo "  • .gz              - Gzip compressed files"
  echo "  • .tar             - Uncompressed tar archives"
  echo "  • .zip             - ZIP archives"
  echo "  • .Z               - Compress files (requires uncompress)"
  echo "  • .7z              - 7-Zip archives (requires p7zip)"
  echo ""
  echo "Examples:"
  echo "  $0 archive.tar.gz"
  echo "  $0 file1.zip file2.rar file3.tar.bz2"
  echo "  $0 *.tar.gz"
  echo ""
  echo "Features:"
  echo "  • Validates archive integrity before extraction"
  echo "  • Creates subdirectories for organized extraction"
  echo "  • Shows file sizes and extraction progress"
  echo "  • Handles multiple files in batch"
  echo ""
  echo "Options:"
  echo "  -h, --help    Show this help message"
}

# Function to process multiple archives
process_multiple_archives() {
  local archives=("$@")
  local processed=0
  local failed=0
  local start_time
  start_time=$(date +%s)

  echo -e "${BLUE}📦 Processing ${#archives[@]} archive(s)...${NC}"
  echo ""

  for archive in "${archives[@]}"; do
    echo "----------------------------------------"
    if extract_archive "$archive"; then
      ((processed++))
    else
      ((failed++))
    fi
    echo ""
  done

  local end_time
  end_time=$(date +%s)
  local duration=$((end_time - start_time))

  echo "========================================"
  echo -e "${GREEN}📊 Extraction Summary:${NC}"
  echo "   Successfully processed: $processed archives"
  [ "$failed" -gt 0 ] && echo -e "${RED}   Failed to process: $failed archives${NC}"
  echo "   Total time: ${duration}s"
}

# Main execution function
main() {
  echo -e "${BLUE}📦 Universal Archive Extractor${NC}"
  echo "=============================="

  # Check for help flag
  if [[ "${1:-}" == "-h" ]] || [[ "${1:-}" == "--help" ]]; then
    show_usage
    exit 0
  fi

  # Check if archive files provided
  if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Error: No archive files specified${NC}"
    echo ""
    show_usage
    exit 1
  fi

  # Check dependencies
  check_dependencies

  # Process archives
  if [ $# -eq 1 ]; then
    # Single archive
    extract_archive "$1"
  else
    # Multiple archives
    process_multiple_archives "$@"
  fi
}

# Run main function with all arguments
main "$@"
