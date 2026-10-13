#!/usr/bin/env bash
# Prepares an update of the pstack port on a review branch. Never touches main or live files.
# Exit 0: up to date (or an update branch for this sha already exists). 10: update ready, clean.
# 20: update needs porting (merge conflicts, gate failures, or test failures). 1: error.
set -euo pipefail
PSTACK="${PSTACK:-$HOME/.claude/pstack}"
WT="${PSTACK_UPDATE_WT:-$HOME/.claude/pstack-update}"
BUN="${BUN:-$HOME/.bun/bin/bun}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"; git -C "$PSTACK" worktree remove --force "$TMP/up-wt" 2>/dev/null || true' EXIT

git -C "$PSTACK" diff --quiet && git -C "$PSTACK" diff --cached --quiet || { echo "main has uncommitted changes; commit them first" >&2; exit 1; }
read -r CUR_SHA _ < "$PSTACK/UPSTREAM-VERSION"

git clone -q --depth 1 --filter=blob:none --sparse https://github.com/cursor/plugins.git "$TMP/plugins"
git -C "$TMP/plugins" sparse-checkout set pstack
NEW_SHA="$(git -C "$TMP/plugins" rev-parse HEAD)"
NEW_VER="$(node -p "require('$TMP/plugins/pstack/plugin.json').version")"
PSTACK_SHA="$NEW_SHA"
BR="update/${PSTACK_SHA:0:10}"
if git -C "$PSTACK" rev-parse -q --verify "$BR" >/dev/null; then
  echo "branch $BR already prepared at $WT"; exit 0
fi

# 1. Vanilla upstream snapshot on the upstream branch. Content decides, not the sha:
# the cursor/plugins HEAD moves for every plugin in that repo.
git -C "$PSTACK" worktree add -q "$TMP/up-wt" upstream
rsync -a --delete --exclude .git "$TMP/plugins/pstack/" "$TMP/up-wt/"
if ! git -C "$TMP/up-wt" status --porcelain | grep -q .; then
  git -C "$PSTACK" worktree remove --force "$TMP/up-wt"
  echo "up to date (pstack $NEW_VER unchanged since ${CUR_SHA:0:10})"; exit 0
fi
git -C "$TMP/up-wt" add -A
git -C "$TMP/up-wt" -c user.email=local@local -c user.name=pstack-updater commit -qm "upstream pstack $NEW_VER @ ${PSTACK_SHA:0:11}"
git -C "$PSTACK" worktree remove --force "$TMP/up-wt"

# 2. Review branch: main + new upstream.
[ -e "$WT" ] && git -C "$PSTACK" worktree remove --force "$WT" 2>/dev/null || rm -rf "$WT"
git -C "$PSTACK" worktree add -q -b "$BR" "$WT" main
CONFLICTS=""
if ! git -C "$WT" -c user.email=local@local -c user.name=pstack-updater merge -q --no-edit upstream 2>/dev/null; then
  CONFLICTS="$(git -C "$WT" diff --name-only --diff-filter=U)"
fi
echo "$PSTACK_SHA $NEW_VER" > "$WT/UPSTREAM-VERSION.pending"

# 3. Gate and tests (only meaningful without conflicts).
GATE="skipped (conflicts)"; TESTS="skipped (conflicts)"; STATUS=10
if [ -n "$CONFLICTS" ]; then
  STATUS=20
else
  if GATE_OUT="$(node "$WT/scripts/check-port.mjs" 2>&1)"; then GATE="pass"; else GATE="FAIL"; STATUS=20; fi
  if TEST_OUT="$(cd "$WT/skills/poteto-mode/scripts" && "$BUN" install --frozen-lockfile >/dev/null 2>&1; "$BUN" test 2>&1)"; then
    TESTS="$(echo "$TEST_OUT" | grep -E '^ *[0-9]+ (pass|fail)' | tr '\n' ' ')"
  else
    TESTS="FAIL: $(echo "$TEST_OUT" | grep -E '^ *[0-9]+ (pass|fail)' | tr '\n' ' ')"; STATUS=20
  fi
fi

{
  echo "# pstack update ${CUR_SHA:0:10} -> ${PSTACK_SHA:0:10} ($NEW_VER)"
  echo
  echo "Review branch: \`$BR\`, worktree: \`$WT\`. Status: $([ $STATUS = 10 ] && echo 'clean, ready to review' || echo 'needs porting')."
  echo
  echo "## Upstream change"
  echo '```'; git -C "$PSTACK" diff --stat upstream~1 upstream | tail -40; echo '```'
  echo
  echo "## Merge conflicts"; echo "${CONFLICTS:-none}"
  echo
  echo "## Gate"; echo "$GATE"; [ "$GATE" = "FAIL" ] && { echo '```'; echo "$GATE_OUT" | grep FAIL | head -60; echo '```'; }
  echo
  echo "## Tests"; echo "$TESTS"
  echo
  echo "## Apply after review"
  echo '```sh'; echo "$PSTACK/scripts/apply-update.sh"; echo '```'
} > "$WT/UPDATE-SUMMARY.md"
cat "$WT/UPDATE-SUMMARY.md"
exit $STATUS
