---
name: code-review
description: Independent code review of a diff, PR, or working tree. Checks correctness, edge cases, security, docs/changelog accuracy, and test coverage. Use for "review this", "check my PR", or pre-merge review.
compatibility: opencode
---

# Code Review

Review with fresh context — the author must not grade their own work.

## Delegation

1. Perform an independent, rigorous critique of the diff or staged changes.
2. When subagents are enabled, invoke an independent reviewer subagent using the configured reviewer/plan model to ensure unbiased inspection.

## Review checklist (pass to the reviewer)

- Only the intended change is present — no unrelated edits.
- Edge cases: empty input, missing data, permissions, timeouts.
- Security: no secrets logged, no unsafe deserialization, no path traversal.
- Tests cover the new behavior and the changed edge cases.
- Docs/changelog match the actual behavior.
- Dependencies: no new transitive risk, versions pinned per SPEC.md.
- Minimalism & Over-engineering: no speculative abstractions, single-implementer interfaces, or unnecessary dependencies when standard library suffices.
- Hygiene & Dead code: no decorative banner comments, narrative workflow comments, unused variables, or dead exports.

## Output

Return each finding as: severity (blocker/major/minor/nit) + file:line + why
it matters + concrete fix. For every comment, either fix the root cause or
explain why the current behavior is intentional. Do not blindly accept or
dismiss AI suggestions.
