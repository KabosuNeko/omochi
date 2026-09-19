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
- [x] Expand Ponytail craftsmanship skill suite to 16 specialized skills.
  - Acceptance criteria: add docker-expert, database-architect, api-designer, git-workflow, and security-audit.
  - Automated validation: `validate.sh`.
- [x] Streamline MCP configuration to minimal footprint (context7-remote + fetch).
  - Acceptance criteria: remove dead/bloated MCPs (git-mcp, sequential-thinking, memory, github, filesystem) in favor of native tools.
  - Automated validation: `opencode mcp list`.
- [x] Purge all legacy OMO references, remove dead omo-routing template, and align documentation.
  - Acceptance criteria: zero stale OMO/DCP mentions in active files; validate.sh and test-install.sh pass.
  - Automated validation: `validate.sh` and `test-install.sh`.
- [x] Add typesafe-ai skill (17 skills total) for TypeSafe and Jev System One programming model.
  - Acceptance criteria: official typesafe-ai skill added, documented, and passing validate.sh.
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
  - 10 opencode-format skills under `.agents/skills/` (initial foundation).
  - `templates/` (global AGENTS, project docs); guardrail and personal skill split.
  - Root `AGENTS.md` maintenance instructions.
- Phase 2 (Maintenance gate):
  - `scripts/validate.sh` full gate (manifest, skills, templates, shellcheck, secrets).
  - `scripts/test-install.sh` isolated installer tests.
  - `.github/workflows/validate.yml` CI gate.
  - `opencode-plugins.txt`, `.rtk/filters.toml`, non-interactive shell rules.