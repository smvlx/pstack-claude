# pstack for Claude Code

This repo ports [pstack](https://github.com/cursor/plugins/tree/main/pstack), poteto's agent workflow bundle for Cursor, to Claude Code. You get `/poteto-mode`, which runs a task through pstack's playbooks and principles, and every bundled skill as its own command, such as `/pstack:how` or `/pstack:interrogate`.

The root [`README.md`](/README.md) is upstream's and describes Cursor. This page describes the port.

Two branches hold the history. `upstream` holds unmodified snapshots of upstream's `pstack/` folder, one commit per update. `main` is upstream plus the port, so `git diff upstream main` shows every change the port makes.

## Install

The skills and scripts refer to `~/.claude/pstack` by absolute path, so clone the repo there. You need `git`, `node`, and the Claude Code CLI. The PR playbooks use `gh`. The updater runs its tests with `bun`, from `~/.bun/bin/bun` or `$BUN`.

1. Clone the repo, and create the local `upstream` branch that the updater writes to.

	```bash
	git clone https://github.com/smvlx/pstack-claude.git ~/.claude/pstack
	git -C ~/.claude/pstack branch upstream origin/upstream
	```

2. Install the entry skill and the agents, and build the plugin.

	```bash
	~/.claude/pstack/scripts/install.sh
	```

	The script copies `port/entry/` to `~/.claude/skills/poteto-mode/` and `port/agents/*.md` to `~/.claude/agents/`. It then runs `scripts/build-plugin.mjs`, which writes the `pstack` plugin into the `local-plugins` marketplace at `~/.claude/local-marketplace`.

3. Register the marketplace, and install the plugin.

	```bash
	claude plugin marketplace add ~/.claude/local-marketplace
	claude plugin install pstack@local-plugins
	```

	If `claude plugin marketplace list` already shows `local-plugins`, run `claude plugin marketplace update local-plugins` instead of `add`.

4. Start a new Claude Code session. Claude Code loads skills and plugins when a session starts.

To choose a model for each role, run `/pstack:setup-pstack`. It writes [`models.md`](/models.md).

## Use it

- `/poteto-mode <task>` reads the port contract and the mode, matches the task to a playbook, and follows it. The playbooks cover features, bug fixes, investigations, refactors, PR babysitting, and more.
- `/pstack:<name>` runs one bundled skill. For example, `/pstack:how` explains a subsystem, `/pstack:interrogate` runs an adversarial review of a design, and `/pstack:unslop` edits prose.

Every `/pstack:` command is a short wrapper that sets `disable-model-invocation: true`. Claude runs one only when you type it. The wrapper tells Claude to read [`CLAUDE-PORT.md`](/CLAUDE-PORT.md) first and then the bundled `skills/<name>/SKILL.md`. So the port's rules always apply, and upstream text changes reach you without a plugin reinstall.

## What changed from Cursor

[`CLAUDE-PORT.md`](/CLAUDE-PORT.md) is the full contract. Where it and a bundled skill disagree, the contract wins. Your `~/.claude/CLAUDE.md` and the current repo's `CLAUDE.md` win over both. The port rewrote every Cursor-only step in place rather than adding pointers, and the gate `scripts/check-port.mjs` fails if a Cursor-only token comes back.

| Area | Upstream on Cursor | This port on Claude Code |
|---|---|---|
| Subagents | The `Task` tool | The `Agent` tool with `subagent_type: "poteto-agent"`, installed from `port/agents/` |
| Cloud agents | Cursor cloud agents | Local background subagents (`run_in_background: true`). Every agent that writes files gets its own git worktree (`isolation: "worktree"`). The one exception is `comment-sicko`, which edits uncommitted changes in place. |
| Read-only helpers | `readonly: true` | The `Explore` agent, or a "do not edit files" line in the prompt |
| Models | An always-applied Cursor rule with model slugs and reasoning budgets | `models.md`, one line per role. A value is `inherit`, `opus`, `sonnet`, `haiku`, `fable`, or `codex`. |
| A second opinion from another model family | Another Cursor model | `codex exec -s read-only` through the Codex CLI, for roles that write no files. This copy is Claude-only and puts `sonnet` in those slots. |
| Questions to the user | `AskQuestion` | `AskUserQuestion` |
| Stacked PRs | Graphite (`gt`) and the Origin CLI | `gh` and git. A stack is a chain of branches, and each PR's base is the branch below it. `git rebase --update-refs` restacks. `scripts/orch/store.ts` reads stacks with `gh pr` and git. |
| Driving a UI or a CLI | `control-ui` and `control-cli` | The built-in browser tools, Bash, or the `run` skill |
| Diff cleanup | `deslop` | The `simplify` skill |
| Transcripts | `~/.cursor/projects/<slug>/agent-transcripts/` | `~/.claude/projects/<slug>/<session-id>.jsonl`, read by `recall`, `automate-me`, and `scripts/worktree-audit.sh` |
| Rules | `~/.cursor/rules/*.mdc` | `~/.claude/CLAUDE.md` and the repo's `CLAUDE.md` |
| Merging | A PR owner merges after a clean verification | No agent merges without an explicit merge instruction from you in the same session. Without one, a run ends at merge-ready. |
| Automations | `automations/benny`, `make-bot-ui`, and webhook routines | Not supported. `make-bot-ui` explains why and stops. The `schedule` skill covers cron-style runs. |
| Skill registration | A Cursor plugin | The `/poteto-mode` entry skill, plus the generated `pstack` plugin for `/pstack:<name>` |

The port rewrote these parts wholesale instead of editing them: `skills/setup-pstack`, `skills/poteto-help`, `skills/make-bot-ui`, the Subagents section of `skills/poteto-mode/SKILL.md`, and `scripts/orch/store.ts`. `docs/guide/`, `automations/`, `agents/`, and the root `README.md` stay as upstream reference and still describe Cursor.

## Files the port adds

- `CLAUDE-PORT.md` holds the port contract.
- `models.md` sets the model for each role.
- `port/entry/` holds the `/poteto-mode` entry skill.
- `port/agents/` holds the `poteto-agent` and `comment-sicko` agents.
- `scripts/install.sh` installs the entry skill and the agents, builds the plugin, and refreshes an installed copy of the plugin.
- `scripts/build-plugin.mjs` writes one wrapper per `skills/*/SKILL.md`. The plugin version is the upstream version plus a hash of the wrappers, so `claude plugin update` picks up a skill that upstream adds or removes.
- `scripts/check-port.mjs` is the gate. It fails on Cursor-only tokens and on a broken plugin build.
- `scripts/update-upstream.sh`, `scripts/apply-update.sh`, and [`UPDATING.md`](/UPDATING.md) make up the update flow.

## Update from upstream

1. Run `~/.claude/pstack/scripts/update-upstream.sh`. It fetches upstream, commits a new snapshot on `upstream`, merges the snapshot into a review branch `update/<sha>` in the worktree `~/.claude/pstack-update`, and runs the gate and the tests. Exit code 0 means nothing changed. Exit code 10 means the update is ready to review. Exit code 20 means the update needs porting by hand. The script never touches `main`, so you can run it on a schedule.
2. Read `~/.claude/pstack-update/UPDATE-SUMMARY.md`, and review the branch. To port an update that exited with 20, follow [`UPDATING.md`](/UPDATING.md).
3. Run `~/.claude/pstack/scripts/apply-update.sh`. It fast-forwards `main`, runs `install.sh`, and removes the worktree.
4. Push both branches.

	```bash
	git -C ~/.claude/pstack push origin main upstream
	```

## License

MIT, from Lauren Tan's pstack in `cursor/plugins`. See [`LICENSE`](/LICENSE).
