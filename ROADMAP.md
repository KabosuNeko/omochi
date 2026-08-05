# Project roadmap

## Phase 1: Foundation

### Outcome

A portable, self-validating setup repository: bootstrap installer, AI-driven
setup prompt, skills, templates, and a maintenance gate.

### Included work

- `setup.sh` bootstrap with `--dry-run`, `--repo`, backup, and idempotency.
- `opencode-setup-prompt.md` with runtime model discovery and known traps.
- `.agents/skills/` (10 opencode-format skills) and `templates/`.
- Root `AGENTS.md`, `SPEC.md`, `ROADMAP.md`, `TASKS.md`.

### Dependencies and risks

- Requires a working opencode-go provider account and an API key for full
  setup; free opencode/Zen models remain a fallback.
- Model IDs and plugin APIs drift; the prompt re-discovers at runtime.

### Exit criteria

- `opencode-setup-prompt.md` works end-to-end on a fresh machine and its
  smoke tests pass with a substitution log when models changed.

### Validation

- Manual smoke tests per the prompt; free fallback verified with
  `opencode/deepseek-v4-flash-free`.

## Phase 2: Maintenance gate

### Outcome

Changes to the repository are validated automatically before reporting done,
and installer behavior is regression-tested.

### Included work

- `scripts/validate.sh`: required files, plugin manifest, skill front matter /
  docs sync, template placeholders, Bash syntax, ShellCheck, tracked-secret
  checks.
- `scripts/test-install.sh`: isolated installer tests (install, backup,
  idempotency, dry-run).
- `.github/workflows/validate.yml`: CI on push and pull request.

### Dependencies and risks

- ShellCheck and git must be available locally for full validation; the gate
  degrades to syntax checks when they are missing rather than failing
  because of the environment.

### Exit criteria

- `./scripts/validate.sh` and `./scripts/test-install.sh` exit 0 on a clean
  tree and in CI.

### Validation

- Run `./scripts/validate.sh` and `./scripts/test-install.sh` locally; confirm
  the workflow runs in CI.

## Phase 3: Release readiness

### Outcome

The repository is self-documenting and safe to share publicly.

### Included work

- `docs/` reference material (SKILLS, LAYOUT, WORKFLOW) wired into AGENTS.
- `templates/project-docs/` validated by the gate.
- README bootstrap instructions verified from a clean environment.

### Dependencies and risks

- Committed files must stay neutral: no API keys, runtime state, or hardcoded
  model IDs outside documented examples.

### Exit criteria

- A fresh clone passes `validate.sh` and `test-install.sh` without any local
  setup state.
- README steps reproduce the setup from scratch.

### Validation

- Run all checks from a fresh checkout; walk through the README bootstrap path
  in a sandbox.