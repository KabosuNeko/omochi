---
name: refactor-human-code
description: Refactor existing (possibly human-written, idiosyncratic) code while preserving behavior and style. Use for "clean this up", "restructure", "remove duplication", or legacy code modernization.
compatibility: opencode
---

# Refactor Human Code

Preserve behavior. Preserve the author's intent. Do not rewrite for style's
sake.

## Workflow

1. Explore first: understand existing interfaces, caller patterns, and tests.
2. Formulate a minimal refactoring plan with clear invariants.
3. Execute end-to-end with tight feedback loops.

## Constraints

- Behavioral preservation: before/after test suite must be green (add tests
  first if none exist).
- Scope discipline: refactor only what the task names; no drive-by changes.
- Keep the existing naming/style of human-authored code unless it conflicts
  with repo lint rules.
- Split work into reviewable commits; run the project's formatter and
  linter after each step.
- Do not introduce new dependencies unless required and agreed.

## Verification

After the refactor: run the full test suite + build, then run an independent
verification pass (via `code-review`) before considering it done.
