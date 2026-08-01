# ai-setup

Portable OpenCode configuration, setup prompt, skills, and project-doc templates.

## Contents

- `opencode-setup-prompt.md` — the self-updating setup prompt (discover models at
  runtime, never hardcode IDs; re-run anytime to auto-update).
- `.agents/skills/` — personal skills (source of truth; copied to
  `~/.agents/skills/` or `~/.config/opencode/skills/` during setup).
- `templates/project-docs/` — SPEC / ROADMAP / TASKS / AGENTS templates for new
  repos (ported from [ChrisTitusTech/titus-ai](https://github.com/ChrisTitusTech/titus-ai)).

## Security rules

- NEVER commit: `auth.json`, `~/.config/fish/fish_variables` (holds
  `OPENCODE_API_KEY` after `set -Ux`), real API keys. Only `{env:VAR}`
  placeholders belong in committed configs.
- The repo `.gitignore` blocks the common sensitive patterns.

## Install / update

Run the setup prompt (`opencode-setup-prompt.md`) from any machine. It is
idempotent: it backs up, re-discovers current OpenCode Go models, and diffs
every change before writing.
