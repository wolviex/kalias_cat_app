# Project Spec: Kalia & The Feline Friends — Calm & Clever

> This document is the authoritative record of all planning decisions. Any architectural or scope decision made during development MUST be documented here. See `project_state.md` for current build status.

---

## 1. Product Overview

**Title:** Kalia & The Feline Friends: Calm & Clever
**Category:** Educational Life-Sim / Tamagotchi Hybrid
**Target Audience:** Ages 3–8 (three distinct difficulty tiers)
**Core Loop:** Care for cats → Play educational minigames → Earn XP/items → Level up & Customize
**Pitch:** A nurturing world where kids learn that taking care of their emotions is just as important as learning their ABCs.

---

## 2. Platform & Distribution

| Target | Details |
| :--- | :--- |
| **Primary** | Android (mobile-first, Google Play Store) |
| **Prototype** | Web (Flutter Web — same codebase, used for rapid iteration and stakeholder review) |
| **Future** | iOS (not in current scope; architecture should not block it) |

**Decision (2026-04-12):** All development is mobile-first in design, touch target sizes, and interaction model. Flutter Web is used exclusively for rapid prototyping and review — it is not a shipping target. A single Flutter codebase serves both.

---

## 3. Tech Stack

| Layer | Technology | Rationale |
| :--- | :--- | :--- |
| **UI / App Framework** | Flutter (Dart) | Cross-platform (Android + Web), strong 2D widget support, single codebase |
| **Game Rendering** | Flame Engine (Flutter game engine) | Lightweight 2D game framework built on Flutter; handles sprites, tilemaps, camera, and game loop without the overhead of Unity/Godot |
| **State Management** | Riverpod | Compile-safe, solo-dev-friendly, scales well; preferred over Provider or Bloc for this project size |
| **Local Storage** | Hive | Fast, NoSQL, no native code; stores player profile, XP, inventory, and cat states |
| **Navigation** | GoRouter | Declarative, URL-compatible (critical for web prototype routing) |
| **Audio** | Flame Audio (wraps audioplayers) | Integrated with Flame; handles BGM + SFX layers |
| **Haptics** | Flutter `HapticFeedback` API | Used in the breathing minigame; gracefully no-ops on web |

**Decision (2026-04-12):** Flame Engine chosen over a pure-Flutter widget approach because minigame interactions (sprite movement, collision detection for laser/letter game, animated state machines for cat moods) are well-suited to a game loop rather than widget rebuilds.

---

## 4. Art & Asset Pipeline

- All character and environment art is **generated via AI image tools** and iterated upon by the producer.
- The 4 PNGs in `/assets/` (Kalia, Noodles, Loaf Cat, Robot Cat) are **placeholders only**.
- Final art will be delivered as **high-contrast, soft-edged 2D vector-style PNG sprite sheets** (per concept spec).
- Animation will use **Flame's SpriteAnimationComponent** with sprite sheet atlas files.
- Asset handoff format: PNG sprite sheets + JSON atlas descriptors (Aseprite or TexturePacker compatible).
- Audio assets: OGG format for Android compatibility; MP3 fallback for web.

---

## 5. Characters & Educational Pillars

| Character | Role | Educational Pillar | Minigame |
| :--- | :--- | :--- | :--- |
| **Kalia** | Player Avatar | Social-Emotional Lead | (All games) |
| **Noodles** | High Energy / Goofy | Spelling / Letter Recognition | Laser Letters |
| **Loaf Cat** | Calm / Hungry | Math / Resource Management | Snack Stack |
| **Robot Cat** | Logical / Curious | Logic / Sequencing / Coding Basics | Logic Loop |
| *(All)* | Emotional State System | EQ / Self-Regulation | Calming the Zoomies |

---

## 6. Dynamic Difficulty Adjustment (DDA)

Selected by parent at onboarding. Can be changed in settings. The world is the same across all tiers; only UI scale, game complexity, and pacing shift.

| Tier | Age Range | Math | Spelling | EQ | Controls |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Explorer** | 3–4 | Shape matching, count to 5 | First-letter identification | Simple emoji-to-emotion | Large touch zones, no fail state |
| **Navigator** | 5–6 | Addition/subtraction within 10 | 3–4 letter CVC words | Helpful vs. unhelpful actions | Basic d-pad / joystick |
| **Master** | 7–8 | Multiplication, patterns, fractions | Full sentences, sight words | Conflict resolution, complex self-regulation | Full 360° movement, inventory management |

**Implementation note:** DDA tier is stored in the player profile (Hive). All minigame components read the active tier at launch via a `DifficultyProvider` (Riverpod). No game logic should hardcode difficulty — always branch on the provider value.

---

## 7. Core Game Systems

### 7.1 Cat Status System
Each cat has the following state fields:
- `hungerLevel` (0–100)
- `energyLevel` (0–100)
- `moodState` (enum: Happy, Neutral, Grumpy, Sad, Zoomies, Overloaded)
- `activeStatus` (emoji/icon bubble displayed above cat)

Status decays over real time (configurable rate). Cats require player interaction to maintain wellbeing. Emotional states gate specific minigames.

### 7.2 XP & Progression — "Purr-gress" System
- Two XP types: **Heart Sparks** (Care XP from feeding/grooming) and **Star Sparks** (Learning XP from minigames)
- Both feed the same "Purr-gress" bar (styled as a yarn ball unrolling)
- Bar fills → triggers **Magical Trunk** level-up sequence
- No pay-to-win: XP is only earned through care and learning activities

### 7.3 Magical Trunk (Level-Up Reward Loop)
Sequence: yarn bar fills → trunk bounces in room → player taps to open → three reward cards appear → player chooses one → item equips with animation.

Reward categories:
- Kalia's Gear (outfits, accessories)
- Cat Costumes (bowties, hats, wings)
- Interactive Toys (modify minigame difficulty/aesthetics)
- Status Boosters (instantly refill a cat's meter)

Milestone tiers:
- **Bonding Levels (1–10):** Basic colors and simple toys
- **Expert Care Levels (11–25):** Thematic matching sets; completing a set unlocks a Super Animation
- **Discovery Levels (26+):** New rooms and outdoor areas unlock

### 7.4 Inventory & Closet
- Persistent inventory stored in Hive
- "Magic Closet" UI accessible from main room
- Equipped items visible on characters in the main scene

### 7.5 Calm Corner
- A dedicated space accessible from the main room at any time (not gated by cat state)
- Contains: guided breathing exercises, sensory play widgets (digital kinetic sand, pop-its)
- Intentionally minimal visual complexity; calming audio on entry

---

## 8. Minigames

### MG-1: Calming the Zoomies (EQ / Self-Regulation)
**Trigger:** Noodles reaches `Zoomies` mood state
**Core mechanic:** Haptic breathing circle — player holds/releases finger to match expanding/contracting ring
**DDA:** Breath duration shorter for Explorer; multi-cycle synchronization for Master
**Reference:** `Concept/MiniGame1.MD`

### MG-2: Robot Cat's Logic Loop (Logic / Sequencing)
**Trigger:** Robot Cat's `broken gear` status
**Core mechanic:** Drag-and-drop shape/command sequences into a power grid
**DDA:** 2-step simple pattern (Explorer) → 3-step with distractors (Navigator) → grid-based coding commands (Master)
**Reference:** `Concept/MiniGame2.MD`

### MG-3: Noodles' Laser Letters (Spelling / Letter Recognition)
**Trigger:** Player initiates play with Noodles while energy is high
**Core mechanic:** Player drags laser dot; Noodles chases it to "pounce" on letters in order
**DDA:** Single-letter matching (Explorer) → CVC words with distractors (Navigator) → moving letters, sight words (Master)
**Reference:** `Concept/MiniGame3.MD`

### MG-4: Loaf Cat's Snack Stack (Math / Resource Management)
**Trigger:** Loaf Cat's `hungerLevel` below threshold
**Core mechanic:** Drag food items to fulfill a specific count/composition order
**DDA:** Simple 1-to-1 counting (Explorer) → addition and halves (Navigator) → fractions and multiplication sets (Master)
**Reference:** `Concept/MiniGame4.MD`

---

## 9. Development Phases

### Phase 0 — Project Foundation
- [ ] Flutter project init (with Flame, Riverpod, Hive, GoRouter dependencies)
- [ ] Folder structure and asset pipeline setup
- [ ] Web prototype build pipeline confirmed (flutter build web)
- [ ] Placeholder art integrated into asset system
- [ ] DifficultyProvider and PlayerProfile model implemented
- [ ] Basic navigation skeleton (Home → Room → Minigame → Reward)

### Phase 1 — Core Room & Cat System MVP
- [ ] Main room scene with all 4 characters as sprites
- [ ] Cat status system (mood states, decay loop, status bubble display)
- [ ] Basic interaction: tap cat → see status
- [ ] DDA tier selection at onboarding
- [ ] Purr-gress bar UI (no rewards yet)

### Phase 2 — First Minigame (EQ — Calming the Zoomies)
- [ ] Zoomies state triggers minigame
- [ ] Breathing circle mechanic with haptic feedback
- [ ] All 3 DDA variants functional
- [ ] XP emit on success → feeds Purr-gress bar

### Phase 3 — Remaining Minigames
- [ ] MG-4: Loaf Cat's Snack Stack (math — highest content reuse, build second)
- [ ] MG-2: Robot Cat's Logic Loop (sequencing)
- [ ] MG-3: Noodles' Laser Letters (most complex — laser physics, letter sprites)

### Phase 4 — Progression & Reward Loop
- [ ] Magical Trunk level-up sequence
- [ ] Reward card system (3-card pick)
- [ ] Inventory and Magic Closet UI
- [ ] Equipped items rendered on characters in room

### Phase 5 — Calm Corner & EQ Polish
- [ ] Calm Corner room/overlay
- [ ] Feelings Check-In mechanic (Mood Mirror)
- [ ] Sensory play widgets (kinetic sand / pop-its)
- [ ] Full audio layer (BGM per room, SFX per interaction)

### Phase 6 — Android Release Prep
- [ ] COPPA compliance audit (no third-party data collection, no ads)
- [ ] Play Store assets (screenshots, listing copy, age rating)
- [ ] Performance profiling on mid-range Android devices
- [ ] Accessibility review (touch target sizes, contrast ratios)
- [ ] Free tier release

### Phase 7 (Future) — One-Time Purchase
- [ ] In-app purchase integration (Google Play Billing)
- [ ] Define free vs. paid content split
- [ ] Parental gate for purchase flow

---

## 10. Future Architecture: Cloud Save & Parent Dashboard

> **Not in current scope. Documented here to ensure the local architecture does not block future implementation.**

### Desired Cloud Features
- **Multi-device sync:** Player profile, XP, inventory synced across devices
- **Parent Dashboard:** Web view (separate from child app) showing learning activity, time played, skills practiced, and emotional regulation moments
- **Progress Reports:** Weekly summary of minigame completions by category (Math, Spelling, EQ, Logic)

### Architectural Guardrails (apply now)
- All player data must live in a **single `PlayerProfile` model** (currently serialized to Hive). This model will become the cloud sync payload.
- No minigame logic should write state directly — always go through `PlayerProfileNotifier` (Riverpod). This keeps a clean seam for a future sync layer.
- The `PlayerProfile` model must be versioned (include a `schemaVersion` field) to support migrations.

---

## 11. Content Team Collaboration

| Role | Responsibility |
| :--- | :--- |
| **Developer (solo)** | All code, architecture, build pipeline |
| **Research Educator** | Validates educational accuracy of minigame content, DDA calibration, EQ script review |
| **Producer** | Art direction, generative AI asset creation, dialogue/copy writing, minigame scenario expansion |

**Content handoff format:** Minigame content (word lists, math problems, dialogue) delivered as JSON data files, not hardcoded. This allows the educator and producer to update content without touching Dart code.

---

## 12. Non-Negotiables (from concept)
- Zero third-party ads — ever
- COPPA compliant
- No fail states for Explorer tier
- No harsh audio feedback (gentle low-buzz for wrong answers, never jarring)
- No pay-to-win mechanics — all progression through play
- Lo-fi, low-frequency background music to prevent overstimulation
- High-contrast, soft-edged visuals for young eyes
