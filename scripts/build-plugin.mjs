#!/usr/bin/env node
import { existsSync, mkdirSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { homedir } from "node:os";
import { dirname, join, resolve, sep } from "node:path";

const home = homedir();
const pstack = resolve(process.env.PSTACK || join(import.meta.dirname, ".."));
const claudeDir = resolve(process.env.CLAUDE_DIR || join(home, ".claude"));
const mkt = join(claudeDir, "local-marketplace");
const pluginDir = join(mkt, "plugins", "pstack");
const shown = pstack.startsWith(home + sep) ? "~" + pstack.slice(home.length) : pstack;

function write(file, text) {
  mkdirSync(dirname(file), { recursive: true });
  writeFileSync(file, text);
}
const writeJson = (file, value) => write(file, JSON.stringify(value, null, 2) + "\n");

function readSkill(name) {
  const file = join(pstack, "skills", name, "SKILL.md");
  if (!existsSync(file)) return { error: `skills/${name} has no SKILL.md` };
  const lines = readFileSync(file, "utf8").split("\n");
  const end = lines.indexOf("---", 1);
  if (lines[0] !== "---" || end === -1) return { error: `skills/${name}/SKILL.md has no frontmatter` };
  return { name, frontmatter: lines.slice(1, end) };
}

function wrapper({ name, frontmatter }) {
  const i = frontmatter.findIndex((line) => line.startsWith("name:"));
  const fm = i === -1 ? [`name: ${name}`, ...frontmatter] : frontmatter.with(i, `name: ${name}`);
  const dir = `${shown}/skills/${name}`;
  const body = `Read \`${shown}/CLAUDE-PORT.md\` in full, then \`${dir}/SKILL.md\` in full, and follow that skill. The port contract wins where they disagree. Paths in the skill that are relative resolve against \`${dir}/\`.`;
  return ["---", ...fm, "---", "", body, ""].join("\n");
}

const skills = readdirSync(join(pstack, "skills"), { withFileTypes: true })
  .filter((d) => d.isDirectory())
  .map((d) => d.name)
  .sort()
  .map(readSkill);
const errors = skills.filter((s) => s.error);
for (const { error } of errors) console.error(`build-plugin: ${error}`);
if (errors.length) process.exit(1);

const upstream = JSON.parse(readFileSync(join(pstack, "plugin.json"), "utf8"));
const { version, description, author, homepage, repository, license } = upstream;
const manifest = { name: "pstack", version, description, author, homepage, repository, license };

rmSync(pluginDir, { recursive: true, force: true });
writeJson(join(pluginDir, ".claude-plugin", "plugin.json"), manifest);
for (const skill of skills) write(join(pluginDir, "skills", skill.name, "SKILL.md"), wrapper(skill));

const mktFile = join(mkt, ".claude-plugin", "marketplace.json");
const market = existsSync(mktFile)
  ? JSON.parse(readFileSync(mktFile, "utf8"))
  : { name: "local-plugins", description: "Personal plugins", owner: { name: "local" }, plugins: [] };
const entry = { name: "pstack", source: "./plugins/pstack", description, version };
const plugins = market.plugins ?? [];
const at = plugins.findIndex((p) => p.name === "pstack");
market.plugins = at === -1 ? [...plugins, entry] : plugins.with(at, entry);
writeJson(mktFile, market);

console.log(`built pstack ${version}: ${skills.length} skills -> ${pluginDir}`);
