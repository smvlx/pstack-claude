---
name: reflect
description: Spawn three parallel review subagents over the active transcript, surface learnings, and route each to a concrete edit on an existing skill. Use when the user says reflect.
disable-model-invocation: true
---

# Reflect

Mine the current conversation for durable learnings, then route them into skill edits.

Invoke when the user says "reflect" or "/reflect". Skip when the conversation is trivial, off-topic, or already covered by an existing skill the parent followed correctly. One-offs are not learnings.

## 1. Locate the active transcript

Before fanning out, find this conversation's transcript. Claude Code writes it to `~/.claude/projects/<slug>/<session-id>.jsonl`, where `<slug>` is the absolute workspace path with every `/` and `.` replaced by `-`. Look only in this workspace's directory. Do not glob across `~/.claude/projects/*/`. That crosses workspace boundaries and reads private chats from unrelated projects.

```bash
ls -t ~/.claude/projects/<slug>/*.jsonl 2>/dev/null | head -10
```

The newest file is usually the current session. Subagent transcripts live under `<session-id>/subagents/`; skip them. To confirm, read the first lines with `"type":"user"` and take the file whose `message.content` contains the conversation's opening user prompt. If none matches, pass a tight digest of the session instead.

## 2. Spawn three reviewers in parallel

One message, three Agent calls, `subagent_type: "general-purpose"`, with "Do not edit files." added to each prompt. Reviewers need MCP access to look up the tickets, chat threads, and observability traces the transcript references, and general-purpose keeps it.

Each reviewer and the synthesizer name a role line in `~/.claude/pstack/models.md` and a default. Omit `model` for `inherit`, and pass `opus`, `sonnet`, `haiku` or `fable` as `model`. Use the default if the file or the line is missing. Any other value falls back to `inherit`; say so. A `codex` entry runs that reviewer's filled prompt through the Codex CLI instead, read-only, per `CLAUDE-PORT.md` section 3 (Bash with `run_in_background: true`, alongside the Agent calls). Codex can read the transcript file but has no MCP access; say so in the summary. If codex fails, rerun that slot on `inherit` and say so.

| Lens | Role line | Default `model` | Prompt template |
|---|---|---|---|
| Judgment | `reflect judgment, divergent, synthesizer` | `inherit` | `references/judgment-reviewer.md` |
| Tooling | `reflect tooling` | `sonnet` | `references/tooling-reviewer.md` |
| Divergent | `reflect judgment, divergent, synthesizer` | `inherit` | `references/divergent-reviewer.md` |

Pass each template verbatim, substituting the transcript path or digest where marked. Reviewers return findings in the Agent response body (or the codex output file).

## 3. Synthesize

One Agent call, `subagent_type: "general-purpose"`, `model` from the `reflect judgment, divergent, synthesizer` line (default `inherit`), with "Do not edit files." in the prompt. It spot-verifies citations through MCP, so a `codex` value on this line runs on `inherit` instead; say so. Pass `references/synthesizer.md` verbatim, with each reviewer's full output inlined where marked. It returns an Accepted / Rejected / Backlog list.

## 4. Structural enforcement check

Move any Accepted item that a lint rule, script, metadata flag, or runtime check would enforce more reliably to Backlog. See the **encode-lessons-in-structure** principle skill.

## 5. Apply

Present the synthesizer's full Accepted / Rejected / Backlog output and wait for explicit approval before applying any Accepted edit. The user picks the subset and may redirect routings. Skill changes affect every future agent in the org. Do not auto-apply.

File each Backlog item to your team's devex or backlog tracker without waiting. Only the Accepted list waits for approval.

Follow each approved row's Routing exactly:

- Trivial existing-skill edit (a one-line bullet, a tightened sentence, a stale fact corrected): the parent does it directly.
- Substantive existing-skill edit (a new section, a new pattern table, more than ~10 lines): hand to the `superpowers:writing-skills` skill (or `skill-creator`) and run its draft / test / iterate loop.
- `tune description: <skill path>` (the skill exists but didn't trigger when it should have): hand to `skill-creator` and run its description-optimization loop.
- `new skill via create-skill: <kebab-name>`: hand creation to `superpowers:writing-skills` or `skill-creator`. Do not invent the shape ad hoc.

If your environment ships a SKILL.md validator, run it on every touched skill before declaring done.

## 6. Summarize for the user

Short list, no preamble:

- Edits applied: `<skill path>`. What changed, one line each.
- New skills created: `<skill path>`. One line each (rare).
- Backlog filed to the devex tracker: `<issue title>` (`<tags>`). One line each.
- Dropped: one line per rejected finding + reason from the synthesizer.
