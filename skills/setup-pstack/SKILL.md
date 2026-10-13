---
name: setup-pstack
description: Configure which models pstack uses per role. Writes `~/.claude/pstack/models.md`, which every pstack skill reads in place of its defaults. Use for /setup-pstack, "configure pstack models", or changing pstack's model choices.
---

# Setup pstack

Write `~/.claude/pstack/models.md`, the file that sets pstack's model per role. Every pstack skill reads its role line there when it spawns a subagent. See `~/.claude/pstack/CLAUDE-PORT.md` section 3.

## Steps

### 1. Detect available values

The valid values are `inherit`, `opus`, `sonnet`, `haiku`, `fable`, and `codex`. `inherit` omits `model` on the Agent call, so the role runs on the session model. `opus`, `sonnet`, `haiku` and `fable` go in the Agent `model` parameter. `codex` runs a role through the Codex CLI as a different model family. Offer `codex` only if `command -v codex` succeeds, and only for roles that write no files: `how explorer`, `how explainer`, `why investigators`, `why synthesizer`, `reflect tooling`, `reflect judgment, divergent, synthesizer`, `arena cross-judge pool`, `interrogate reviewers`, and `swarm workers` when the swarm only verifies. Reasoning effort is a session setting in Claude Code, not part of the value, so there is no budget to pick.

### 2. Load current state

The default role-to-model mapping is the shape shown in step 5 below. If `~/.claude/pstack/models.md` already exists, read it and treat its role values as the current choices. Otherwise start from those defaults. A line whose role is not in step 5, such as `how critics`, is from a retired role. Drop it. A value outside step 1's list falls back to `inherit`; list it as needing a choice.

### 3. Show the roles and confirm

Show every role with its value, marking any value that needs a choice. Also list each line step 2 dropped. Ask whether to accept as-is or change specific roles, offering the values from step 1 as the options. Use `AskUserQuestion` rather than free text. For panel roles (arena runners, architect runners, interrogate reviewers) the value is a list, and one subagent runs per entry, so the list length sets the count. `arena cross-judge pool` is also a list, but Arena selects one value from it, preferring `codex` for a different family. `swarm workers` is the default model for every worker unless a race or comparison assigns another model per arm.

### 4. Validate

Every value written must be in step 1's list. `codex` must not appear on a writer role (the code playbooks, `fast mechanical edits`, `arena runners`, `architect runners`), and must not appear anywhere if `command -v codex` failed. If a choice breaks either rule, stop and ask again.

### 5. Write the file

Write `~/.claude/pstack/models.md`: keep the comment header, then one line per role, using the same labels poteto-mode uses. Overwrite the whole file so re-runs stay idempotent. Shape, with the defaults:

```
# pstack model configuration. One line per role. Delete a line to fall back to the skill default.
# Values: inherit (omit Agent `model`, run on the session model), opus, sonnet, haiku, fable,
# or codex (a different model family via the Codex CLI, read-only roles only). See CLAUDE-PORT.md section 3.
# Panel roles take a comma-separated list; one subagent runs per entry.
feature, refactoring: inherit
bug-fix: inherit
perf-issue: inherit
hillclimb: inherit
judgment and prose: inherit
hardest tasks: inherit
fast mechanical edits: sonnet
how explorer: sonnet
how explainer: inherit
why investigators: sonnet
why synthesizer: inherit
reflect tooling: sonnet
reflect judgment, divergent, synthesizer: inherit
arena runners: inherit, sonnet
arena cross-judge pool: inherit, codex
swarm workers: sonnet
architect runners: inherit, sonnet
interrogate reviewers: inherit, codex
```

### 6. Confirm

Tell the user the file was written and that the next pstack skill run reads it. Re-running this skill updates it.

### 7. Offer a verification skill (optional)

Check whether the project has a way to drive the real app for proof (a `verify-*` skill, or an existing harness). If not, offer once: "want a project-local verification skill, so agents can drive the app the way a user does and prove changes work? I can generate one with the create-verification-skill skill." On yes, read and follow `~/.claude/pstack/skills/create-verification-skill/SKILL.md`. On no, move on without pushing.
