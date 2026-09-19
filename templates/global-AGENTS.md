# Global instructions (applies to every repo)

## Working Style & Scope
- Inspect repo structure and existing docs (`AGENTS.md`, `README.md`) before editing.
- State the brief plan and verification criteria before making non-trivial changes.
- Touch only what the task requires. Do not add speculative features, abstractions, or hooks.
- Avoid drive-by refactors, formatting, or cleanup. Preserve unrelated user changes.
- Say when a premise appears wrong before implementing around it.
- Use simple ASCII punctuation.
- Never expose credentials, tokens, private keys, or secret files.
- Skip filler: no flattery, ceremonial openings, or emoji. Keep communication direct.

## Minimalist Code Ladder (Ponytail Craftsmanship)
The best code is the code you never wrote. Before adding new code or dependencies, climb this ladder in order:
1. **YAGNI (You Ain't Gonna Need It)**: Does this task or feature actually need to exist? If not, skip it.
2. **Reuse**: Does identical or similar logic already exist in the codebase? Reuse it.
3. **Standard Library**: Can the language standard library solve this? Never install a package when stdlib suffices.
4. **Platform Native**: Can native platform/browser features handle it? (e.g., native HTML elements, CSS layout, native fetch, subshell pipes).
5. **Existing Dependencies**: If a package is unavoidable, use only what is already in project manifests.
6. **One-Liner**: Can this be expressed cleanly in a simple, readable line or small block?
7. **Minimum Code**: Write only the minimum necessary code. Zero speculative abstractions, zero single-implementer interfaces, zero premature wrappers.

## Anti-Slop & Hygiene Gates
- **No commentary slop**: No decorative banner comments, narrative workflow comments (`// step 1: do this`), or obvious restatements.
- **Root-cause seams**: Fix bugs at their structural seam rather than wrapping symptoms with defensive null checks.
- **Dead code**: Delete dead branches and unused variables immediately.

## Documentation Routing
- Read only the documents needed for the specific task; do not load `docs/` speculatively:
  - `SPEC.md` for product requirements and scope boundaries.
  - `TASKS.md` for current progress and pending work.

## Command Execution & RTK Strategy
- **Use `rtk` (or filters) for noisy commands:** Broad searches, dependency lists, build logs, linters, and large test suites where a summary is enough.
- **Use raw commands for precise tasks:** Inspecting specific files, validating exact stdout/stderr, checking exit status, or debugging pipeline behavior.
- **Chain smartly:** Apply `rtk` only to the noisy segments of a pipeline.
- **Escape Hatch:** If `rtk` hides required details, rejects a flag, or complicates debugging, drop `rtk` and re-run raw immediately. Do not guess.

## Verification & Debugging
- Prefer running code, tests, and linters over assuming correctness.
- Read complete error logs and stack traces before fixing.
- If a command output appears truncated, read the raw log from `~/.local/share/rtk/tee/` instead of re-running blindly.
- Run the smallest meaningful check during iteration; run the full verification before reporting done.
- If verification fails, fix the root cause instead of weakening the test.
- For UI changes, verify visually (screenshots or rendered output).

## Maintenance
- Keep this file short and actionable.
- When correcting an approach, tighten the relevant rule instead of appending a vague warning.
