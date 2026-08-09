# Progress Plan — Getting to a Child-Appropriate, Shippable App

> Created 2026-07-15 from a review of `Screenshot 2026-07-15 145015.png`, the Concept folder
> (including `Design_handoff/`), `project_spec.md`, and `project_state.md`.
> Designed for **minimal user intervention**: every task is marked either 🤖 (Claude can do it
> autonomously) or 🧑 (needs the user / content team). The 🧑 list is deliberately tiny.

---

## 1. What the screenshot shows (current state)

The room redesign from `Concept/Design_handoff/` is largely in place — painted wall/floor,
window with live sky, plant, rug, cat-ear bed, yarn basket, title pill, action dots,
Purr-gress bar all match the handoff spec. But:

1. **Loaf Cat and Robot Cat render as raw placeholder sprite sheets** — whole AI-generated
   PNGs with "SPRITE SHEET: …" titles and checkerboard backgrounds baked into the image.
   Source: `room_screen.dart` lines ~250 and ~278 use plain `Image.asset` on
   `assets/characters/Loaf Cat.png` / `Robot Cat.png`. This is the single biggest
   "not a real game yet" signal on screen.
2. **Kalia and Noodles are not visible at all** in the screenshot, though the code positions
   them at L48% and L18%. Either the `SpriteSheetAnimator` is failing silently or the frames
   render at zero/washed-out size — needs diagnosis.
3. **Mood-chart poster is barely visible** (faint text top-right instead of the cream card
   with 6 mood faces from the handoff spec).

Everything else needed for "child-appropriate" is mostly a matter of finishing work already
specced: the last minigame (MG-3), removing the dev menu, a parental gate, audio, and the
Phase 6 release checklist.

---

## 2. Guiding decision: how to fix the character art with zero user intervention

The placeholder sheets can't be sliced cleanly (labels + checkerboard are baked into the
pixels). But the **Design_handoff already solves this**: all four characters were redrawn as
clean, mood-reactive SVGs in `Design_handoff/characters.jsx`, and the handoff README
explicitly offers two Flutter integration paths. We take that path:

> **Decision:** Port the four handoff characters (Kalia, Noodles, Loaf Cat, Robot Cat) into
> Flutter as `CustomPainter`s (matching the pattern already used for all room props in
> `room_painters.dart`). No new art generation, no external tools, no asset deliveries
> needed. The AI placeholder PNGs are retired from the room screen entirely.

Why CustomPainter over exported SVG assets: the props are already painters, mood-reactive
details (eye shapes per mood, Noodles' zoomies eyes, Robot's grumpy eyes) are parameterizable
in a painter but awkward with static SVG files, and it avoids adding the `flutter_svg`
dependency. The `characters.jsx` file contains exact paths, colors, and proportions to
transcribe.

---

## 3. Workstreams

### WS-A — Characters & room visual completion 🤖 *(highest priority — fixes the screenshot)*

- [x] A1. Port **Loaf Cat** painter from `characters.jsx` (cream body, orange loaf cap with
      cross-hatch, squinty smile eyes; grumpy/sad eye variants). Replace `Image.asset` in room.
      *(2026-07-15 — `lib/shared/widgets/character_painters.dart`, verified via golden render)*
- [x] A2. Port **Robot Cat** painter (blue boxy body, chest panel with heart, maraca arm;
      grumpy line-eyes variant). Replace `Image.asset` in room. *(2026-07-15)*
- [x] A3. Port **Noodles** painter (orange/cream, curled tail, zoomies eye variant) and use it
      as the room representation. `SpriteSheetAnimator` retired from the room. *(2026-07-15)*
- [x] A4. Port **Kalia** painter (curls, polka-dot dress, no mood bubble). *(2026-07-15)*
- [x] A5. Kalia/Noodles invisibility resolved by A3/A4 — the room no longer depends on
      `SpriteSheetAnimator`. Legacy sprite files (`cat_sprite.dart`, `sprite_sheet_animator.dart`,
      `*_sprites.dart`) are now unreferenced by any screen; delete in Session 2 cleanup. *(2026-07-15)*
- [x] A6. Fix the **mood-chart poster** rendering to match handoff (cream card, ochre border,
      6 mood faces). Root cause: the `CustomPaint` was a bare (childless) non-positioned child
      of a `Stack`, so it collapsed to zero size and never drew. Fixed with `Positioned.fill`.
      Verified via `goldens/mood_chart_poster.png`. *(2026-07-15)*
- [x] A7. Painters take each cat's live `moodState`; room + care sheet pass it through so faces
      react (grumpy/sad/zoomies eye variants). *(2026-07-15)*
- [x] A8. Care-sheet header portrait now renders the painted character head (new
      `CharacterPortrait` widget), replacing the placeholder-PNG `Image.asset`. Closet/trunk/
      reward screens use emoji reward items (no character PNGs), so nothing else to change.
      Verified via `goldens/portraits.png`. *(2026-07-15)*
- [ ] A9. Verify equipped-item badge overlays still position correctly on painted characters.
      *(deferred to Session 2 — needs a run with owned+equipped items)*
- [x] A10. Component-level visual verification done via golden renders (characters ×3 mood sets,
      portraits, mood-chart poster). A full live-scene screenshot is the S1 user review step —
      a full-room golden was attempted but is brittle in the sandbox because GoogleFonts fetches
      Caveat/Nunito over the network at test time. *(2026-07-15)*

### WS-A′ — Visual improvement pass 🤖 *(user-directed interlude, 2026-07-16 — done)*

- [x] Rebuilt all four painters against the target sprite sheets in `/assets`, replacing
      geometric primitives with organic paths: outline hierarchy (primary ~4.5 / interior ~3 /
      detail ~1.5, round caps+joins), tapered filled-ribbon limbs/whiskers/tails
      (`_taperedQuad`), subtle vertical gradient fills, and blurred contact/ground shadows.
- [x] Palette + anatomy matched to targets: Noodles tan/cream, round dot eyes, cream face
      patch; Loaf scalloped golden crust, sagging body, orange/gray calico ear-patches; Kalia
      bulbous curl silhouette, chubby face, pink long sleeves, floral dress; Robot plush
      proportions, inset panel grid + heart, striped maraca.
- [x] Verified over 3 golden-render iterations (`test/goldens/characters_*.png`).

### WS-B — Last minigame + externalized content 🤖

- [ ] B1. **MG-3: Noodles' Laser Letters** — replace the stub at
      `lib/features/minigames/reading/reading_screen.dart` per spec §8: tap floating
      lily-pad/fish letter targets; Sprout = single capital letter, Seedling = 3-letter CVC
      words in order, Bloom = sight words with moving targets. Gentle wobble on wrong tap,
      never harsh. +15 Star Sparks, wired to the Noodles "Play while Happy/Neutral" trigger.
- [ ] B2. Create **content JSON files** in `assets/data/` (spec §11 requires content as data,
      not code): `words.json` (letters, CVC lists, sight words per tier), `math.json`
      (counting/addition/fraction prompt sets), `feelings.json` (emotion cards + scenario
      prompts + Mood Mirror affirmations). Seed with sensible age-appropriate defaults so the
      educator can later *edit* rather than *author from scratch*.
- [ ] B3. Refactor MG-2/MG-3/MG-4 and Mood Mirror to load from those JSON files.
- [ ] B4. Remove the **dev games menu** from the room AppBar (open Phase 2 item) — minigames
      are reachable only through cat-state triggers and Play actions, as designed.

### WS-C — Child-safety & COPPA hardening 🤖

- [ ] C1. **Parental gate** (simple adult-knowledge check, e.g. "tap 3 × 4") in front of:
      DDA tier change, motion/audio settings, and any future purchase flow. Kids should not
      be able to change their own difficulty from Kalia's profile sheet.
- [ ] C2. **COPPA self-audit**: confirm zero network calls, zero third-party SDKs, zero
      analytics, no data leaves the device; document the result in `project_spec.md` §12.
- [ ] C3. **Accessibility pass**: all touch targets ≥ 48dp (esp. Explorer tier), text contrast
      ≥ 4.5:1 against the paper palette, semantic labels on interactive elements.
- [ ] C4. Lock orientation to landscape (`DeviceOrientation.landscapeLeft/Right`) per the
      handoff README, if not already done.
- [ ] C5. Confirm no fail states in Explorer tier across all 5 minigames; verify wrong-answer
      feedback is gentle everywhere (spec §12 non-negotiables).
- [ ] C6. Respect the `motion` setting (minimal/moderate/lots) in every animated element —
      audit against the handoff's ambient-motion list.

### WS-D — Audio without waiting on the content team 🤖

- [ ] D1. Programmatically generate **gentle placeholder audio** (soft sine/triangle chimes,
      low-pass filtered, quiet — per the "no harsh audio" rule) for the 7 specced SFX slots
      and 2 BGM slots (simple lo-fi loop). Write a small generation script so files are
      reproducible, drop outputs into `assets/audio/`.
- [ ] D2. Verify `AudioService` plays them at every existing hook; keep the try/catch guards.
- [ ] D3. Mark final audio as a 🧑 swap-in task — file names already match spec, so the
      content team just replaces files.

### WS-E — Phase 6: Android release prep 🤖 mostly / 🧑 at the end

- [ ] E1. Android build config: applicationId, versioning, adaptive launcher icon (can be
      generated from the Kalia painter), splash screen.
- [ ] E2. Performance profiling on web + `flutter build apk --profile`; fix jank from
      painters/animations (target mid-range devices).
- [ ] E3. Draft Play Store listing copy from `concept.MD`'s App Store summary; capture
      in-app screenshots for the listing. 🤖 drafts, 🧑 approves.
- [ ] E4. Data-safety form answers + IARC age-rating questionnaire answers drafted as a doc
      for the user to paste in. 🤖 drafts, 🧑 submits.

---

## 4. Execution order (session by session)

| Session | Scope | Exit criteria |
| :--- | :--- | :--- |
| **S1** ✅ | WS-A (A1–A8, A10) | Room shows 4 painted, mood-reactive characters; no raw sprite sheets anywhere on screen; care-sheet portraits painted; mood-chart poster fixed. *(A9 + legacy-file cleanup rolled to S2)* |
| **S2** | A9 + legacy-file deletion + B4 + C4 | Equipped-badge check on painted chars; delete unused sprite files; dev menu gone; landscape locked |
| **S3** | B1 (Laser Letters) | All 5 minigames playable across all 3 tiers |
| **S4** | B2–B3 (content JSON) | Educator-editable content files drive MG-2/3/4 + Mood Mirror |
| **S5** | C1–C3, C5–C6 | Parental gate live; COPPA + accessibility audits documented |
| **S6** | WS-D (audio) | App has sound end-to-end with generated placeholders |
| **S7** | WS-E | Release candidate APK + listing/copy pack for user review |

Each session ends with `flutter analyze` clean, a `project_state.md` update, and a commit —
consistent with existing practice.

---

## 5. The only things that need the user 🧑

1. **Look at screenshots after S1** and say "yes, keep going" (or note tweaks) — one message.
2. **Final art/audio** (optional): the app ships fine on painted characters and generated
   audio; producer-delivered assets are a drop-in upgrade, not a blocker.
3. **Play Store account actions** (S7): create the listing, paste the drafted copy/data-safety
   answers, upload the AAB. Claude prepares everything paste-ready.
4. **Educator review** (any time): edit the seeded JSON content files — no code involved.

Everything else in this plan is executable autonomously.
