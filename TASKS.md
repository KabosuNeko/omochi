# Project tasks

## Current phase: Phase 2 (Maintenance gate)

- [x] Add `scripts/validate.sh` full gate.
  - Scope: required files, plugin manifest, skills, templates, Bash/ShellCheck,
    tracked secrets.
  - Acceptance criteria: clean tree exits 0; each failure type reports a path.
  - Automated validation: `bash -n`; `shellcheck` when present.
  - Manual validation: run locally, confirm failures on a deliberately broken
    tree.
- [x] Add `scripts/test-install.sh`.
  - Scope: install, backup, idempotency, dry-run against `setup.sh`.
  - Acceptance criteria: passes in an isolated temp HOME without touching the
    real environment.
  - Automated validation: run the script; assert clone, single backup,
    unchanged re-run, dry-run writes nothing.
  - Manual validation: none beyond the assertions.
- [x] Upgrade `setup.sh` (dry-run, repo override, backup, PATH-resolved
  checks).
  - Acceptance criteria: `--dry-run` writes nothing; existing `~/omochi` is
    backed up once; `command -v`-based checks make installs skippable when
    tools already exist.
  - Automated validation: `test-install.sh`.
- [x] Add `.github/workflows/validate.yml`.
  - Scope: ubuntu validation gate on push and pull request.
  - Acceptance criteria: workflow runs ShellCheck and both scripts.
  - Manual validation: green CI on the push.
- [x] Add `docs/` (SKILLS, LAYOUT, WORKFLOW) and wire into `AGENTS.md`.
  - Acceptance criteria: SKILLS.md list matches `.agents/skills/`; LAYOUT
    documents discovery; WORKFLOW documents the setup lifecycle.
  - Automated validation: `validate.sh` docs-sync check.
- [x] Add `opencode-plugins.txt` and `.rtk/filters.toml`.
  - Acceptance criteria: manifest entries all appear in the setup prompt;
    filters file is a committed example.
  - Automated validation: `validate.sh` manifest checks.
- [x] Add DCP + non-interactive shell rules.
  - Scope: `@tarquinen/opencode-dcp` npm plugin and the remote
    `opencode-shell-strategy` instructions URL in the setup prompt.
  - Acceptance criteria: manifest + prompt stay in sync; DCP uses its default
    `dcp.jsonc`; shell-strategy loads from the URL at each session.
  - Automated validation: `validate.sh` manifest and prompt-sync checks.
  - Manual validation: on next real setup, `/dcp` panel appears and the
    instructions load without errors.
- [x] Add SPEC / ROADMAP / TASKS for this repository.
  - Acceptance criteria: they match current phase and validation status.

## Completed

- Bootstrap `setup.sh` (bun, opencode, rtk, repo clone).
- `opencode-setup-prompt.md` with role-based model discovery and known traps.
- 10 opencode-format skills under `.agents/skills/`.
- `templates/` (global AGENTS, OMO routing, project docs); guardrail and
  personal skill split.
- Root `AGENTS.md` maintenance instructions.