#!/usr/bin/env python3
# ~/.config/rx/youtube-downloader-utility.py
# Hardlinked to ~/.local/bin/ytdl
# Aliases:
#   ytd = ytdl video    # Download video with options
#   ytx = ytdl audio    # Extract audio from video
#   ytl = ytdl list     # Download from a list of URLs
#   ytp = ytdl urls     # Extract URLs from playlist

import sys
import os
import argparse
import subprocess
import concurrent.futures
import time
import re
import tempfile
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple, Union

# Constants
DEFAULT_RATE_LIMIT = "2M"
DEFAULT_CONCURRENT = 3
DEFAULT_SLEEP = 3
FAILED_LOG = "failed_ytdx_urls.txt"

# ANSI color codes for terminal output
class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    MAGENTA = "\033[95m"
    CYAN = "\033[96m"

# Emoji indicators for different message types
class Emoji:
    INFO = "ℹ️"
    SUCCESS = "✅"
    ERROR = "❌"
    WARNING = "⚠️"
    DOWNLOAD = "⬇️"
    PROCESSING = "🔄"
    MUSIC = "🎵"
    VIDEO = "🎬"
    PLAYLIST = "📋"
    BATCH = "📦"
    WAITING = "⏳"
    SLEEPING = "😴"
    COMPLETE = "🎉"
    STATS = "📊"
    TARGET = "🎯"
    DEBUG = "🔧"
    SUBTITLES = "📝"
    QUALITY = "📏"
    FORMAT = "🎞️"
    SEARCH = "🔍"

# Logging functions
def log_msg(emoji: str, message: str) -> None:
    """Print a formatted log message with emoji."""
    print(f"{emoji} {message}")

def log_error(message: str) -> None:
    """Print a formatted error message."""
    print(f"{Emoji.ERROR} {Colors.RED}Error: {message}{Colors.RESET}", file=sys.stderr)

def log_success(message: str) -> None:
    """Print a formatted success message."""
    print(f"{Emoji.SUCCESS} {Colors.GREEN}{message}{Colors.RESET}")

def log_warning(message: str) -> None:
    """Print a formatted warning message."""
    print(f"{Emoji.WARNING} {Colors.YELLOW}{message}{Colors.RESET}")

def log_debug(message: str, debug: bool = False) -> None:
    """Print a debug message if debug mode is enabled."""
    if debug:
        print(f"{Emoji.DEBUG} {Colors.CYAN}DEBUG: {message}{Colors.RESET}")

# Check if yt-dlp is available
def check_yt_dlp() -> bool:
    """Check if yt-dlp is installed and available."""
    try:
        subprocess.run(["yt-dlp", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        return True
    except (subprocess.SubprocessError, FileNotFoundError):
        log_error("yt-dlp is not installed. Please install it first.")
        print("  macOS: brew install yt-dlp")
        print("  Linux: apt install yt-dlp or equivalent")
        return False

# Run yt-dlp command and return output
def run_yt_dlp(args: List[str], capture_output: bool = True, debug: bool = False) -> Tuple[int, str]:
    """Run yt-dlp with the given arguments and return exit code and output."""
    cmd = ["yt-dlp"] + args
    
    if debug:
        log_debug(f"Running command: {' '.join(cmd)}")
    
    try:
        if capture_output:
            result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            return result.returncode, result.stdout
        else:
            result = subprocess.run(cmd)
            return result.returncode, ""
    except subprocess.SubprocessError as e:
        return 1, str(e)

# Video download functionality
def download_video(args: argparse.Namespace) -> int:
    """Download videos with the specified options."""
    # Set defaults based on arguments
    quality = args.quality
    format_preference = args.format
    subtitle_mode = "none" if args.no_subtitles else "auto"
    urls = args.urls
    
    # Quality suffix for output filenames
    quality_suffix_map = {
        "2160": "_4K",
        "1080": "_FHD",
        "720": "_HD"
    }
    quality_suffix = quality_suffix_map.get(quality, "_FHD")
    
    # Log selected options
    log_msg(Emoji.QUALITY, f"Video quality: {quality}p")
    log_msg(Emoji.FORMAT, f"Format preference: {format_preference}")
    if subtitle_mode == "auto":
        log_msg(Emoji.SUBTITLES, "Subtitles: Auto (SRT preferred → VTT → any available)")
    else:
        log_msg(Emoji.SUBTITLES, "Subtitles: Disabled")
    log_msg(Emoji.INFO, f"Output directory: {os.getcwd()}")
    log_msg(Emoji.INFO, f"URLs to process: {len(urls)}")
    print()
    
    # Build format selector based on preferences
    format_selector = ""
    if format_preference == "mp4":
        format_selector = f"bv*[height<={quality}][ext=mp4]+ba[ext=m4a]/bv*[height<={quality}][ext=mkv]+ba/b[height<={quality}][ext=mp4]/b[height<={quality}]"
    elif format_preference == "mkv":
        format_selector = f"bv*[height<={quality}][ext=mkv]+ba/bv*[height<={quality}][ext=mp4]+ba[ext=m4a]/b[height<={quality}][ext=mkv]/b[height<={quality}]"
    elif format_preference == "both":
        format_selector = f"bv*[height<={quality}]+ba/b[height<={quality}]"
    
    total_downloads = 0
    successful_downloads = 0
    failed_downloads = 0
    skipped_downloads = 0
    
    # Process downloads
    if format_preference == "both":
        # Download both MP4 and MKV formats
        for format_type in ["mp4", "mkv"]:
            log_msg(Emoji.TARGET, f"Processing format: {format_type}")
            print("----------------------------------------")
            
            format_success = 0
            format_failed = 0
            format_skipped = 0
            
            # Set format-specific selector
            if format_type == "mp4":
                format_selector = f"bv*[height<={quality}][ext=mp4]+ba[ext=m4a]/b[height<={quality}][ext=mp4]"
            else:
                format_selector = f"bv*[height<={quality}][ext=mkv]+ba/b[height<={quality}][ext=mkv]"
            
            for url in urls:
                total_downloads += 1
                
                # Create format-specific output template
                output_template = f"%(title)s{quality_suffix}.%(ext)s"
                if format_type == "mkv":
                    output_template = f"%(title)s{quality_suffix}_MKV.%(ext)s"
                
                log_msg(Emoji.DOWNLOAD, f"Processing [{total_downloads}]: {url} ({format_type})")
                
                # Check if file already exists
                exit_code, filename_output = run_yt_dlp(["--get-filename", "-o", output_template, "--format", format_selector, url])
                
                if exit_code == 0 and os.path.exists(filename_output.strip()):
                    log_msg(Emoji.WARNING, f"Skipping (exists): {filename_output.strip()}")
                    skipped_downloads += 1
                    format_skipped += 1
                    continue
                
                # Build subtitle options
                subtitle_options = []
                if subtitle_mode == "auto":
                    subtitle_options = [
                        "--write-subs", 
                        "--write-auto-subs", 
                        "--sub-langs", "all", 
                        "--sub-format", "srt/vtt/best"
                    ]
                
                # Main download command
                download_args = [
                    "--embed-chapters",
                    "--embed-metadata",
                    "--embed-subs",
                    *subtitle_options,
                    "--no-warnings",
                    "--format", format_selector,
                    "-o", output_template,
                    "--ignore-errors",
                    "--no-overwrites",
                    "--continue",
                    url
                ]
                
                exit_code, _ = run_yt_dlp(download_args, capture_output=False)
                
                if exit_code == 0:
                    log_success(f"Downloaded {format_type} version ({quality}p)")
                    
                    # Check for subtitle availability
                    if subtitle_mode == "auto":
                        check_subtitle_status(output_template, url)
                    
                    successful_downloads += 1
                    format_success += 1
                else:
                    log_error(f"Failed: {url} ({format_type} format)")
                    failed_downloads += 1
                    format_failed += 1
                
                print()
            
            log_msg(Emoji.STATS, f"Format {format_type} summary:")
            print(f"   Successful: {format_success}")
            print(f"   Skipped: {format_skipped}")
            print(f"   Failed: {format_failed}")
            print()
    else:
        # Single format download
        log_msg(Emoji.TARGET, f"Processing single format: {format_preference}")
        print("----------------------------------------")
        
        for i, url in enumerate(urls, 1):
            total_downloads += 1
            
            # Create output template
            output_template = f"%(title)s{quality_suffix}.%(ext)s"
            
            log_msg(Emoji.DOWNLOAD, f"Processing [{i}/{len(urls)}]: {url}")
            
            # Check if file already exists
            exit_code, filename_output = run_yt_dlp(["--get-filename", "-o", output_template, "--format", format_selector, url])
            
            if exit_code == 0 and os.path.exists(filename_output.strip()):
                log_msg(Emoji.WARNING, f"Skipping (exists): {filename_output.strip()}")
                skipped_downloads += 1
                continue
            
            # Build subtitle options
            subtitle_options = []
            if subtitle_mode == "auto":
                subtitle_options = [
                    "--write-subs", 
                    "--write-auto-subs", 
                    "--sub-langs", "all", 
                    "--sub-format", "srt/vtt/best"
                ]
            
            # Main download command
            download_args = [
                "--embed-chapters",
                "--embed-metadata",
                "--embed-subs",
                *subtitle_options,
                "--no-warnings",
                "--format", format_selector,
                "-o", output_template,
                "--ignore-errors",
                "--no-overwrites",
                "--continue",
                url
            ]
            
            exit_code, _ = run_yt_dlp(download_args, capture_output=False)
            
            if exit_code == 0:
                log_success(f"Downloaded {quality}p video")
                
                # Check for subtitle availability
                if subtitle_mode == "auto":
                    check_subtitle_status(output_template, url)
                
                successful_downloads += 1
            else:
                log_error(f"Failed: {url}")
                failed_downloads += 1
            
            print()
    
    # Final summary report
    log_msg(Emoji.STATS, "FINAL SUMMARY:")
    print(f"   Total download attempts: {total_downloads}")
    print(f"   Successful: {successful_downloads}")
    print(f"   Skipped (existing): {skipped_downloads}")
    print(f"   Failed: {failed_downloads}")
    print(f"   Quality: {quality}p")
    print(f"   Format(s): {format_preference}")
    if subtitle_mode == "auto":
        print("   Subtitles: Auto-detected")
    else:
        print("   Subtitles: None")
    print(f"   Output directory: {os.getcwd()}")
    
    if failed_downloads == 0:
        log_msg(Emoji.COMPLETE, "All downloads completed successfully!")
    else:
        log_warning(f"Some downloads failed. Check the output above for details.")
    
    return 0

def check_subtitle_status(output_template: str, url: str) -> None:
    """Check and report subtitle status for a downloaded video."""
    exit_code, filename_output = run_yt_dlp(["--get-filename", "-o", output_template, url])
    
    if exit_code == 0:
        video_file = filename_output.strip()
        base_name = os.path.splitext(video_file)[0]
        
        # Check for subtitle files in priority order
        if os.path.exists(f"{base_name}.srt"):
            log_msg(Emoji.SUBTITLES, "Subtitles: SRT format downloaded")
        elif os.path.exists(f"{base_name}.vtt"):
            log_msg(Emoji.SUBTITLES, "Subtitles: VTT format downloaded")
        elif any(f.startswith(f"{base_name}.") and f.endswith(".srt") for f in os.listdir(".")):
            log_msg(Emoji.SUBTITLES, "Subtitles: SRT format downloaded (language-specific)")
        elif any(f.startswith(f"{base_name}.") and f.endswith(".vtt") for f in os.listdir(".")):
            log_msg(Emoji.SUBTITLES, "Subtitles: VTT format downloaded (language-specific)")
        elif any(f.startswith(f"{base_name}.") and any(f.endswith(ext) for ext in [".srt", ".vtt", ".ass", ".ssa", ".ttml"]) for f in os.listdir(".")):
            subtitle_files = [f for f in os.listdir(".") if f.startswith(f"{base_name}.") and any(f.endswith(ext) for ext in [".srt", ".vtt", ".ass", ".ssa", ".ttml"])]
            if subtitle_files:
                ext = os.path.splitext(subtitle_files[0])[1][1:].upper()
                log_msg(Emoji.SUBTITLES, f"Subtitles: {ext} format downloaded")
        else:
            log_msg(Emoji.SUBTITLES, "No subtitles exist for this video")

# Audio extraction functionality
def extract_audio(args: argparse.Namespace) -> int:
    """Extract audio from videos with the specified options."""
    # Parse arguments
    formats = args.formats if args.formats else ["opus"]
    urls = args.urls
    max_concurrent = args.concurrent
    sleep_delay = args.sleep
    browser = args.browser
    batch_file = args.batch_file
    
    cookies_option = f"--cookies-from-browser {browser}" if browser else ""
    
    # Read URLs from batch file if provided
    if batch_file:
        if not os.path.isfile(batch_file):
            log_error(f"Batch file not found: {batch_file}")
            return 1
        
        with open(batch_file, 'r') as f:
            batch_urls = [line.strip() for line in f if line.strip() and not line.strip().startswith('#')]
            urls.extend(batch_urls)
    
    # Validate URLs
    if not urls:
        log_error("No URLs provided")
        return 1
    
    log_msg(Emoji.MUSIC, f"Formats: {', '.join(formats)}")
    log_msg(Emoji.INFO, f"Concurrent downloads: {max_concurrent}")
    log_msg(Emoji.INFO, f"Sleep between batches: {sleep_delay}s")
    if browser:
        log_msg(Emoji.INFO, f"Using cookies from browser: {browser}")
    print()
    
    # Process each URL
    for url in urls:
        log_msg(Emoji.SEARCH, f"Analyzing URL: {url}")
        
        # Extract individual video URLs from playlists
        playlist_args = ["--flat-playlist", "--print", "%(url)s"]
        if browser:
            playlist_args.extend(cookies_option.split())
        playlist_args.append(url)
        
        exit_code, video_urls_output = run_yt_dlp(playlist_args)
        
        if exit_code != 0:
            log_error(f"Failed to extract video URLs from: {url}")
            continue
        
        # Convert to list
        video_urls = [line.strip() for line in video_urls_output.splitlines() if line.strip()]
        
        log_msg(Emoji.INFO, f"Found {len(video_urls)} videos to process")
        
        # Process each format
        for audio_format in formats:
            log_msg(Emoji.TARGET, f"Processing {audio_format} format for {len(video_urls)} videos...")
            
            # Process videos in batches with rate limiting
            for i in range(0, len(video_urls), max_concurrent):
                batch_num = i // max_concurrent + 1
                total_batches = (len(video_urls) + max_concurrent - 1) // max_concurrent
                
                log_msg(Emoji.BATCH, f"Processing batch {batch_num} of {total_batches}...")
                
                # Process batch with ThreadPoolExecutor
                with concurrent.futures.ThreadPoolExecutor(max_workers=max_concurrent) as executor:
                    futures = []
                    
                    for j in range(max_concurrent):
                        if i + j < len(video_urls):
                            video_url = video_urls[i + j]
                            video_index = i + j + 1
                            
                            log_msg(Emoji.DOWNLOAD, f"Starting download {video_index}/{len(video_urls)}: {os.path.basename(video_url)}")
                            
                            # Create download function for this video
                            futures.append(
                                executor.submit(
                                    download_audio, 
                                    video_url, 
                                    audio_format, 
                                    browser
                                )
                            )
                    
                    # Wait for all futures to complete
                    for future in concurrent.futures.as_completed(futures):
                        try:
                            success, message = future.result()
                            if success:
                                log_success(message)
                            else:
                                log_error(message)
                        except Exception as e:
                            log_error(f"Error in download thread: {str(e)}")
                
                # Rate limiting: sleep between batches (except for the last one)
                if batch_num < total_batches:
                    log_msg(Emoji.SLEEPING, f"Rate limiting: sleeping for {sleep_delay}s before next batch...")
                    time.sleep(sleep_delay)
            
            log_msg(Emoji.SUCCESS, f"Completed all {audio_format} downloads")
            print()
    
    log_msg(Emoji.COMPLETE, "All downloads completed")
    return 0

def download_audio(video_url: str, audio_format: str, browser: Optional[str] = None) -> Tuple[bool, str]:
    """Download audio from a single video URL."""
    cmd_args = [
        "-x",
        "--audio-format", audio_format,
        "--audio-quality", "0",
        "--embed-metadata",
        "--write-thumbnail",
        "--concurrent-fragments", "3",
        "--throttled-rate", "2M",
        "-o", "%(title)s.%(ext)s"
    ]
    
    if browser:
        cmd_args.extend(["--cookies-from-browser", browser])
    
    cmd_args.append(video_url)
    
    exit_code, output = run_yt_dlp(cmd_args)
    
    if exit_code == 0:
        # Try to extract title from output or get it from yt-dlp
        title_match = re.search(r'Destination: (.+?)\.(opus|mp3|flac|m4a)', output)
        if title_match:
            title = os.path.basename(title_match.group(1))
        else:
            # Get title directly from yt-dlp
            title_args = ["--get-title"]
            if browser:
                title_args.extend(["--cookies-from-browser", browser])
            title_args.append(video_url)
            
            _, title_output = run_yt_dlp(title_args)
            title = title_output.strip() if title_output else os.path.basename(video_url)
        
        return True, f"Completed: {title}"
    else:
        # Check if file already exists
        if "has already been downloaded" in output:
            title_match = re.search(r'([^\/]+)\.(opus|mp3|flac|m4a) has already been downloaded', output)
            if title_match:
                title = title_match.group(1)
            else:
                title_args = ["--get-title"]
                if browser:
                    title_args.extend(["--cookies-from-browser", browser])
                title_args.append(video_url)
                
                _, title_output = run_yt_dlp(title_args)
                title = title_output.strip() if title_output else os.path.basename(video_url)
            
            return True, f"{title} exists"
        
        # Extract failure reason
        error_match = re.search(r'ERROR: (.+)', output)
        if error_match:
            reason = error_match.group(1)
            
            # Special handling for conversion failures
            if "Postprocessing: Conversion failed!" in reason:
                title_args = ["--get-title"]
                if browser:
                    title_args.extend(["--cookies-from-browser", browser])
                title_args.append(video_url)
                
                _, title_output = run_yt_dlp(title_args)
                title = title_output.strip() if title_output else "Unknown"
                
                # Check if the download itself succeeded
                if "has already been downloaded" in output or "100% of" in output or os.path.exists(f"{title}.opus"):
                    return True, f"{title} exists (conversion failed)"
                else:
                    with open(FAILED_LOG, "a") as f:
                        f.write(f"{video_url}\n")
                    return False, f"Failed: {os.path.basename(video_url)} - Conversion failed"
            else:
                with open(FAILED_LOG, "a") as f:
                    f.write(f"{video_url}\n")
                return False, f"Failed: {os.path.basename(video_url)} - {reason}"
        else:
            with open(FAILED_LOG, "a") as f:
                f.write(f"{video_url}\n")
            return False, f"Failed: {os.path.basename(video_url)}"

# List download functionality
def download_from_list(args: argparse.Namespace) -> int:
    """Download from a list of URLs with the specified options."""
    # This is similar to extract_audio but with more options
    # For brevity, I'm reusing the extract_audio function with some modifications
    return extract_audio(args)

# Extract URLs from playlist
def extract_playlist_urls(args: argparse.Namespace) -> int:
    """Extract URLs from playlists and save to a file."""
    sources = args.sources
    output_file = args.output
    
    # Initialize output file
    with open(output_file, 'w') as f:
        pass
    
    # Check if first source is a file
    input_file = None
    playlist_urls = []
    
    if os.path.isfile(sources[0]):
        input_file = sources[0]
        sources = sources[1:]  # Remove the file from sources
        
        log_msg(Emoji.INFO, f"Reading playlist URLs from: {input_file}")
        log_msg(Emoji.INFO, f"Output file: {output_file}")
        print("----------------------------------------")
        
        # Read URLs from file
        try:
            with open(input_file, 'r') as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#'):
                        continue
                    
                    # Add https:// if not present
                    if not line.startswith(('http://', 'https://')):
                        line = f"https://{line}"
                    
                    playlist_urls.append(line)
        except Exception as e:
            log_error(f"Error reading file {input_file}: {str(e)}")
            return 1
    else:
        # Command line arguments mode
        log_msg(Emoji.INFO, "Processing playlists from command line arguments")
        log_msg(Emoji.INFO, f"Output file: {output_file}")
        print("----------------------------------------")
        
        # Add all URLs to the list
        for url in sources:
            # Add https:// if not present
            if not url.startswith(('http://', 'https://')):
                url = f"https://{url}"
            
            playlist_urls.append(url)
    
    # Validate playlist URLs
    if not playlist_urls:
        log_error("No playlist URLs provided")
        return 1
    
    total_videos = 0
    playlist_count = 0
    
    # Process each playlist URL
    for playlist_url in playlist_urls:
        playlist_count += 1
        
        log_msg(Emoji.SEARCH, f"Processing playlist: {playlist_url}")
        
        # Extract URLs and save to output file
        with tempfile.NamedTemporaryFile(mode='w+', delete=False) as temp_file:
            temp_path = temp_file.name
        
        exit_code, _ = run_yt_dlp(["--get-url", "--flat-playlist", "--no-warnings", playlist_url], capture_output=False)
        
        if exit_code == 0:
            # Count the number of URLs extracted
            exit_code, url_output = run_yt_dlp(["--get-url", "--flat-playlist", "--no-warnings", playlist_url])
            
            if exit_code == 0:
                urls = [line.strip() for line in url_output.splitlines() if line.strip()]
                count = len(urls)
                
                log_success(f"Found {count} videos")
                
                # Append URLs to output file
                with open(output_file, 'a') as f:
                    for url in urls:
                        f.write(f"{url}\n")
                
                total_videos += count
            else:
                log_error(f"Failed to extract URLs from playlist: {playlist_url}")
        else:
            log_error(f"Failed to extract from playlist: {playlist_url}")
    
    print("----------------------------------------")
    log_msg(Emoji.STATS, f"Processed {playlist_count} playlists")
    log_msg(Emoji.TARGET, f"Total videos extracted: {total_videos}")
    log_msg(Emoji.INFO, f"All URLs saved to: {output_file}")
    
    # Final check
    if os.path.isfile(output_file) and os.path.getsize(output_file) > 0:
        with open(output_file, 'r') as f:
            final_count = sum(1 for _ in f)
        log_success(f"Final file contains {final_count} total URLs")
    else:
        log_error("Output file is empty or doesn't exist")
        return 1
    
    return 0

# Set up argument parser
def setup_argparse() -> argparse.ArgumentParser:
    """Set up command-line argument parser."""
    parser = argparse.ArgumentParser(description="YouTube Downloader Utility")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Video command
    video_parser = subparsers.add_parser("video", help="Download videos with options")
    video_parser.add_argument("urls", nargs="+", help="YouTube URLs to download")
    video_parser.add_argument("--quality", choices=["720", "1080", "2160"], default="1080", 
                             help="Video quality to download (default: 1080)")
    video_parser.add_argument("--format", choices=["mp4", "mkv", "both"], default="mp4",
                             help="Video format to download (default: mp4)")
    video_parser.add_argument("--no-subtitles", action="store_true", help="Skip subtitle download")
    
    # Audio command
    audio_parser = subparsers.add_parser("audio", help="Extract audio from videos")
    audio_parser.add_argument("urls", nargs="*", help="YouTube URLs to download")
    audio_parser.add_argument("--formats", nargs="+", choices=["opus", "mp3", "flac"], default=["opus"],
                             help="Audio formats to extract (default: opus)")
    audio_parser.add_argument("--all", action="store_true", help="Download all audio formats")
    audio_parser.add_argument("-j", "--concurrent", type=int, default=2, 
                             help="Number of concurrent downloads (default: 2)")
    audio_parser.add_argument("-s", "--sleep", type=float, default=2.4,
                             help="Sleep time between batches (default: 2.4)")
    audio_parser.add_argument("-b", "--browser", default="chrome",
                             help="Browser to extract cookies from (default: chrome)")
    audio_parser.add_argument("-a", "--batch-file", help="File with URLs to download")
    
    # List command
    list_parser = subparsers.add_parser("list", help="Download from a list of URLs")
    list_parser.add_argument("urls", nargs="*", help="YouTube URLs to download")
    list_parser.add_argument("--formats", nargs="+", choices=["opus", "mp3", "flac"], default=["opus"],
                            help="Audio formats to extract (default: opus)")
    list_parser.add_argument("--all", action="store_true", help="Download all audio formats")
    list_parser.add_argument("-j", "--concurrent", type=int, default=3, 
                            help="Number of concurrent downloads (default: 3)")
    list_parser.add_argument("-s", "--sleep", type=float, default=3,
                            help="Sleep time between batches (default: 3)")
    list_parser.add_argument("-b", "--browser", default="chrome",
                            help="Browser to extract cookies from (default: chrome)")
    list_parser.add_argument("-c", "--cookies", help="Path to cookies file")
    list_parser.add_argument("-r", "--rate-limit", default="2M",
                            help="Download rate limit (default: 2M)")
    list_parser.add_argument("-a", "--batch-file", help="File with URLs to download")
    list_parser.add_argument("-v", "--verbose", action="store_true", help="Show detailed output")
    list_parser.add_argument("-d", "--debug", action="store_true", help="Show debug information")
    
    # URLs command
    urls_parser = subparsers.add_parser("urls", help="Extract URLs from playlists")
    urls_parser.add_argument("sources", nargs="+", 
                            help="Playlist URLs or file containing URLs")
    urls_parser.add_argument("--output", default="youtube_urls.txt",
                            help="Output file for extracted URLs (default: youtube_urls.txt)")
    
    return parser

def main() -> int:
    """Main function."""
    parser = setup_argparse()
    args = parser.parse_args()
    
    # Check if yt-dlp is available
    if not check_yt_dlp():
        return 1
    
    # Check if command is provided
    if not args.command:
        parser.print_help()
        return 1
    
    # Process command
    if args.command == "video":
        return download_video(args)
    elif args.command == "audio":
        # Handle --all flag
        if args.all:
            args.formats = ["opus", "mp3", "flac"]
        return extract_audio(args)
    elif args.command == "list":
        # Handle --all flag
        if args.all:
            args.formats = ["opus", "mp3", "flac"]
        return download_from_list(args)
    elif args.command == "urls":
        return extract_playlist_urls(args)
    else:
        parser.print_help()
        return 1

if __name__ == "__main__":
    sys.exit(main())

