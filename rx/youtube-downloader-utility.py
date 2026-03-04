#!/usr/bin/env python3
# ~/.config/rx/youtube-downloader-utility.py
# Hardlinked to ~/.local/bin/ytdl

import sys
import os
import argparse
import subprocess
import time
from pathlib import Path
from typing import List, Tuple

# ANSI colors
class C:
    R = "\033[0m"
    G = "\033[92m"
    Y = "\033[93m"
    RED = "\033[91m"

# Quality mappings
QUALITY_MAP = {
    "4K": "2160",
    "FHD": "1080", 
    "HD": "720",
    "SD": "480"
}

def log(msg: str, color: str = "") -> None:
    """Print colored message"""
    print(f"{color}{msg}{C.R}" if color else msg)

def check_yt_dlp() -> bool:
    """Verify yt-dlp is installed"""
    try:
        subprocess.run(["yt-dlp", "--version"], stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=True)
        return True
    except (subprocess.SubprocessError, FileNotFoundError):
        log("ERROR: yt-dlp not installed", C.RED)
        print("  macOS: brew install yt-dlp")
        print("  Linux: apt install yt-dlp")
        return False

def run_yt_dlp(args: List[str]) -> Tuple[int, str]:
    """Execute yt-dlp command"""
    try:
        result = subprocess.run(["yt-dlp"] + args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        return result.returncode, result.stdout
    except subprocess.SubprocessError as e:
        return 1, str(e)

def download_video(urls: List[str], quality: str = "4K", skip_subs: bool = False) -> int:
    """Download videos sequentially with rate limiting"""
    
    height = QUALITY_MAP.get(quality, "2160")
    quality_suffix = f"_{quality}"
    
    # Format selector - MP4 only, best quality at/below target
    format_selector = f"bv*[height<={height}][ext=mp4]+ba[ext=m4a]/b[height<={height}][ext=mp4]"
    
    log(f"Quality: {quality} ({height}p)", C.G)
    log(f"Subtitles: {'Disabled' if skip_subs else 'EN-US only'}", C.G)
    log(f"Videos to process: {len(urls)}\n", C.G)
    
    successful = []
    failed = []
    skipped = []
    
    for i, url in enumerate(urls, 1):
        log(f"[{i}/{len(urls)}] Processing: {url}", C.Y)
        
        # Output template
        output_template = f"%(title)s{quality_suffix}.%(ext)s"
        
        # Check if file exists
        exit_code, filename = run_yt_dlp(["--get-filename", "-o", output_template, "--format", format_selector, url])
        
        if exit_code == 0 and os.path.exists(filename.strip()):
            log(f"  SKIP: File exists\n", C.Y)
            skipped.append(url)
            continue
        
        # Build download command
        dl_args = [
            "--format", format_selector,
            "-o", output_template,
            "--embed-chapters",
            "--embed-metadata",
            "--embed-thumbnail",  # Embed thumbnail IN video
            "--no-warnings",
            "--no-overwrites",
            "--continue",
        ]
        
        # Add EN-US subtitle options if not skipped
        if not skip_subs:
            dl_args.extend([
                "--write-subs",
                "--sub-langs", "en-US,en",  # EN-US preferred, fallback to EN
                "--embed-subs",
                "--sub-format", "srt/best"
            ])
        
        dl_args.append(url)
        
        # Download
        exit_code, output = run_yt_dlp(dl_args)
        
        if exit_code == 0:
            log(f"  SUCCESS: Downloaded {quality}\n", C.G)
            successful.append(url)
        else:
            # Check for rate limiting or blocking
            if any(x in output.lower() for x in ["rate limit", "too many requests", "429", "forbidden", "403"]):
                log(f"  ERROR: Rate limited or blocked", C.RED)
                log(f"  Last successful download: {successful[-1] if successful else 'None'}\n", C.RED)
                failed.append(url)
                break  # Stop processing on rate limit
            else:
                log(f"  FAILED: {output.splitlines()[-1] if output else 'Unknown error'}\n", C.RED)
                failed.append(url)
        
        # Rate limiting: sleep between downloads (except last one)
        if i < len(urls):
            log(f"  Sleeping 15s to avoid rate limits...\n", C.Y)
            time.sleep(15)
    
    # Summary
    log("=" * 50, C.G)
    log(f"SUMMARY:", C.G)
    log(f"  Successful: {len(successful)}")
    log(f"  Skipped: {len(skipped)}")
    log(f"  Failed: {len(failed)}")
    
    if successful:
        log(f"\nLast successful: {successful[-1]}", C.G)
    
    if failed:
        log(f"\nFailed URLs:", C.RED)
        for url in failed:
            log(f"  {url}", C.RED)
    
    return 0 if not failed else 1

def download_audio(urls: List[str], audio_format: str = "opus") -> int:
    """Extract audio from videos"""
    
    log(f"Format: {audio_format}", C.G)
    log(f"Videos to process: {len(urls)}\n", C.G)
    
    successful = []
    failed = []
    skipped = []
    
    for i, url in enumerate(urls, 1):
        log(f"[{i}/{len(urls)}] Processing: {url}", C.Y)
        
        dl_args = [
            "-x",
            "--audio-format", audio_format,
            "--audio-quality", "0",  # Best quality
            "--embed-metadata",
            "--embed-thumbnail",
            "-o", "%(title)s.%(ext)s",
            "--no-warnings",
            "--no-overwrites",
            url
        ]
        
        exit_code, output = run_yt_dlp(dl_args)
        
        if exit_code == 0 or "has already been downloaded" in output:
            if "has already been downloaded" in output:
                log(f"  SKIP: File exists\n", C.Y)
                skipped.append(url)
            else:
                log(f"  SUCCESS: Extracted audio\n", C.G)
                successful.append(url)
        else:
            if any(x in output.lower() for x in ["rate limit", "too many requests", "429", "forbidden", "403"]):
                log(f"  ERROR: Rate limited or blocked", C.RED)
                log(f"  Last successful: {successful[-1] if successful else 'None'}\n", C.RED)
                failed.append(url)
                break
            else:
                log(f"  FAILED: {output.splitlines()[-1] if output else 'Unknown error'}\n", C.RED)
                failed.append(url)
        
        # Rate limiting
        if i < len(urls):
            log(f"  Sleeping 15s...\n", C.Y)
            time.sleep(15)
    
    # Summary
    log("=" * 50, C.G)
    log(f"SUMMARY:", C.G)
    log(f"  Successful: {len(successful)}")
    log(f"  Skipped: {len(skipped)}")
    log(f"  Failed: {len(failed)}")
    
    if successful:
        log(f"\nLast successful: {successful[-1]}", C.G)
    
    if failed:
        log(f"\nFailed URLs:", C.RED)
        for url in failed:
            log(f"  {url}", C.RED)
    
    return 0 if not failed else 1

def extract_playlist_urls(playlist_url: str) -> List[str]:
    """Extract individual video URLs from playlist in order"""
    exit_code, output = run_yt_dlp(["--flat-playlist", "--print", "%(url)s", playlist_url])
    
    if exit_code != 0:
        log(f"ERROR: Failed to extract playlist URLs", C.RED)
        return []
    
    urls = [line.strip() for line in output.splitlines() if line.strip()]
    log(f"Extracted {len(urls)} videos from playlist", C.G)
    return urls

def main() -> int:
    parser = argparse.ArgumentParser(description="YouTube Downloader")
    subparsers = parser.add_subparsers(dest="command", help="Command")
    
    # Video command
    video_parser = subparsers.add_parser("video", aliases=["v"], help="Download video")
    video_parser.add_argument("urls", nargs="+", help="URLs, playlist URL, or file path")
    video_parser.add_argument("-q", "--quality", choices=["4K", "FHD", "HD", "SD"], default="4K",
                             help="Video quality (default: 4K)")
    video_parser.add_argument("--no-subs", action="store_true", help="Skip subtitles")
    
    # Audio command
    audio_parser = subparsers.add_parser("audio", aliases=["a"], help="Extract audio")
    audio_parser.add_argument("urls", nargs="+", help="URLs, playlist URL, or file path")
    audio_parser.add_argument("-f", "--format", choices=["opus", "mp3", "flac"], default="opus",
                             help="Audio format (default: opus)")
    
    args = parser.parse_args()
    
    if not check_yt_dlp():
        return 1
    
    if not args.command:
        parser.print_help()
        return 1
    
    # Process URLs from file, playlist, or direct URLs
    urls = []
    for source in args.urls:
        if os.path.isfile(source):
            # Read URLs from file
            with open(source, 'r') as f:
                urls.extend([line.strip() for line in f if line.strip() and not line.startswith('#')])
        elif "playlist" in source.lower() or "list=" in source:
            # Extract URLs from playlist
            urls.extend(extract_playlist_urls(source))
        else:
            # Direct URL
            urls.append(source)
    
    if not urls:
        log("ERROR: No valid URLs found", C.RED)
        return 1
    
    # Execute command
    if args.command in ["video", "v"]:
        return download_video(urls, args.quality, args.no_subs)
    elif args.command in ["audio", "a"]:
        return download_audio(urls, args.format)
    
    return 1

if __name__ == "__main__":
    sys.exit(main())