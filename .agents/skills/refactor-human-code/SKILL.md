---
name: refactor-human-code
description: Refactor existing (possibly human-written, idiosyncratic) code while preserving behavior and style. Use for "clean this up", "restructure", "remove duplication", or legacy code modernization. Delegates execution to the hephaestus agent (DeepSeek V4 Pro).
compatibility: opencode
---

# Refactor Human Code

Preserve behavior. Preserve the author's intent. Do not rewrite for style's
sake.

## Delegation (mandatory)

1. Delegate the refactor to the `hephaestus` agent via `call_omo_agent`
   (subagent_type: hephaestus). Hephaestus runs on the main coding model.
2. He works autonomously: explore first, then execute end-to-end. Give him a
   goal and constraints, not a recipe.

## Constraints (pass to hephaestus)

- Behavioral preservation: before/after test suite must be green (add tests
  first if none exist).
- Scope discipline: refactor only what the task names; no drive-by changes.
- Keep the existing naming/style of human-authored code unless it conflicts
  with repo lint rules.
- Split work into reviewable commits; run the project's formatter and
  linter after each step.
- Do not introduce new dependencies unless required and agreed.

## Verification

After the refactor: run the full test suite + build, then hand the diff to
`code-review` (momus) before considering it done.
