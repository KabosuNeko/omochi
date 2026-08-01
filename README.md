# ai-setup

Portable OpenCode configuration, setup prompt, skills, and project-doc templates.

## Contents

- `opencode-setup-prompt.md` — the self-updating setup prompt (discover models at
  runtime, never hardcode IDs; re-run anytime to auto-update). Includes a
  "Known traps" appendix verified against a real setup (npm v11 git deps,
  fetch MCP honeypot package, OMO installer array-plugins crash, context7
  collision).
- `.agents/skills/` — personal skills (source of truth; copied to
  `~/.agents/skills/` or `~/.config/opencode/skills/` during setup).
- `templates/project-docs/` — SPEC / ROADMAP / TASKS / AGENTS templates for new
  repos (ported from [ChrisTitusTech/titus-ai](https://github.com/ChrisTitusTech/titus-ai)).
- `templates/global-AGENTS.md` — the global `~/.config/opencode/AGENTS.md`
  (working style, verification, skill routing) used by setup step 9.
- `templates/omo-routing.jsonc` — OMO agent/category model routing for
  `~/.omo/omo.jsonc` with `<main>/<worker>/<planner>` placeholders
  (verified `models`-array format) used by setup step 6.

## Security rules

- NEVER commit: `auth.json`, `~/.config/fish/fish_variables` (holds
  `OPENCODE_API_KEY` after `set -Ux`), real API keys. Only `{env:VAR}`
  placeholders belong in committed configs.
- The repo `.gitignore` blocks the common sensitive patterns.

## Install / update

Run the setup prompt (`opencode-setup-prompt.md`) from any machine. It is
idempotent: it backs up, re-discovers current OpenCode Go models, and diffs
every change before writing.

## Auto setup on a new machine

One-liner bootstrap (installs opencode + bun, clones this repo). Requires the
repo to be pushed to GitHub first — the raw URL only exists after a push.

```bash
curl -fsSL https://raw.githubusercontent.com/KabosuNeko/ai-setup/main/setup.sh | bash
```

Then, three manual steps (interactive or secret — they cannot be automated):

```bash
opencode auth login                        # opencode-go + OpenCode Zen (free models)
set -Ux OPENCODE_API_KEY "sk-..."          # fish; opencode-go token from your workspace
opencode run "$(cat ~/Projects/ai-setup/opencode-setup-prompt.md)"   # AI-driven setup + smoke tests
```

The prompt provisions everything else: live model discovery, `opencode.jsonc`
+ `octto.json`, oh-my-openagent, `~/.omo/omo.jsonc` routing, 14 skills, project
templates, global `AGENTS.md`, and runs the smoke tests. It is safe to re-run
anytime as an "auto update".
