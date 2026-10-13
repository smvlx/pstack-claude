Ported from https://github.com/cursor/plugins/tree/main/pstack (MIT, Lauren Tan).
Bundle: ~/.claude/pstack (git repo: branch `upstream` = vanilla snapshots, `main` = port).
Current upstream base: see ~/.claude/pstack/UPSTREAM-VERSION. First port: 0.15.21 @ 1dcc2bacde7, 2026-10-13.
Port contract: ~/.claude/pstack/CLAUDE-PORT.md. Gate: node ~/.claude/pstack/scripts/check-port.mjs
Updates: a weekly scheduled task prepares a review branch; read ~/.claude/pstack/UPDATING.md, then run
~/.claude/pstack/scripts/apply-update.sh after reviewing. Never auto-applied.
