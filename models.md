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
