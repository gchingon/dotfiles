#!/usr/bin/env python3
# ln ~/.config/rx/trans-pull.py ~/.local/bin/tsp
"""
tsp - Transcript Processing Tool
A unified tool for downloading and converting video transcripts

Usage:
    tsp srt URL                    # Download transcript as SRT only
    tsp stm URL                    # Download and convert to markdown
    tsp vtm URL                    # Download and convert to markdown (prefer VTT)
    tsp stm filename.srt           # Convert SRT to markdown
    tsp stm 'pattern*.srt'         # Convert SRT files matching glob pattern
    tsp vtm filename.vtt           # Convert VTT to markdown
    tsp -h, --help                 # Show help

Additional features:
    tsp batch URL                  # Download both SRT and VTT if available
    tsp clean directory/           # Convert all SRT/VTT files in directory
    tsp json URL                   # Download transcript as JSON with metadata

Flags:
    -k, --keep-original            # Keep original transcript file after conversion
    -f, --force                    # Force re-conversion of existing files
    -o, --output DIR               # Specify output directory
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Optional, Tuple, List


class TranscriptProcessor:
    def __init__(self):
        self.supported_formats = ['srt', 'vtt', 'json']
        
    def slugify(self, text: str) -> str:
        """Convert text to a URL-safe slug"""
        text = text.lower()
        text = re.sub(r'[^\w\s-]', '', text)
        text = re.sub(r'[-\s]+', '-', text)
        return text.strip('-')
    
    def check_dependencies(self) -> bool:
        """Check if yt-dlp is installed"""
        try:
            subprocess.run(['yt-dlp', '--version'], 
                           capture_output=True, check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            print("ERROR: yt-dlp is not installed. Please install it first.")
            print("Install with: pip install yt-dlp")
            return False
    
    def get_video_info(self, url: str) -> Optional[Tuple[str, str]]:
        """Get video title and ID from URL"""
        try:
            result = subprocess.run(
                ['yt-dlp', '--print', 'title', '--print', 'id', url],
                capture_output=True, text=True, check=True
            )
            lines = result.stdout.strip().split('\n')
            if len(lines) >= 2:
                title = self.slugify(lines[0])
                video_id = lines[1]
                return title, video_id
            return None
        except subprocess.CalledProcessError:
            print(f"ERROR: Failed to get video info from {url}")
            return None
    
    def download_transcript(self, url: str, output_dir: str = ".", 
                            format_pref: str = "srt") -> Optional[str]:
        """Download transcript from URL and return subtitle filepath"""
        if not self.check_dependencies():
            return None
            
        video_info = self.get_video_info(url)
        if not video_info:
            return None
            
        title, video_id = video_info
        base_filename = f"{title}-[{video_id}]"
        
        formats_to_try = [format_pref]
        if format_pref == "srt":
            formats_to_try.append("vtt")
        elif format_pref == "vtt":
            formats_to_try.append("srt")
            
        for fmt in formats_to_try:
            try:
                output_template = os.path.join(output_dir, f"{base_filename}.%(ext)s")
                
                cmd = [
                    'yt-dlp',
                    '--write-auto-sub',
                    '--write-subs',
                    '--skip-download',
                    '--sub-format', fmt,
                    '--sub-langs', 'en.*',
                    '-o', output_template,
                    url
                ]
                
                subprocess.run(cmd, capture_output=True, text=True, check=True)
                
                # Glob by title only to find subs, ignore video_id / language suffixes
                candidates = list(Path(output_dir).glob(f"{title}*.{fmt}"))
                if not candidates:
                    continue

                # Prefer non "-orig" if both exist
                preferred = [p for p in candidates if "-orig" not in p.stem]
                chosen = preferred[0] if preferred else candidates[0]

                downloaded_file = str(chosen)
                print(f"Downloaded transcript: {downloaded_file}")
                return downloaded_file
                    
            except subprocess.CalledProcessError:
                continue
                
        print(f"ERROR: No transcript available for {url}")
        return None
    
    def clean_srt_content(self, content: str) -> str:
        """Clean SRT content for markdown conversion"""
        lines = content.split('\n')
        cleaned_lines = []
        
        timecode_pattern = re.compile(
            r'^\d{2}:\d{2}:\d{2}[,.]\d{3}\s*-->\s*\d{2}:\d{2}:\d{2}[,.]\d{3}'
        )
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            if line.isdigit():
                continue
            if timecode_pattern.match(line):
                continue
            if re.match(r'^\d{2}:\d{2}:\d{2}[,.]\d{3}', line):
                continue
            cleaned_lines.append(line)
        
        seen = set()
        deduped_lines = []
        for line in cleaned_lines:
            if line not in seen:
                seen.add(line)
                deduped_lines.append(line)
                
        return '\n'.join(deduped_lines)
    
    def clean_vtt_content(self, content: str) -> str:
        """Clean VTT content for markdown conversion"""
        lines = content.split('\n')
        cleaned_lines = []
        
        timecode_pattern = re.compile(
            r'^\d{2}:\d{2}:\d{2}[,.]\d{3}\s*-->\s*\d{2}:\d{2}:\d{2}[,.]\d{3}'
        )
        
        for line in lines:
            line = line.strip()
            if not line:
                continue
            if line == 'WEBVTT' or line.startswith('WEBVTT '):
                continue
            if line.startswith('NOTE'):
                continue
            if line.isdigit():
                continue
            if timecode_pattern.match(line):
                continue
            if re.match(r'^\d{2}:\d{2}:\d{2}[,.]\d{3}', line):
                continue
            line = re.sub(r'<[^>]+>', '', line)
            if not line.strip():
                continue
            cleaned_lines.append(line)
        
        seen = set()
        deduped_lines = []
        for line in cleaned_lines:
            if line not in seen:
                seen.add(line)
                deduped_lines.append(line)
                
        return '\n'.join(deduped_lines)
    
    def convert_to_markdown(self, input_file: str, keep_original: bool = True, skip_existing: bool = True) -> Optional[str]:
        """Convert SRT or VTT file to markdown"""
        if not os.path.exists(input_file):
            print(f"ERROR: File {input_file} not found")
            return None

        file_path = Path(input_file)
        extension = file_path.suffix.lower()
        base_name = file_path.stem
        output_file = file_path.parent / f"{base_name}.md"

        # Skip if output file already exists and skip_existing is True
        if skip_existing and output_file.exists():
            print(f"SKIPPED: {output_file} already exists (use --force to re-convert)")
            return str(output_file)
        
        try:
            with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
        except Exception as e:
            print(f"ERROR: Failed to read {input_file}: {e}")
            return None
            
        if extension == '.srt':
            cleaned_content = self.clean_srt_content(content)
        elif extension == '.vtt':
            cleaned_content = self.clean_vtt_content(content)
        else:
            print(f"ERROR: Unsupported file format: {extension}")
            return None
            
        try:
            with open(output_file, 'w', encoding='utf-8') as f:
                f.write(cleaned_content)
            
            original_lines = len([line for line in content.split('\n') if line.strip()])
            final_lines = len([line for line in cleaned_content.split('\n') if line.strip()])
            
            print(f"SUCCESS: Created {output_file} (reduced from {original_lines} to {final_lines} lines)")
            
            if not keep_original:
                os.remove(input_file)
                print(f"Deleted original file: {input_file}")
                
            return str(output_file)
            
        except Exception as e:
            print(f"ERROR: Failed to write {output_file}: {e}")
            return None
    
    def download_json_transcript(self, url: str, output_dir: str = ".") -> Optional[str]:
        """Download transcript with metadata as JSON"""
        if not self.check_dependencies():
            return None
            
        video_info = self.get_video_info(url)
        if not video_info:
            return None
            
        title, video_id = video_info
        output_file = os.path.join(output_dir, f"{title}-[{video_id}].json")
        
        try:
            metadata_cmd = ['yt-dlp', '--dump-json', '--no-download', url]
            metadata_result = subprocess.run(
                metadata_cmd, capture_output=True, text=True, check=True
            )
            metadata = json.loads(metadata_result.stdout)
            
            transcript_file = self.download_transcript(url, output_dir, "srt")
            if not transcript_file:
                transcript_file = self.download_transcript(url, output_dir, "vtt")
            
            transcript_content = ""
            if transcript_file:
                with open(transcript_file, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    if transcript_file.endswith('.srt'):
                        transcript_content = self.clean_srt_content(content)
                    else:
                        transcript_content = self.clean_vtt_content(content)
            
            output_data = {
                'title': metadata.get('title', ''),
                'video_id': video_id,
                'url': url,
                'duration': metadata.get('duration', 0),
                'upload_date': metadata.get('upload_date', ''),
                'uploader': metadata.get('uploader', ''),
                'description': metadata.get('description', ''),
                'transcript': transcript_content
            }
            
            with open(output_file, 'w', encoding='utf-8') as f:
                json.dump(output_data, f, indent=2, ensure_ascii=False)
                
            print(f"SUCCESS: Created JSON transcript: {output_file}")
            
            if transcript_file and os.path.exists(transcript_file):
                os.remove(transcript_file)
                
            return output_file
            
        except Exception as e:
            print(f"ERROR: Failed to create JSON transcript: {e}")
            return None
    
    def batch_download(self, url: str, output_dir: str = ".") -> List[str]:
        """Download all available transcript formats"""
        downloaded_files = []
        for fmt in ['srt', 'vtt']:
            file_path = self.download_transcript(url, output_dir, fmt)
            if file_path:
                downloaded_files.append(file_path)
        return downloaded_files
    
    def clean_directory(self, directory: str, skip_existing: bool = True) -> List[str]:
        """Convert all SRT and VTT files in a directory to markdown"""
        converted_files = []
        dir_path = Path(directory)

        if not dir_path.exists():
            print(f"ERROR: Directory {directory} not found")
            return converted_files

        for file_path in dir_path.glob('*'):
            if file_path.suffix.lower() in ['.srt', '.vtt']:
                result = self.convert_to_markdown(str(file_path), keep_original=True, skip_existing=skip_existing)
                if result:
                    converted_files.append(result)

        print(f"Converted {len(converted_files)} files in {directory}")
        return converted_files


def main():
    parser = argparse.ArgumentParser(
        description='Transcript Processing Tool - Download and convert video transcripts',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  tsp srt https://youtube.com/watch?v=xyz     # Download SRT transcript
  tsp stm https://youtube.com/watch?v=xyz     # Download and convert to markdown
  tsp stm transcript.srt                       # Convert SRT to markdown
  tsp stm 'HTLAL*.srt' -k                      # Convert matching files, skip existing
  tsp stm 'HTLAL*.srt' -k -f                   # Convert matching files, force re-convert
  tsp vtm transcript.vtt                       # Convert VTT to markdown
  tsp batch https://youtube.com/watch?v=xyz    # Download all available formats
  tsp clean ~/Downloads/                       # Convert all transcripts in directory
  tsp clean ~/Downloads/ -f                    # Re-convert all transcripts (force)
        """
    )
    
    parser.add_argument('action', help='Action to perform: srt, stm, vtm, batch, clean, json')
    parser.add_argument('target', help='URL, filename, directory, or glob pattern to process')
    parser.add_argument('-o', '--output', default='.', help='Output directory (default: current directory)')
    parser.add_argument('-k', '--keep-original', action='store_true', help='Keep original transcript file after conversion')
    parser.add_argument('-f', '--force', action='store_true', help='Force re-conversion of existing files')
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
        
    args = parser.parse_args()
    
    processor = TranscriptProcessor()
    
    # Handle URL-based actions
    if args.target.startswith(('http://', 'https://', 'www.')):
        if args.action == 'srt':
            processor.download_transcript(args.target, args.output, 'srt')
        elif args.action == 'stm':
            transcript_file = processor.download_transcript(args.target, args.output, 'srt')
            if transcript_file:
                processor.convert_to_markdown(transcript_file, keep_original=args.keep_original)
        elif args.action == 'vtm':
            transcript_file = processor.download_transcript(args.target, args.output, 'vtt')
            if transcript_file:
                processor.convert_to_markdown(transcript_file, keep_original=args.keep_original)
        elif args.action == 'batch':
            processor.batch_download(args.target, args.output)
        elif args.action == 'json':
            processor.download_json_transcript(args.target, args.output)
        else:
            print(f"ERROR: Invalid action '{args.action}' for URL")
            return
    
    # Handle file-based actions and glob patterns
    elif '*' in args.target or '?' in args.target or '[' in args.target:
        # Glob pattern detected
        if args.action in ['stm', 'vtm']:
            matched_files = list(Path('.').glob(args.target))
            if not matched_files:
                print(f"ERROR: No files matching pattern '{args.target}'")
                return

            converted_count = 0
            skipped_count = 0
            for file_path in sorted(matched_files):
                if file_path.suffix.lower() in ['.srt', '.vtt']:
                    result = processor.convert_to_markdown(
                        str(file_path),
                        keep_original=args.keep_original,
                        skip_existing=not args.force
                    )
                    if result:
                        converted_count += 1
                    else:
                        skipped_count += 1

            print(f"Processed {converted_count} files (skipped {skipped_count})")
        else:
            print(f"ERROR: Action '{args.action}' not compatible with glob patterns")
            return

    # Handle single file
    elif os.path.exists(args.target):
        if args.action in ['stm', 'vtm']:
            processor.convert_to_markdown(
                args.target,
                keep_original=args.keep_original,
                skip_existing=not args.force
            )
        else:
            print(f"ERROR: Action '{args.action}' not compatible with file '{args.target}'")
            return
    
    # Handle directory cleaning
    elif args.action == 'clean':
        processor.clean_directory(args.target, skip_existing=not args.force)
    
    else:
        print(f"ERROR: Target '{args.target}' not found or invalid")


if __name__ == '__main__':
    main()
