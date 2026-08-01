---
name: code-review
description: Independent code review of a diff, PR, or working tree. Checks correctness, edge cases, security, docs/changelog accuracy, and test coverage. Use for "review this", "check my PR", or pre-merge review. Always delegates to the momus agent for the actual critique.
compatibility: opencode
---

# Code Review

Review with fresh context — the author must not grade their own work.

## Delegation (mandatory)

1. Call the `momus` agent via `call_omo_agent` (subagent_type: momus) or the
   `task` tool with category targeting the reviewer agent. Momus runs on the
   assigned reviewer model.
2. If momus is unavailable, fall back to OMO's `review-work` skill
   (5 parallel reviewers) and report which path was used.

## Review checklist (pass to the reviewer)

- Only the intended change is present — no unrelated edits.
- Edge cases: empty input, missing data, permissions, timeouts.
- Security: no secrets logged, no unsafe deserialization, no path traversal.
- Tests cover the new behavior and the changed edge cases.
- Docs/changelog match the actual behavior.
- Dependencies: no new transitive risk, versions pinned per SPEC.md.

## Output

Return each finding as: severity (blocker/major/minor/nit) + file:line + why
it matters + concrete fix. For every comment, either fix the root cause or
explain why the current behavior is intentional. Do not blindly accept or
dismiss AI suggestions.
