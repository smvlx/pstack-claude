#!/usr/bin/env bash
# Installs the entry skill and agents from the repo into the live Claude Code dirs.
set -euo pipefail
PSTACK="$HOME/.claude/pstack"
mkdir -p "$HOME/.claude/skills/poteto-mode" "$HOME/.claude/agents"
cp "$PSTACK/port/entry/SKILL.md" "$PSTACK/port/entry/SOURCE.md" "$HOME/.claude/skills/poteto-mode/"
cp "$PSTACK"/port/agents/*.md "$HOME/.claude/agents/"
echo "installed /poteto-mode and $(ls "$PSTACK"/port/agents/*.md | wc -l | tr -d ' ') agents"
