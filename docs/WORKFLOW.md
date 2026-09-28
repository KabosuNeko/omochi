# Setup and maintenance workflow

## Setup lifecycle

1. Bootstrap with `setup.sh`: installs opencode, bun, and rtk; clones this
   repository into `~/omochi`; installs the managed files — `.agents/skills/`
   to `~/.agents/skills/`, `templates/project-docs/` and
   `templates/global-AGENTS.md` and `plugins/rtk.ts` into `~/.config/opencode/`.
   Preview with `--dry-run`; `~/omochi` and any replaced config file are backed
   up first (`~/omochi.bak-*`, `<file>.bak-*`).
2. Manual and interactive, therefore not automatable:
   - `opencode auth login` — select the opencode-go provider (and OpenCode Zen
     for free fallback models).
   - optionally export the `OPENCODE_API_KEY` env var persistently
     (`set -Ux` in fish), for when the key must come from the environment
     instead of the stored login. Never store keys in config files.
3. Run the AI-driven setup:
   `opencode run "$(cat ~/omochi/opencode-setup-prompt.md)"`. It refreshes the
   model list, assigns models by role, writes `~/.config/opencode/opencode.jsonc`,
   configures rtk, verifies the installed files, and runs smoke tests.
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
  `docs/SKILLS.md`. Changes reach `~/.agents/skills/` by re-running `setup.sh`
  (`git -C ~/omochi pull && bash ~/omochi/setup.sh`), not by re-running the
  setup prompt.
- `plugins/rtk.ts` is installed into `~/.config/opencode/plugins/`; after
  changing it run `./scripts/smoke.sh`, which fails unless the opencode server
  log shows a rewritten (`rtk `-prefixed) bash command. It needs a logged-in
  provider, so it stays out of CI.
- `templates/` holds portable templates (project docs, global AGENTS);
  update them when the setup prompt's provisioning changes.
- `docs/` is reference material; point to it from `AGENTS.md` or skills rather
  than expecting automatic discovery.
- After changing configuration, skills, install scripts, templates, docs, or
  layout, run `./scripts/validate.sh`. Diagnose `setup.sh` with
  `./scripts/test-install.sh`.
- Do not hardcode model IDs in committed files; keep role placeholders and
  documented fallback examples only.

## When a setup breaks

- Free fallbacks (`opencode/muse-spark-1.3-contributor-free`) continue to work after a
  provider balance or subscription error; `opencode auth login` restores the
  opencode provider.
- Plugin breakage after an upgrade: `opencode plugin remove <plugin>` and then
  `opencode plugin add <plugin>`; installed files live under
  `~/.cache/opencode/packages/<plugin>@<version>/node_modules/` (older trees
  also under `~/.cache/opencode/npm/<plugin>@<version>/`).
- rtk stops rewriting commands: `./scripts/smoke.sh` prints the offending
  server-log line. The plugin is installed from `plugins/rtk.ts` by
  `setup.sh`; re-run it, then confirm `opencode plugin list` shows `rtk`.
- Model discovery needs raw output: `opencode models <provider>` with
  `--verbose` must not be wrapped by rtk (excluded in
  `~/.config/rtk/config.toml`); when a wrapped command fails, read the saved
  output under `~/.local/share/rtk/tee/`.