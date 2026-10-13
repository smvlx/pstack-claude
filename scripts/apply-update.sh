#!/usr/bin/env bash
# Applies a reviewed update branch: fast-forwards main, installs entry skill and agents, cleans up.
set -euo pipefail
PSTACK="${PSTACK:-$HOME/.claude/pstack}"
WT="${PSTACK_UPDATE_WT:-$HOME/.claude/pstack-update}"
BR="$(git -C "$WT" branch --show-current)"
case "$BR" in update/*) ;; *) echo "no update branch at $WT" >&2; exit 1;; esac
git -C "$WT" diff --quiet && git -C "$WT" diff --cached --quiet || { echo "$WT has uncommitted changes" >&2; exit 1; }
[ -z "$(git -C "$WT" diff --name-only --diff-filter=U)" ] || { echo "unresolved conflicts in $WT" >&2; exit 1; }
[ -f "$WT/UPSTREAM-VERSION.pending" ] || { echo "missing UPSTREAM-VERSION.pending" >&2; exit 1; }
node "$WT/scripts/check-port.mjs" >/dev/null || { echo "gate fails on $BR; run node $WT/scripts/check-port.mjs" >&2; exit 1; }
if git -C "$WT" ls-files --error-unmatch UPSTREAM-VERSION.pending >/dev/null 2>&1 || [ -f "$WT/UPSTREAM-VERSION.pending" ]; then
  mv "$WT/UPSTREAM-VERSION.pending" "$WT/UPSTREAM-VERSION"; rm -f "$WT/UPDATE-SUMMARY.md"
  git -C "$WT" add -A && git -C "$WT" -c user.email=local@local -c user.name=pstack-updater commit -qm "record upstream $(cut -d' ' -f2 "$WT/UPSTREAM-VERSION") @ $(cut -c1-11 "$WT/UPSTREAM-VERSION")"
fi
git -C "$PSTACK" merge -q --ff-only "$BR"
"$PSTACK/scripts/install.sh"
git -C "$PSTACK" worktree remove --force "$WT"
git -C "$PSTACK" branch -q -D "$BR"
echo "applied $BR; now at upstream $(cat "$PSTACK/UPSTREAM-VERSION"). Start a new session to load the changes."
