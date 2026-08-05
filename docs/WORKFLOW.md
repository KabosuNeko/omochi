# Setup and maintenance workflow

## Setup lifecycle

1. Bootstrap with `setup.sh`: installs opencode, bun, and rtk; clones this
   repository into `~/omochi`. Preview with `--dry-run`; existing `~/omochi`
   directories are backed up before replacement.
2. Manual and interactive, therefore not automatable:
   - `opencode auth login` — select the opencode-go provider (and OpenCode Zen
     for free fallback models).
   - set the `OPENCODE_API_KEY` env var persistently (`set -Ux` in fish).
     Never store keys in config files.
3. Run the AI-driven setup:
   `opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"`. It refreshes the
   model list, assigns models by role, writes `~/.config/opencode/opencode.jsonc`,
   `octto.json`, and OMO routing, installs oh-my-openagent, provisions skills
   and templates, configures rtk, and runs smoke tests.
4. Review the diff of every changed file against its backup before accepting.

## How the setup prompt stays current

- Every model ID in the prompt is a reference only. The agent re-discovers live
  models (step 0 and step 4) and substitutes any ID that no longer exists,
  logging substitutions in the required output.
- Plugin entries use `@latest`; refreshes never need a plugin bump.
- Every step is idempotent, so re-running the prompt is the auto-update
  mechanism: models migrate, setup verifies the diff, smoke tests confirm the
  result.
- Known traps are documented in the prompt itself so re-runs avoid repeating
  installation mistakes.

## Maintaining this repository

- `SPEC.md` defines requirements and acceptance criteria; `ROADMAP.md` orders
  phases and exit criteria; `TASKS.md` records validated work.
- `.agents/skills/` holds reusable skills; follow the authoring rules in
  `docs/SKILLS.md`.
- `templates/` holds portable templates (project docs, global AGENTS, OMO
  routing); update them when the setup prompt's provisioning changes.
- `docs/` is reference material; point to it from `AGENTS.md` or skills rather
  than expecting automatic discovery.
- After changing configuration, skills, install scripts, templates, docs, or
  layout, run `./scripts/validate.sh`. Diagnose `setup.sh` with
  `./scripts/test-install.sh`.
- Do not hardcode model IDs in committed files; keep role placeholders and
  documented fallback examples only.

## When a setup breaks

- Free fallbacks (`opencode/deepseek-v4-flash-free`) continue to work after a
  provider balance or subscription error; `opencode auth login` restores the
  opencode provider.
- Plugin breakage after an upgrade: remove
  `~/.cache/opencode/node_modules/<plugin>` and restart opencode.
- Model discovery needs raw output: `opencode models <provider>` with
  `--verbose` must not be wrapped by rtk (excluded in
  `~/.config/rtk/config.toml`); when a wrapped command fails, read the saved
  output under `~/.local/share/rtk/tee/`.