#!/usr/bin/env python3
# ln ~/.config/rx/trans-pull.py ~/.local/bin/tsp
"""
tsp - Transcript Processing Tool
A unified tool for downloading and converting video transcripts

Usage:
    tsp URL srt                    # Download transcript as SRT only
    tsp URL stm                    # Download and convert to markdown 
    tsp URL vtm                    # Download and convert to markdown (prefer VTT)
    tsp stm filename.srt           # Convert SRT to markdown
    tsp vtm filename.vtt           # Convert VTT to markdown
    tsp -h, --help                 # Show help
    
Additional features:
    tsp URL batch                  # Download both SRT and VTT if available
    tsp clean directory/           # Convert all SRT/VTT files in directory
    tsp URL json                   # Download transcript as JSON with metadata
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
            result = subprocess.run([
                'yt-dlp', '--print', 'title', '--print', 'id', url
            ], capture_output=True, text=True, check=True)
            
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
        """Download transcript from URL"""
        if not self.check_dependencies():
            return None
            
        video_info = self.get_video_info(url)
        if not video_info:
            return None
            
        title, video_id = video_info
        base_filename = f"{title}-[{video_id}]"
        
        # Try to download preferred format first
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
                    '--skip-download',
                    '--sub-format', fmt,
                    '-o', output_template,
                    url
                ]
                
                result = subprocess.run(cmd, capture_output=True, text=True, check=True)
                
                # Find the downloaded file
                downloaded_file = os.path.join(output_dir, f"{base_filename}.{fmt}")
                if os.path.exists(downloaded_file):
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
        
        for line in lines:
            line = line.strip()
            # Skip empty lines, numbers, and timecodes
            if (not line or 
                line.isdigit() or 
                '-->' in line or
                re.match(r'^\d+:\d+:\d+', line)):
                continue
            cleaned_lines.append(line)
        
        # Remove duplicates while preserving order
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
        
        for line in lines:
            line = line.strip()
            # Skip WEBVTT header, empty lines, numbers, and timecodes
            if (not line or 
                line == 'WEBVTT' or
                line.startswith('NOTE') or
                line.isdigit() or 
                '-->' in line or
                re.match(r'^\d+:\d+:\d+', line)):
                continue
            
            # Remove HTML tags
            line = re.sub(r'<[^>]+>', '', line)
            if line:
                cleaned_lines.append(line)
        
        # Remove duplicates while preserving order
        seen = set()
        deduped_lines = []
        for line in cleaned_lines:
            if line not in seen:
                seen.add(line)
                deduped_lines.append(line)
                
        return '\n'.join(deduped_lines)
    
    def convert_to_markdown(self, input_file: str, keep_original: bool = True) -> Optional[str]:
        """Convert SRT or VTT file to markdown"""
        if not os.path.exists(input_file):
            print(f"ERROR: File {input_file} not found")
            return None
            
        file_path = Path(input_file)
        extension = file_path.suffix.lower()
        base_name = file_path.stem
        output_file = file_path.parent / f"{base_name}.md"
        
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
            
            # Count lines for reporting
            original_lines = len([line for line in content.split('\n') if line.strip()])
            final_lines = len([line for line in cleaned_content.split('\n') if line.strip()])
            
            print(f"SUCCESS: Created {output_file} (reduced from {original_lines} to {final_lines} lines)")
            
            # Delete original file if requested
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
            # Get video metadata
            metadata_cmd = [
                'yt-dlp', '--dump-json', '--no-download', url
            ]
            metadata_result = subprocess.run(metadata_cmd, capture_output=True, text=True, check=True)
            metadata = json.loads(metadata_result.stdout)
            
            # Try to get transcript
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
            
            # Create JSON output
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
            
            # Clean up transcript file if it was created
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
    
    def clean_directory(self, directory: str) -> List[str]:
        """Convert all SRT and VTT files in a directory to markdown"""
        converted_files = []
        dir_path = Path(directory)
        
        if not dir_path.exists():
            print(f"ERROR: Directory {directory} not found")
            return converted_files
            
        for file_path in dir_path.glob('*'):
            if file_path.suffix.lower() in ['.srt', '.vtt']:
                result = self.convert_to_markdown(str(file_path), keep_original=True)
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
  tsp https://youtube.com/watch?v=xyz srt    # Download SRT transcript
  tsp https://youtube.com/watch?v=xyz stm    # Download and convert to markdown
  tsp stm transcript.srt                     # Convert SRT to markdown  
  tsp vtm transcript.vtt                     # Convert VTT to markdown
  tsp https://youtube.com/watch?v=xyz batch  # Download all available formats
  tsp clean ~/Downloads/                     # Convert all transcripts in directory
        """
    )
    
    parser.add_argument('target', help='URL or filename to process')
    parser.add_argument('action', help='Action to perform: srt, stm, vtm, batch, clean, json')
    parser.add_argument('-o', '--output', default='.', help='Output directory (default: current directory)')
    parser.add_argument('--keep-original', action='store_true', help='Keep original transcript file after conversion')
    
    if len(sys.argv) == 1:
        parser.print_help()
        return
        
    args = parser.parse_args()
    
    processor = TranscriptProcessor()
    
    # Handle URL-based actions
    if args.target.startswith(('http://', 'https://')):
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
    
    # Handle file-based actions
    elif os.path.exists(args.target):
        if args.action == 'stm' and args.target.endswith('.srt'):
            processor.convert_to_markdown(args.target, keep_original=args.keep_original)
        elif args.action == 'vtm' and args.target.endswith('.vtt'):
            processor.convert_to_markdown(args.target, keep_original=args.keep_original)
        elif args.action == 'clean' and os.path.isdir(args.target):
            processor.clean_directory(args.target)
        else:
            print(f"ERROR: Action '{args.action}' not compatible with file '{args.target}'")
            return
    
    # Handle directory cleaning
    elif args.action == 'clean':
        processor.clean_directory(args.target)
    
    else:
        print(f"ERROR: Target '{args.target}' not found or invalid")


if __name__ == '__main__':
    main()
