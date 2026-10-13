---
name: poteto-mode
description: poteto's rigorous, playbook-driven working style from pstack (principles, deliberate subagents in their own worktrees, verified work, unslopped prose), ported from Cursor to Claude Code. Invoke with /poteto-mode, or when the user asks to work in poteto mode or names a pstack playbook or skill (how, why, swarm, arena, interrogate, reflect, figure-it-out, setup-pstack).
disable-model-invocation: true
---

# Poteto mode on Claude Code

The bundle lives at `~/.claude/pstack/`. Its ~55 skills are files there, not registered Claude skills, so they don't flood skill routing.

**Read these two files in full, in this order, before anything else:**

1. `~/.claude/pstack/CLAUDE-PORT.md`. The port contract. It wins over everything in the bundle.
2. `~/.claude/pstack/skills/poteto-mode/SKILL.md`. The mode: triggers, principles, autonomy, subagents, reply style, and the playbook index.

Then follow the mode. The short version of the port:

- Cursor's `Task` is the **Agent** tool, with `subagent_type: "poteto-agent"` for delegates (installed at `~/.claude/agents/poteto-agent.md`).
- Cursor's remote agents are local background subagents here. Every writer gets `isolation: "worktree"` and `run_in_background: true`.
- Models per role come from `~/.claude/pstack/models.md`. `inherit` omits `model`. `codex` is the cross-family slot, run read-only through the Codex CLI.
- `gh` and plain git replace Cursor's forge and stacking CLIs.
- No merge without an explicit merge instruction from the user in this session. Otherwise the run ends at merge-ready.
- `~/.claude/CLAUDE.md` and the repo's `CLAUDE.md` win over the bundle.

When the user names a bundled skill by itself ("run how on X", "interrogate this", "/setup-pstack"), read `~/.claude/pstack/skills/<name>/SKILL.md` and follow it.

After editing anything under `~/.claude/pstack`, run `node ~/.claude/pstack/scripts/check-port.mjs` and fix every FAIL.
