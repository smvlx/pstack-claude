# pstack update 1dcc2bacde -> 101b274dd9 (0.15.25)

Review branch: `update/101b274dd9`, worktree: `~/.claude/pstack-update`. Status: ported, ready to review.

## Gate and tests

- `node scripts/check-port.mjs`: 0 failures, 5 Cursor mentions (all intentional, in `port/entry/SKILL.md` and the mode's pointer line).
- `cd skills/poteto-mode/scripts && ~/.bun/bin/bun test`: 68 pass, 0 fail on three consecutive runs. One earlier cold run reported 1 fail and 1 error with only 60 tests collected, and did not reproduce.

## Conflicts resolved

Kept the port's text, because upstream only appended the per-spawn "reasoning level and fast or standard speed" sentence (plus Cursor model families in arena and interrogate):
how, why, reflect, recall, no-comments, show-me-your-work, arena, interrogate, and the playbooks autonomous-run, feature, hillclimb, perf-issue, refactoring, runtime-forensics, session-pickup, worktree-cleanup. The same sentence was stripped from the auto-merged bug-fix, eval, trace-forensics, automate-me and figure-it-out.

Hand-ported from upstream's new text:

- `poteto-mode/SKILL.md`. Principle one-liners taken from upstream. Subagents section kept, with a new "Match the model to the job" paragraph. The session effort carries to subagents. Agent `effort` is passed only when the user names a level. Claude Code has no per-spawn fast mode.
- `autopilot-full.md`, `autopilot-stack.md`, `shipping.md`. Upstream's restructured steps, mapped to `gh` and plain git, `poteto-agent` worktree agents, the built-in browser tools, the `simplify` skill, TaskStop for stuck agents, and merges only on an explicit user instruction in this session.
- `orchestrate.md`, `multi-phase-plan.md`. "Restack" becomes topology mutation by one stacker. A full swarm runs once per code-ready head. The `--forge origin` mention is dropped.
- `ketchup`. Upstream's shorter, visual catch-up, with `/bro` and `/visualize` mapped to the bro skill and the session's inline chart tool.
- `swarm`, `opening-a-pr`. Upstream's deletions and the "move the child onto trunk per shipping step 4" line.
- `scripts/orch/{store,orch,orch.test}.ts`. Kept the port's gh frontier. Upstream converged on a gh base-chain walk too, plus a `--forge origin` option, which is Origin-only.
- `scripts/worktree-audit.sh`. Took upstream's normalized `{number, state, head}` rows and lowercase state, without the Origin branch.

## Other changes

- New skills `sharpen` and `in-your-own-words` came in unchanged. Neither has Cursor-isms.
- `port/agents/poteto-agent.md`. Carries upstream's "if the mode file is missing, stop and tell your parent". The `~/.cursor/plugins/` search does not apply.
- `scripts/check-port.mjs`. New patterns for `cursor-grok-*` and `composer-*`, `inherit-parent`, per-spawn speed (`fast or standard speed`, `-fast` slugs), and Origin forge selection.
- `scripts/check-port.mjs` also skips `UPDATE-SUMMARY.md`. The summary names banned tokens on purpose, and `apply-update.sh` runs the gate before it deletes the summary.
- `CLAUDE-PORT.md`. Notes upstream's new `docs/harness/claude-code.md` as reference that this port does not use.
- No new model role upstream, so `models.md` and `setup-pstack` are unchanged.

## Not ported

- Per-spawn reasoning level and speed. Upstream's own Claude Code adapter (`docs/harness/claude-code.md`) maps slugs to `model` plus `effort`. The port keeps effort at the session level because the port has no per-role effort values. Adding an optional effort per `models.md` line would be the follow-up if wanted.
- `orch frontier set --forge origin`, and the Origin branches in shipping, autopilot and worktree-audit. Origin is Cursor-only.
- Upstream's `README.md` now has a Claude Code install section for upstream's marketplace plugin. It stays as upstream reference. The port's GitHub page is `.github/README.md`.

## Apply after review

```sh
~/.claude/pstack/scripts/apply-update.sh
```
