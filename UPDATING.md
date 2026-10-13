# Updating the pstack port from upstream

`~/.claude/pstack` is a git repo with two branches.

- `upstream` holds vanilla `cursor/plugins` `pstack/` snapshots, one commit per update.
- `main` is the Claude Code port: upstream plus the port commits. It is what's live.

`UPSTREAM-VERSION` on `main` records the upstream sha and version the port is based on.

## The scripts

- `scripts/update-upstream.sh` prepares an update and never touches `main` or the live files. It fetches upstream and exits 0 if `pstack/` content is unchanged. Otherwise it commits the new snapshot on `upstream`, creates branch `update/<sha>` from `main` in the worktree `~/.claude/pstack-update`, and merges `upstream` into it. It then runs the gate and the bun tests and writes `~/.claude/pstack-update/UPDATE-SUMMARY.md`. Exit codes: 10 means the update is clean and ready to review, 20 means it needs porting (conflicts, gate failures or failing tests), 1 is an error.
- `scripts/apply-update.sh` applies a reviewed update. It refuses on conflicts, uncommitted changes or a failing gate. Then it fast-forwards `main`, runs `scripts/install.sh` and removes the worktree. It can be re-run.
- `scripts/install.sh` copies `port/entry/` to `~/.claude/skills/poteto-mode/` and `port/agents/*.md` to `~/.claude/agents/`. Edit those canonical copies in the repo, never the live ones.

## Porting an update (exit 20, or exit 10 with new Cursor-isms)

Work only in `~/.claude/pstack-update`. Never touch `main`, `~/.claude/skills` or `~/.claude/agents`.

1. Read `UPDATE-SUMMARY.md`, `CLAUDE-PORT.md` and `git -C ~/.claude/pstack diff upstream~1 upstream`. Port only what upstream changed.
2. Resolve conflicts. The port rewrote some files wholesale: `skills/setup-pstack`, `skills/poteto-help`, `skills/make-bot-ui`, the Subagents section of `skills/poteto-mode/SKILL.md`, and `scripts/orch/store.ts`. For those, keep the port's version (`git checkout --ours <file>`), then read upstream's diff for the file and carry the new behavior over by hand. Elsewhere, take upstream's new text and re-apply the port mapping from `CLAUDE-PORT.md` section 4.
3. Port new Cursor-isms in the steps themselves. A pointer to `CLAUDE-PORT.md` does not count.
4. If upstream changed `agents/poteto-agent.md` or `agents/comment-sicko.md`, carry the change into `port/agents/`. If upstream added a model role, add its line to `models.md` and to `skills/setup-pstack/SKILL.md`. If upstream added a new kind of Cursor token, add a pattern for it to `scripts/check-port.mjs`.
5. Run `node scripts/check-port.mjs` until it shows 0 failures. Run `cd skills/poteto-mode/scripts && ~/.bun/bin/bun test` until it is green.
6. Commit on the `update/<sha>` branch. Update `UPDATE-SUMMARY.md` with what you ported and anything you could not port, then stop. The user reviews and runs `scripts/apply-update.sh`.
