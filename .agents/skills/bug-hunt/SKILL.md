---
name: bug-hunt
description: 'Systematic debugging of failing tests, crashes, or wrong behavior. Root-cause driven: reproduce, isolate, instrument, fix, verify. Use for "why is this broken", stack traces, flaky tests, or regression hunting. Delegates deep investigation to the oracle agent (Qwen3.7 Max).'
compatibility: opencode
---

# Bug Hunt

Debug like a scientist: reproduce first, hypothesize, prove, then fix.

## Delegation

For hard bugs (multi-file, intermittent, unfamiliar stack), delegate to the
`oracle` agent via `call_omo_agent` (subagent_type: oracle) — architecture
and debugging consultant. Use the local flow below for quick bugs.

## Local flow

1. Reproduce: get a minimal failing case (command, test, input). Never guess
   from the symptom alone.
2. Isolate: bisect — last change, half of the diff, or binary search over
   inputs until the fault line is found.
3. Instrument: add temporary logging or a debugger breakpoint at the fault
   line; read the actual values.
4. Root cause: state the mechanism in one sentence before proposing a fix.
   If you cannot, keep investigating — symptom-patching is forbidden.
5. Fix: smallest change that removes the cause. Add a regression test that
   fails on the old code and passes on the fix.
6. Verify: run the focused test, then the broader suite, then the original
   failing case.

## Anti-patterns

- No shotgun changes ("maybe this fixes it").
- No suppressing errors without handling them.
- No deleting tests to make CI pass.
