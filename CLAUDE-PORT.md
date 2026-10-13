# pstack on Claude Code: the port contract

pstack was written for Cursor. This file maps it onto Claude Code. **Where this
file and any bundled skill or playbook disagree, this file wins.** The user's
own `~/.claude/CLAUDE.md` and the current repo's `CLAUDE.md` win over both.

A pointer here loses to a concrete step in a playbook, because a reader follows
the step. So every Cursor-only step in the bundle was rewritten in place, and
`scripts/check-port.mjs` fails if a Cursor dispatch token comes back. Run it
after editing anything in the bundle:

```sh
node ~/.claude/pstack/scripts/check-port.mjs
```

Upstream: `cursor/plugins` `pstack/`. `UPSTREAM-VERSION` records the sha and
version the port is based on. `~/.claude/pstack` is a local git repo: branch
`upstream` holds vanilla snapshots, `main` is the port, so
`git -C ~/.claude/pstack diff upstream main` shows the whole port. Updates
arrive through a weekly scheduled task and land on a review branch; see
`UPDATING.md`.

## 1. Where things live

- Entry point: `~/.claude/skills/poteto-mode/SKILL.md` (`/poteto-mode`), installed
  from `port/entry/` by `scripts/install.sh`. Edit the repo copy, not the live one.
- The mode: `~/.claude/pstack/skills/poteto-mode/SKILL.md`.
- A playbook `playbooks/x.md` is `~/.claude/pstack/skills/poteto-mode/playbooks/x.md`.
- Any bundled skill **name** (`how`, `why`, `swarm`, `principle-x`, ...) is
  `~/.claude/pstack/skills/<name>/SKILL.md`. These are **not** registered as
  Claude skills. Read the file instead of calling the Skill tool. A user typing
  `/how` or `/interrogate` outside poteto mode gets nothing; they say "run the
  how skill" inside poteto mode instead.
- Agents: `~/.claude/agents/poteto-agent.md` and `comment-sicko.md`, installed from
  `port/agents/`.
- Model roles: `~/.claude/pstack/models.md` (section 3).
- `docs/guide/`, `automations/`, `README.md` and `agents/` are kept as upstream reference and still describe Cursor. Don't follow their install or setup steps.

## 2. Subagents

- Cursor's `Task` tool is the **Agent** tool. Parameters map as follows.
  - `subagent_type: "poteto-agent"` stays. It is installed.
  - A read-only helper uses `subagent_type: "Explore"` for searches, or
    `"general-purpose"` with an explicit "do not edit files" line in the prompt.
    Claude Code has no `readonly` flag.
  - Cursor cloud agents and `environment: "cloud"` become a local subagent with
    `isolation: "worktree"` and `run_in_background: true`. Never use
    `isolation: "remote"`.
  - `is_background: true` is `run_in_background: true`.
  - Continue a running agent with **SendMessage** to its name or ID.
- **Every agent that writes files gets `isolation: "worktree"`.** Two writers
  never share a checkout. One exception: `comment-sicko` (the **no-comments** skill)
  edits uncommitted changes in place, so it runs in the current checkout, alone,
  with no other writer active there. Never `git stash` across agents; the stash is global.
- Subagents cannot spawn subagents in every configuration. If a delegate's
  Agent call fails, it does the lane itself sequentially and says so.

## 3. Models

`~/.claude/pstack/models.md` holds one line per role, the same role names
upstream uses. Values:

- `inherit`: omit `model` on the Agent call. The role runs on the session model.
- `opus`, `sonnet`, `haiku`, `fable`: pass that as `model`.
- `codex`: a **different model family**, run through the Codex CLI. Only valid
  for roles that do not write files (reviewers, judges, explorers,
  investigators). Run it from Bash, read-only:

  ```sh
  codex exec -s read-only --skip-git-repo-check --ephemeral -C <repo> \
    -o <scratch>/codex-<label>.md "<the filled prompt>"
  ```

  Read the output file. If `codex` is missing or fails, run that slot on
  `inherit` and say in the reply that the review was same-family.

A skill that says "a different model family" means a `codex` slot. A second
Claude agent is a second opinion from the same family, which is weaker
evidence. Say so rather than implying independence you did not get.

## 4. Tools and terms

| Upstream says | On Claude Code |
|---|---|
| `AskQuestion` | `AskUserQuestion` |
| Cursor's `create-skill` | `superpowers:writing-skills`, or `skill-creator` |
| `deslop` (cursor-team-kit) | the `simplify` skill on the diff |
| `control-ui` | the built-in browser tools (`mcp__Claude_Browser__*`, `preview_start`), or the `run` skill |
| `control-cli` | drive the CLI from Bash, or the `run` skill |
| Cursor's built-in babysit skill | does not exist; the Babysit playbook is the only one |
| Bugbot / agentic security review | whatever review bots the repo runs (Copilot, Claude review, CodeRabbit). Same skeptical triage. |
| `~/.cursor/rules/*.mdc` | `~/.claude/CLAUDE.md` or the repo's `CLAUDE.md` |
| `.cursor/skills/<name>/SKILL.md` | `.claude/skills/<name>/SKILL.md` |
| `agent-transcripts/` | `~/.claude/projects/<slug>/<session-id>.jsonl`, where `<slug>` is the absolute workspace path with every `/` and `.` replaced by `-` |
| Origin CLI, Graphite, `gt` | `gh` and plain git. A stack is a chain of branches, each PR's `--base` is the branch below it. Restack with `git rebase --update-refs`. |
| `/loop` | `/loop` exists in Claude Code. For a PR, prefer `gh pr checks <n> --watch` or the desktop app's PR monitor. |
| Cursor automations, `automations/benny`, `make-bot-ui` | not supported. Use the `schedule` skill for cron-style cloud runs. |
| a Cursor restart | a Claude Code restart or `/clear` |

## 5. Merging and other irreversible actions

- **No agent merges without an explicit merge instruction from the user in this
  session** ("merge it", "land the stack", "I want everything merged by
  morning"). Without one, every path that upstream ends in a merge ends at
  **merge-ready**, reported with links. Never enable auto-merge unless asked.
- Always pause (on top of the mode's own list): force-push to a shared branch,
  deploys, production config or variables, data deletion, messages to people,
  making a repo public, and anything outside the current repository.

## 6. Safety checks and your own rules

The user's `~/.claude/CLAUDE.md` and the current repo's `CLAUDE.md` apply inside
every playbook and win over this contract. Personal rules, such as progress
files, reply formats or design guides, belong there. Every playbook also keeps
these checks:

- Before any commit, push, repo creation or PR, run `git config user.email`
  and `gh api user --jq .login`, and confirm both are the identity the user
  means to use for this repo. Stop if either is wrong.
- Before any commit, review the staged diff for secrets, keys, tokens and
  `.env` files.
- New repos are private. Making a repo public needs the user's go-ahead.
