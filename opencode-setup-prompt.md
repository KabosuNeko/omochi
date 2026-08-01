# OpenCode Setup Prompt — Self-Updating Edition

> Created: 2026-08-01 · OpenCode: 1.18.8 · OS: CachyOS (Arch) · Shell: Fish
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
   - model: <main> · small_model: <worker> · agent.plan.model: <planner>
   - plugin: ["oh-my-openagent", "opencode-pty", "octto", "opencode-worktree",
     "@plannotator/opencode", "@franlol/opencode-md-table-formatter@latest"]
   - mcp: filesystem, git, fetch, sequential-thinking, context7 (remote
     https://mcp.context7.com/mcp) -> enabled;
     memory, github (remote https://api.githubcopilot.com/mcp/, OAuth) -> disabled
   - NEVER hardcode API keys: use {env:VAR} or auth.json only
4. Assign models by role (pick from the live list; names in brackets are
   current-model references only):
   | Role | Selection criteria (priority order) | 2026 reference |
   |---|---|---|
   | Main coding (complex logic, architecture, heavy generation) | Strongest stable reasoning model on Go; prefer $60/month tier over $15 if equal strength | deepseek-v4-pro (fallback: qwen3.7-max) |
   | Worker (small_model: autocomplete, boilerplate, light tasks) | Fastest + cheapest with highest quota (prefer $60 tier) | deepseek-v4-flash (fallback: qwen3.7-plus) |
   | Planner/Reviewer (deep reading, planning, code review) | Code-specialized, cheap, $60 tier, "Claude-like" behavior (fits OMO prompts) | kimi-k2.7-code (fallback: glm-5.2) |
   For EACH role: run `opencode models opencode-go` to verify the ID exists;
   if missing, pick the closest per criteria and log the substitution.
5. Install oh-my-openagent (repo: code-yeongyu/oh-my-openagent, npm:
   oh-my-openagent; the legacy oh-my-opencode name only loads with a warning):
   bunx oh-my-openagent install --no-tui --platform=opencode
   --claude=no --openai=no --gemini=no --copilot=no --opencode-zen=no
   --zai-coding-plan=no --kimi-for-coding=no --vercel-ai-gateway=no
   --opencode-go=yes --skip-auth
   (idempotent — safe to re-run when models change; OMO resolves per-agent
   fallback chains from the enabled providers)
6. OMO Agent Skill Routing — override AGENT models in ~/.omo/omo.jsonc
   ("opencode" -> "agents" block) with step 4 discovered IDs:
   - code-review, docs-reader -> momus, librarian -> <planner>
   - refactor-human-code -> hephaestus -> <main>
   - bug-hunt -> oracle -> <main fallback or strongest debugging model>
   - sisyphus -> <main> · explore -> <worker>
   Note: OMO routes by agent/category, NOT by skill; the matching skills must
   state "delegate to agent X" inside their SKILL.md.
7. Personal skills (7, at ~/.config/opencode/skills/<name>/SKILL.md):
   frontend-design (ui-ux-pro merged in), code-review, refactor-human-code,
   bug-hunt, docs-reader, test-writer, grill-me.
   Provisioning order (first source that works):
   a. cp -r ~/Projects/ai-setup/.agents/skills/* ~/.config/opencode/skills/
   b. git clone --depth 1 https://github.com/KabosuNeko/ai-setup <tmp>
      && copy .agents/skills/* from it (then delete <tmp>)
   c. write the 7 SKILL.md yourself from the descriptions in this prompt
   Do not create skills that duplicate OMO built-ins (git-master, playwright,
   frontend-ui-ux, review-work, remove-ai-slops).
8. titus-guardrails layer (ported from ChrisTitusTech/titus-ai):
   - git clone --depth 1 https://github.com/ChrisTitusTech/titus-ai ~/titus-ai
   - Copy 7 skills: ai-project-manager, pr-readiness, linux-sysadmin,
     bash-scripting, python-ai, rust-cli, hugo -> ~/.agents/skills/
     (skip: forgejo-maintainer, podman-operator, quickshell, mdbook,
     homelab-admin; the agents/openai.yaml inside skills is Codex metadata,
     opencode ignores it — harmless)
   - Copy 4 templates (AGENTS, SPEC, ROADMAP, TASKS).md from the first
     source that works: ~/Projects/ai-setup/templates/project-docs/ OR the
     ai-setup clone (7b) OR titus-ai .agents/skills/ai-project-manager/
     assets/project-docs/ -> ~/.config/opencode/templates/project-docs/
   - Write ~/.config/opencode/AGENTS.md (global rules modeled on codex-home/
     AGENTS.md: change-focused, skip filler, run checks, stop before
     destructive actions — strip Codex-specific parts)
9. Fish env var (if not set): set -gx OPENCODE_API_KEY "sk-..."
   then set -Ux OPENCODE_API_KEY "sk-..." (persistent; never store keys in
   config files)
10. Review the diff of EVERY changed file against its backup, highlighting
    the model configuration section.
11. Smoke tests:
    - opencode --version · opencode mcp list (all servers present;
      github/memory disabled)
    - bunx oh-my-openagent doctor -> exit 0, agent models = discovered IDs
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
```
