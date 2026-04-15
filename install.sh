#!/bin/bash

set -e

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing claude-skills to $SKILLS_DIR ..."
echo ""

mkdir -p "$SKILLS_DIR"

SKILLS=("arch-doc" "refine")

for skill in "${SKILLS[@]}"; do
  if [ -d "$SCRIPT_DIR/$skill" ]; then
    cp -r "$SCRIPT_DIR/$skill" "$SKILLS_DIR/"
    echo "✓ $skill"
  fi
done

echo ""
echo "Done. Restart Claude Code to activate."
