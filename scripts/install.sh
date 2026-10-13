#!/usr/bin/env bash
# Installs the entry skill and agents from the repo into the live Claude Code dirs.
set -euo pipefail
PSTACK="${PSTACK:-$HOME/.claude/pstack}"
mkdir -p "${CLAUDE_DIR:-$HOME/.claude}/skills/poteto-mode" "${CLAUDE_DIR:-$HOME/.claude}/agents"
cp "$PSTACK/port/entry/SKILL.md" "$PSTACK/port/entry/SOURCE.md" "${CLAUDE_DIR:-$HOME/.claude}/skills/poteto-mode/"
cp "$PSTACK"/port/agents/*.md "${CLAUDE_DIR:-$HOME/.claude}/agents/"
echo "installed /poteto-mode and $(ls "$PSTACK"/port/agents/*.md | wc -l | tr -d ' ') agents"
