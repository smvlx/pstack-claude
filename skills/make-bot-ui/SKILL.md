---
name: Make Bot UI
description: >-
  Unsupported on Claude Code. Upstream built a custom UI that wakes a bot
  over a webhook routine. Read only to learn why it does not apply here.
disable-model-invocation: true
---
# How to make a bot UI (unsupported on Claude Code)

Upstream, this skill built a page whose buttons POST JSON to a webhook routine, and the routine woke a bot agent with that JSON. It depends on pieces of the upstream editor that Claude Code does not have:

- webhook routines created with `update_state`, with a sender key shown on the routine's panel,
- the `SendToUser` secret-request card that stores the key without the agent seeing it,
- a `[routine]` wake turn carrying a `<webhook_event>` block.

Claude Code has no webhook-triggered agent wake, so none of the steps can run. Tell the user that and stop.

The nearest thing is the `schedule` skill: scheduled routines that run on a cron schedule, or once at a set time. A UI cannot wake those on demand. If the user needs a button that starts work now, they can run a command or prompt Claude Code directly instead.
