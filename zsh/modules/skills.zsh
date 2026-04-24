# ~/.config/zsh/modules/skills.zsh
# Hermes skill management

export HERMES_SKILLS_MASTER="${HOME}/.hermes/skills"

# Quick skill view from master registry
skill-view() {
  local name="$1"
  local registry="${HERMES_SKILLS_MASTER}/MASTER-REGISTRY.json"
  
  if [[ -f "$registry" ]]; then
    python3 -c "import json; r=json.load(open('$registry')); s=[x for x in r['indexed_skills'] if x['name']=='$name']; print(s[0]['location'] if s else 'Not found')" 2>/dev/null
  fi
}

# Check if skill exists locally or in master
has-skill() {
  local name="$1"
  local local_skill="./.hermes/skills/SKILL--${name}.md"
  local master_skill="${HERMES_SKILLS_MASTER}/SKILL--${name}.md"
  
  if [[ -f "$local_skill" ]] || [[ -L "$local_skill" ]]; then
    echo "local"
  elif [[ -f "$master_skill" ]]; then
    echo "master"
  else
    echo "none"
  fi
}
