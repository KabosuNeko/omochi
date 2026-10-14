# omochi

an opencode setup that just works.

## Setup

```bash
# Linux bootstrap: installs opencode + bun + rtk, clones this repo
# (preview with --dry-run; existing ~/omochi is backed up first)
curl -fsSL https://raw.githubusercontent.com/KabosuNeko/omochi/main/setup.sh | bash

# then (manual, cannot be automated):
opencode auth login                        # opencode-go + OpenCode Zen (stores the key)
set -Ux OPENCODE_API_KEY "sk-..."          # optional: only for env-based auth

# AI-driven setup: discovers models, writes configs,
# provisions templates, runs smoke tests. Safe to re-run = auto-update.
opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"
```

```powershell
# Windows bootstrap (PowerShell 5.1+): the same installer in PowerShell. It
# installs OpenCode 2.0 via npm, because winget only ships 1.x.
# (preview: download setup.ps1 and run it with -DryRun; ~\omochi is backed up first)
powershell -ExecutionPolicy Bypass -c "irm https://raw.githubusercontent.com/KabosuNeko/omochi/main/setup.ps1 | iex"

# then (manual, cannot be automated):
opencode auth login                        # opencode-go + OpenCode Zen (stores the key)
setx OPENCODE_API_KEY "sk-..."             # optional: only for env-based auth

# AI-driven setup: discovers models, writes configs,
# provisions templates, runs smoke tests. Safe to re-run = auto-update.
opencode run "$(Get-Content $HOME\omochi\opencode-setup-prompt.md -Raw)"
```

## Layout

- `opencode-setup-prompt.md` — self-updating setup prompt + verified "known traps" (npm git deps, fetch-MCP honeypot, rtk rewrite); platform-aware (Linux + Windows)
- `setup.sh` — Linux bootstrap installer (opencode, bun, rtk; installs skills, templates, global AGENTS.md, and the rtk plugin; `--dry-run`/`--repo`)
- `setup.ps1` — Windows bootstrap installer (`-DryRun`/`-Repo`): npm or standalone opencode 2.0, bun via the official installer, rtk via winget or the prebuilt binary
- `AGENTS.md` + `SPEC.md`/`ROADMAP.md`/`TASKS.md` — repo maintenance and project docs
- `.agents/skills/` — 23 specialized skills installed to `~/.agents/skills/` by the setup scripts
- `plugins/rtk.ts` — opencode plugin that rewrites bash/shell commands through rtk
- `templates/project-docs/` — SPEC/ROADMAP/TASKS/AGENTS
- `templates/global-AGENTS.md` — global `~/.config/opencode/AGENTS.md`
- `opencode-plugins.txt` — maintained npm plugin manifest
- `.rtk/filters.toml` — project-local rtk filter example
- `.gitattributes` — LF working tree on every platform (Git Bash needs it)
- `docs/` — SKILLS, LAYOUT, WORKFLOW reference docs
- `scripts/` — validate.sh gate, test-install.sh / test-install.ps1 installer tests, smoke.sh / smoke.ps1 rtk checks
- `.github/workflows/validate.yml` — CI on push and pull request (Linux + Windows)

## Validate

```bash
./scripts/validate.sh        # repo gate: files, manifest, skills, plugin transpile, Bash, PowerShell, secrets
./scripts/test-install.sh    # installer integration test (isolated HOME)
./scripts/test-install.ps1   # Windows installer integration test (PowerShell)
./scripts/smoke.sh           # rtk plugin rewrite check (needs a logged-in provider)
./scripts/smoke.ps1          # the same check on Windows
```

## Rules

- Never commit `auth.json`, `fish_variables`, API keys, `.env`. Only `{env:VAR}` in configs. `.gitignore` + `validate.sh` block the common ones.
- No model IDs hardcoded in configs; everything is discovered at runtime by the prompt.
- rtk (token saver) is installed by the setup scripts and configured by the prompt: its plugin rewrites only the bash/shell tool, and the rtk config (`~/.config/rtk/config.toml`; Windows: `%APPDATA%\rtk\config.toml`) excludes the `opencode` CLI so model discovery keeps raw output.
