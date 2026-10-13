---
name: poteto-help
description: Guides users through pstack setup, /poteto-mode, and picking the skill, playbook, or principle for a task. Type /poteto-help with a question.
disable-model-invocation: true
---

# Poteto help

Answer the user's question about pstack, hand them a prompt they can send, and link the file the answer came from. For a help question, don't start the work. The user asked how, and a pstack run spends real tokens, so let them send the prompt.

A message that asks for work, such as "use pstack to fix this bug", is not a help question. Read [`poteto-mode`](../poteto-mode/SKILL.md), do the work under it, and mention once that starting each task with `/poteto-mode` keeps it on.

This file maps questions to the skills and guide pages that hold the answers. Those files own the details. Read the file you route to before you quote it, and trust it when it disagrees with this map. The links here are relative to `~/.claude/pstack/skills/poteto-help/`. Give the user the absolute local path under `~/.claude/pstack/`, which they can open.

On Claude Code, only `/poteto-mode` is a slash command. The bundled skills (`how`, `why`, `swarm`, `setup-pstack`, and the rest) are files under `~/.claude/pstack/skills/`, not registered skills. Where this file or its references write `/how`, the user types `/poteto-mode run the how skill on <X>`, or names the skill inside a chat that already runs the mode. Word every example prompt that way.

## Find out what they need

Infer the need from the message and the conversation. A named situation, such as "which skill reviews a PR?", goes straight to its section. If the need is still unclear, ask one multiple-choice question with these options, then answer only the section they pick:

- Get set up
- Start a task with `/poteto-mode`
- Pick a skill for a situation
- Fix a run that went wrong
- Make pstack my own

Check the state that changes the answer, and mention it only when it does:

- `~/.claude/pstack/models.md` holds the model per role. Lines still at the defaults it ships with (mostly `inherit`, `sonnet` for bulk roles, `codex` for the cross-family reviewer and judge) mean the user hasn't run the setup-pstack skill.
- No `verify-*` skill or other app harness in the project means agents have no scripted way to drive the app. Mention the create-verification-skill skill when the question is about proving a change works.

When `models.md` is still at its defaults and it matters, ask whether the user wants to pick a model for each role now. It matters when the user is new, the question is about setup or cost, or the answer depends on which models run. Ask at most once per chat. If the need is also unclear, ask both questions together. Offer two choices:

- Now: give them `/poteto-mode run the setup-pstack skill` to type, and answer their question too.
- Later: answer their question, and add one line saying every role keeps its default model until they run the setup-pstack skill.

## Get set up

1. The install is two places. The entry skill is `~/.claude/skills/poteto-mode/SKILL.md`, which registers `/poteto-mode`. The bundle is `~/.claude/pstack/`: the skills, playbooks, `models.md`, and `CLAUDE-PORT.md`, the contract that maps upstream's steps onto Claude Code. The `poteto-agent` and `comment-sicko` agents live in `~/.claude/agents/`.
2. Optionally run `/poteto-mode run the setup-pstack skill`. It maps a model to each role and rewrites `~/.claude/pstack/models.md`. Editing that file by hand works too. The next pstack run reads it.
3. Start a real task with `/poteto-mode`, a goal, and a check that can pass or fail.

Nothing runs until the user invokes `/poteto-mode`. The [README](../../README.md) and [guide page 1](../../docs/guide/01-setup.md) describe the upstream install; [`CLAUDE-PORT.md`](../../CLAUDE-PORT.md) says what differs here. Offer to word their first prompt with them, per [`references/prompting.md`](references/prompting.md).

If cost is the worry, say where the tokens go and how to spend fewer. pstack spends extra tokens on subagents and review panels. Rerun the setup-pstack skill and pick cheaper models, such as `sonnet` or `haiku` for bulk roles. A role set to `inherit` runs on the session model, so a cheaper session model makes it cheaper. A `codex` slot spends Codex quota, not Claude tokens. A shorter panel list runs fewer subagents, one for each entry. Save `/poteto-mode` for work that needs rigor.

pstack was built for another editor. This copy is ported to Claude Code: subagents are Agent tool calls, writers get their own worktree, and the cross-family slot is the Codex CLI. Upstream docs that mention Custom Modes, remote workers, or other model slugs describe the original; `CLAUDE-PORT.md` wins where they disagree.

## Start a task with `/poteto-mode`

`/poteto-mode` matches the task to a playbook, copies the playbook's steps into the todo list, and runs the other skills as the steps need them. A step it skips stays in the list as `skip: <reason>`. A good prompt states the goal and how to tell it's done. It doesn't list skills, because a hand-written sequence tends to drop or reorder steps the playbook would keep. Read [`references/prompting.md`](references/prompting.md) before you help word one. [Guide page 2](../../docs/guide/02-poteto-mode.md) has examples.

`/poteto-mode` loads into the conversation once. It fades as the chat moves on and as context is compacted. Start each new task with `/poteto-mode`, or invoke it again when a long chat drifts. Claude Code has no Custom Modes. Mid-chat, "new task" makes the mode match a fresh playbook. `/poteto-mode` already uses `poteto-agent` for the subagents its playbook steps spawn. To get the same style from a subagent of your own, spawn it with `subagent_type: "poteto-agent"`.

## Pick a skill

The default answer is `/poteto-mode`, which runs most of the others when its steps need them. Name a skill directly when the user wants more or less of something than the playbook gives. Read the skill before you recommend it, and give one example prompt.

| The user wants to | Skill |
|---|---|
| Do any non-trivial task with rigor | [`/poteto-mode`](../poteto-mode/SKILL.md) |
| Know how code works now, or where new code should live | [`/how`](../how/SKILL.md) |
| Know why code is shaped this way, or where a number came from | [`/why`](../why/SKILL.md) |
| Understand a change or subsystem, explained plainly | [`/teach`](../teach/SKILL.md) |
| Catch up on their own recent work on a topic | [`/recall`](../recall/SKILL.md) |
| Catch up on everything in this chat since their last message, with enough context to decide each action item | [`/ketchup`](../ketchup/SKILL.md) |
| Know what a small diff could break outside itself | [`/blast-radius`](../blast-radius/SKILL.md) |
| Settle types and module shape before code that crosses a function boundary | [`/architect`](../architect/SKILL.md) |
| Get several attempts at one brief, merged into the best one | [`/arena`](../arena/SKILL.md) |
| Run parallel checks over slices, or race workers, as background agents | [`/swarm`](../swarm/SKILL.md) |
| Have different models review a diff and try to break it | [`/interrogate`](../interrogate/SKILL.md) |
| Fix a bug test-first when a cheap local test exists | [`/tdd`](../tdd/SKILL.md) |
| Apply TypeScript rules to `.ts` or `.tsx` work | [`/typescript-best-practices`](../typescript-best-practices/SKILL.md) |
| Strip comments before review, using a reviewer that didn't write them | [`/no-comments`](../no-comments/SKILL.md) |
| Clean AI tells out of prose | [`/unslop`](../unslop/SKILL.md) |
| Write docs, an RFC, a README, a PR description, or a commit message to a standard | [`/technical-writing`](../technical-writing/SKILL.md) |
| Hear the last reply again in plain words | [`/bro`](../bro/SKILL.md) |
| Give agents a scripted way to drive the app and prove behavior | [`/create-verification-skill`](../create-verification-skill/SKILL.md) |
| Bring a verification skill and its feature map back in line with the app | [`/maintain-verification-skill`](../maintain-verification-skill/SKILL.md) |
| Vet a performance number before reporting or acting on it | [`/benchmark-checklist`](../benchmark-checklist/SKILL.md) |
| Run a large or cross-cutting change, or one to review after stepping away | [`/figure-it-out`](../figure-it-out/SKILL.md) |
| Keep a decision log during a run, and review it afterward | [`/show-me-your-work`](../show-me-your-work/SKILL.md) |
| Pick a model for each role | [`/setup-pstack`](../setup-pstack/SKILL.md) |
| Turn their own working habits into a personal mode skill | [`/automate-me`](../automate-me/SKILL.md) |
| Turn what a finished task taught into skill edits | [`/reflect`](../reflect/SKILL.md) |
| Stop agents from repeating the same mistakes in this repo | [`/correct`](../correct/SKILL.md) |
| Find their way around pstack | `/poteto-help` |

If a skill directory next to this one is missing from the table, read its frontmatter and route by its description. The `principle-*` directories are covered under principles below.

Close calls:

- `/how` explains what the code does. `/why` explains the reasons. `/teach` runs one or both and explains the result plainly.
- `/arena` gives every worker the same brief and merges the best parts. `/swarm` splits work into slices or a race and returns one report.
- `/architect` implements right after it settles the design. Add "with checkpoint" to review the design before it writes code.
- `/interrogate` reviews the diff. `/blast-radius` looks for breakage outside the diff and proves the one fact that makes the change safe.
- `/recall` rebuilds context across recent chats. `/ketchup` covers only this chat since the user's last message. Resuming one specific chat or branch is the Session pickup playbook.
- `/figure-it-out` designs one rigorous run. The Orchestrate playbook runs a program that spans days and many PRs. The Autonomous run playbook drives one task to a finish condition.

Not in pstack, or not ported:

- Upstream's cleanup and app-driving helpers map to the `simplify` skill, Bash or the `run` skill, and the built-in browser tools here. `CLAUDE-PORT.md` section 4 has the table.
- `/loop` is a Claude Code built-in. Skill authoring uses `superpowers:writing-skills` or `skill-creator`.
- `make-bot-ui` and upstream automations are not supported. The `schedule` skill covers cron-style cloud runs.
- pstack has no `/orchestrate` skill. Orchestrate is a `/poteto-mode` playbook. If the slash menu shows `/orchestrate`, another plugin provides it.

## Playbooks and principles

Playbooks are step lists inside `/poteto-mode`, not skills, so they have no slash command. Inside `/poteto-mode`, describing the task picks one, and these phrases name one directly:

- "babysit this pr" or "check on pr 123" runs Babysit. It drives the PR to merge-ready and stops there. It doesn't merge unless the user asks to merge, land, or ship.
- "land the stack" runs Shipping.
- "take over this branch" runs Session pickup.
- "pause safely" runs Pause safely.
- "full autopilot on this queue" runs Autopilot-full. "stack them, don't ship" runs Autopilot-stack.
- "run the eval playbook" runs Eval.

Without `/poteto-mode`, a phrase such as "babysit this pr" runs no playbook at all. The Playbooks section of [`poteto-mode`](../poteto-mode/SKILL.md) lists every playbook and when it applies. [Guide page 6](../../docs/guide/06-verify-and-ship.md) covers opening, babysitting, and landing a PR.

pstack has no planning skill. Claude Code's plan mode works alongside it. For work that spans phases or stacked PRs, asking `/poteto-mode` for a plan runs the [Multi-phase plan playbook](../poteto-mode/playbooks/multi-phase-plan.md), which writes the plan and doesn't implement it. For a design question, the Prototype playbook or `/architect` settles it in code first.

Principles are one-rule skills that `/poteto-mode` reads and cites in its replies. The user rarely invokes one. They steer with the names instead, as in "apply prove it works. show me the real output." Asking for one by name ("read principle-prove-it-works") loads it on demand. [Guide page 8](../../docs/guide/08-principles.md) lists them.

## Fix a run that went wrong

| Symptom | Fix |
|---|---|
| The mode stopped applying after a few turns | It loaded once and faded. Start each task with `/poteto-mode`, or invoke it again. |
| A question got treated as the next step of the last task | Say "new task", or say the turn doesn't need the mode. |
| A new model choice had no effect | Check the role's line in `~/.claude/pstack/models.md`. A value outside `inherit`, `opus`, `sonnet`, `haiku`, `fable`, `codex` falls back to `inherit`, and `codex` falls back to `inherit` on writer roles or when the CLI fails. |
| Runs cost more than expected | See the cost paragraph under Get set up. |
| A skill didn't load on its own | Bundled skills aren't registered with Claude Code. They load when `/poteto-mode` runs them or when the user names one inside the mode, and the mode doesn't run every skill. |
| Parallel agents overwrote each other | Every writing agent needs `isolation: "worktree"` on its Agent call, so each gets its own checkout. |
| An overnight run moved but finished nothing | `/loop` needs a check that can pass or fail, not a duration. See [guide page 7](../../docs/guide/07-overnight.md). |
| The reply claims success from a green build | Ask for the real command, flow, stored value, or profile. That's the prove-it-works principle. |

For a run that drifts, [`references/prompting.md`](references/prompting.md) has one-line steers. [Guide page 10](../../docs/guide/10-recipes-and-pitfalls.md) has more pitfalls and the recipes worth copying.

## Make pstack my own

- [`/automate-me`](../automate-me/SKILL.md) drafts a personal mode skill from the user's own history, to use alongside `/poteto-mode`.
- [`/reflect`](../reflect/SKILL.md) after a session turns its lessons into skill edits the user approves.
- `/poteto-mode write a skill for <workflow>` runs the authoring playbook. The eval playbook tests a skill change blind.
- Fix a misbehaving skill in its own PR, not inside the feature work where it went wrong.

[Guide page 9](../../docs/guide/09-make-it-yours.md) covers each of these.

## Reply

Lead with the answer. Give at most one example prompt in a code block, adapted from [`references/recipes.md`](references/recipes.md) when one fits, then the link to that file. Keep it short unless the user asked for the whole map.
