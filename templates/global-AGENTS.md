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
The best code is the code you never wrote. You solve the whole problem with the
least new code. End your reply with one or two lines: what you skipped or did
not check, and any risk the user must know.

### Before you write
Read the task and the code it touches. List every place your change must reach:
callers, tests, fixtures, config, exports. Check what your change could break
for users: data it would destroy or expose, callers that stop working. That is
scope. Extra features are not.

### The smallest complete change
Take the first option that fully works:
1. **Does it need to exist?** Skip features, options and flexibility nobody asked for, and name them in one line. A vague request ("build me X") gets the smallest version that does the core job.
2. **Already in this codebase** (a helper, component, service, pattern)? Use it the way the surrounding code does.
3. **Standard library or a platform feature?** Use it, unless the project has its own. A house component beats a native widget.
4. **An installed dependency?** Use it. Never add a dependency for a few lines.
5. **Can it be one line a reader gets at a glance?** One line.
6. **Otherwise:** the minimum code that works.

- Be lazy about the solution, never about the change itself: finish every part the task needs, including the callers, tests and fixtures your change breaks.
- No abstraction, wrapper, type conversion, option, config, boilerplate or "for later" code nobody asked for. Keep values in the form the platform already gives you. Deletion beats addition. Keep the structure the codebase already has: its layers, interfaces and conventions.
- The shortest working diff wins, once you know everything it must touch. A one-liner that needs decoding is not short.
- Comment only the why the code cannot show, in one line.
- Bug fix: before you edit, grep every caller of the function you touch, then fix the root cause once in the shared code.
- Code you move or merge keeps its error handling and validation.
- Between options of equal size, take the one that is correct on edge cases.
- Lazy code without its check is unfinished: new non-trivial logic (a branch, a loop, a parser, money or security, or a whole new script or app) leaves one small test or an assert-based self-check. Trivial changes need none.
- A shortcut with a known limit gets a code comment in this form: `shortcut: <the limit>, <when to upgrade>`. Older code may say `ponytail:`; ponytail-debt still finds both.

Never cut: validation at trust boundaries, error handling that prevents data
loss, security, accessibility, the calibration real hardware needs, anything the
user asked for.

Source: Ponytail v5.2.0 (MIT, github.com/DietrichGebert/ponytail), synced 2026-10-14.

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
- Non-trivial logic leaves one runnable check behind: the smallest thing that fails if the logic breaks (assert-based demo or a single small test, no framework or fixtures). Trivial one-liners need no check.
- Deliberate shortcuts stay visible: grep for `shortcut:` markers (older code may say `ponytail:`) before treating code as finished or safe to delete.
- If verification fails, fix the root cause instead of weakening the test.
- For UI changes, verify visually (screenshots or rendered output).

## Maintenance
- Keep this file short and actionable.
- When correcting an approach, tighten the relevant rule instead of appending a vague warning.
