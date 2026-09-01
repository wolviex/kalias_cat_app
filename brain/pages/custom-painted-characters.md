---
id: custom-painted-characters
title: Use CustomPainter characters instead of placeholder sprite sheets
category: decision
status: active
tags: [art, architecture, testing]
created: "2026-09-01T02:22:22"
updated: "2026-09-01T02:22:22"
---

<!-- compiled_truth -->
## Decision

Room characters and care-sheet portraits use Flutter `CustomPainter` implementations based on the design-handoff artwork. The AI-generated PNG sprite sheets remain source references and a possible future asset seam, but are not the production room rendering path.

## Rationale

- Placeholder sheets contain labels and checkerboard backgrounds, so they cannot be cleanly sliced.
- Painter inputs accept live `MoodState`, allowing visual reactions without a static-asset matrix.
- The room already uses CustomPainter props, keeping the visual system consistent and avoiding an added SVG dependency.

## Consequences

- Character rendering lives behind `PaintedCharacter` and painter classes in shared widgets.
- Golden tests provide component-level visual regression coverage.
- Final producer art can replace this implementation through the existing widget seam.


## Timeline

- time: 2026-09-01T02:22:22
  kind: decision
  summary: "Created this page: Use CustomPainter characters instead of placeholder sprite sheets"
  source: "project_spec.md §4, Concept/progress_plan.md, git commit 6666fcf"
  affects: [custom-painted-characters]

- time: 2026-09-01T02:22:22
  kind: decision
  summary: Captured the design-handoff CustomPainter character decision
  source: "project_spec.md §4 and 2026-07 history"
  affects: [custom-painted-characters]
