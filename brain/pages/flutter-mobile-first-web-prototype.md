---
id: flutter-mobile-first-web-prototype
title: Flutter mobile-first app with web prototype
category: decision
status: active
tags: [architecture, platform]
created: "2026-09-01T02:22:22"
updated: "2026-09-01T02:22:22"
---

<!-- compiled_truth -->
## Decision

Kalia is built as one Flutter application, designed mobile-first for Android delivery. Flutter Web is a shared-codebase prototype and review surface rather than a shipping target; iOS is deferred but should remain technically possible.

## Rationale

- Android is the primary distribution target for children ages 3–8.
- The web build enables rapid stakeholder review without duplicating UI and game logic.
- Flutter provides a single Dart UI stack for both, while GoRouter keeps web routes addressable.

## Consequences

- Interaction design, touch targets, and orientation are optimized for mobile first.
- The development proxy configuration is captured in [[development-proxy-base-path]].
- Web-only debug constraints must not drive release-product architecture.


## Timeline

- time: 2026-09-01T02:22:22
  kind: decision
  summary: "Created this page: Flutter mobile-first app with web prototype"
  source: "project_spec.md §2–3 and git history"
  affects: [flutter-mobile-first-web-prototype]

- time: 2026-09-01T02:22:22
  kind: decision
  summary: Captured the mobile-first Flutter and web-prototype delivery boundary
  source: "project_spec.md §2–3"
  affects: [flutter-mobile-first-web-prototype]
