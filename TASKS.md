# Project tasks

## Current phase: Phase 4 (OpenCode 2.0 Native "Super Lean")

- [x] Migrate to OpenCode 2.0 native multi-agent, worktrees, and context compaction.
  - Acceptance criteria: remove OMO, worktree, and dcp plugins from global manifest; rely on native 2.0 capabilities.
  - Automated validation: `validate.sh`.
- [x] Streamline plugins manifest to verified OpenCode 2.0 packages (`@plannotator/opencode`).
  - Acceptance criteria: `opencode-plugins.txt` contains only active V2 plugins; zero load errors in OpenCode 2.0.
  - Automated validation: `validate.sh`.
- [x] Rewrite RTK shell rewrite hook to OpenCode 2.0 V2 Plugin API (`Plugin.define`).
  - Acceptance criteria: `~/.config/opencode/plugins/rtk.ts` uses domain hooks; token savings preserved.
  - Automated validation: smoke test `rtk rewrite`.
- [x] Integrate Ponytail minimalist rules and anti-slop gates directly into AGENTS and skills.
  - Acceptance criteria: no external npm plugin needed for craftsmanship rules; portable across OpenCode versions.
  - Automated validation: `validate.sh`.

## Completed

- Phase 3 (Release readiness):
  - Wire `docs/` reference material (SKILLS, LAYOUT, WORKFLOW) into `AGENTS.md`.
  - Validate `templates/project-docs/` by the gate.
  - Verify README bootstrap instructions from a clean environment.
  - Integrate minimalist code ladder (Ponytail) into global instructions.
  - Integrate Anti-Slop craftsmanship gates into `frontend-design` skill.
  - Enrich `code-review` and `bug-hunt` skills with anti-overengineering and root-cause seam rules.

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