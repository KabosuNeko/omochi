---
name: grill-me
description: Adversarial questioning before starting non-trivial work. Asks tough questions about requirements, assumptions, failure modes, and acceptance criteria to expose plan gaps. Use for "grill me", "challenge my plan", or before any feature with ambiguous scope. Lightweight alternative to OMO hyperplan.
compatibility: opencode
---

# Grill Me

Scrutinize the plan before a single line of code is written.

## Flow

1. Ask the user (or read from SPEC.md/TASKS.md) the following, one at a
   time, aggressively but constructively:

   - What problem, exactly, and for whom? Who is NOT the user?
   - What happens if this feature is wrong — worst realistic failure?
   - Which existing behavior might this break? How would we notice?
   - What is the minimal version that proves the approach works?
   - What acceptance criteria are observable and testable?
   - What is explicitly out of scope / a non-goal?
   - What do you NOT know yet, and how will you find out?
   - If this takes 3x longer than expected, what is the fallback?

2. For each weak answer, propose a concrete resolution (split scope, add a
   test, spike, remove the requirement) — never just criticize.
3. If the plan survives without a changed decision, report the top-3 risks
   that remain and the cheapest experiment that would de-risk them.

## Delegation

For large plans, run this via the `metis` (gap analyzer) or `momus`
(reviewer) agent for an independent pass. For small plans, run locally —
this skill's value is the questions, not the model.
