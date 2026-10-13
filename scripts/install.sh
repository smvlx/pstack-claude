#!/usr/bin/env bash
# Installs the entry skill and agents from the repo into the live Claude Code dirs, and builds the pstack plugin.
set -euo pipefail
PSTACK="${PSTACK:-$HOME/.claude/pstack}"
mkdir -p "${CLAUDE_DIR:-$HOME/.claude}/skills/poteto-mode" "${CLAUDE_DIR:-$HOME/.claude}/agents"
cp "$PSTACK/port/entry/SKILL.md" "$PSTACK/port/entry/SOURCE.md" "${CLAUDE_DIR:-$HOME/.claude}/skills/poteto-mode/"
cp "$PSTACK"/port/agents/*.md "${CLAUDE_DIR:-$HOME/.claude}/agents/"
PSTACK="$PSTACK" CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}" node "$PSTACK/scripts/build-plugin.mjs"
if [ -z "${CLAUDE_DIR:-}" ] && command -v claude >/dev/null && [[ "$(claude plugin list 2>/dev/null)" == *pstack@local-plugins* ]]; then
  claude plugin marketplace update local-plugins
  claude plugin update pstack@local-plugins
fi
echo "installed /poteto-mode, $(ls "$PSTACK"/port/agents/*.md | wc -l | tr -d ' ') agents and the pstack plugin (/pstack:<skill>)"
