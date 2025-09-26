#!/usr/bin/env python3

"""
Multi-Format Audio Artwork Checker - Sorts audio files based on embedded artwork
Usage: ./audio-artwork-check.py [OPTIONS] [PATH]

Like a quality control station that sorts components with/without documentation
Handles: FLAC, ALAC, Opus, APE, MP3, OGG, AAC, M4A
"""

import argparse
import logging
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import List, Optional

# Configuration
SUPPORTED_FORMATS = ['flac', 'alac', 'opus', 'ape', 'mp3', 'ogg', 'aac', 'm4a', 'mp4']
DEFAULT_NO_ART_DIR = 'no-art'

# Global counters
processed = 0
moved = 0
errors = 0

class Colors:
    """ANSI color codes - like wire color coding in electrical work"""
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

def setup_logging(verbose: bool = False) -> None:
    """Setup logging configuration"""
    level = logging.DEBUG if verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(message)s',
        handlers=[logging.StreamHandler(sys.stderr)]
    )

def log_info(message: str) -> None:
    """Log info message with color"""
    print(f"{Colors.BLUE}[INFO]{Colors.NC} {message}", file=sys.stderr)

def log_warn(message: str) -> None:
    """Log warning message with color"""
    print(f"{Colors.YELLOW}[WARN]{Colors.NC} {message}", file=sys.stderr)

def log_error(message: str) -> None:
    """Log error message with color"""
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}", file=sys.stderr)

def log_success(message: str) -> None:
    """Log success message with color"""
    print(f"{Colors.GREEN}[SUCCESS]{Colors.NC} {message}", file=sys.stderr)

def log_debug(message: str) -> None:
    """Log debug message"""
    logging.debug(f"[DEBUG] {message}")

def check_dependencies() -> bool:
    """Check if required dependencies are available"""
    missing_deps = []

    # Check for ffprobe
    if not shutil.which('ffprobe'):
        missing_deps.append('ffprobe (from ffmpeg)')

    # Check for fd
    if not shutil.which('fd'):
        missing_deps.append('fd (fd-find)')

    if missing_deps:
        log_error(f"Missing dependencies: {', '.join(missing_deps)}")
        log_error("Install with:")
        log_error("  macOS: brew install ffmpeg fd")
        log_error("  Ubuntu: apt install ffmpeg fd-find")
        return False

    return True

def is_supported_format(file_path: Path) -> bool:
    """Check if file format is supported"""
    extension = file_path.suffix.lower().lstrip('.')
    return extension in SUPPORTED_FORMATS

def has_embedded_artwork(file_path: Path) -> bool:
    """
    Check if audio file has embedded artwork
    Like checking if a component has proper labeling attached
    """
    log_debug(f"Checking artwork in: {file_path}")

    try:
        # Use ffprobe to check for video streams (artwork appears as video stream)
        result = subprocess.run([
            'ffprobe', '-v', 'quiet', '-select_streams', 'v',
            '-show_entries', 'stream=codec_name', '-of', 'csv=p=0',
            str(file_path)
        ], capture_output=True, text=True, check=False)

        if result.returncode != 0:
            log_debug(f"ffprobe failed for {file_path}: {result.stderr}")
            return False

        video_streams = len([line for line in result.stdout.strip().split('\n') if line])
        log_debug(f"Video streams found: {video_streams}")

        has_art = video_streams > 0
        log_debug(f"Artwork {'detected' if has_art else 'not found'} in: {file_path}")
        return has_art

    except Exception as e:
        log_error(f"Error checking artwork in {file_path}: {e}")
        return False

def get_audio_format(file_path: Path) -> str:
    """Get display name for audio format"""
    extension = file_path.suffix.lower().lstrip('.')

    # For M4A/MP4, try to determine actual codec
    if extension in ['m4a', 'mp4']:
        try:
            result = subprocess.run([
                'ffprobe', '-v', 'quiet', '-select_streams', 'a:0',
                '-show_entries', 'stream=codec_name', '-of', 'csv=p=0',
                str(file_path)
            ], capture_output=True, text=True, check=False)

            if result.returncode == 0:
                codec = result.stdout.strip()
                if codec == 'alac':
                    return 'ALAC'
                elif codec == 'aac':
                    return 'AAC'
        except Exception:
            pass

        return 'M4A'

    # Standard format mapping
    format_map = {
        'flac': 'FLAC',
        'opus': 'Opus',
        'ape': 'APE',
        'mp3': 'MP3',
        'ogg': 'OGG',
        'aac': 'AAC'
    }

    return format_map.get(extension, extension.upper())

def process_audio_file(file_path: Path, dest_dir: Path, dry_run: bool = False) -> bool:
    """Process a single audio file"""
    global processed, moved, errors

    log_debug(f"Processing file: {file_path}")
    processed += 1

    if not file_path.is_file():
        log_error(f"File not found: {file_path}")
        errors += 1
        return False

    if not is_supported_format(file_path):
        log_warn(f"Skipping unsupported file: {file_path}")
        return True

    # Test if file is valid
    try:
        result = subprocess.run([
            'ffprobe', '-v', 'quiet', str(file_path)
        ], capture_output=True, check=False)

        if result.returncode != 0:
            log_error(f"Invalid or corrupted audio file: {file_path}")
            errors += 1
            return False
    except Exception as e:
        log_error(f"Error validating {file_path}: {e}")
        errors += 1
        return False

    format_name = get_audio_format(file_path)

    if has_embedded_artwork(file_path):
        log_info(f"✓ [{format_name}] Artwork found: {file_path.name}")
        return True
    else:
        log_warn(f"✗ [{format_name}] No artwork: {file_path.name}")

        # Ensure destination directory exists
        if not dry_run:
            dest_dir.mkdir(parents=True, exist_ok=True)

        dest_file = dest_dir / file_path.name

        if dry_run:
            log_info(f"[DRY RUN] Would move: {file_path} → {dest_file}")
        else:
            try:
                shutil.move(str(file_path), str(dest_file))
                log_success(f"Moved to: {dest_file}")
                moved += 1
            except Exception as e:
                log_error(f"Failed to move {file_path}: {e}")
                errors += 1
                return False

        return True

def find_audio_files(directory: Path, recursive: bool = False) -> List[Path]:
    """Use fd to find audio files in directory"""
    log_debug(f"Looking for supported audio files in: {directory}")

    try:
        # Build fd command with extensions
        fd_cmd = ['fd', '--type', 'f']
        if not recursive:
            fd_cmd.extend(['--max-depth', '1'])
        for ext in SUPPORTED_FORMATS:
            fd_cmd.extend(['-e', ext])

        fd_cmd.append(str(directory))

        log_debug(f"Running fd command: {' '.join(fd_cmd)}")

        result = subprocess.run(fd_cmd, capture_output=True, text=True, check=False)

        # Debugging: Print the output of fd
        log_debug(f"fd stdout: {result.stdout}")
        log_debug(f"fd stderr: {result.stderr}")

        # Convert output to Path objects and filter
        audio_files = []
        for line in result.stdout.strip().split('\n'):
            if line:  # Skip empty lines
                file_path = Path(line)
                if is_supported_format(file_path):
                    audio_files.append(file_path)

        # Sort for consistent processing order
        audio_files.sort()

        log_debug(f"fd found {len(audio_files)} supported files")
        return audio_files

    except Exception as e:
        log_error(f"Error finding audio files: {e}")
        return []

def process_directory(directory: Path, dest_dir: Path, dry_run: bool = False, recursive: bool = False) -> None:
    """Process all audio files in a directory"""
    log_info(f"Processing directory: {directory}")

    audio_files = find_audio_files(directory, recursive)

    if not audio_files:
        log_warn(f"No supported audio files found in: {directory}")
        log_info(f"Supported formats: {', '.join(SUPPORTED_FORMATS)}")
        return

    log_info(f"Found {len(audio_files)} audio files to process")

    for file_path in audio_files:
        log_debug(f"Processing file from directory: {file_path}")
        if not process_audio_file(file_path, dest_dir, dry_run):
            log_warn(f"Failed to process {file_path}, continuing with next file")

def show_summary() -> bool:
    """Show processing summary"""
    print()
    log_info("=== Processing Summary ===")
    log_info(f"Files processed: {processed}")
    log_info(f"Files moved: {moved}")
    log_info(f"Errors encountered: {errors}")
    log_info(f"Supported formats: {', '.join(SUPPORTED_FORMATS)}")

    if errors > 0:
        log_warn("Some files had errors - check logs above")
        return False
    else:
        log_success("All operations completed successfully")
        return True

def main():
    """Main function - like your project workflow"""
    parser = argparse.ArgumentParser(
        description="Check audio files for embedded artwork",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
SUPPORTED FORMATS:
    {', '.join(SUPPORTED_FORMATS)}

EXAMPLES:
    %(prog)s                          # Process current directory
    %(prog)s /path/to/music          # Process specific directory
    %(prog)s song.flac               # Process single file
    %(prog)s -n /music               # Dry run on /music directory
    %(prog)s -v -d ./missing-art .   # Verbose mode, custom destination
    %(prog)s -r /path/to/music        # Recursive processing of subdirectories

DEPENDENCIES:
    - ffprobe (from ffmpeg package)
    - fd (fd-find command)
        """
    )

    parser.add_argument(
        'path',
        nargs='?',
        default='.',
        help='Directory to process or specific audio file (default: current directory)'
    )
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose logging (DEBUG level)'
    )
    parser.add_argument(
        '-n', '--dry-run',
        action='store_true',
        help='Show what would be done without making changes'
    )
    parser.add_argument(
        '-d', '--dest-dir',
        default=DEFAULT_NO_ART_DIR,
        help=f'Destination directory for files without artwork (default: ./{DEFAULT_NO_ART_DIR})'
    )
    parser.add_argument(
        '-r', '--recursive',
        action='store_true',
        help='Recursively process files in subdirectories'
    )

    args = parser.parse_args()

    # Setup logging
    setup_logging(args.verbose)

    # Convert paths to Path objects
    target_path = Path(args.path).resolve()
    dest_dir = Path(args.dest_dir).resolve()

    log_info("Starting multi-format audio artwork check")
    log_info(f"Target: {target_path}")
    log_info(f"Destination for files without artwork: {dest_dir}")
    log_info(f"Supported formats: {', '.join(SUPPORTED_FORMATS)}")

    if args.dry_run:
        log_info("Dry run mode enabled - no files will be moved")

    # Preflight checks - like checking your tools before starting work
    if not check_dependencies():
        sys.exit(1)

    log_debug("Dependencies checked, proceeding with processing")

    if not target_path.exists():
        log_error(f"Target path does not exist: {target_path}")
        sys.exit(1)

    # Process based on whether target is file or directory
    log_debug(f"About to process target: {target_path}")
    if target_path.is_file():
        log_debug("Processing as single file")
        process_audio_file(target_path, dest_dir, args.dry_run)
    elif target_path.is_dir():
        log_debug("Processing as directory")
        process_directory(target_path, dest_dir, args.dry_run, args.recursive)
    else:
        log_error(f"Target is neither a file nor directory: {target_path}")
        sys.exit(1)

    # Show summary unless we're in dry run mode with single file
    if not args.dry_run or target_path.is_dir():
        success = show_summary()
        sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
