# OpenCode Setup Prompt — Self-Updating Edition

> Created: 2026-08-01 · Updated: 2026-08-01 (verified against a real setup) ·
> OpenCode: 1.18.8 · OS: CachyOS (Arch) · Shell: Fish
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
   (opencode.jsonc, package.json, octto.json, ~/.local/share/opencode/auth.json,
   ~/.omo/omo.jsonc if present, ~/.agents/skills if present) -> .bak-<date>.
2. Install bun if missing: sudo pacman -S bun
3. Write ~/.config/opencode/opencode.jsonc (fixed structure; models come from
   the step 4 discovery):
   - model: <main> · small_model: <worker> · agent.plan.model: <planner>
   - plugin: ["oh-my-openagent@latest", "opencode-pty", "octto",
     "opencode-worktree", "@franlol/opencode-md-table-formatter@latest",
     ["@plannotator/opencode@latest", {"workflow": "plan-agent",
     "planningAgents": ["plan", "sisyphus"]}]]
     (plannotator has NO model of its own: it runs on the agent.plan model)
   - Write ~/.config/opencode/octto.json: {"port": 0, "agents":
     {"probe": {"model": "<worker>"}, "bootstrapper": {"model": "<worker>"},
     "octto": {"model": "<main>"}}}
   - mcp (exact commands are verified; do not substitute):
     - filesystem: npx -y @modelcontextprotocol/server-filesystem
       <your Projects dir> <your Documents dir>
     - git: npx -y git-mcp   [TRAP: github:github/git-mcp fails — npm v11
       blocks git deps (EALLOWGIT) and bunx resolves it to a 404 tarball]
     - fetch: npx -y mcp-fetch-server   [TRAP: @modelcontextprotocol/
       server-fetch no longer exists on npm, and mcp-server-fetch is a
       SECURITY CANARY (honeypot) — never use it]
     - sequential-thinking: npx -y @modelcontextprotocol/server-sequential-thinking
     - context7-remote: remote https://mcp.context7.com/mcp
       (named context7-remote on purpose: OMO injects its own "context7"
       at runtime; ours must not collide -> see step 6 disabled_mcps)
     - memory (local, npx -y @modelcontextprotocol/server-memory),
       github (remote https://api.githubcopilot.com/mcp/, OAuth) -> disabled
   - NEVER hardcode API keys: use {env:VAR} or auth.json only
4. Assign models by role (pick from the live list; names in brackets are
   current-model references only):
   | Role | Selection criteria (priority order) | 2026 reference |
   |---|---|---|
   | Main coding (complex logic, architecture, heavy generation) | Strongest stable reasoning model on Go; prefer $60/month tier over $15 if equal strength | deepseek-v4-pro (fallback: qwen3.7-max) |
   | Worker (small_model: autocomplete, boilerplate, light tasks) | Fastest + cheapest with highest quota (prefer $60 tier). If the opencode provider (Zen) is authenticated, prefer its FREE worker: opencode/deepseek-v4-flash-free — it matches the Go flash in speed and costs nothing | deepseek-v4-flash-free (fallback: opencode-go/deepseek-v4-flash, qwen3.7-plus) |
   | Planner/Reviewer (deep reading, planning, code review) | Code-specialized, cheap, $60 tier, "Claude-like" behavior (fits OMO prompts) | kimi-k2.7-code (fallback: glm-5.2) |
   For EACH role: run `opencode models opencode-go` to verify the ID exists;
   if missing, pick the closest per criteria and log the substitution.
5. Install oh-my-openagent (repo: code-yeongyu/oh-my-openagent, npm:
   oh-my-openagent; the legacy oh-my-opencode name only loads with a warning).
   [TRAP: the installer crashes with "plugin.startsWith is not a function" if
   the plugin array contains an array-form entry (the plannotator options
   entry). Fix: write the plugin array FLAT first (plain strings only), run
   the installer, then re-add the plannotator options entry.]
   bunx oh-my-openagent install --no-tui --platform=opencode
   --claude=no --openai=no --gemini=no --copilot=no --opencode-zen=no
   --zai-coding-plan=no --kimi-for-coding=no --vercel-ai-gateway=no
   --opencode-go=yes --skip-auth
   (idempotent — safe to re-run when models change; OMO resolves per-agent
   fallback chains from the enabled providers)
 6. OMO Agent Skill Routing — write the agent + category model routing in
    ~/.omo/omo.jsonc ("[opencode]" -> "agents" / "categories" blocks) with
    step 4 discovered IDs, using the template at
    ~/Projects/ai-setup/templates/omo-routing.jsonc (or from the ai-setup
    clone; fallback: write it from the routing lines below).
    Modern key format (verified):
    - Chain = one array "models": ["<primary>", "<fb1>", "<fb2>"] — the
      first entry is the primary model, the rest are fallbacks in order.
      (Legacy "model" + "fallback_models" still parse, but OMO auto-migrates
      them to "models" — write the new form directly.)
    - "reasoning" (enum off|minimal|low|medium|high|xhigh|max|auto) per
      model: as a string on a plain "model" key, or as
      {"model": ..., "reasoning": ...} objects inside "models".
    - "model_fallback": true, "runtime_fallback": {"enabled": true,
      "retry_on_errors": [429, 500, 502, 503, 504], "max_fallback_attempts": 3,
      "cooldown_seconds": 30, "timeout_seconds": 120, "notify_on_fallback":
      true, "restore_primary_after_cooldown": true}
    - "disabled_mcps": ["context7"]  (keep OUR context7-remote; drop OMO's
      auto-injected one to avoid tool-name collision)
    Routing (verified models; see template for the full JSONC):
    - code-review, docs-reader -> momus, librarian -> <planner>
      (fallback: glm-5.2 / qwen3.7-plus)
    - refactor-human-code -> hephaestus -> <main> (fallback: qwen3.7-max)
    - bug-hunt -> oracle -> qwen3.7-max (fallback: <main>)
    - sisyphus -> <main> (fallback: <planner>, opencode/big-pickle)
    - sisyphus-junior -> <planner> (fallback: <worker>, opencode/big-pickle)
    - prometheus -> <planner> reasoning high (fallback: glm-5.2)
    - metis, atlas -> <planner> reasoning low (fallback: qwen3.7-plus)
    - explore -> <worker> (fallback: opencode/big-pickle)
    - multimodal-looker -> a vision-capable model (e.g. kimi-k3)
   Categories (default reasoning tiers): visual-engineering, artistry ->
   <planner> reasoning high; ultrabrain, deep -> <main> reasoning max;
   quick -> <worker>; writing -> <planner> reasoning low.
   "opencode/big-pickle" is a FREE model on the opencode provider (Zen);
   it works as last-resort fallback without a subscription.
   Note: OMO routes by agent/category, NOT by skill; the matching skills must
   state "delegate to agent X" inside their SKILL.md.
7. Optional free-tier fallback: run `opencode auth login` and select
   "OpenCode Zen" (free models; no payment needed). Required only if you
   want big-pickle / other opencode provider free models to work.
8. Personal skills (7, at ~/.config/opencode/skills/<name>/SKILL.md):
   frontend-design (ui-ux-pro merged in), code-review, refactor-human-code,
   bug-hunt, docs-reader, test-writer, grill-me.
   Provisioning order (first source that works):
   a. cp -r ~/Projects/ai-setup/.agents/skills/* ~/.config/opencode/skills/
   b. git clone --depth 1 https://github.com/KabosuNeko/ai-setup <tmp>
      && copy .agents/skills/* from it (then delete <tmp>)
   c. write the 7 SKILL.md yourself from the descriptions in this prompt
   Do not create skills that duplicate OMO built-ins (git-master, playwright,
   frontend-ui-ux, review-work, remove-ai-slops).
9. titus-guardrails layer (ported from ChrisTitusTech/titus-ai):
   - git clone --depth 1 https://github.com/ChrisTitusTech/titus-ai ~/titus-ai
   - Copy 7 skills: ai-project-manager, pr-readiness, linux-sysadmin,
     bash-scripting, python-ai, rust-cli, hugo -> ~/.agents/skills/
     (skip: forgejo-maintainer, podman-operator, quickshell, mdbook,
     homelab-admin; the agents/openai.yaml inside skills is Codex metadata,
     opencode ignores it — harmless)
   - Copy 4 templates (AGENTS, SPEC, ROADMAP, TASKS).md from the first
     source that works: ~/Projects/ai-setup/templates/project-docs/ OR the
     ai-setup clone (8b) OR titus-ai .agents/skills/ai-project-manager/
     assets/project-docs/ -> ~/.config/opencode/templates/project-docs/
   - Write ~/.config/opencode/AGENTS.md: copy
     ~/Projects/ai-setup/templates/global-AGENTS.md (or from the ai-setup
     clone) — global rules: change-focused, skip filler, run checks, stop
     before destructive actions.
10. Fish env var (if not set): set -gx OPENCODE_API_KEY "sk-..."
    then set -Ux OPENCODE_API_KEY "sk-..." (persistent; never store keys in
    config files)
11. Review the diff of EVERY changed file against its backup, highlighting
    the model configuration section.
12. Smoke tests:
    - opencode --version · opencode mcp list (expected: websearch, grep_app,
      lsp, filesystem, git, fetch, sequential-thinking, context7-remote
      connected; codegraph/memory/github disabled; NO plain "context7")
    - bunx oh-my-openagent doctor -> exit 0, agent models = discovered IDs
    - opencode run -m opencode/big-pickle "Reply with exactly: OK"
      (verifies free fallback works end-to-end)
    - opencode run "List the files in this repo and read one file"
      (verifies repo reading)
    - confirm skills are discovered from ~/.agents/skills and
      ~/.config/opencode/skills

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
  billing page; free fallbacks (big-pickle) keep working meanwhile.
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
