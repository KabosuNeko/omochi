# ai-setup

Portable OpenCode setup: one prompt, skills, templates.

## Setup a machine

```bash
# bootstrap: installs opencode + bun, clones this repo (needs the repo pushed first)
curl -fsSL https://raw.githubusercontent.com/KabosuNeko/ai-setup/main/setup.sh | bash

# then (manual, cannot be automated):
opencode auth login                        # opencode-go + OpenCode Zen
set -Ux OPENCODE_API_KEY "sk-..."          # fish; go token from your workspace

# AI-driven setup: discovers models, writes configs, installs OMO,
# provisions skills/templates, runs smoke tests. Safe to re-run = auto-update.
opencode run "$(cat ~/Projects/ai-setup/opencode-setup-prompt.md)"
```

## Layout

- `opencode-setup-prompt.md` — self-updating setup prompt + verified "known traps" (npm git deps, fetch-MCP honeypot, OMO array-plugin crash, context7 collision)
- `setup.sh` — bootstrap installer
- `.agents/skills/` — 7 personal skills
- `templates/project-docs/` — SPEC/ROADMAP/TASKS/AGENTS
- `templates/global-AGENTS.md` — global `~/.config/opencode/AGENTS.md`
- `templates/omo-routing.jsonc` — OMO model routing, `<main>/<worker>/<planner>` placeholders

## Rules

- Never commit `auth.json`, `fish_variables`, API keys, `.env`. Only `{env:VAR}` in configs. `.gitignore` blocks the common ones.
- No model IDs hardcoded in configs; everything is discovered at runtime by the prompt.
