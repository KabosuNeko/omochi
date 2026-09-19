# OpenCode Setup Prompt — Self-Updating Edition

> Created: 2026-08-01 · Updated: 2026-09-19 (verified on OpenCode 2.0 Native) ·
> OpenCode: 2.0+ · OS: CachyOS (Arch) · Shell: Fish
> Note: Every model ID in this prompt is a REFERENCE ONLY, valid at the time of
> writing. When running, the agent MUST discover live models (step 0) and
> substitute any ID that no longer exists.

```markdown
# OpenCode Personal Setup — Self-Updating Edition

## Invariant Rules (never violate)
1. NEVER hardcode model IDs. Every model must be discovered at runtime via:
   opencode models opencode-go --verbose  (add --refresh if the cache is stale).
2. If a model named in this prompt no longer exists in the live list, pick the
   closest replacement using the ROLE CRITERIA table below, and log
   "replaced X -> Y (not on Go anymore)" in the file you wrote.
3. Plugins always use @latest, never pin versions.
4. Every step must be idempotent (safe to re-run, never breaks existing config).
5. Never overwrite config blindly — always backup and review diffs first.
6. Never use temporary configs from /tmp as the final config.

## System
- OS: CachyOS (Arch Linux); Shell: Fish (use `set -gx` / `set -Ux`)
- Packages: pacman (yay/paru for AUR); preserve all existing configuration

## Step 0 — Refresh before setup
- opencode upgrade (if a new version exists)
- opencode models opencode-go --refresh --verbose  -> snapshot the current
  model list + prices/quota; this is the source for step 4.

## Steps
1. Inspect ~/.config/opencode; back up every file you will touch
   (opencode.jsonc, package.json, ~/.local/share/opencode/auth.json,
   ~/.omo/omo.jsonc if present, ~/.agents/skills if present) -> .bak-<date>.
2. Install bun if missing: sudo pacman -S bun
3. Write ~/.config/opencode/opencode.jsonc (fixed structure; models come from
   the step 4 discovery):
   - model: <main> · small_model: <worker>
   - agents: {"plan": {"model": "<planner>"}}
   - plugins: [["@plannotator/opencode@latest", {"workflow": "plan-agent", "planningAgents": ["plan"]}]]
     (plannotator runs on the plan agent. OpenCode 2.0 handles multi-agent,
     worktrees, and context compaction natively; no external OMO, worktree,
     or dcp plugins are required)
   - instructions (non-plugin shell rules, remote):
     ["https://raw.githubusercontent.com/JRedeker/opencode-shell-strategy/trunk/shell_strategy.md"]
     (teaches non-interactive command forms: -y/-n flags, sudo -n, ssh
     accept-new; no TTY/PTY in opencode so interactive commands hang)
   - mcp (minimal footprint; rely on native file/git/search tools):
     - context7-remote: remote https://mcp.context7.com/mcp (live SDK & library docs, zero local CPU/RAM overhead)
     - fetch: npx -y mcp-fetch-server   [TRAP: @modelcontextprotocol/
       server-fetch no longer exists on npm, and mcp-server-fetch is a
       SECURITY CANARY (honeypot) — never use it]
     (Avoid redundant local MCPs like filesystem, git-mcp, memory, or sequential-thinking — OpenCode 2.0 native tools and model thinking are strictly superior and consume fewer tokens)
   - NEVER hardcode API keys: use {env:VAR} or auth.json only
4. Assign models by role (pick from the live list; names in brackets are
    current-model references only). PRICING POLICY: prefer cheap opencode-go
    models with long context/output limits (deepseek flash 1M/384K, deepseek
    pro 1M/384K, qwen3.7-plus 1M). AVOID pricey tiers for
    routine work (kimi, full-size glm at ~$1+/$4+, and similar — they
    only earn their cost at specialized niches); cheap flash variants
    with long limits (e.g. glm-5.3-flash) are fair game. Every
    agent/category fallback chain MUST end with a free model (opencode/
    muse-spark-1.3-contributor-free) so the setup keeps working on zero balance.
    | Role | Selection criteria (priority order) | 2026 reference |
    |---|---|---|
    | Main coding (complex logic, architecture, heavy generation) | Cheapest fast reasoning on Go with long limits (prioritize deepseek-v4-flash for lowest cost & latency; fallback: deepseek-v4.1-flash, deepseek-v4-pro) | deepseek-v4-flash (fallback: deepseek-v4.1-flash, deepseek-v4-pro, qwen3.8-max) |
    | Worker (small_model: autocomplete, boilerplate, light tasks) | Cheapest free with the longest limits (1M ctx / 131K out). If the opencode provider (Zen) is authenticated, the FREE worker opencode/muse-spark-1.3-contributor-free is preferred — costs nothing | muse-spark-1.3-contributor-free (fallback: opencode-go/deepseek-v4-flash, qwen3.8-flash, glm-5.3-flash) |
    | Planner/Reviewer (deep reading, planning, code review) | Cheap code-capable on Go, long context (1M), vision is a plus | qwen3.7-plus (fallback: qwen3.8-max, deepseek-v4-flash, deepseek-v4-pro) |
   For EACH role: run `opencode models opencode-go` to verify the ID exists;
   if missing, pick the closest per criteria and log the substitution.
5. Native Multi-Agent Architecture (OpenCode 2.0 Native):
   OpenCode 2.0 includes native multi-agent support, native worktrees, and
   native context compaction. We do NOT install oh-my-openagent (OMO),
   opencode-worktree, or opencode-dcp — avoiding 40MB of bloat, brittle
   experimental hooks, and version breakages on OS updates.
6. Multi-Agent & Skill Specialization:
   - Primary coding agent uses <main> (cheapest fast reasoning on Go).
   - Background worker & title generator use <worker> (free muse-spark).
   - Plan agent uses <planner> (code-capable Qwen on Go).
    - All persona roles (code review, bug hunting, docs reading, frontend design,
      quickshell, test writing, refactoring, containerization, db architecture,
      api design, git workflow, security audit) are cleanly fulfilled by omochi's
      16 specialized skills under ~/.config/opencode/skills/ and ~/.agents/skills/.
 7. Optional free-tier fallback: run `opencode auth login` and select
    "OpenCode Zen" (free models; no payment needed). Required only if you
    want muse-spark-1.3-contributor-free / other opencode provider free models to work.
  8. Personal skills (13, at ~/.config/opencode/skills/<name>/SKILL.md):
    api-designer, bug-hunt, code-review, database-architect, docker-expert,
    docs-reader, frontend-design, git-workflow, grill-me, quickshell,
    refactor-human-code, security-audit, test-writer.
    Provisioning order (first source that works):
    a. cp -r ~/omochi/.agents/skills/* ~/.config/opencode/skills/
    b. git clone --depth 1 https://github.com/KabosuNeko/omochi <tmp>
       && copy .agents/skills/* from it (then delete <tmp>)
    c. write the 13 SKILL.md yourself from the descriptions in this repo
  9. Guardrail skills (3, opencode-native, shipped in this repo):
     bash-scripting, python-ai, linux-sysadmin -> ~/.agents/skills/
     Provisioning order (first source that works):
     a. cp -r ~/omochi/.agents/skills/{bash-scripting,python-ai,
        linux-sysadmin} ~/.agents/skills/
     b. copy from the omochi clone (8b)
     c. write the 3 SKILL.md yourself from the descriptions in this repo
    - Copy 4 templates (AGENTS, SPEC, ROADMAP, TASKS).md from
      ~/omochi/templates/project-docs/ (or the omochi clone 8b)
      -> ~/.config/opencode/templates/project-docs/
    - Write ~/.config/opencode/AGENTS.md: copy
      ~/omochi/templates/global-AGENTS.md (or from omochi
      clone) — global rules: change-focused, skip filler, run checks, stop
      before destructive actions.
10. Fish env var (if not set): set -gx OPENCODE_API_KEY "sk-..."
    then set -Ux OPENCODE_API_KEY "sk-..." (persistent; never store keys in
    config files)
11. rtk (token saver): single Rust binary that compresses bash tool output
    before the agent reads it.
    - Binary: installed by setup.sh to ~/.local/bin/rtk (NO pacman package —
      official installer; reinstall with: curl -fsSL
      https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh)
    - Plugin: write ~/.config/opencode/plugins/rtk.ts using OpenCode 2.0 V2 Plugin API:
      `export default { id: "rtk", async setup(ctx) { await ctx.tool.hook("execute.before", ...) } }`.
      Only the bash/shell tool is rewritten — built-in Read/Grep/Glob/LSP bypass it, so
      savings are smaller than on Claude Code.
    - Config: write ~/.config/rtk/config.toml:
        [hooks]
        exclude_commands = ["opencode"]
      (TRAP: never let rtk compress `opencode models --verbose` — model
      discovery needs raw output; excluded commands make `rtk rewrite`
      return "", and the plugin treats empty output as pass-through)
    - "No hook installed" from `rtk gain` refers to the Claude Code hook —
      ignore it, the opencode plugin is the integration here.
    - Degrades safely: plugin disables itself if rtk is missing from PATH;
      rewrite errors pass the command through unchanged. On command failure
      rtk saves full output to ~/.local/share/rtk/tee/*.log (tee mode).
    - Uninstall: rm -f ~/.config/opencode/plugins/rtk.ts && rm -f ~/.local/bin/rtk
12. Review the diff of EVERY changed file against its backup, highlighting
    the model configuration section.
13. Smoke tests:
    - opencode --version (expected: 2.0+) · opencode mcp list (expected:
      filesystem, git, fetch, context7-remote connected; github/memory/sequential-thinking disabled)
    - grep -q 'opencode-shell-strategy' ~/.config/opencode/opencode.jsonc
      (instructions URL present)
    - opencode run -m opencode/muse-spark-1.3-contributor-free "Reply with exactly: OK"
      (verifies free fallback works end-to-end)
    - opencode run "List the files in this repo and read one file"
      (verifies repo reading)
    - confirm skills are discovered from ~/.agents/skills and
      ~/.config/opencode/skills
    - rtk --version && rtk rewrite "git status" (expect: "rtk git status")
    - test -f ~/.config/opencode/plugins/rtk.ts && grep -q
      'exclude_commands' ~/.config/rtk/config.toml
    - opencode run -m opencode/muse-spark-1.3-contributor-free "Run: ls -la" && rtk
      gain (expect: "rtk ls -la" counted — proves the plugin rewrote)

## Required Output
1. The actual JSONC written (highlight the model section).
2. The Fish commands used (set -gx / set -Ux OPENCODE_API_KEY).
3. List of changed files + diffs (highlight model config).
4. Smoke test results + MODEL SUBSTITUTION TABLE if any ID changed.

## Maintenance (re-run this prompt anytime you want an "auto update")
- Models change / new models appear: re-run this prompt as-is — step 0
  refreshes, step 4 re-discovers, step 5 is idempotent, and the diff review
  surfaces exactly what changed.
- Do not touch plugin entries; @latest updates itself. If a plugin breaks
  after an update: rm -rf ~/.cache/opencode/node_modules/<plugin> and restart
  opencode.
- If opencode-go reports "Insufficient balance", top up at the workspace
  billing page; free fallbacks (muse-spark-1.3-contributor-free) keep working meanwhile.
```

### Known traps (from a real setup, 2026-08-01)

1. **npm v11 blocks git deps** — `npx github:github/git-mcp` fails with
   EALLOWGIT; `bunx github:...` resolves to a 404 tarball. Use the npm
   package: `npx -y git-mcp`.
2. **Fetch MCP naming** — `@modelcontextprotocol/server-fetch` no longer
   exists on npm; `mcp-server-fetch` (0.0.2) is a SECURITY RESEARCH CANARY /
   honeypot (its bin is a garbage shell script). Use `mcp-fetch-server`
   (github.com/zcaceres/fetch-mcp).
3. **OMO installer + array plugin entries** — crashes with
   `TypeError: plugin.startsWith is not a function` when the plugin array
   contains an array-form entry (plannotator options). Install with a flat
   array, then re-add the options entry.
4. **Context7 collision** — OMO injects its own `context7` MCP at runtime.
   Keep your remote one under a different name (`context7-remote`) and set
   `"disabled_mcps": ["context7"]` in omo.jsonc.
5. **opencode-go account state** — deepseek-v4-flash may require a manual
   opt-in (China-hosted), and prepaid balance is separate from subscriptions.
   Check the workspace page if a model errors out.
6. **rtk is pre-1.0 and rewrites every bash command** — covers only the
   bash tool (Read/Grep/Glob/LSP bypass it), so opencode savings < Claude
   Code. Always exclude `opencode` in ~/.config/rtk/config.toml so model
   discovery keeps raw output. When a rewritten command fails, rtk saves
   full output to ~/.local/share/rtk/tee/ — read it there instead of
   re-running. Check `rtk gain` after a week; if savings are negligible:
   rtk init -g --uninstall.
7. **DCP × OMO compaction overlap** — both manage context. DCP adds a
   `compress` tool plus dedup/purge-error pruning and nudges; OMO has its
   own auto-compact hook (`anthropic-context-window-limit-recovery`). Keep
   everything on defaults first; if sessions compact redundantly (double
   summaries), disable OMO's auto-compact hook in
   ~/.config/opencode/oh-my-opencode.json ("disabled_hooks":
   ["anthropic-context-window-limit-recovery"]) or set DCP "enabled": false
   in ~/.config/opencode/dcp.jsonc. DCP trades ~5% cache-hit rate for
   smaller contexts; it is AGPL-licensed and its upstream development has
   slowed (new features move to Sleev) — it still works on current
   opencode.
8. **Sequential Thinking with Native Reasoning Models** — when using models
   with built-in CoT reasoning (DeepSeek Pro/R1, Qwen Reasoning), having the
   `@modelcontextprotocol/server-sequential-thinking` MCP active can trigger
   double-reasoning loops (model reasons in thought tokens, then calls the
   sequential thinking tool, doubling latency and token consumption).
   Keep sequential-thinking disabled or enable only for non-thinking models.
