# Handoff: Kalia & The Feline Friends — Redesign

## Overview

A redesign of the **Kalia & The Feline Friends** educational life-sim for early learners. The goal of this redesign was to move the Room screen — the heart of the app — away from default Material scaffolding toward a **soft watercolor storybook** aesthetic: warm paper tones, hand-lettered moments, painted characters, subtle ambient motion, and care interactions that give kids rich, mood-aware feedback.

This handoff covers:
- The redesigned **Room** (landscape orientation, 16:9).
- The redesigned **Care sheet** bottom sheet (Feed / Play / Pet actions with mood-reactive emoji).
- All four characters redrawn as SVG (Kalia, Noodles, Loaf Cat, Robot Cat) to match the existing sprite references.
- Supporting room props: window, mood-chart poster, plant, rug, cat-ear bed, yarn basket, magical trunk.

## About the Design Files

The files in this bundle are **design references created in HTML + React (inline Babel)** — a runnable prototype showing the intended look, motion, and interaction model. They are **not production code** to copy directly.

Your task is to **recreate these designs inside the existing Flutter codebase** (`lib/features/room/…`) using its established patterns: `flutter_riverpod` for state, the theme in `lib/core/theme`, existing router in `lib/core/router`, and Flutter primitives (`CustomPaint`, `SvgPicture.asset`, `AnimatedContainer`, `TweenAnimationBuilder`, etc.) — not by shipping the HTML.

Where the HTML uses SVG for characters, the Flutter build should either:
1. Render the equivalent shapes with `CustomPainter`, OR
2. Export each redrawn character from the HTML as an SVG asset and use `flutter_svg`.

(Option 2 is faster and recommended for first pass.)

## Fidelity

**High-fidelity.** Colors, typography, spacing, motion timing, and character silhouettes are all final. The layout in the HTML uses percentage positioning over a 820×400 landscape viewport — reproduce those proportions in Flutter using `FractionallySizedBox` / `Align` / `Stack` positioned children.

## Orientation

**Landscape only.** Lock the app to `DeviceOrientation.landscapeLeft` + `landscapeRight` in `main.dart`. The design is authored at a 16:9-ish ratio (820×400 working canvas).

## Screens / Views

### 1. Room screen (`features/room/room_screen.dart`)

**Purpose.** The home view. The child sees Kalia and her three cat friends in a warm, painted bedroom. Tapping any character opens the Care sheet. Ambient elements (window sky, dust motes, plant sway) give the room life without demanding attention.

**Layout (landscape, % of 820×400 stage):**

| Layer | Element | Position (L/T/W/H) | Notes |
|---|---|---|---|
| BG | Lavender wall | full | `#E2D0E8` (afternoon); shifts with time-of-day |
| BG | Paw-print wallpaper | top 0–66% | SVG pattern 70×70, paw glyph in `#D0BEDC` at 35% opacity |
| BG | Wood-plank floor | bottom 34% | gradient `#E8C89A → #C89860`, plank lines at 0/25/50/75/100% x, slight diagonal |
| BG | Baseboard | on floor top | 8px white strip |
| Mid | Window | L3% T8% W22% H46% | pink curtains, curtain rod, arched panes, live sky inside |
| Mid | Mood-chart poster | R4% T10% W16% H32% | cream card w/ "HOW ARE YOU FEELING?" + 6 colored mood faces |
| Mid | Plant | R2% Bottom30% W8% H28% | lilac pot, swaying leaves |
| Mid | Cream rug | L18% R18% Bottom4% H24% | ellipse, lilac border, cream center |
| Mid | Yarn basket + cat bed | L2% Bottom2% W20% H40% | purple cat-ear bed (left), woven basket w/ rainbow yarn balls (right), loose ball + mouse toy |
| Mid | Magical trunk | R22% Bottom4% W11% H22% | wooden trunk w/ gold fittings, heart lock; pulses + sparkles when `pendingTrunks > 0` |
| Front | Noodles | L18% Bottom4% W16% | orange+white long cat, mood bubble above |
| Front | Loaf Cat | L33% Bottom2% W17% | chubby white cat w/ orange loaf cap |
| Front | Kalia (player) | L48% Bottom2% W15% | curly-haired girl, blue dotted dress, pink shoes |
| Front | Robot Cat | L64% Bottom3% W15% | blue boxy cat, chest panel, maraca |
| Chrome | Title pill | top-left, auto | `rgba(251,245,234,0.7)` + blur, "Kalia's room" (Caveat 22px) + time-of-day tag |
| Chrome | Action dots | top-right | three 32px circles: 🧘 (calm corner), 🧳 (trunks — badged when pending), ♪ (sound) |
| Chrome | Purr-gress bar | L16 Bottom10 W260 | level dot + XP bar + star count |

**Time-of-day palettes** (one of: morning/afternoon/dusk/night):

| Mode | Wall | Floor top | Floor bottom | Overlay |
|---|---|---|---|---|
| morning | `#F0DCE8` | `#E8C89A` | `#D8A878` | `rgba(255,220,170,.04)` |
| afternoon | `#E2D0E8` | `#E8C89A` | `#C89860` | `rgba(0,0,0,0)` |
| dusk | `#D0A8B8` | `#C89868` | `#A06838` | `rgba(230,140,90,.14)` |
| night | `#453850` | `#3D3238` | `#2A2028` | `rgba(50,60,120,.25)` |

Paw-print opacity drops from 0.35 → 0.20 at night.

**Ambient motion (respect `motion` setting: minimal / moderate / lots):**
- Plant leaves sway (6s ease-in-out, 0.8° rotate).
- Dust motes drift up-and-off-screen (6–10 of them, 7–14s loops).
- Trunk bobs (1.8s) only when `pendingTrunks > 0`.
- Yarn basket pulses a warm glow when Noodles' mood is `zoomies`.
- All characters breathe (scale 1.00 → 1.015, 3.5–4.5s).
- Noodles' tail twitches (5s, 4° flick).
- Robot's arms sway (4s, counter-phased).
- All motion stops at `minimal`.

### 2. Care sheet (`features/room/care_sheet.dart`)

**Trigger.** Tap any character.

**Structure.** Bottom sheet, 72% of screen height max, `#FBF5EA` background, 28px top radius, dimmed backdrop (`rgba(61,46,35,0.28)` + 2px blur) with tap-to-dismiss.

**Contents (per cat):**
1. **Grabber** — 44×4 rounded bar, `#E0D0B8`.
2. **Header row** — 56px color-tinted circle holding a shrunk character portrait, name (Caveat 30px), blurb (Nunito 13px), pillar label (10px uppercase), close button (34px).
3. **Stat tiles** — two white rounded tiles: Fullness 🍓 (coral `#D88A7A`) and Energy ✧ (sage `#A8C5A0`). Each shows label + 0–100 bar + `value/100`.
4. **Needs banner** — only shown when `needs != null`. Dashed coral border on `#FCE9D6`, with glyph + hand-lettered microcopy ("a little hungry" / "feeling low on spark") + "Help →" CTA.
5. **Mood-reactive care row** —
   - Small uppercase label: *"They're feeling {mood} — try:"*
   - Three `CareBtn` (Feed / Play / Pet), each 1fr, 18px radius, colored (blush / sage / lilac), with a glyph that **changes with the cat's current mood** (see table below).

**Mood → emoji vocabulary** (both button icon AND particle burst + toast line):

| Mood | Feed | Play | Pet | Toast tail |
|---|---|---|---|---|
| happy | 🍓 | ✨ | ❤️ | "purr purr" |
| calm | 🥛 | 🍃 | ❤️ | "cozy" |
| grumpy | 🍗 | 🪀 | ✨ | "feeling better" |
| sad | 🥞 | 🎈 | 🤗 | "cheered up" |
| zoomies | 🐟 | ⚡ | 💫 | "zoom zoom!" |
| neutral | 🍓 | 🪶 | ❤️ | "nice" |

**Kalia variant.** When `focusedCat == 'kalia'`, replace the stats/needs/care row with a centered card: "That's you!" + total XP + trunk count + Sprout/Seedling/Bloom tier picker.

### 3. Action feedback

**On Feed/Play/Pet tap:**
1. Dispatch the state update (+25 to hunger or energy, +5 XP except for Pet which is free).
2. Spawn **8 particles** of the mood-mapped glyph (one in every 4 replaced with ✨ for sparkle mix).
3. Particles rise from bottom-center of sheet, drift ±35px x, fade out over 1.6s (`floatUp` keyframe).
4. Show a toast pill bottom-center: `"+5 ✦  🍓 purr purr"` style, Caveat 22px, `rgba(255,255,255,1)`, shadow `0 10px 28px rgba(61,46,35,.14)`. Slides up 8px and fades in 0.35s, stays 1.25s, fades out.
5. Cat's button squishes to `scale(0.96)` on pressdown.

## Characters (visual spec)

Drawn as SVG at `viewBox 200×220` (Kalia is 200×260 because she's taller). Each file in `characters.jsx` is self-contained and uses two shared filters:
- `*-brush` — `feTurbulence baseFrequency 0.85` + `feDisplacementMap scale 1.1` for watercolor edge wobble.
- `*-paper` — noise overlay at 0.25–0.3 opacity to simulate paper grain.

### Noodles
- Orange back `#E8A066`, cream belly/face `#FBF0DC`.
- Upright sitting body. Tail curls right from hip to upper right, wags every 5s.
- Triangular ears with pink inner `#E8B4A0`.
- Whiskers (4), pink triangle nose `#E87E8A`, simple dot eyes that become vertical ellipses on `zoomies`.

### Loaf Cat
- Cream body `#FBF0DC`, orange "loaf" cap `#F0B270` over back/head with braided cross-hatch lines.
- Gray cheek patch `#D0C8BE` on one side.
- Squinty smile eyes (curved arcs), small triangular nose `#3D2E23`, soft smile.
- Grumpy eyes become crossed diagonal lines; sad eyes flip to upward arcs.

### Robot Cat
- **Blue** body `#4A7CB8`, lighter blue ear inserts `#6A9CD8`, dark blue legs `#2D5590`.
- Chest panel `#3A6AA0`, 2×2 grid inscribed, small coral heart `#E87E8A` centered.
- Tall triangle ears with pointed tips (reaches y=15).
- Both arms raised; right arm holds a yellow maraca `#F0D090`.
- Round black pupils with white highlights. Grumpy → angled line eyes.

### Kalia (player)
- Skin `#E8C8A8`, dark curly hair `#3D2518` drawn as 7 overlapping circles for the curls.
- Blue A-line dress `#3E5B7A` with white polka-dot pattern (~8 dots).
- Pink inner tank `#F5D0C4`, visible shoulder straps.
- Dark-gray tights `#5C5560`, pink shoes `#E87E8A`.
- Coral cheeks at 60% opacity, simple smile.
- **Only character that doesn't show a mood bubble** (she represents the player).

## Other props

- **Window.** Arched frame `#E8D5B0` with central cross mullions, pink curtains `#F5C0CC` on a wooden rod `#B88858`, curtain ties `#D8A0B0`. Sky inside is a top-to-bottom gradient that changes with time-of-day; sun/moon circle reposition per mode; two fluffy clouds (day only); rolling hills `#7BA078` → `#3D3050` at night.
- **MoodChart poster.** Cream card, ochre border `#B88858`, title "HOW ARE YOU FEELING?" in lilac, 6 mood faces in a 3×2 grid (happy/sad/mad/shy/calm/ok).
- **Plant.** Lilac pot `#B8A5D0`, 3 leaf blades (alternating sage `#7BA078` / `#A8C5A0`), swaying group.
- **Rug.** Ellipse, lilac border ring `#C8B5D8`, cream center `#FBF0E2`, brush filter applied.
- **Yarn basket corner.** Purple cat-ear bed `#B8A5D0` (darker cushion `#8B7AAE`, light pillow `#D0C0E0`) on the left, woven basket `#B88858` with 5 yarn balls (coral/butter/sage/blue/lilac) on the right, plus a loose yarn ball + gray mouse toy with coral tail out front.
- **Magical trunk.** Wooden `#8B5E3C` body with domed `#A87048` lid, gold bands `#F0D090` at sides and small keyhole plate; faint sparkles around lid when `pendingTrunks > 0`.
- **Mood bubble.** Tiny white pill 3×10px padding, 13px char, colored per mood (happy `#D88A7A`, calm `#7BA078`, sad `#8FB8C7`, grumpy `#B25C20`, zoomies `#E87E8A`).
- **Needs indicator.** 20px white circle with 1.6px coral border, bobbing 1.5s, containing 🥣 (hungry) or 💤 (tired).

## State Management

Use Riverpod. Suggested shape (mirrors the prototype reducer):

```dart
class RoomState {
  final TimeOfDay timeOfDay;        // morning | afternoon | dusk | night
  final MotionLevel motion;         // minimal | moderate | lots
  final bool showChrome;
  final String? focusedCatId;       // null | 'noodles' | 'loaf' | 'robot' | 'kalia'
  final int xp;
  final int level;
  final int trunks;
  final int pendingTrunks;
  final Tier tier;                   // sprout | seedling | bloom
  final Map<String, CatStatus> cats; // per-cat hunger/energy/mood/needs
}
```

Actions:
- `FEED(catId)` → hunger +=25 (cap 100), mood → happy if hunger > 70, needs → hungry if hunger < 35, xp += 5.
- `PLAY(catId)` → energy +=25 (cap 100), mood → zoomies if Noodles & energy ≥ 85 else happy if energy > 70, needs → tired if energy < 35, xp += 5.
- `PET(catId)` → no stat change; only triggers feedback.
- `FOCUS_CAT(catId)` → opens/closes sheet.
- `SET(key, value)` / `SET_MOOD(catId, mood)` for tweaks.

Over time (timer), hunger and energy should drift down at a tier-dependent rate; when either drops below 35 the `needs` flag flips on.

## Design Tokens

```dart
// Colors
const paper        = Color(0xFFF5ECDE);
const paperLight   = Color(0xFFFBF5EA);
const paper2       = Color(0xFFEEE1CB);
const ink          = Color(0xFF3D2E23);
const inkSoft      = Color(0xFF6B5A4A);
const inkFaint     = Color(0xFFA39282);
const blush        = Color(0xFFE8B4A0);
const sage         = Color(0xFFA8C5A0);
const butter       = Color(0xFFF0D090);
const lilac        = Color(0xFFB8A5D0);
const dusk         = Color(0xFFD88A7A);
const stream       = Color(0xFF8FB8C7);

// Radius
const rSm = 10.0, rMd = 18.0, rLg = 28.0;

// Shadows
final shadowSm = [BoxShadow(blurRadius: 6, offset: Offset(0,2), color: Color(0x14000000))];
final shadowMd = [BoxShadow(blurRadius: 28, offset: Offset(0,10), color: Color(0x24000000))];
final shadowLg = [BoxShadow(blurRadius: 60, offset: Offset(0,24), color: Color(0x38000000))];

// Type
// Heading: Caveat (Google Fonts). Body: Nunito.
// Sizes in prototype: Caveat 30 (sheet title), 22 (room title), 26 (Kalia greeting).
// Nunito 10–14 for UI, uppercase labels get letter-spacing 0.10–0.14em, weight 800.

// Animation
const tBreathe = Duration(milliseconds: 3500);
const tSway    = Duration(seconds: 4);
const tBob     = Duration(milliseconds: 1800);
const tTail    = Duration(seconds: 5);
const tDust    = Duration(seconds: 8);
const curvePop = Cubic(0.2, 0.8, 0.2, 1);
```

## Assets

- **Source sprite references** (existing, do not change): `assets/characters/{Kalia,Loaf Cat,Noodles the Cat,Robot Cat}.png`, `assets/backgrounds/bg_room_wall.png`, `assets/backgrounds/bg_room_floor.png`, `assets/backgrounds/item_yarn_corner.png`. The redesign preserves their silhouettes and palette; in Flutter you can either keep them as raster sprites **or** swap in SVGs exported from the prototype — visual parity is maintained either way.
- **Fonts**: add **Caveat** and **Nunito** from `google_fonts` (or bundle locally).
- No new illustrated assets are required.

## Files (in this handoff bundle)

- `Kalia Redesign.html` — the runnable prototype. Open in a browser to see the live design; scrub the Tweaks panel on the left.
- `app.jsx` — top-level React app: reducer, landscape device frame, tweaks panel.
- `room.jsx` — Room layout, backdrop, character placement, chrome.
- `characters.jsx` — all four character SVGs + props (Window, MoodChart, Plant, YarnBasket, MagicalTrunk, MoodBubble).
- `care_sheet.jsx` — bottom sheet with mood-reactive Feed/Play/Pet.
- `_ref/` — the original PNGs the redesign was matched against (Kalia, Loaf, Noodles, Robot, room wall, floor, yarn corner).

Open `Kalia Redesign.html` directly in a browser. No build step.
