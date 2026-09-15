# Project tasks

## Current phase: Phase 3 (Release readiness)

- [x] Wire `docs/` reference material (SKILLS, LAYOUT, WORKFLOW) into `AGENTS.md`.
  - Acceptance criteria: routing sections in root and global instructions point to reference docs.
  - Automated validation: `validate.sh`.
- [x] Validate `templates/project-docs/` by the gate.
  - Acceptance criteria: templates exist, match standard structure, non-empty.
  - Automated validation: `validate.sh`.
- [x] Verify README bootstrap instructions from a clean environment.
  - Acceptance criteria: isolated HOME installer test passes.
  - Automated validation: `test-install.sh`.
- [x] Integrate minimalist code ladder (Ponytail) into global instructions.
  - Acceptance criteria: `templates/global-AGENTS.md` and active AGENTS include the 7-rung deletion ladder.
  - Automated validation: `validate.sh`.
- [x] Integrate Anti-Slop craftsmanship gates into `frontend-design` skill.
  - Acceptance criteria: purpose test, anti-slop visual/copy checks, and accessibility requirements in place.
  - Automated validation: `validate.sh`.
- [x] Enrich `code-review` and `bug-hunt` skills with anti-overengineering and root-cause seam rules.
  - Acceptance criteria: checklists and anti-patterns cover slop detection and shared-seam fixes.
  - Automated validation: `validate.sh`.

## Completed

- Phase 1 (Foundation):
  - Bootstrap `setup.sh` (bun, opencode, rtk, repo clone).
  - `opencode-setup-prompt.md` with role-based model discovery and known traps.
  - 10 opencode-format skills under `.agents/skills/`.
  - `templates/` (global AGENTS, OMO routing, project docs); guardrail and personal skill split.
  - Root `AGENTS.md` maintenance instructions.
- Phase 2 (Maintenance gate):
  - `scripts/validate.sh` full gate (manifest, skills, templates, shellcheck, secrets).
  - `scripts/test-install.sh` isolated installer tests.
  - `.github/workflows/validate.yml` CI gate.
  - `opencode-plugins.txt`, `.rtk/filters.toml`, DCP + non-interactive shell rules.