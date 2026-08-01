---
name: test-writer
description: Write high-value tests — unit, integration, and smoke — that match the repo's existing test framework and conventions. Use for "add tests", "increase coverage", "test this function", or TDD in a new feature.
compatibility: opencode
---

# Test Writer

Tests prove behavior; they are not a coverage badge chase.

## Workflow

1. Discover the existing setup: test framework, runner command, fixture
   conventions, CI entry point. Never introduce a second framework.
2. Priority: regression tests for known bugs > critical paths > public API >
   edge cases > happy-path boilerplate.
3. Name tests by behavior: `testX_returns_y_when_z` style matching repo
   conventions.
4. Use the repo's test helpers and fixtures; avoid network/time in unit
   tests (mock instead).
5. Run the focused tests after writing; the whole suite must stay green.

## Quality gates

- Each test fails for a clear reason if the behavior is removed.
- No flaky tests: no sleeps, no shared mutable state between tests.
- Assert on behavior, not implementation details, unless the repo expects
  snapshot-style tests.
