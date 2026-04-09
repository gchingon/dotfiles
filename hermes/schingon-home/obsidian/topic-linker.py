#!/usr/bin/env python3
"""
topic-linker.py — Hermes-Obsidian topic linker
Adds "See Also" WikiLinks to session logs based on Topics folder.

Usage:
  python3 topic-linker.py --dry-run    # Preview changes
  python3 topic-linker.py              # Apply changes
"""

import argparse
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path

FOOTER_START = "---
## See Also"
FOOTER_END = "<!-- topic-linker-generated -->"

def get_config():
    """Load configuration from ~/.hermes/obsidian/config.json"""
    config_path = Path.home() / ".hermes" / "obsidian" / "config.json"
    if not config_path.exists():
        return None
    with open(config_path) as f:
        return json.load(f)

def expand_path(path_str):
    """Expand ~ and environment variables"""
    return Path(os.path.expandvars(os.path.expanduser(path_str)))

def load_topics(vault_path, topics_folder):
    """Load all topic names from Topics folder"""
    topics_dir = expand_path(vault_path) / topics_folder
    if not topics_dir.exists():
        return {}
    
    topics = {}
    for f in topics_dir.glob("*.md"):
        name = f.stem
        # Add both exact match and normalized
        topics[name.lower()] = name
        topics[name.lower().replace("-", " ")] = name
        topics[name.lower().replace("_", " ")] = name
    return topics

def strip_existing_footer(content):
    """Remove old See Also footer"""
    pattern = rf'\n?{re.escape(FOOTER_START)}.*?{re.escape(FOOTER_END)}\n?'
    return re.sub(pattern, '', content, flags=re.DOTALL)

def find_matching_topics(content, topics):
    """Find which topics appear in content"""
    content_lower = content.lower()
    matched = set()
    for key, name in topics.items():
        if key in content_lower:
            matched.add(name)
    return sorted(matched)

def build_footer(matched_topics):
    """Build the See Also footer"""
    if not matched_topics:
        return None
    lines = [FOOTER_START]
    for topic in matched_topics:
        lines.append(f"- [[{topic}]]")
    lines.append(FOOTER_END)
    return "
".join(lines)

def process_file(filepath, topics, dry_run=False):
    """Process a single file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Check if already has our footer
    if FOOTER_END in content:
        # Already processed by us
        content_clean = strip_existing_footer(content)
    else:
        content_clean = content.rstrip()
    
    matched = find_matching_topics(content_clean, topics)
    footer = build_footer(matched)
    
    if not footer:
        return "no_topics"
    
    new_content = content_clean + "

" + footer + "
"
    
    if dry_run:
        print(f"[DRY-RUN] Would update: {filepath} ({len(matched)} topics)")
        return "updated"
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"Updated: {filepath} ({len(matched)} topics)")
    return "updated"

def main():
    parser = argparse.ArgumentParser(description="Link session logs to topic notes")
    parser.add_argument("--dry-run", action="store_true", help="Preview changes")
    args = parser.parse_args()
    
    config = get_config()
    if not config:
        print("Error: Config not found at ~/.hermes/obsidian/config.json")
        sys.exit(1)
    
    vault_path = expand_path(config["hermes_obsidian"]["vault_path"])
    sessions_dir = vault_path / config["hermes_obsidian"]["sessions_folder"]
    topics_folder = config["hermes_obsidian"]["topics_folder"]
    
    if not sessions_dir.exists():
        print(f"Error: Sessions directory not found: {sessions_dir}")
        sys.exit(1)
    
    # Load topics
    topics = load_topics(vault_path, topics_folder)
    print(f"Loaded {len(topics)} unique topics from {topics_folder}/")
    
    # Process all session files
    updated = 0
    unchanged = 0
    no_topics = 0
    
    for md_file in sorted(sessions_dir.glob("*.md")):
        result = process_file(md_file, topics, args.dry_run)
        if result == "updated":
            updated += 1
        elif result == "no_topics":
            no_topics += 1
        else:
            unchanged += 1
    
    print(f"\nSummary: {updated} updated, {unchanged} unchanged, {no_topics} no matching topics")

if __name__ == "__main__":
    main()
