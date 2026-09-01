---
id: riverpod-hive-player-state-boundary
title: Riverpod controls locally persisted player state
category: decision
status: active
tags: [architecture, state, persistence]
created: "2026-09-01T02:22:22"
updated: "2026-09-01T02:22:22"
---

<!-- compiled_truth -->
## Decision

Use Riverpod notifiers as the application state boundary and Hive CE as the local persistence store. Player progression is centralized in `PlayerProfile`, and cat wellbeing is modeled separately with moods derived from hunger and energy rather than stored directly.

## Rationale

- A small solo-developed app benefits from compile-safe state updates and explicit persistence seams.
- Centralizing profile mutations preserves a future cloud-save and parent-dashboard migration path.
- Derived moods avoid stale emotional state and directly gate care prompts and minigames.

## Consequences

- UI and minigames should mutate profile data through `PlayerProfileNotifier`, not direct storage writes.
- Difficulty tier is persisted and should govern minigame complexity.
- Local-only data is a foundation for the privacy posture described in [[child-safety-and-progression-constraints]].


## Timeline

- time: 2026-09-01T02:22:22
  kind: decision
  summary: "Created this page: Riverpod controls locally persisted player state"
  source: "project_spec.md §3, §6, §10 and code"
  affects: [riverpod-hive-player-state-boundary]

- time: 2026-09-01T02:22:22
  kind: decision
  summary: Captured the Riverpod/Hive persistence and derived-mood boundary
  source: project_spec.md and kalias/lib/core
  affects: [riverpod-hive-player-state-boundary]
