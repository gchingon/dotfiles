#!/usr/bin/env python3
"""
gen-epi.py - Automated Podcast Episode Generator

Automates the creation of podcast episodes by:
- Auto-detecting next episode number
- Checking rotation schedules (throwback, conspiracy, ethereal)
- Generating episode files from templates
- Creating context logs
- Providing next steps

Author: Gallo (via Claude)
Version: 1.0.0
"""

import argparse
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Tuple

# Try to import colorama for colored output, fallback to plain text
try:
    from colorama import init, Fore, Style
    init(autoreset=True)
    HAS_COLOR = True
except ImportError:
    # Fallback: no colors
    class Fore:
        GREEN = RED = YELLOW = CYAN = MAGENTA = BLUE = ""
    class Style:
        BRIGHT = RESET_ALL = ""
    HAS_COLOR = False

# Project paths
PROJECT_ROOT = Path("/Users/schingon/Documents/notes/projects/podcast")
EPISODES_DIR = PROJECT_ROOT / "publisht-podcast-epis"
TEMPLATES_DIR = PROJECT_ROOT / "templates"
CONTEXT_DIR = PROJECT_ROOT / "context"

# Rotation rules (based on CLAUDE.md)
ROTATION_RULES = {
    5: "throwback",
    7: "conspiracy",
    9: "ethereal"
}

# Episode type configurations
EPISODE_TYPES = {
    "standard": {
        "template": "episode-standard.md",
        "title_format": "{episode_number}-{title}.md",
        "description": "Regular episode with 2-5 segments on core content pillars"
    },
    "prerec": {
        "template": "episode-prerec.md",
        "title_format": "{episode_number}-PREREC-{title}.md",
        "description": "Pre-recorded guest interview (PremiereHybrid format)"
    },
    "throwback": {
        "template": "episode-throwback.md",
        "title_format": "{episode_number}-throwback-{title}.md",
        "description": "80s/90s nostalgia or personal story time"
    },
    "ethereal": {
        "template": "episode-ethereal.md",
        "title_format": "{episode_number}-ethereal-{title}.md",
        "description": "Consciousness, deity, religion topics"
    },
    "conspiracy": {
        "template": "episode-conspiracy.md",
        "title_format": "{episode_number}-conspiracy-{title}.md",
        "description": "Conspiracy theory (Gallo picks: for/against/skeptic)"
    }
}


def print_header(text: str) -> None:
    """Print a styled header."""
    print(f"\n{Fore.CYAN}{Style.BRIGHT}{'='*70}")
    print(f"{text:^70}")
    print(f"{'='*70}{Style.RESET_ALL}\n")


def print_success(text: str) -> None:
    """Print success message."""
    print(f"{Fore.GREEN}✓ {text}{Style.RESET_ALL}")


def print_error(text: str) -> None:
    """Print error message."""
    print(f"{Fore.RED}✗ {text}{Style.RESET_ALL}", file=sys.stderr)


def print_warning(text: str) -> None:
    """Print warning message."""
    print(f"{Fore.YELLOW}⚠ {text}{Style.RESET_ALL}")


def print_info(text: str) -> None:
    """Print info message."""
    print(f"{Fore.CYAN}ℹ {text}{Style.RESET_ALL}")


def get_next_episode_number() -> int:
    """
    Scan publisht-podcast-epis/ for highest episode number and return next.

    Returns:
        Next episode number as integer
    """
    if not EPISODES_DIR.exists():
        print_warning(f"Episodes directory not found: {EPISODES_DIR}")
        return 1

    max_episode = 0
    pattern = re.compile(r'^0*(\d+)-.*\.md$')

    for file in EPISODES_DIR.glob("*.md"):
        match = pattern.match(file.name)
        if match:
            episode_num = int(match.group(1))
            max_episode = max(max_episode, episode_num)

    return max_episode + 1


def check_rotation(episode_num: int) -> Optional[str]:
    """
    Check if episode number matches any rotation schedule.

    Args:
        episode_num: Episode number to check

    Returns:
        Episode type string or None if no rotation match
    """
    for divisor, ep_type in ROTATION_RULES.items():
        if episode_num % divisor == 0:
            return ep_type
    return None


def slugify(text: str) -> str:
    """
    Convert text to URL-friendly slug.

    Args:
        text: Text to slugify

    Returns:
        Slugified text
    """
    # Convert to lowercase
    text = text.lower()
    # Replace spaces and underscores with hyphens
    text = re.sub(r'[\s_]+', '-', text)
    # Remove non-alphanumeric characters except hyphens
    text = re.sub(r'[^a-z0-9-]', '', text)
    # Remove multiple consecutive hyphens
    text = re.sub(r'-+', '-', text)
    # Strip leading/trailing hyphens
    text = text.strip('-')
    return text


def format_episode_number(num: int) -> str:
    """Format episode number with leading zeros (e.g., 0126)."""
    return f"{num:04d}"


def load_template(episode_type: str) -> str:
    """
    Load episode template from templates directory.

    Args:
        episode_type: Type of episode (standard, prerec, etc.)

    Returns:
        Template content as string

    Raises:
        FileNotFoundError: If template doesn't exist
    """
    template_file = TEMPLATES_DIR / EPISODE_TYPES[episode_type]["template"]

    if not template_file.exists():
        raise FileNotFoundError(f"Template not found: {template_file}")

    return template_file.read_text()


def substitute_template(template: str, variables: Dict[str, str]) -> str:
    """
    Substitute template variables with provided values.

    Args:
        template: Template content
        variables: Dictionary of variable names to values

    Returns:
        Processed template
    """
    result = template

    # Replace YAML frontmatter fields
    result = result.replace('title: "{Episode Title}"', f'title: "{variables.get("title", "Episode Title")}"')
    result = result.replace('title: "PREREC - {Guest Name/Topic}"', f'title: "PREREC - {variables.get("title", "Guest Name/Topic")}"')
    result = result.replace('created: YYYY-MM-DD', f'created: {variables.get("date", "YYYY-MM-DD")}')
    result = result.replace('updated: YYYY-MM-DD', f'updated: {variables.get("date", "YYYY-MM-DD")}')
    result = result.replace('episode_number: 0nn', f'episode_number: {variables.get("episode_number", "0nn")}')
    result = result.replace('recording_date: YYYY-MM-DD', f'recording_date: {variables.get("date", "YYYY-MM-DD")}')

    # PREREC specific
    if "guest_name" in variables:
        result = result.replace('guests: ["{Guest Name}"]', f'guests: ["{variables["guest_name"]}"]')
        result = result.replace('**Guest Name**: {Full Name}', f'**Guest Name**: {variables["guest_name"]}')
        result = result.replace('"{guest name}"', f'"{variables["guest_name"]}"')
        result = result.replace('{Guest Name}', variables["guest_name"])

    # Source URL
    if "source" in variables and variables["source"]:
        result = result.replace('source: ""', f'source: "{variables["source"]}"')
        result = result.replace('[r/subreddit/post-url]', variables["source"])
        result = result.replace('[TikTok/YouTube URL]', variables["source"])

    # Generic placeholders
    result = result.replace('{Episode Title}', variables.get("title", "Episode Title"))
    result = result.replace('{episode_number}', variables.get("episode_number", "0nn"))
    result = result.replace('0nn', variables.get("episode_number", "0nn"))
    result = result.replace('{title}', variables.get("title", ""))
    result = result.replace('{date}', variables.get("date", ""))

    return result


def create_episode_file(
    episode_num: int,
    episode_type: str,
    title: str,
    guest_name: Optional[str] = None,
    source: Optional[str] = None
) -> Path:
    """
    Create episode file from template.

    Args:
        episode_num: Episode number
        episode_type: Type of episode
        title: Episode title
        guest_name: Guest name for PREREC episodes
        source: Source URL (Reddit, video, etc.)

    Returns:
        Path to created episode file

    Raises:
        FileExistsError: If episode file already exists
    """
    # Format episode number
    formatted_num = format_episode_number(episode_num)

    # Create filename
    title_slug = slugify(title)
    filename_template = EPISODE_TYPES[episode_type]["title_format"]
    filename = filename_template.format(
        episode_number=formatted_num,
        title=title_slug
    )

    episode_path = EPISODES_DIR / filename

    # Check if file exists
    if episode_path.exists():
        raise FileExistsError(f"Episode file already exists: {episode_path}")

    # Load and process template
    template = load_template(episode_type)

    variables = {
        "episode_number": formatted_num,
        "title": title,
        "date": datetime.now().strftime("%Y-%m-%d")
    }

    if guest_name:
        variables["guest_name"] = guest_name

    if source:
        variables["source"] = source

    content = substitute_template(template, variables)

    # Ensure directory exists
    EPISODES_DIR.mkdir(parents=True, exist_ok=True)

    # Write file
    episode_path.write_text(content)

    return episode_path


def create_context_log(
    episode_num: int,
    episode_type: str,
    episode_path: Path,
    title: str,
    source: Optional[str] = None,
    guest_name: Optional[str] = None
) -> Path:
    """
    Create context log for episode generation.

    Args:
        episode_num: Episode number
        episode_type: Type of episode
        episode_path: Path to generated episode file
        title: Episode title
        source: Source URL if provided
        guest_name: Guest name if PREREC

    Returns:
        Path to created context log
    """
    date_str = datetime.now().strftime("%Y-%m-%d")
    time_str = datetime.now().strftime("%H:%M:%S")
    formatted_num = format_episode_number(episode_num)

    log_filename = f"{date_str}-episode-{formatted_num}-generated.md"
    log_path = CONTEXT_DIR / log_filename

    # Build log content
    log_content = f"""# Episode Generation Log

**Date**: {date_str}
**Time**: {time_str}
**Episode Number**: {formatted_num}
**Episode Type**: {episode_type}
**Title**: {title}

## Generated Files

- Episode: `{episode_path}`

## Episode Details

- **Type**: {episode_type.upper()}
- **Description**: {EPISODE_TYPES[episode_type]["description"]}
"""

    if guest_name:
        log_content += f"- **Guest**: {guest_name}\n"

    if source:
        log_content += f"- **Source**: {source}\n"

    rotation = check_rotation(episode_num)
    if rotation:
        log_content += f"\n## Rotation Match\n\n✓ Episode {episode_num} matches {rotation.upper()} rotation schedule\n"

    log_content += f"""
## Next Steps

1. **Review Episode File**: Open `{episode_path.name}` and review template
2. **Assign Segments**: Create 2-5 segment files in `segments/` directory
3. **Gather Content**:
   - Research topic and find supporting material
   - Review Reddit/video sources if provided
   - Identify evo-psych/sociology references
4. **Complete Checklist**: Work through production checklist in episode file
5. **Refine Hook**: Craft compelling hook based on content
6. **SEO Keywords**: Finalize keywords and target phrases
7. **Review Brand Alignment**: Check against `brand.md` for tone/voice consistency

## Quick Commands

```bash
# Open episode file
open "{episode_path}"

# Create new segment
cd {PROJECT_ROOT / 'segments'}

# Review brand guidelines
open "{PROJECT_ROOT / 'brand.md'}"
```

---

Generated by gen-epi.py v1.0.0
"""

    # Ensure context directory exists
    CONTEXT_DIR.mkdir(parents=True, exist_ok=True)

    # Write log
    log_path.write_text(log_content)

    return log_path


def interactive_mode() -> None:
    """Run interactive episode generation."""
    print_header("Podcast Episode Generator - Interactive Mode")

    # Get next episode number
    next_episode = get_next_episode_number()
    print_info(f"Next episode number: {format_episode_number(next_episode)}")

    # Check rotation
    rotation_match = check_rotation(next_episode)
    if rotation_match:
        print_warning(f"Rotation match detected: Episode {next_episode} should be {rotation_match.upper()}")
        use_rotation = input(f"  Use {rotation_match} template? [Y/n]: ").strip().lower()
        if use_rotation in ('', 'y', 'yes'):
            episode_type = rotation_match
        else:
            episode_type = None
    else:
        episode_type = None

    # Select episode type if not set by rotation
    if not episode_type:
        print("\n" + Fore.CYAN + "Select episode type:")
        for i, (type_key, type_info) in enumerate(EPISODE_TYPES.items(), 1):
            print(f"  {i}. {type_key:12s} - {type_info['description']}")

        while True:
            try:
                choice = input(f"\nEnter choice [1-{len(EPISODE_TYPES)}]: ").strip()
                choice_num = int(choice)
                if 1 <= choice_num <= len(EPISODE_TYPES):
                    episode_type = list(EPISODE_TYPES.keys())[choice_num - 1]
                    break
                else:
                    print_error(f"Please enter a number between 1 and {len(EPISODE_TYPES)}")
            except ValueError:
                print_error("Please enter a valid number")

    print_success(f"Episode type: {episode_type}")

    # Get title
    print()
    if episode_type == "prerec":
        title = input("Enter guest name or topic: ").strip()
        guest_name = title
    else:
        title = input("Enter episode title: ").strip()
        guest_name = None

    if not title:
        print_error("Title cannot be empty")
        sys.exit(1)

    # Get optional source
    source = input("Enter source URL (Reddit/video) [optional]: ").strip() or None

    # Confirm
    print(f"\n{Fore.MAGENTA}{'─'*70}")
    print(f"Episode {format_episode_number(next_episode)}: {title}")
    print(f"Type: {episode_type}")
    if guest_name:
        print(f"Guest: {guest_name}")
    if source:
        print(f"Source: {source}")
    print(f"{'─'*70}{Style.RESET_ALL}\n")

    confirm = input("Generate episode? [Y/n]: ").strip().lower()
    if confirm not in ('', 'y', 'yes'):
        print_warning("Cancelled")
        sys.exit(0)

    # Generate episode
    try:
        episode_path = create_episode_file(
            next_episode,
            episode_type,
            title,
            guest_name=guest_name,
            source=source
        )
        print_success(f"Episode created: {episode_path}")

        # Create context log
        log_path = create_context_log(
            next_episode,
            episode_type,
            episode_path,
            title,
            source=source,
            guest_name=guest_name
        )
        print_success(f"Context log created: {log_path}")

        # Print next steps
        print(f"\n{Fore.GREEN}{Style.BRIGHT}{'─'*70}")
        print("Next Steps:")
        print(f"{'─'*70}{Style.RESET_ALL}")
        print(f"1. Open episode file: {Fore.CYAN}{episode_path}{Style.RESET_ALL}")
        print(f"2. Review context log: {Fore.CYAN}{log_path}{Style.RESET_ALL}")
        print(f"3. Create segments in: {Fore.CYAN}{PROJECT_ROOT / 'segments'}/{Style.RESET_ALL}")
        print(f"4. Complete production checklist in episode file")
        print()

    except FileExistsError as e:
        print_error(str(e))
        sys.exit(1)
    except FileNotFoundError as e:
        print_error(str(e))
        sys.exit(1)


def check_rotation_command(args: argparse.Namespace) -> None:
    """Display rotation schedule information."""
    print_header("Episode Rotation Schedule")

    next_episode = get_next_episode_number()
    print_info(f"Current episode number: {format_episode_number(next_episode)}")

    # Check current rotation
    rotation = check_rotation(next_episode)
    if rotation:
        print(f"\n{Fore.YELLOW}{Style.BRIGHT}Episode {next_episode} matches rotation:{Style.RESET_ALL}")
        print(f"  Type: {rotation.upper()}")
        print(f"  Description: {EPISODE_TYPES[rotation]['description']}")
    else:
        print(f"\n{Fore.GREEN}No rotation match - use STANDARD episode{Style.RESET_ALL}")

    # Show next few rotations
    print(f"\n{Fore.CYAN}Upcoming Rotation Schedule:{Style.RESET_ALL}")
    print(f"{'─'*70}")

    for i in range(next_episode, next_episode + 20):
        rot = check_rotation(i)
        if rot:
            print(f"  Episode {format_episode_number(i)}: {Fore.YELLOW}{rot.upper()}{Style.RESET_ALL}")

    print(f"{'─'*70}\n")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description="Automated podcast episode generator",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s                                    # Interactive mode
  %(prog)s --topic "Dating Red Flags"        # Quick standard episode
  %(prog)s --prerec "Dr. Smith" --topic "Attachment Theory"
  %(prog)s --reddit "https://reddit.com/r/dating_advice/..."
  %(prog)s --check-rotation                  # Show rotation schedule
  %(prog)s --type conspiracy --topic "Area 51"

Episode Types:
  standard    - Regular episode (2-5 segments on core pillars)
  prerec      - Pre-recorded guest interview (PremiereHybrid)
  throwback   - 80s/90s nostalgia or personal story time
  ethereal    - Consciousness, deity, religion topics
  conspiracy  - Conspiracy theory (Gallo picks stance)

Rotation Schedule:
  Every 5th episode  - Throwback
  Every 7th episode  - Conspiracy
  Every 9th episode  - Ethereal
        """
    )

    parser.add_argument(
        '--topic',
        help='Episode topic or title'
    )

    parser.add_argument(
        '--type',
        choices=list(EPISODE_TYPES.keys()),
        help='Episode type (default: auto-detect from rotation or standard)'
    )

    parser.add_argument(
        '--prerec',
        metavar='GUEST_NAME',
        help='Guest name for PREREC episode (implies --type prerec)'
    )

    parser.add_argument(
        '--reddit',
        metavar='URL',
        help='Reddit source URL'
    )

    parser.add_argument(
        '--video',
        metavar='URL',
        help='Video source URL (TikTok, YouTube, etc.)'
    )

    parser.add_argument(
        '--check-rotation',
        action='store_true',
        help='Show rotation schedule and exit'
    )

    parser.add_argument(
        '--version',
        action='version',
        version='%(prog)s 1.0.0'
    )

    args = parser.parse_args()

    # Check rotation command
    if args.check_rotation:
        check_rotation_command(args)
        sys.exit(0)

    # If no arguments, run interactive mode
    if not any([args.topic, args.prerec, args.reddit, args.video]):
        interactive_mode()
        sys.exit(0)

    # CLI mode
    print_header("Podcast Episode Generator")

    # Get next episode number
    next_episode = get_next_episode_number()
    print_info(f"Next episode number: {format_episode_number(next_episode)}")

    # Determine episode type
    episode_type = args.type
    guest_name = None

    if args.prerec:
        episode_type = "prerec"
        guest_name = args.prerec

    # Check rotation if type not specified
    if not episode_type:
        rotation = check_rotation(next_episode)
        if rotation:
            print_warning(f"Rotation match: Episode {next_episode} should be {rotation.upper()}")
            episode_type = rotation
        else:
            episode_type = "standard"

    print_success(f"Episode type: {episode_type}")

    # Get title
    title = args.topic or args.prerec
    if not title:
        print_error("Title/topic is required")
        sys.exit(1)

    # Get source
    source = args.reddit or args.video or None

    # Generate episode
    try:
        episode_path = create_episode_file(
            next_episode,
            episode_type,
            title,
            guest_name=guest_name,
            source=source
        )
        print_success(f"Episode created: {episode_path}")

        # Create context log
        log_path = create_context_log(
            next_episode,
            episode_type,
            episode_path,
            title,
            source=source,
            guest_name=guest_name
        )
        print_success(f"Context log created: {log_path}")

        # Print summary
        print(f"\n{Fore.GREEN}{Style.BRIGHT}{'─'*70}")
        print(f"Episode {format_episode_number(next_episode)} Generated Successfully")
        print(f"{'─'*70}{Style.RESET_ALL}")
        print(f"File: {Fore.CYAN}{episode_path}{Style.RESET_ALL}")
        print(f"Log:  {Fore.CYAN}{log_path}{Style.RESET_ALL}")
        print()

    except FileExistsError as e:
        print_error(str(e))
        sys.exit(1)
    except FileNotFoundError as e:
        print_error(str(e))
        sys.exit(1)


if __name__ == "__main__":
    main()
