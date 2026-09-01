---
slug: stack
title: Tech stack
role: tech-stack choices
updated: "2026-09-01T02:22:23"
---

# Tech stack

## Technology choices

| domain | decision | rationale |
|---|---|---|
| App UI and delivery | Flutter/Dart, Android-first with Web prototype | One codebase supports mobile delivery and browser review. See [[flutter-mobile-first-web-prototype]]. |
| Navigation | GoRouter | Declarative routes work for app navigation and prototype URLs. |
| State | Riverpod | Compile-safe state coordination for a solo-maintained app. |
| Persistence | Hive CE | Local profile, progression, inventory, and cat data without a backend. See [[riverpod-hive-player-state-boundary]]. |
| Audio | Flame Audio / audioplayers wrapper | Separate BGM and SFX integration with guarded calls while media is still being supplied. |
| Visual rendering | Flutter CustomPainter | Mood-reactive, handoff-faithful room and character visuals. See [[custom-painted-characters]]. |
| Testing | Flutter widget and golden tests | Painter outputs have golden coverage for visual review. |

## Open items

- Final art and audio are replaceable content handoffs; current painter and audio seams support that swap.
- Cloud save, parent dashboard, and purchases are future architecture considerations, not current dependencies.
