# Project State: Kalia & The Feline Friends

> This document tracks build progress. Updated at the start and end of every work session. See `project_spec.md` for the full plan.

---

## Current Phase: Phase 6 — Android Release Prep

**Status:** Not started (Phases 3, 4, 5 complete)

---

## Phase Completion

| Phase | Name | Status |
| :--- | :--- | :--- |
| **Phase 0** | Project Foundation | ✅ Complete |
| **Phase 1** | Core Room & Cat System MVP | ✅ Complete |
| **Phase 2** | Care Loop, Persistence & First Minigames | ✅ Complete |
| **Phase 3** | Remaining Minigames (x3) | ✅ Complete |
| **Phase 4** | Progression & Reward Loop | ✅ Complete |
| **Phase 5** | Calm Corner & EQ Polish | ✅ Complete |
| **Phase 6** | Android Release Prep | Not started |
| **Phase 7** | One-Time Purchase (Future) | Not started |

---

## Phase 5 Checklist

- [x] Calm Corner screen (`lib/features/calm_corner/calm_corner_screen.dart`) — dark indigo theme; always accessible from room AppBar (🧘 icon); 3 activity hub tiles + Mood Mirror link; switches to calm BGM on entry, restores room BGM on exit
- [x] Free breathing activity — 4-cycle no-DDA version embedded in Calm Corner; expanding circle animation; tap to start/restart
- [x] Pop-Its — 5×6 bubble grid in Calm Corner; each bubble pops with scale animation; all-clear celebration + auto-reset; plays `sfx/pop.mp3` hook
- [x] Kinetic Sand — touch/drag CustomPainter canvas; 6-colour palette; scatter dots with blur; clear button
- [x] Mood Mirror screen (`lib/features/calm_corner/mood_mirror_screen.dart`) — 6 feeling cards (Happy/Calm/Sad/Angry/Worried/Tired); per-feeling affirming text; "Let's breathe together" CTA for difficult emotions; fade-in animation
- [x] AudioService (`lib/core/services/audio_service.dart`) — `ChangeNotifierProvider`; `playBgm()`, `stopBgm()`, `playSfx()`, `toggleMute()`; all calls try/catch guarded
- [x] Audio hooks placed at: room BGM (infrastructure ready), calm BGM on entry/exit, pop SFX in Pop-Its
- [x] Mute toggle button in room AppBar and Calm Corner AppBar
- [x] Routes `/calm-corner` and `/mood-mirror` added to router
- [x] `flutter analyze` — no issues
- [ ] Audio files pending from content team (see spec §Phase 5 for full list)

---

## Phase 4 Checklist

- [x] `RewardCatalog` — 21 items: 8 Kalia Gear (trunks 1–5), 8 Cat Costumes (6–10), 5 Toys (11+) (`lib/core/models/reward_item.dart`)
- [x] `PlayerProfile` extended — `pendingTrunks`, `inventory: List<String>`, `equipped: Map<String,String>` (fields 8–10); Hive adapter regenerated
- [x] `addXp()` auto-increments `pendingTrunks` per completed cycle
- [x] `PlayerProfileNotifier.openTrunk()` — awards item to inventory, decrements pending, increments `trunkOpenCount`
- [x] `PlayerProfileNotifier.equip()` — sets/clears slot in `equipped` map
- [x] Trunk screen (`lib/features/trunk/trunk_screen.dart`) — bounce animation → tap to open → 3 random cards (prefers un-owned) → pick one → elastic reveal → back to room
- [x] Reward screen — shows purple "🧳 Trunk Unlocked!" banner when `pendingTrunks > 0`; routes to `/trunk`
- [x] Closet screen (`lib/features/closet/closet_screen.dart`) — inventory grid grouped by category; tap to equip/unequip; empty state
- [x] Routes `/trunk` and `/closet` added to `app_router.dart`
- [x] Room: 🧳 wardrobe icon in AppBar → closet; trunk item pulses orange when pending; character badge overlays for equipped hat/accessory slots
- [x] `flutter analyze` — no issues

---

## Phase 3 Checklist

- [x] Room redesigned: grid → `LayoutBuilder` + `Stack` + `Positioned` (% of screen width); natural depth layering
- [x] Yarn corner interactive item (`item_yarn_corner.png`) — `_RoomItem` with pulse glow, tap → MG-1; used as pattern for all future room items
- [x] Noodles sprite sheet integrated (`noodles_sprite.png` — 1536×921, 4×3 frames at 384×307px); mood-driven animation (idle/dance/run) via `NoodlesSprites` catalog
- [x] `SpriteSheetAnimator` — BoxFit.contain aspect-ratio logic; `child: SizedBox.expand()` fix for zero-size CustomPaint
- [x] MG-2: Feelings Sort (`eq_sort_screen.dart`) — drag emotion cards to feeling buckets; 3 DDA tiers; wrong-drop red flash; completes via Robot Cat
- [x] MG-5: Robot Cat's Logic Loop (`logic_loop_screen.dart`) — tap-to-fill sequence puzzle; shape tiles (Sprout/Seedling) + robot command tiles (Bloom); wrong flash + validate
- [x] Logic Loop route `/minigame/logic-loop` wired in router + dev games menu
- [x] `flutter analyze` — no issues

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
│   │   │   ├── kalia_sprites.dart             # Kalia sprite sheet frame rects
│   │   │   ├── noodles_sprites.dart           # Noodles sprite sheet — idle/dance/run frames
│   │   │   ├── player_profile.dart            # Hive model — XP, inventory, equipped, progress
│   │   │   ├── player_profile.g.dart          # Generated Hive adapter (fields 0–10)
│   │   │   └── reward_item.dart               # RewardItem, RewardCatalog, RewardSlots (21 items)
│   │   ├── providers/
│   │   │   ├── cats_provider.dart             # CatsNotifier — all 3 cats + decay timer
│   │   │   └── player_profile_provider.dart   # Notifier: addXp, openTrunk, equip
│   │   ├── router/
│   │   │   └── app_router.dart                # GoRouter — all routes incl. trunk, closet
│   │   └── theme/                             # (Phase 5) custom typography/colors
│   ├── features/
│   │   ├── home/home_screen.dart              # Greeting + "Enter Room" button
│   │   ├── onboarding/onboarding_screen.dart  # Name entry + DDA tier picker
│   │   ├── room/room_screen.dart              # Stack-positioned room; trunk + badges + closet btn
│   │   ├── minigames/
│   │   │   ├── breathing/breathing_screen.dart     # MG-1: Calming the Zoomies ✅
│   │   │   ├── eq_sort/eq_sort_screen.dart         # MG-2: Feelings Sort ✅
│   │   │   ├── reading/reading_screen.dart         # MG-3: Laser Letters — stub (Phase 5)
│   │   │   ├── math/math_screen.dart               # MG-4: Snack Stack ✅
│   │   │   └── logic_loop/logic_loop_screen.dart   # MG-5: Logic Loop ✅
│   │   ├── reward/reward_screen.dart          # XP celebration + trunk CTA if pendingTrunks > 0
│   │   ├── trunk/trunk_screen.dart            # Trunk opening: bounce → 3 cards → reveal
│   │   ├── closet/closet_screen.dart          # Inventory grid; equip/unequip by slot
│   │   └── calm_corner/
│   │       ├── calm_corner_screen.dart        # Hub + breathe/pop-its/sand activities inline
│   │       └── mood_mirror_screen.dart        # 6 feeling cards + affirming messages
│   ├── core/services/
│   │   └── audio_service.dart                 # AudioService + provider; BGM/SFX hooks
│   └── shared/widgets/
│       ├── cat_sprite.dart                    # Tappable sprite + mood bubble + status sheet
│       ├── purr_progress_bar.dart             # XP bar at room bottom
│       └── sprite_sheet_animator.dart         # Generic sprite sheet → Canvas, BoxFit.contain
└── assets/
    ├── characters/   # Kalia + Noodles sprite sheets; Loaf Cat + Robot Cat placeholders
    ├── backgrounds/  # bg_room_wall, bg_room_floor, item_yarn_corner, item_magical_trunk (pending)
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
| 2026-04-13 | **Phase 3 complete.** Room redesigned to Stack/Positioned layout. Yarn corner item with pulse glow. Noodles sprite sheet (384×307 frames, mood-driven anim). SpriteSheetAnimator BoxFit.contain fix. MG-2 Feelings Sort (drag-and-drop, 3 DDA tiers). MG-5 Robot Cat's Logic Loop (sequence puzzle, shape + command tiles). Dev env documented (profile mode workaround, NPM WebSocket headers). `flutter analyze` clean. |
| 2026-04-14 | **Phase 4 complete.** RewardCatalog (21 items, 3 categories). PlayerProfile extended (pendingTrunks, inventory, equipped — fields 8–10, adapter regenerated). Trunk screen (bounce → card pick → reveal). Reward screen trunk CTA. Closet screen (equip/unequip grid). Trunk + closet routes. Room: trunk item, closet AppBar button, equipped emoji badge overlays on all characters. `flutter analyze` clean. |
| 2026-04-14 | **Phase 5 complete.** Calm Corner screen (hub → breathe/pop-its/sand activities). Free breathing (4-cycle, no XP). Pop-Its (5×6 grid, pop animation, auto-reset). Kinetic Sand (touch-draw canvas, 6-colour palette). Mood Mirror screen (6 feelings, affirming messages, breathe CTA). AudioService (flame_audio wrapper, BGM+SFX hooks, mute toggle, try/catch guarded). Routes `/calm-corner` + `/mood-mirror`. Room AppBar: mute + calm corner buttons. `flutter analyze` clean. |
