---
name: ponytail-audit
description: Whole-repo audit for over-engineering. Ranks what to delete, simplify, or replace with a standard-library or platform-native equivalent, tagged delete, stdlib, native, reuse, yagni, shrink. Use for "audit this codebase", "what can I delete", "find bloat", or before a large refactor. Report only, applies nothing.
compatibility: opencode
---

# Ponytail Audit

Repo-wide companion to `code-review`: scan the whole tree for complexity instead
of one diff, and rank findings biggest cut first.

## Tags

- `delete:` dead code, unused flexibility, speculative feature. Replacement: nothing.
- `stdlib:` hand-rolled thing the standard library ships. Name the function.
- `native:` dependency or code doing what the platform already does. Name the feature.
- `reuse:` equivalent helper, util, or pattern already in this repo. Name the path.
- `yagni:` abstraction with one implementation, config nobody sets, layer with one caller.
- `shrink:` same logic, fewer lines. Show the shorter form.

## Hunt

Dependencies the stdlib or platform already ships; single-implementation
interfaces; factories with one product; wrappers that only delegate; files
exporting one thing; dead flags and config; hand-rolled stdlib; helpers
duplicating an equivalent that already lives in the repo. Before emitting
`delete:`, grep the whole tree for the symbol, including tests, fixtures, and
string or dynamic references.

## Output

One line per finding, numbered and ranked:
`<N>. <tag> <what to cut>. <replacement>. [path]`
so the user can reply "fix 2 and 5". Close with `net: -<N> lines, -<M> deps
possible.`; when there is nothing to cut, say `Lean already. Ship.`

## Boundaries

Scope is over-engineering only. Correctness, security, and performance findings
are out of scope: route them to `code-review`. Report only, never apply fixes,
and never delete pre-existing code the user did not ask about.

Adapted from Ponytail v4.13.0 (MIT): github.com/DietrichGebert/ponytail
