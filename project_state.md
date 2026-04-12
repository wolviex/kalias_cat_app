# Project State: Kalia & The Feline Friends

> This document tracks build progress. Updated at the start and end of every work session. See `project_spec.md` for the full plan.

---

## Current Phase: Phase 1 — Core Room & Cat System MVP

**Status:** Not started

---

## Phase Completion

| Phase | Name | Status |
| :--- | :--- | :--- |
| **Phase 0** | Project Foundation | ✅ Complete |
| **Phase 1** | Core Room & Cat System MVP | Not started |
| **Phase 2** | First Minigame (Calming the Zoomies) | Not started |
| **Phase 3** | Remaining Minigames (x3) | Not started |
| **Phase 4** | Progression & Reward Loop | Not started |
| **Phase 5** | Calm Corner & EQ Polish | Not started |
| **Phase 6** | Android Release Prep | Not started |
| **Phase 7** | One-Time Purchase (Future) | Not started |

---

## Phase 0 Checklist

- [x] Flutter 3.41.6 confirmed (Dart 3.11.4)
- [x] Flutter project initialized at `kalias/` — Flame, Riverpod, Hive CE, GoRouter, flame_audio
- [x] Folder/asset structure established (`characters/`, `backgrounds/`, `ui/`, `audio/`, `data/`)
- [x] Placeholder character PNGs copied to `kalias/assets/characters/`
- [x] `DifficultyTier` enum created (`lib/core/models/difficulty_tier.dart`)
- [x] `PlayerProfile` Hive model created + adapter generated (`lib/core/models/player_profile.dart`)
- [x] `PlayerProfileNotifier` (Riverpod) wired up (`lib/core/providers/player_profile_provider.dart`)
- [x] Navigation skeleton: Home → Room → Minigame (×4 stubs) → Reward (`lib/core/router/app_router.dart`)
- [x] Web prototype build confirmed: `flutter build web` ✓

---

## Flutter Project Structure

```
kalias/
├── lib/
│   ├── main.dart                          # App entry point, Hive init, ProviderScope
│   ├── core/
│   │   ├── models/
│   │   │   ├── difficulty_tier.dart       # DDA enum (sprout / seedling / bloom)
│   │   │   ├── player_profile.dart        # Hive model — XP, character, tier, progress
│   │   │   └── player_profile.g.dart      # Generated Hive adapter
│   │   ├── providers/
│   │   │   └── player_profile_provider.dart  # Riverpod notifier + box provider
│   │   ├── router/
│   │   │   └── app_router.dart            # GoRouter config + AppRoutes constants
│   │   └── theme/                         # (Phase 1) custom typography/colors
│   ├── features/
│   │   ├── home/home_screen.dart          # Greeting + "Enter Room" button
│   │   ├── room/room_screen.dart          # 2×2 minigame card grid
│   │   ├── minigames/
│   │   │   ├── breathing/                 # Stub → Phase 2
│   │   │   ├── eq_sort/                   # Stub → Phase 2
│   │   │   ├── reading/                   # Stub → Phase 2
│   │   │   └── math/                      # Stub → Phase 2
│   │   └── reward/reward_screen.dart      # +10 XP, Purr-gress display, Back to Room
│   └── shared/widgets/                    # (Phase 1) reusable UI components
└── assets/
    ├── characters/   # 4 placeholder PNGs (Kalia, Loaf Cat, Noodles, Robot Cat)
    ├── backgrounds/  # placeholder
    ├── ui/           # placeholder
    ├── audio/sfx/    # placeholder
    ├── audio/music/  # placeholder
    └── data/         # placeholder.json
```

---

## Known Blockers / Open Items

- Final art assets: not yet available. All 4 character PNGs are AI-generated placeholders.
- Content JSON files (word lists, math problems, dialogue): not yet created — awaiting educator/producer collaboration.
- Character selection screen: not yet built — player always starts as "Kalia" (default in `PlayerProfile.defaults`).
- Onboarding/DDA selection screen: not yet built — tier defaults to `seedling`.

---

## Session Log

| Date | Work Done |
| :--- | :--- |
| 2026-04-12 | Project scoped. `project_spec.md` written. Tech stack decided (Flutter + Flame + Riverpod + Hive). Platform confirmed Android-first + web prototype. |
| 2026-04-12 | Attempted Phase 0 start. Flutter SDK not found in PATH. Container reload required. |
| 2026-04-12 | **Phase 0 complete.** Flutter 3.41.6 confirmed. Full project scaffold built: models, providers, router, all screen stubs. `flutter analyze` clean. `flutter build web` ✓. |
