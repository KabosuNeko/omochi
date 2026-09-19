---
name: frontend-design
description: Design-first frontend work — establish visual direction (typography, color palette, spacing, layout) before implementation, with strict anti-slop craftsmanship filters. Use for UI tasks, styling, components, landing pages, or "make it look good" requests.
compatibility: opencode
---

# Frontend Design

Design first, implement second. Never start writing components before the
visual direction is explicit.

## Workflow

1. If the repo has no design tokens, define them first in a small section of
   the task output: typography scale, color palette (with accessible
   contrast ratios), spacing scale, radius, shadows.
2. Establish a bold, intentional aesthetic direction: distinctive typography,
   cohesive palettes, purposeful hierarchy.
3. Sketch the layout (wireframe in text/ASCII or in code comments) before
   touching styles.
4. Implement with the existing stack only — check the project's package.json
   / build config before adding any dependency.
5. Verify responsive behavior at 375px / 768px / 1280px and check contrast.
6. Keep every change focused on the requested UI; do not refactor unrelated
   code.

## Craftsmanship & Anti-Slop Gates

Every visual and textual decision must pass a purpose test: what hierarchy or user
need does it serve? Reject generic AI defaults:

- **Color & Decoration**:
  - No generic blue-purple or neon gradients as defaults.
  - No excessive glassmorphism, floating shadows, or radial glow orbs on every element.
  - No pill-shaped everything; reserve rounded badges/capsules for actual tags.
  - Prefer solid contrast and intentional palette over stacked trendy effects.
- **Layout & Structure**:
  - No default bento grids or copy-paste 3-card feature columns unless the content naturally requires that shape.
  - Ensure interactive elements are functional (no unclickable mock buttons).
  - Respect native platform controls over heavy custom component wrappers.
- **Copywriting**:
  - Ban empty buzzwords ("seamless", "revolutionary", "unlock the power of", "next-generation").
  - Use clear, direct, and factual descriptions.
  - Never fabricate statistics, testimonials, or compliance claims.
- **Accessibility & Resilience**:
  - Maintain WCAG AA contrast for text against backgrounds.
  - Preserve visible focus indicators for keyboard navigation.
  - Handle loading, empty, and error states gracefully.

## Delegation

For visual-heavy requests or complex UI reviews, invoke an independent subagent or
execute locally with strict visual verification.
