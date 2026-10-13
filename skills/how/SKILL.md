---
name: how
description: "Use for \"how does X work\", code walkthroughs before changing something, and placement / ownership / layering questions (\"where should this live\", \"which package owns this\", \"is this the right layer\"). Explains subsystem architecture, runtime flow, onboarding mental models. Use why for motivation."
disable-model-invocation: true
---

# How

Explore the codebase to answer "how does X work?" questions. Produce architectural explanations at the level of a senior engineer onboarding onto a subsystem, enough to build a working mental model, not so much that it reads like annotated source code.

Spawn every subagent with the Agent tool. Explorers use `subagent_type: "Explore"`; the explainer uses `subagent_type: "general-purpose"` with "Do not edit files." in its prompt. Explorers use the `how explorer` line in `~/.claude/pstack/models.md` (default `sonnet`), and every explainer uses the `how explainer` line (default `inherit`). Omit `model` for `inherit`, and pass `opus`, `sonnet`, `haiku` or `fable` as `model`. A `codex` entry runs that same filled prompt through the Codex CLI instead of the Agent tool, read-only, per `CLAUDE-PORT.md` section 3 (Bash with `run_in_background: true`, alongside the Agent calls); if codex fails, rerun that slot on `inherit` and say so. Use the default if the file or the line is missing. Any other value falls back to `inherit`; say so.

## 1. Assess complexity

If the scope is ambiguous, state your interpretation and explore. The user can redirect.

- **Simple** (a single module, a small utility, a narrow question such as "how does function X work"): no explorers. Spawn one explainer that explores and explains in one pass, built from `references/explainer-prompt.md` without the explorer-findings section. Go to step 4.
- **Complex** (a subsystem spanning multiple files or services, a cross-cutting feature, a full architectural overview): go to step 2.

When in doubt, take the simple path.

## 2. Explore (complex only)

Decompose the question into 2 to 4 angles, each a distinct slice of the subsystem. Spawn all explorers in a single message, each with `references/explorer-prompt.md` and its angle filled in.

## 3. Synthesize (complex only)

Once all explorers have returned, spawn one explainer with `references/explainer-prompt.md` and every explorer's findings filled in.

## 4. Present

Present the explainer's output. Light edits for clarity or context from the conversation are fine. Do not substantially rewrite it.

## Output format

The explanation uses the sections defined in `references/explainer-prompt.md`, dropping any that do not apply: Overview, Key Concepts, How It Works, Where Things Live, Gotchas.
