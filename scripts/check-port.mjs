#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync, statSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, relative } from "node:path";

const root = join(import.meta.dirname, "..");
const skipDirs = new Set([".git", "node_modules", "docs", "automations"]);
const skipUpstreamAgents = join(root, "agents");
const skipFiles = new Set(["CLAUDE-PORT.md", "README.md", "UPDATING.md", "check-port.mjs", "plugin.json", "LICENSE"]);

const banned = [
  [/\bTask tool\b|\bTask\(|`Task` call/, "Cursor Task tool (use the Agent tool)"],
  [/generalPurpose/, "generalPurpose (use general-purpose)"],
  [/grok-\d/, "Grok model slug"],
  [/claude-opus-\d-\d-(xhigh|max|high|medium|low)/, "Cursor Claude slug"],
  [/environment:\s*"?cloud/, "cloud environment (use isolation: \"worktree\")"],
  [/cloud[- ]agent/i, "cloud agent"],
  [/\bgt (log|info|sync|submit|metadata|tracking|restack|create|modify|ran|knows|arguments|track)\b|Graphite/, "Graphite"],
  [/\borigin (pr|stack)\b|Origin CLI/, "Origin CLI"],
  [/pstack-models\.mdc|\.cursor\//, "Cursor rule or path"],
  [/\bAskQuestion\b/, "AskQuestion (use AskUserQuestion)"],
  [/readonly: true/, "readonly flag"],
  [/cursor-team-kit|control-ui|control-cli|\bdeslop\b/, "cursor-team-kit skill"],
  [/agent-transcripts/, "Cursor transcript dir"],
  [/think (carefully|hard)|step by step/i, "banned prompt phrase"],
];

function* walk(dir) {
  for (const name of readdirSync(dir)) {
    const p = join(dir, name);
    if (statSync(p).isDirectory()) { if (!skipDirs.has(name) && p !== skipUpstreamAgents) yield* walk(p); }
    else if (!skipFiles.has(name) && /\.(md|mjs|ts|sh|yaml|json)$/.test(name)) yield p;
  }
}

let failures = 0, warnings = 0;
for (const file of walk(root)) {
  readFileSync(file, "utf8").split("\n").forEach((line, i) => {
    const where = `${relative(root, file)}:${i + 1}`;
    for (const [re, label] of banned) if (re.test(line)) { failures++; console.log(`FAIL ${where}  ${label}: ${line.trim().slice(0, 140)}`); }
    if (/\bCursor\b/.test(line)) { warnings++; console.log(`warn ${where}  mentions Cursor: ${line.trim().slice(0, 140)}`); }
  });
}

const skillCount = (dir) => readdirSync(dir).filter((name) => existsSync(join(dir, name, "SKILL.md"))).length;
const tmp = mkdtempSync(join(tmpdir(), "pstack-plugin-"));
try {
  const build = spawnSync(process.execPath, [join(root, "scripts", "build-plugin.mjs")], { encoding: "utf8", env: { ...process.env, PSTACK: root, CLAUDE_DIR: tmp } });
  const want = skillCount(join(root, "skills"));
  const got = build.status === 0 ? skillCount(join(tmp, "local-marketplace", "plugins", "pstack", "skills")) : 0;
  if (build.status !== 0) { failures++; console.log(`FAIL scripts/build-plugin.mjs exited ${build.status}: ${build.stderr.trim()}`); }
  else if (got !== want) { failures++; console.log(`FAIL scripts/build-plugin.mjs built ${got} wrappers for ${want} skills`); }
} finally {
  rmSync(tmp, { recursive: true, force: true });
}
console.log(`\n${failures} failure(s), ${warnings} Cursor mention(s) to eyeball.`);
process.exit(failures ? 1 : 0);
