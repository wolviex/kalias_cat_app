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

| Character | Role | Educational Pillar | Minigame(s) |
| :--- | :--- | :--- | :--- |
| **Kalia** | Player Avatar | Social-Emotional Lead | (All games — companion) |
| **Noodles** | High Energy / Goofy | EQ Self-Regulation + Spelling | MG-1: Calming the Zoomies · MG-3: Laser Letters |
| **Loaf Cat** | Calm / Hungry | Math / Counting | MG-4: Snack Stack |
| **Robot Cat** | Logical / Curious | EQ Literacy + Logic / Sequencing | MG-2: Feelings Sort · MG-5: Logic Loop |

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
- `hungerLevel` (0–100, where 100 = fully satisfied / 0 = starving)
- `energyLevel` (0–100, where 100 = fully rested / 0 = exhausted)
- `moodState` (enum: Happy, Neutral, Grumpy, Sad, Zoomies, Overloaded) — computed from levels, never stored
- `activeStatus` (emoji/icon bubble displayed above cat)

Status decays over real time (configurable rate). Cats require player interaction to maintain wellbeing. Emotional states gate specific minigames.

**Care actions and visible feedback (Phase 2):**
- **Feed** — increases `hungerLevel` by +25. Shows a food particle animation rising from the cat. If cat was Grumpy/Sad due to hunger, mood bubble updates immediately.
- **Play** — increases `energyLevel` by +25. Shows a sparkle/bounce animation on the cat sprite. If Noodles' energy reaches the Zoomies threshold, Zoomies mood triggers.
- Both actions award **Heart Sparks XP** (see §7.2) and persist to Hive immediately.

**Cat state persistence (Phase 2):** Hunger and energy levels will be snapshotted to Hive on every care action and on app background. On re-launch, real-time elapsed time is calculated and decay is applied retroactively (capped at 8 hours to avoid punishing long absences).

### 7.2 XP & Progression — "Purr-gress" System
- Two XP types: **Heart Sparks** (Care XP from feeding/playing) and **Star Sparks** (Learning XP from minigames)
- Both feed the same "Purr-gress" bar (styled as a yarn ball unrolling)
- Bar fills → triggers **Magical Trunk** level-up sequence
- No pay-to-win: XP is only earned through care and learning activities

**XP award table:**

| Action | XP | Type |
| :--- | :--- | :--- |
| Feed a cat | +5 | Heart Sparks |
| Play with a cat | +5 | Heart Sparks |
| Complete any minigame | +15 | Star Sparks |
| Complete minigame (all DDA variants) | +20 | Star Sparks |
| Daily first login | +10 | Heart Sparks |

**Purr-gress cycle = 100 XP.** Each completed cycle opens one Magical Trunk (Phase 4).

**Milestone unlocks (provisional — content team to finalise):**

| Trunk # | Unlock |
| :--- | :--- |
| 1–5 | Kalia outfit accessories (hats, scarves) |
| 6–10 | Cat costumes (bowties, tiny hats) |
| 11–20 | Interactive toys (change minigame aesthetics) |
| 21+ | New room areas (garden, cosy corner) |

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

### Cat State → Minigame Trigger Map

| Cat | Trigger Condition | Minigame |
| :--- | :--- | :--- |
| **Noodles** | `energyLevel >= 85` AND `hungerLevel >= 60` → `Zoomies` mood | MG-1: Calming the Zoomies |
| **Robot Cat** | `energyLevel < 35` → `Grumpy` mood | MG-2: Feelings Sort |
| **Loaf Cat** | `hungerLevel < 35` → `Grumpy` mood | MG-4: Loaf Cat's Snack Stack |
| **Noodles** | Player taps "Play" while mood is `Happy` or `Neutral` | MG-3: Noodles' Laser Letters |
| **Robot Cat** | `moodState == Happy` (both levels ≥ 70) | MG-5: Robot Cat's Logic Loop |

When a trigger fires, the room shows a visual prompt ("Noodles needs help calming down! 🌀") and tapping the cat routes to the minigame. Minigame completion restores the cat's triggering stat by +40 in addition to awarding XP.

---

### MG-1: Calming the Zoomies (EQ / Self-Regulation)
**Trigger:** Noodles reaches `Zoomies` mood state (energy ≥ 85, hunger ≥ 60)
**Core mechanic:** Haptic breathing circle — player holds/releases finger to match expanding/contracting ring. The ring pulses with an inhale cue, player holds; exhale cue, player releases. Complete 3 breath cycles to calm Noodles.
**DDA:**
- Sprout: Large ring, slow pace, 2 cycles, no timing window
- Seedling: Medium ring, moderate pace, 3 cycles, gentle timing window
- Bloom: Smaller ring, faster pace, 4 cycles, tighter timing — sync with Noodles' on-screen breathing

---

### MG-2: Feelings Sort (EQ / Emotional Literacy)
**Trigger:** Robot Cat's `energyLevel < 35` → Grumpy mood
**Route:** `/minigame/eq-sort`
**Core mechanic:** Player drags illustrated emotion cards (happy face, sad face, angry face, etc.) into matching "feeling buckets." Robot Cat calms down as emotions are sorted correctly.
**DDA:**
- Sprout: 3 emotions, large cards, picture-only labels
- Seedling: 5 emotions, word labels added
- Bloom: Nuanced emotions (nervous, proud, embarrassed), scenario-based prompts

---

### MG-5: Robot Cat's Logic Loop (Logic / Sequencing)
**Trigger:** Robot Cat's `moodState == Happy` (both levels ≥ 70) — Robot Cat wants to play logic puzzles when feeling great
**Route:** `/minigame/logic-loop` *(stub added in Phase 3)*
**Core mechanic:** Player drags shape/command tiles into a power grid in the correct sequence to "power up" Robot Cat. Wrong order causes a gentle short-circuit animation and lets the player retry.
**DDA:**
- Sprout: 2-step pattern, shapes only, unlimited retries
- Seedling: 3-step with distractor tiles
- Bloom: Grid-based coding commands (move forward, turn left, repeat)

---

### MG-3: Noodles' Laser Letters (Spelling / Letter Recognition)
**Trigger:** Player-initiated "Play" action on Noodles when mood is Happy/Neutral
**Core mechanic:** Player taps floating lily pads / fish bearing letters or words to match a prompt. Correct taps make Noodles pounce; wrong taps cause a gentle wobble (never a harsh sound).
**DDA:**
- Sprout: Single capital letter matching (tap the A)
- Seedling: 3-letter CVC words; tap all letters in order
- Bloom: Sight words; moving targets; short-sentence prompts

---

### MG-4: Loaf Cat's Snack Stack (Math / Counting)
**Trigger:** Loaf Cat's `hungerLevel < 35`
**Core mechanic:** A plate appears with a number prompt. Player taps or drags food items onto the plate to match the count. Loaf Cat reacts with increasing happiness as the plate fills.
**DDA:**
- Sprout: Count to 5; one food type; 1-to-1 matching
- Seedling: Addition within 10; two food types; "How many altogether?"
- Bloom: Fractions ("give Loaf Cat half the fish"), multiplication sets

---

## 9. Development Phases

### Phase 0 — Project Foundation
- [ ] Flutter project init (with Flame, Riverpod, Hive, GoRouter dependencies)
- [ ] Folder structure and asset pipeline setup
- [ ] Web prototype build pipeline confirmed (flutter build web)
- [ ] Placeholder art integrated into asset system
- [ ] DifficultyProvider and PlayerProfile model implemented
- [ ] Basic navigation skeleton (Home → Room → Minigame → Reward)

### Phase 1 — Core Room & Cat System MVP ✅
- [x] Main room scene with all 4 characters as sprites
- [x] Cat status system (mood states, decay loop, status bubble display)
- [x] Basic interaction: tap cat → see status bottom sheet
- [x] DDA tier selection at onboarding
- [x] Purr-gress bar UI
- [x] Feed and Play buttons in status sheet (state updates, no animation yet)

### Phase 2 — Care Loop, Persistence & First Minigame
- [ ] **Cat state persistence** — snapshot hunger/energy to Hive on care action and app background; apply retroactive decay on re-launch (cap 8h)
- [ ] **Feed/Play visible feedback** — particle animation on care action; mood bubble updates immediately; care sound stub
- [ ] **Heart Sparks XP** — feed (+5) and play (+5) award XP via `PlayerProfileNotifier.addXp()`
- [ ] **Kalia avatar profile** — tapping Kalia shows a profile sheet: player name, DDA tier, total XP, trunk count; option to change tier
- [ ] **Cat state → minigame triggers** — Zoomies/Grumpy mood shows room prompt; tap cat → routes to the appropriate minigame
- [ ] **MG-1: Calming the Zoomies** — breathing circle with haptic feedback; all 3 DDA variants; Star Sparks XP on completion; calms Noodles (+40 energy)
- [ ] **MG-4: Loaf Cat's Snack Stack** — counting/food drag mechanic; all 3 DDA variants; XP + hunger restore on completion
- [ ] Remove dev games menu from AppBar once triggers are live

### Phase 3 — Remaining Minigames & Sprite Polish
- [ ] **MG-3: Noodles' Laser Letters** — letter tap/word mechanic; all 3 DDA variants (most complex — build last)
- [ ] **MG-5: Robot Cat's Logic Loop** — drag-and-drop sequencing grid; Happy-state trigger; all 3 DDA variants; new route `/minigame/logic-loop`
- [ ] **Idle animations** — replace static PNGs with simple idle sprite animations (2–4 frame loop) for each cat; mood-reactive pose changes (Zoomies = bouncing, Sad = drooping)
- [ ] **React animations** — bounce/sparkle on feed; heart float on play; integrate with Flutter `AnimationController`

### Phase 4 — Progression & Reward Loop
- [ ] Magical Trunk level-up sequence (yarn bar fills → trunk bounces → player taps → 3 reward cards)
- [ ] Reward card system (3-card pick, one reward awarded)
- [ ] Inventory and Magic Closet UI
- [ ] Equipped items rendered on characters in room
- [ ] Milestone unlock table implemented (see §7.2)

### Phase 5 — Calm Corner & EQ Polish
- [ ] Calm Corner room/overlay (accessible any time, not gated)
- [ ] Feelings Check-In mechanic (Mood Mirror)
- [ ] Sensory play widgets (kinetic sand / pop-its)
- [ ] Full audio layer (BGM per room, SFX per interaction, lo-fi music only)

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
