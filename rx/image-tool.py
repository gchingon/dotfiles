#!/usr/bin/env python3
# ~/.config/rx/image-tool.py
# Hardlinked to ~/.local/bin/imgtool
# Description: Hybrid image processing utility using Pillow + ImageMagick

import sys
import os
import argparse
import glob
import subprocess
import tempfile
import shutil
from pathlib import Path
from typing import List, Dict, Any, Optional, Tuple, Union
import concurrent.futures
import time
import re

# Try to import Pillow
try:
    from PIL import Image, ImageOps, ImageEnhance, ImageFilter, ExifTags
    HAVE_PILLOW = True
except ImportError:
    HAVE_PILLOW = False

# ANSI color codes
class Colors:
    RESET = "\033[0m"
    BOLD = "\033[1m"
    RED = "\033[91m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    BLUE = "\033[94m"
    MAGENTA = "\033[95m"
    CYAN = "\033[96m"

# Emoji indicators
class Emoji:
    INFO = "ℹ️"
    SUCCESS = "✅"
    ERROR = "❌"
    WARNING = "⚠️"
    IMAGE = "🖼️"
    RESIZE = "↔️"
    CONVERT = "🔄"
    OPTIMIZE = "🔧"
    CROP = "✂️"
    ROTATE = "🔄"
    FILTER = "🎨"
    BATCH = "📦"
    WATERMARK = "💧"
    METADATA = "📋"
    TEXT = "📝"
    THUMBNAIL = "🖼️"

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

# Check dependencies
def check_pillow() -> bool:
    """Check if Pillow is installed and available."""
    if not HAVE_PILLOW:
        log_error("Pillow is not installed. Please install it first.")
        print("  pip install Pillow")
        return False
    return True

def check_imagemagick() -> bool:
    """Check if ImageMagick is available."""
    try:
        result = subprocess.run(['magick', '--version'], 
                              capture_output=True, text=True, timeout=5)
        return result.returncode == 0
    except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.SubprocessError):
        try:
            # Try alternative command names
            result = subprocess.run(['convert', '-version'], 
                                  capture_output=True, text=True, timeout=5)
            return result.returncode == 0
        except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.SubprocessError):
            return False

def get_magick_command() -> str:
    """Get the appropriate ImageMagick command."""
    if check_imagemagick():
        # Try 'magick' first (ImageMagick 7+)
        try:
            subprocess.run(['magick', '--version'], 
                          capture_output=True, timeout=2)
            return 'magick'
        except:
            pass
    
    # Fall back to 'convert' (ImageMagick 6)
    try:
        subprocess.run(['convert', '-version'], 
                      capture_output=True, timeout=2)
        return 'convert'
    except:
        return None

# ImageMagick-based functions
def create_text_image_magick(text: str, output_path: str, font: str = "Arial-Black", 
                           size: int = 48, fill: str = "black", stroke: Optional[str] = None,
                           stroke_width: int = 2, background: str = "transparent",
                           gravity: str = "center", density: int = 150,
                           interline_spacing: int = -15) -> bool:
    """Create an image from text using ImageMagick."""
    magick_cmd = get_magick_command()
    if not magick_cmd:
        log_error("ImageMagick is not available. Please install ImageMagick.")
        return False
    
    try:
        # Build ImageMagick command
        cmd = [
            magick_cmd,
            '-background', background,
            '-density', str(density),
            '-pointsize', str(size),
            '-font', font,
            '-interline-spacing', str(interline_spacing),
            '-fill', fill,
            '-gravity', gravity
        ]
        
        # Add stroke if specified
        if stroke:
            cmd.extend(['-stroke', stroke, '-strokewidth', str(stroke_width)])
        
        # Add text and output
        cmd.extend([f'label:{text}', output_path])
        
        # Execute command
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            log_success(f"Created text image: {output_path}")
            return True
        else:
            log_error(f"ImageMagick error: {result.stderr}")
            return False
            
    except Exception as e:
        log_error(f"Failed to create text image: {str(e)}")
        return False

def create_youtube_thumbnail(text: str, output_path: str, template_path: Optional[str] = None,
                           font: str = "Arial-Black", size: int = 27, fill: str = "gold",
                           stroke: str = "magenta", stroke_width: int = 2,
                           rotation: float = -12, position: str = "+600+20") -> bool:
    """Create a YouTube thumbnail using ImageMagick."""
    magick_cmd = get_magick_command()
    if not magick_cmd:
        log_error("ImageMagick is not available. Please install ImageMagick.")
        return False
    
    # Use default template if none provided
    if not template_path:
        # You can set a default template path here
        template_path = os.path.expandvars("${SCS}/images/YT-thumbnail-template.png")
        if not os.path.exists(template_path):
            log_warning("No template provided and default template not found")
            template_path = None
    
    try:
        # Create temporary file for text image
        with tempfile.NamedTemporaryFile(suffix='.png', delete=False) as temp_file:
            temp_text_path = temp_file.name
        
        try:
            # Create text image
            text_cmd = [
                magick_cmd,
                '-background', 'transparent',
                '-density', '250',
                '-pointsize', str(size),
                '-font', font,
                '-interline-spacing', '-35',
                '-fill', fill,
                '-stroke', stroke,
                '-strokewidth', str(stroke_width),
                '-gravity', 'center',
                f'label:{text}',
                '-rotate', str(rotation),
                temp_text_path
            ]
            
            result = subprocess.run(text_cmd, capture_output=True, text=True, timeout=30)
            if result.returncode != 0:
                log_error(f"Failed to create text overlay: {result.stderr}")
                return False
            
            if template_path and os.path.exists(template_path):
                # Composite text onto template
                composite_cmd = [
                    magick_cmd, 'composite',
                    '-geometry', position,
                    temp_text_path,
                    template_path,
                    output_path
                ]
            else:
                # Just save the text image if no template
                log_warning("No template available, saving text image only")
                shutil.copy(temp_text_path, output_path)
                log_success(f"Created thumbnail: {output_path}")
                return True
            
            result = subprocess.run(composite_cmd, capture_output=True, text=True, timeout=30)
            if result.returncode == 0:
                log_success(f"Created YouTube thumbnail: {output_path}")
                return True
            else:
                log_error(f"Failed to composite thumbnail: {result.stderr}")
                return False
                
        finally:
            # Clean up temp file
            if os.path.exists(temp_text_path):
                os.unlink(temp_text_path)
                
    except Exception as e:
        log_error(f"Failed to create YouTube thumbnail: {str(e)}")
        return False

def resize_with_magick(input_path: str, output_path: str, resize_spec: str) -> bool:
    """Resize image using ImageMagick (for percentage or advanced options)."""
    magick_cmd = get_magick_command()
    if not magick_cmd:
        log_error("ImageMagick is not available.")
        return False
    
    try:
        cmd = [magick_cmd, input_path, '-resize', resize_spec, output_path]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            log_success(f"Resized with ImageMagick: {input_path} → {output_path}")
            return True
        else:
            log_error(f"ImageMagick resize error: {result.stderr}")
            return False
            
    except Exception as e:
        log_error(f"Failed to resize with ImageMagick: {str(e)}")
        return False

def shave_edges_magick(input_path: str, output_path: str, geometry: str) -> bool:
    """Shave edges using ImageMagick."""
    magick_cmd = get_magick_command()
    if not magick_cmd:
        log_error("ImageMagick is not available.")
        return False
    
    try:
        cmd = [magick_cmd, input_path, '-shave', geometry, output_path]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            log_success(f"Shaved edges: {input_path} → {output_path}")
            return True
        else:
            log_error(f"ImageMagick shave error: {result.stderr}")
            return False
            
    except Exception as e:
        log_error(f"Failed to shave edges: {str(e)}")
        return False

# Pillow-based functions (keeping your existing ones)
def resize_image(input_path: str, output_path: str, width: Optional[int] = None, 
                 height: Optional[int] = None, scale: Optional[float] = None,
                 keep_aspect: bool = True, quality: int = 90) -> bool:
    """Resize an image to the specified dimensions using Pillow."""
    try:
        with Image.open(input_path) as img:
            original_width, original_height = img.size
            
            if scale is not None:
                # Scale by percentage
                width = int(original_width * scale)
                height = int(original_height * scale)
            elif width is not None and height is not None:
                # Both dimensions specified
                if keep_aspect:
                    # Calculate aspect ratio
                    aspect = original_width / original_height
                    if width / height > aspect:
                        width = int(height * aspect)
                    else:
                        height = int(width / aspect)
            elif width is not None:
                # Only width specified, calculate height to maintain aspect ratio
                height = int(original_height * (width / original_width))
            elif height is not None:
                # Only height specified, calculate width to maintain aspect ratio
                width = int(original_width * (height / original_height))
            else:
                # No dimensions specified, use original
                width, height = original_width, original_height
            
            # Resize the image
            resized_img = img.resize((width, height), Image.LANCZOS)
            
            # Save the resized image
            resized_img.save(output_path, quality=quality, optimize=True)
            
            log_success(f"Resized image: {input_path} → {output_path} ({width}x{height})")
            return True
    except Exception as e:
        log_error(f"Failed to resize {input_path}: {str(e)}")
        return False

# [Keep all your existing Pillow functions: convert_image, optimize_image, crop_image, 
# rotate_image, apply_filter, add_watermark, extract_metadata, batch_process]

def convert_image(input_path: str, output_path: str, format: str, quality: int = 90) -> bool:
    """Convert an image to a different format."""
    try:
        with Image.open(input_path) as img:
            # Convert to RGB if saving as JPEG (removes alpha channel)
            if format.lower() in ['jpg', 'jpeg'] and img.mode == 'RGBA':
                img = img.convert('RGB')
            
            # Save with the new format
            img.save(output_path, format=format.upper(), quality=quality, optimize=True)
            
            log_success(f"Converted image: {input_path} → {output_path}")
            return True
    except Exception as e:
        log_error(f"Failed to convert {input_path}: {str(e)}")
        return False

# Command implementations
def cmd_text(args: argparse.Namespace) -> int:
    """Implement the text command using ImageMagick."""
    if not check_imagemagick():
        log_error("ImageMagick is required for text operations")
        return 1
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    
    if create_text_image_magick(
        text=args.text,
        output_path=args.output,
        font=args.font,
        size=args.size,
        fill=args.fill,
        stroke=args.stroke,
        stroke_width=args.stroke_width,
        background=args.background,
        gravity=args.gravity,
        density=args.density,
        interline_spacing=args.interline_spacing
    ):
        return 0
    else:
        return 1

def cmd_yt_thumb(args: argparse.Namespace) -> int:
    """Implement the YouTube thumbnail command using ImageMagick."""
    if not check_imagemagick():
        log_error("ImageMagick is required for YouTube thumbnail creation")
        return 1
    
    # Create output directory if it doesn't exist
    output_dir = os.path.dirname(os.path.abspath(args.output))
    if output_dir:
        os.makedirs(output_dir, exist_ok=True)
    
    if create_youtube_thumbnail(
        text=args.text,
        output_path=args.output,
        template_path=args.template,
        font=args.font,
        size=args.size,
        fill=args.fill,
        stroke=args.stroke,
        stroke_width=args.stroke_width,
        rotation=args.rotation,
        position=args.position
    ):
        return 0
    else:
        return 1

def cmd_resize_percent(args: argparse.Namespace) -> int:
    """Implement resize by percentage using ImageMagick."""
    if not check_imagemagick():
        log_error("ImageMagick is required for percentage resize")
        return 1
    
    if not os.path.isfile(args.input):
        log_error(f"Input file not found: {args.input}")
        return 1
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    
    resize_spec = f"{args.percent}%"
    if resize_with_magick(args.input, args.output, resize_spec):
        return 0
    else:
        return 1

def cmd_shave(args: argparse.Namespace) -> int:
    """Implement the shave command using ImageMagick."""
    if not check_imagemagick():
        log_error("ImageMagick is required for shave operation")
        return 1
    
    if not os.path.isfile(args.input):
        log_error(f"Input file not found: {args.input}")
        return 1
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    
    if shave_edges_magick(args.input, args.output, args.geometry):
        return 0
    else:
        return 1

# [Keep all your existing cmd_ functions for Pillow operations]
def cmd_resize(args: argparse.Namespace) -> int:
    """Implement the resize command."""
    if not check_pillow():
        return 1
    
    if not os.path.isfile(args.input):
        log_error(f"Input file not found: {args.input}")
        return 1
    
    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    
    if resize_image(args.input, args.output, args.width, args.height, args.scale, 
                   not args.ignore_aspect, args.quality):
        return 0
    else:
        return 1

# Set up argument parser
def setup_argparse() -> argparse.ArgumentParser:
    """Set up command-line argument parser."""
    parser = argparse.ArgumentParser(description="Hybrid image processing utility (Pillow + ImageMagick)")
    subparsers = parser.add_subparsers(dest="command", help="Command to execute")
    
    # Text command (ImageMagick)
    text_parser = subparsers.add_parser("text", help="Create image from text (uses ImageMagick)")
    text_parser.add_argument("text", help="Text to render")
    text_parser.add_argument("output", help="Output image file")
    text_parser.add_argument("--font", default="Arial-Black", help="Font name (default: Arial-Black)")
    text_parser.add_argument("--size", type=int, default=48, help="Font size (default: 48)")
    text_parser.add_argument("--fill", default="black", help="Text fill color (default: black)")
    text_parser.add_argument("--stroke", help="Text stroke color (optional)")
    text_parser.add_argument("--stroke-width", type=int, default=2, help="Stroke width (default: 2)")
    text_parser.add_argument("--background", default="transparent", help="Background color (default: transparent)")
    text_parser.add_argument("--gravity", default="center", help="Text gravity (default: center)")
    text_parser.add_argument("--density", type=int, default=150, help="Image density (default: 150)")
    text_parser.add_argument("--interline-spacing", type=int, default=-15, help="Line spacing (default: -15)")
    
    # YouTube thumbnail command (ImageMagick)
    yt_parser = subparsers.add_parser("yt-thumb", help="Create YouTube thumbnail (uses ImageMagick)")
    yt_parser.add_argument("text", help="Thumbnail text")
    yt_parser.add_argument("output", help="Output thumbnail file")
    yt_parser.add_argument("--template", help="Template image path")
    yt_parser.add_argument("--font", default="Arial-Black", help="Font name (default: Arial-Black)")
    yt_parser.add_argument("--size", type=int, default=27, help="Font size (default: 27)")
    yt_parser.add_argument("--fill", default="gold", help="Text fill color (default: gold)")
    yt_parser.add_argument("--stroke", default="magenta", help="Text stroke color (default: magenta)")
    yt_parser.add_argument("--stroke-width", type=int, default=2, help="Stroke width (default: 2)")
    yt_parser.add_argument("--rotation", type=float, default=-12, help="Text rotation angle (default: -12)")
    yt_parser.add_argument("--position", default="+600+20", help="Text position on template (default: +600+20)")
    
    # Resize by percentage (ImageMagick)
    resize_pct_parser = subparsers.add_parser("resize-percent", help="Resize by percentage (uses ImageMagick)")
    resize_pct_parser.add_argument("percent", type=int, help="Resize percentage")
    resize_pct_parser.add_argument("input", help="Input image file")
    resize_pct_parser.add_argument("output", help="Output image file")
    
    # Shave edges (ImageMagick)
    shave_parser = subparsers.add_parser("shave", help="Shave image edges (uses ImageMagick)")
    shave_parser.add_argument("geometry", help="Shave geometry (e.g., '10x10')")
    shave_parser.add_argument("input", help="Input image file")
    shave_parser.add_argument("output", help="Output image file")
    
    # Regular resize command (Pillow)
    resize_parser = subparsers.add_parser("resize", help="Resize image with precise control (uses Pillow)")
    resize_parser.add_argument("input", help="Input image file")
    resize_parser.add_argument("output", help="Output image file")
    resize_parser.add_argument("-w", "--width", type=int, help="Target width in pixels")
    resize_parser.add_argument("-h", "--height", type=int, help="Target height in pixels")
    resize_parser.add_argument("-s", "--scale", type=float, help="Scale factor (e.g., 0.5 for half size)")
    resize_parser.add_argument("--ignore-aspect", action="store_true",
                              help="Ignore aspect ratio when both width and height are specified")
    resize_parser.add_argument("-q", "--quality", type=int, default=90,
                              help="Output image quality (1-100, default: 90)")
    
    # Convert command (Pillow)
    convert_parser = subparsers.add_parser("convert", help="Convert image format (uses Pillow)")
    convert_parser.add_argument("input", help="Input image file")
    convert_parser.add_argument("output", help="Output image file")
    convert_parser.add_argument("-f", "--format", required=True,
                               choices=["jpg", "jpeg", "png", "gif", "bmp", "tiff", "webp"],
                               help="Target format")
    convert_parser.add_argument("-q", "--quality", type=int, default=90,
                              help="Output image quality (1-100, default: 90)")
    
    # Add other Pillow commands as needed...
    
    return parser

def cmd_convert(args: argparse.Namespace) -> int:
    """Convert image format using Pillow."""
    success = convert_image(args.input, args.output, args.format, args.quality)
    return 0 if success else 1


def main() -> int:
    """Main function."""
    parser = setup_argparse()
    args = parser.parse_args()
    
    # Check if command is provided
    if not args.command:
        parser.print_help()
        return 1
    
    # Route to appropriate handler
    if args.command == "text":
        return cmd_text(args)
    elif args.command == "yt-thumb":
        return cmd_yt_thumb(args)
    elif args.command == "resize-percent":
        return cmd_resize_percent(args)
    elif args.command == "shave":
        return cmd_shave(args)
    elif args.command == "resize":
        return cmd_resize(args)
    elif args.command == "convert":
        return cmd_convert(args)
    # Add other command handlers...
    else:
        parser.print_help()
        return 1

if __name__ == "__main__":
    sys.exit(main())
