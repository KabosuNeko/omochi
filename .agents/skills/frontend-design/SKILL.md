---
name: frontend-design
description: Design-first frontend work — establish visual direction (typography, color palette, spacing, layout) before implementation. Use for UI tasks, styling, components, landing pages, or "make it look good" requests. Load OMO's frontend-ui-ux skill for the designer-turned-developer persona.
compatibility: opencode
---

# Frontend Design

Design first, implement second. Never start writing components before the
visual direction is explicit.

## Workflow

1. If the repo has no design tokens, define them first in a small section of
   the task output: typography scale, color palette (with accessible
   contrast ratios), spacing scale, radius, shadows.
2. Load the OMO `frontend-ui-ux` skill (`skill` tool) for the designer
   persona: bold aesthetic direction, distinctive typography, cohesive
   palettes.
3. Sketch the layout (wireframe in text/ASCII or in code comments) before
   touching styles.
4. Implement with the existing stack only — check the project's package.json
   / build config before adding any dependency.
5. Verify responsive behavior at 375px / 768px / 1280px and check contrast.
6. Keep every change focused on the requested UI; do not refactor unrelated
   code.

## Delegation

For visual-heavy requests, delegate to the `visual-engineering` category or
let the main agent run this skill directly. Do not route to GPT-native
agents.
