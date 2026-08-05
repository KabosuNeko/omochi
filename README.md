# omochi

an opencode setup that just works.

## Setup

```bash
# bootstrap: installs opencode + bun + rtk, clones this repo
# (preview with --dry-run; existing ~/omochi is backed up first)
curl -fsSL https://raw.githubusercontent.com/KabosuNeko/omochi/main/setup.sh | bash

# then (manual, cannot be automated):
opencode auth login                        # opencode-go + OpenCode Zen
set -Ux OPENCODE_API_KEY "sk-..."          # fish; go token from your workspace

# AI-driven setup: discovers models, writes configs, installs OMO,
# provisions skills/templates, runs smoke tests. Safe to re-run = auto-update.
opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"
```

## Layout

- `opencode-setup-prompt.md` — self-updating setup prompt + verified "known traps" (npm git deps, fetch-MCP honeypot, OMO array-plugin crash, context7 collision, rtk rewrite)
- `setup.sh` — bootstrap installer (opencode, bun, rtk; `--dry-run`/`--repo`)
- `AGENTS.md` + `SPEC.md`/`ROADMAP.md`/`TASKS.md` — repo maintenance and project docs
- `.agents/skills/` — 10 skills (7 personal + 3 guardrails: bash-scripting, python-ai, linux-sysadmin)
- `templates/project-docs/` — SPEC/ROADMAP/TASKS/AGENTS
- `templates/global-AGENTS.md` — global `~/.config/opencode/AGENTS.md`
- `templates/omo-routing.jsonc` — OMO model routing, `<main>/<worker>/<planner>` placeholders
- `opencode-plugins.txt` — maintained npm plugin manifest
- `.rtk/filters.toml` — project-local rtk filter example
- `docs/` — SKILLS, LAYOUT, WORKFLOW reference docs
- `scripts/` — validate.sh gate + test-install.sh integration test
- `.github/workflows/validate.yml` — CI on push and pull request

## Validate

```bash
./scripts/validate.sh        # repo gate: files, manifest, skills, Bash, secrets
./scripts/test-install.sh    # installer integration test (isolated HOME)
```

## Rules

- Never commit `auth.json`, `fish_variables`, API keys, `.env`. Only `{env:VAR}` in configs. `.gitignore` + `validate.sh` block the common ones.
- No model IDs hardcoded in configs; everything is discovered at runtime by the prompt.
- rtk (token saver) is installed by `setup.sh` and configured by the prompt: its plugin rewrites only the bash tool, and `~/.config/rtk/config.toml` excludes the `opencode` CLI so model discovery keeps raw output.
