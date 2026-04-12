# Project State: Kalia & The Feline Friends

> This document tracks build progress. Updated at the start and end of every work session. See `project_spec.md` for the full plan.

---

## Current Phase: Phase 3 — Remaining Minigames & Sprite Polish

**Status:** Not started

---

## Phase Completion

| Phase | Name | Status |
| :--- | :--- | :--- |
| **Phase 0** | Project Foundation | ✅ Complete |
| **Phase 1** | Core Room & Cat System MVP | ✅ Complete |
| **Phase 2** | Care Loop, Persistence & First Minigames | ✅ Complete |
| **Phase 3** | Remaining Minigames (x3) | Not started |
| **Phase 4** | Progression & Reward Loop | Not started |
| **Phase 5** | Calm Corner & EQ Polish | Not started |
| **Phase 6** | Android Release Prep | Not started |
| **Phase 7** | One-Time Purchase (Future) | Not started |

---

## Phase 2 Checklist

- [x] Cat state persistence — Hive `cat_states` box; retroactive decay on re-launch (8h cap)
- [x] Feed/Play visual feedback — `AnimatedSwitcher` on mood bubble shows 🍖/⚡ for 1.5s; reaction cleared automatically
- [x] Heart Sparks XP — +5 XP on feed and play, awarded via `PlayerProfileNotifier`
- [x] Kalia avatar profile sheet — name, tier, total XP, trunk count, change tier in-place
- [x] Cat state → minigame triggers — `minigameTriggered` computed on `CatState`; pulsing `!` badge on sprite; trigger banner with "Play" button in status sheet
- [x] MG-1: Calming the Zoomies — breathing circle with DDA (2/3/4 cycles, haptic feedback); restores Noodles +40 energy; +15 Star Sparks XP
- [x] MG-4: Loaf Cat's Snack Stack — tap-to-feed counting game; DDA (1-food Sprout / 2-food Seedling+); restores Loaf Cat +40 hunger; +15 XP
- [x] Reward screen — accepts `xpEarned` via router `extra`; shows Purr-gress bar; no double-XP
- [x] `flutter analyze` — no issues

---

## Phase 1 Checklist

- [x] Main room scene with all 4 characters as sprites (`room_screen.dart`)
- [x] `CatId`, `MoodState`, `CatState` models (`lib/core/models/cat_state.dart`)
- [x] `CatsNotifier` — in-memory cat state with 30s decay timer (`lib/core/providers/cats_provider.dart`)
- [x] Tap cat → bottom sheet with hunger/energy bars + Feed/Play buttons
- [x] Status mood bubble above each cat (emoji + color-coded)
- [x] Kalia player avatar in room (no status bubble; tap shows "That's you!" snackbar)
- [x] Onboarding screen — name entry + DDA tier picker, auto-redirects on first launch
- [x] Purr-gress bar at bottom of room (`lib/shared/widgets/purr_progress_bar.dart`)
- [x] Dev games menu in AppBar (🎮 icon) for stub navigation until Phase 2 triggers
- [x] `flutter analyze` — no issues

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
│   ├── main.dart                              # App entry point, Hive init, ProviderScope
│   ├── core/
│   │   ├── models/
│   │   │   ├── cat_state.dart                 # CatId, MoodState, CatState (computed mood)
│   │   │   ├── difficulty_tier.dart           # DDA enum (sprout / seedling / bloom)
│   │   │   ├── player_profile.dart            # Hive model — XP, character, tier, progress
│   │   │   └── player_profile.g.dart          # Generated Hive adapter
│   │   ├── providers/
│   │   │   ├── cats_provider.dart             # CatsNotifier — all 3 cats + decay timer
│   │   │   └── player_profile_provider.dart   # Riverpod notifier + box provider
│   │   ├── router/
│   │   │   └── app_router.dart                # GoRouter + first-launch redirect
│   │   └── theme/                             # (Phase 2) custom typography/colors
│   ├── features/
│   │   ├── home/home_screen.dart              # Greeting + "Enter Room" button
│   │   ├── onboarding/onboarding_screen.dart  # Name entry + DDA tier picker
│   │   ├── room/room_screen.dart              # Live room: 4 sprites + Purr-gress bar
│   │   ├── minigames/
│   │   │   ├── breathing/                     # Stub → Phase 2 (Calming the Zoomies)
│   │   │   ├── eq_sort/                       # Stub → Phase 3 (Logic Loop)
│   │   │   ├── reading/                       # Stub → Phase 3 (Laser Letters)
│   │   │   └── math/                          # Stub → Phase 3 (Snack Stack)
│   │   └── reward/reward_screen.dart          # +10 XP, Purr-gress display, Back to Room
│   └── shared/widgets/
│       ├── cat_sprite.dart                    # Tappable sprite + mood bubble + status sheet
│       └── purr_progress_bar.dart             # XP bar at room bottom
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
| 2026-04-12 | **Phase 1 complete.** Room scene live with 4 character sprites. Cat status system with mood states and 30s decay timer. Tap-to-status bottom sheet with Feed/Play buttons. Onboarding screen (name + DDA tier). Purr-gress bar. `flutter analyze` clean. |
| 2026-04-12 | **Phase 2 complete.** Cat state persistence (Hive + retroactive decay). Feed/Play XP (+5). Animated mood bubble reactions. Minigame trigger badges + banners. MG-1 Calming the Zoomies (breathing circle, 3 DDA tiers, haptics). MG-4 Snack Stack (tap-to-count, 2 DDA tiers). Kalia profile sheet. Reward screen with XP param. `flutter analyze` clean. |
