#!/usr/bin/env python3
"""
skill-adopt.py — Hermes Skill Discovery and Adoption

Rules:
1. Check local ./.hermes/skills/ first
2. If not found, check ~/.hermes/skills/ (master)
3. If master skill works as-is → create symlink
4. If needs modification → copy and adapt locally
5. If conflict → local version wins

Usage:
  python3 skill-adopt.py list              # List available skills
  python3 skill-adopt.py adopt obsidian     # Adopt obsidian skill
  python3 skill-adopt.py adopt --local obsidian  # Force local copy
  python3 skill-adopt.py sync              # Sync all applicable skills
"""

import argparse
import json
import os
import shutil
import sys
from pathlib import Path

def get_master_registry():
    """Load master skills registry"""
    registry_path = Path.home() / ".hermes" / "skills" / "MASTER-REGISTRY.json"
    if not registry_path.exists():
        print("Error: Master registry not found. Run setup first.")
        sys.exit(1)
    with open(registry_path) as f:
        return json.load(f)

def get_local_skills_dir():
    """Get local skills directory for current project"""
    local = Path.cwd() / ".hermes" / "skills"
    return local if local.exists() else None

def list_skills(registry, local_dir=None):
    """List all available skills with adoption status"""
    print("\n=== AVAILABLE SKILLS ===\n")
    
    indexed = registry.get("indexed_skills", [])
    
    for skill in indexed:
        name = skill["name"]
        universal = "✓" if skill.get("universal") else "○"
        category = skill.get("category", "uncategorized")
        
        # Check local status
        local_status = ""
        if local_dir:
            local_file = local_dir / skill["file"]
            if local_file.exists() or (local_file.is_symlink() if local_file.exists() else False):
                local_status = " [LOCAL]"
            elif any(local_dir.glob(f"SKILL--{name}*")) or any(local_dir.glob(f"{name}*")):
                local_status = " [LOCAL (variant)]"
        
        print(f"  {universal} {name:20} ({category}){local_status}")
        print(f"     {skill.get('adoption_notes', '')}")
        print()
    
    print("Legend: ✓ = Universal (works anywhere), ○ = Platform-specific")
    print("        [LOCAL] = Adopted in this project")

def adopt_skill(registry, skill_name, force_local=False):
    """Adopt a skill from master registry"""
    indexed = registry.get("indexed_skills", [])
    skill = next((s for s in indexed if s["name"] == skill_name), None)
    
    if not skill:
        print(f"Error: Skill '{skill_name}' not found in registry.")
        print("Run 'list' to see available skills.")
        sys.exit(1)
    
    master_path = Path(skill["location"]).expanduser()
    local_dir = Path.cwd() / ".hermes" / "skills"
    local_dir.mkdir(parents=True, exist_ok=True)
    
    local_path = local_dir / skill["file"]
    
    # Check if already exists
    if local_path.exists():
        print(f"Skill '{skill_name}' already adopted locally.")
        return
    
    # Decide: symlink or copy
    if skill.get("universal") and not force_local:
        # Universal skill: symlink to master
        if master_path.exists():
            os.symlink(master_path, local_path)
            print(f"✓ Symlinked '{skill_name}' → {master_path}")
        else:
            print(f"Error: Master skill file not found: {master_path}")
            sys.exit(1)
    else:
        # Platform-specific or force_local: copy and adapt
        if master_path.exists():
            shutil.copy2(master_path, local_path)
            print(f"✓ Copied '{skill_name}' to {local_path}")
            print(f"  Edit this file to adapt for this project.")
        else:
            print(f"Error: Master skill file not found: {master_path}")
            sys.exit(1)

def sync_skills(registry):
    """Sync all applicable universal skills"""
    indexed = registry.get("indexed_skills", [])
    local_dir = Path.cwd() / ".hermes" / "skills"
    
    adopted = 0
    skipped = 0
    
    for skill in indexed:
        if not skill.get("universal"):
            skipped += 1
            continue
        
        local_path = local_dir / skill["file"]
        if local_path.exists() or local_path.is_symlink():
            skipped += 1
            continue
        
        adopt_skill(registry, skill["name"])
        adopted += 1
    
    print(f"\nSync complete: {adopted} adopted, {skipped} skipped (already exist or platform-specific)")

def main():
    parser = argparse.ArgumentParser(description="Hermes skill adoption")
    parser.add_argument("command", choices=["list", "adopt", "sync"])
    parser.add_argument("skill", nargs="?", help="Skill name (for adopt)")
    parser.add_argument("--local", action="store_true", help="Force local copy instead of symlink")
    
    args = parser.parse_args()
    
    registry = get_master_registry()
    local_dir = get_local_skills_dir()
    
    if args.command == "list":
        list_skills(registry, local_dir)
    elif args.command == "adopt":
        if not args.skill:
            print("Error: Skill name required for adopt")
            sys.exit(1)
        adopt_skill(registry, args.skill, args.local)
    elif args.command == "sync":
        sync_skills(registry)

if __name__ == "__main__":
    main()
