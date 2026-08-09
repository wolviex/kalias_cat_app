Phase 5.5: Engagement & Child-Usability Pass
Decision and scope
Phase 6 and Phase 7 should be explicitly paused. Phase 5.5 becomes the current phase and must pass its usability gate before Android release preparation resumes.

This pass is not a new art overhaul, minigame phase, audio-content phase, COPPA review, store-listing pass, or purchase implementation. Those remain deferred. It is a focused room discoverability, motion, and navigation pass.

1. Audit conclusions
The diagnosis should be recorded accurately before implementation because several existing planning notes are stale.

Confirmed resolved; do not reopen
Kalia and Noodles are no longer invisible. The supplied Screenshot 2026-07-23 155656.png shows all four painted characters.
The mood poster zero-size CustomPaint defect is resolved with Positioned.fill.
The room is already a layered LayoutBuilder/Stack, not the old grid.
The room already renders the backdrop, window, plant, rug, yarn basket/bed, trunk, title, Purr-gress display, and painter-based characters.
Corrected diagnosis
There is no Material AppBar in the room. The actual controls are smaller than the assumed default Material controls: _ChromeLayer creates three _ChromeBtns, each only 32×32 logical pixels, containing an unlabeled 15 px glyph. They are Calm, Trunk, and a developer games menu.
The room is not animation-free. It already has:
6-second plant sway at only about ±0.8°;
12-second dust motes;
4-second whole-character breathing scale;
conditional trunk bobbing;
character focus scale;
needs-badge bobbing;
care-sheet transitions;
clock-derived morning/afternoon/dusk/night painters. These effects are too subtle, synchronized, conditional, or structurally limited to make the room read as alive.
RoomNotifier computes time of day when it is built, but it does not periodically refresh or refresh on app resume. Time-of-day art is therefore implemented, but it is not a continuously maintained room system.
The current implementation contradicts old checklist entries:
there is no Closet control in the current room;
there is no current _RoomItem class and the yarn basket is a static CustomPaint, despite older documentation saying that the yarn corner uses an interactive pulse pattern;
the old checklist says the room has a mute control, but the current _ChromeLayer has Calm, Trunk, and Games only.
Feed and Play are discoverable only after a child guesses that a character can be tapped and opens its care sheet.
The screenshot is approximately 2533×887, much wider than the 820×400 handoff stage. Percentage positioning stretches the composition toward distant edges, creating dead space and making the already-small controls harder to notice.
Other readability problems visible in source include a 6 px mood-chart title, 10 px time label, 20×20 needs badge with a 10 px emoji, and 14×14 trunk count badge with 9 px text.
Router destinations are plain GoRoute.builder routes. There are no custom fade/slide page transitions.
kalias/lib/core/theme/ is empty; room dimensions and styles are currently inline. Shared child-UI and motion tokens need to be introduced rather than adding more literals.
Known work intentionally left outside Phase 5.5
Concept/progress_plan.md also tracks MG-3, final audio delivery, remaining content work, painter/art consistency, parental/release tasks, and store preparation. Those should not be duplicated into this phase. Phase 5.5 should only correct stale room claims and reference those separate workstreams as deferred.

2. Handoff-to-Flutter design contract
Use Concept/Design_handoff/room.jsx, care_sheet.jsx, characters.jsx, app.jsx, and Concept Art.png as the visual source of truth: warm paper colors, rounded cards, soft shadows, large expressive mood marks, script typography for decorative headings, and icon-plus-word actions.

The implementation contract is:

JSX reference assets remain inline SVG primitives. Do not add PNGs, HTML canvas, CSS clip-path polygons, or external SVG files.
Flutter continues to use the existing CustomPainter vector-path equivalent; do not introduce raster replacements or image-backed room/character parts.
Preserve and reuse WatercolorDefs in the JSX source. Apply watercolor/noise texture only to large fills such as walls, floors, body masses, clothing, or large props—never eyes, mouths, text, whiskers, or thin strokes.
Create shared painter constants for ink, contour widths, interior strokes, round caps/joins, texture opacity, shadows, and animation defaults.
Never draw a dark duplicate path beneath a fill to imitate an outline. Each shape is one filled path with its real stroke.
Every character must use this internal order:
<defs />
<GroundShadow />
<RearParts />
<MainBody />
<BodyMarkings />
<Limbs />
<Head />
<Face />
<Highlights />
<TextureOverlay />
Independently moving parts must remain separate <g> groups in JSX and equivalent part groups in Flutter. Do not animate the root SVG or wrap the entire production character painter in an idle transform. Ground shadows must remain stationary while bodies, heads, eyes, tails, ears, curls, or limbs move independently.
Decorative script text should use Caveat at 22–26 px. Functional labels must use Nunito bold at no less than 14 px; do not use script text for actions a beginning reader must identify.
3. Workstream A — touch targets and button redesign
A1. Add shared tokens
Create kalias/lib/core/theme/app_tokens.dart and move new shared values there:

primary tap target: 64×64 minimum;
secondary/close/back/sound target: 56×56 minimum;
primary icon: 28–30 px;
primary label: 14 px Nunito, weight 800;
decorative heading: 24 px Caveat, weight 700;
status/mood emoji: 24 px minimum;
badge: 22×22 minimum, text 12 px;
action radius: 20 px;
dock gap: 8 px;
normal shadow: y=4, blur=12, warm-ink opacity about 14%;
focused shadow: y=5, blur=18, action-color opacity about 28%;
press scale: 1.0 → 0.96 over 100 ms, returning over 140 ms.
Use the shared warm palette rather than unrelated Material defaults:

paper: #FBF5EA;
ink: #3D2E23;
Feed: peach #F3C3A6;
Play: gold #F2D36B;
Calm: lilac #CAB8E8;
Closet: soft blue #B9DCE8;
Trunk: coral #E8B4A0.
All labels use dark ink; verify at least 4.5:1 contrast for functional text.

A2. Constrain the room composition
Extract the scene into a RoomStage based on the handoff ratio 820:400 (2.05:1).

Fill the viewport with the backdrop, but center interactive room content within the largest 2.05:1 stage that fits.
Do not scale controls with FittedBox; 56/64 logical-pixel targets must remain real logical sizes.
Use stage-local width/height for all prop and character positions.
Reserve the bottom 84 px of the stage as a HUD-safe zone, and reposition character baselines/props above it so the action dock never covers feet, status bubbles, or the trunk.
Wrap the stage in SafeArea with at least 12 px edge inset.
Test the exact supplied wide ratio as well as ordinary landscape sizes.
This keeps the visual scene coherent on 2533×887 instead of sending controls and props to opposite sides of the screen.

A3. Replace _ChromeBtn with a persistent labeled dock
Remove the three 32 px _ChromeBtns. Add _PrimaryActionDock as the last room HUD layer below the care sheet, centered at the bottom of the stage.

The dock must always show these five actions, in this order:

🥣 Feed
🧶 Play
🧘 Calm
👗 Closet
🧳 Trunk
Each action is a shared ChildActionButton:

minimum 64 px high;
five equal-width cells in a dock capped at 544 px wide;
icon above a one-word label;
warm color-coded fill, rounded rectangle, real stroke, and soft shadow;
Semantics(button: true, label: ...) and HitTestBehavior.opaque;
visible pressed state and light haptic selection feedback;
no essential meaning communicated by color or animation alone.
Behavior is fixed as follows:

Calm: context.push(AppRoutes.calmCorner).
Closet: context.push(AppRoutes.closet); this restores the missing room entry point.
Trunk: always visible. A pending trunk receives a 22 px count badge and stronger bounce. If none is pending, tapping shows the friendly two-second message “Fill your Purr-gress to unlock a trunk!” rather than navigating to an unusable state.
Feed/Play: tapping enters a targeted-care mode. Show a warm instruction banner—“Who gets food?” or “Who wants to play?”—and halo/bounce the three cats. The next cat tap performs the action. Tapping Kalia says “Choose a cat friend” and leaves the mode active. Tapping the selected dock action again, or a 56 px Close control on the prompt, cancels.
Extract existing Feed/Play side effects from care_sheet.dart into one shared CareActionController so dock actions and care-sheet actions update cat state, XP, reaction animation, persistence, and audio exactly once. Do not duplicate business logic.
Keep tapping a cat as an alternate path to the care sheet; a child can therefore either tap a clearly labeled action first or explore a character first.

A4. Remove developer and utility clutter
Remove the visible ♪ games launcher from normal room UI.
Preserve it only behind kDebugMode && bool.fromEnvironment('SHOW_DEV_MENU'), defaulting to false, through a long press on the room title. It must never appear in release builds or usability captures.
Restore Sound as a secondary 56 px icon-plus-Sound label control at the upper right. It is not one of the five primary dock actions.
Move the Purr-gress pill beneath the upper-left title so it cannot collide with the bottom dock.
Increase the time label from 10 to 13 px.
A5. Repair mood/care readability
In room_screen.dart, room_painters.dart, and care_sheet.dart:

mood chart heading: 12 px minimum, not 6;
mood face/emoji: 22–24 px minimum;
make the entire mood poster an opaque hit target of at least 112×128 px, add a visible Feelings label, and route it to AppRoutes.moodMirror;
needs indicator: 32×32 px, emoji 18 px;
mood bubble: at least 44×44 px, emoji 24 px;
character hit regions: at least 96×120 px, while ensuring adjacent hit regions do not overlap;
care-sheet Feed and Play controls use the same 64 px ChildActionButton contract;
care-sheet close/back controls are at least 56 px;
decorative overlays use IgnorePointer so they cannot obscure a valid target.
4. Workstream B — room idle-animation pass
B1. Restore a reusable interactive-room wrapper
Because the documented _RoomItem no longer exists, create a shared RoomInteractive widget rather than attempting to extend stale code. It owns:

the 64 px minimum hit contract;
semantics and focus state;
press feedback;
a persistent but gentle discoverability cue;
a phase offset so all items do not pulse simultaneously;
a static high-contrast outline/halo when reduced motion is enabled.
Apply it to every actual room interaction:

each cat and Kalia;
yarn basket;
mood poster;
trunk;
Sound control;
all five dock actions.
Do not animate purely decorative props merely to imply that they are tappable.

Default discoverability cycle:

4.8 seconds total;
one 700 ms cue per cycle, then rest;
scale 1.0→1.04→1.0;
y lift 0→−3→0 px;
halo blur 10→18→10 px and opacity 12%→28%→12%;
stagger instances by 180 ms.
Exceptions:

pending Trunk: 0→−8→0 px over 900 ms, once every 2.4 seconds;
cat-selection mode: the three eligible cats use a more visible 1.0→1.05 cue every 1.4 seconds;
dock actions: cue one at a time on a 10-second staggered sequence rather than all pulsing continuously.
The yarn basket again routes to AppRoutes.breathing, matching the earlier documented MG-1 room-item behavior.

B2. Replace root-character breathing with grouped motion
Remove the current whole-PaintedCharacter Transform.scale breathing implementation. Add a shared CharacterMotionSpec and part-level pose inputs.

All four characters receive:

body breathing;
blinking;
one anatomy-appropriate secondary movement;
non-synchronized phase offsets.
Exact baseline motion:

body breath: scaleY 0.992→1.012, scaleX 1.004→0.998, anchored at the feet, over 4.2 seconds ease-in-out;
head counter-motion: y +1→−1 px during the breath;
blink: close 90 ms, hold 70 ms, open 120 ms;
blink schedules: Noodles 4.2 s, Loaf Cat 4.8 s, Kalia 5.4 s, Robot Cat 3.8 s;
ground shadow never scales or translates with breathing.
Secondary motion:

Noodles: tail group rotates 0→7°→−2°→0 over 900 ms every 5.2 s;
Loaf Cat: visible paw/loaf-hat group tilts 0→2°→0 over 700 ms every 6.1 s;
Robot Cat: tail/ear group rotates ±6° over 750 ms every 4.7 s;
Kalia: one curl/hand group sways ±2° over 900 ms every 5.8 s.
In JSX these are independent <g> transforms. In Flutter they are equivalent named painter groups or part layers; only those groups receive transforms. The root character and ground shadow remain fixed.

B3. Amplify ambient motion without overstimulation
Plant: increase from ±0.8°/6 s to ±2.5° over 4.8 s, anchored at the pot. Give leaf clusters a delayed additional ±1° part-group sway; do not rotate the entire root asset.
Dust: moderate mode uses 8 motes, lots mode 12; 9-second lifecycle; radius 1–3 px; opacity 12–28%; vertical travel 18% of the stage and horizontal drift 8–20 px. Keep dust off at night and in minimal motion.
Window light: add a 7-second sunbeam opacity cycle from 16–26% in daytime; at night use small staggered star twinkles over 2.8 seconds.
Keep motion behind interactive content and wrap painter-heavy layers in RepaintBoundary.
B4. Make time-of-day truly live
Add an injectable roomClockProvider for deterministic tests.
Have RoomNotifier re-evaluate the clock every minute and update state only when the time bucket changes.
Refresh immediately when the app resumes.
Cross-fade old/new backdrop and window painter layers over 1,200 ms at morning/afternoon/dusk/night boundaries instead of swapping abruptly.
Preserve current thresholds: morning 06:00–10:59, afternoon 11:00–16:59, dusk 17:00–19:59, night otherwise.
B5. Reduced-motion behavior
If MediaQuery.disableAnimations is true, force effective MotionLevel.minimal:

stop pulse, dust, plant, breathing, blink, and secondary loops;
retain labels, outlines, halos, and pending badges so discoverability is never animation-dependent;
use an immediate route transition;
preserve care-action state changes and static feedback.
5. Workstream C — navigation and transition polish
Convert room destinations in app_router.dart from builder to a shared CustomTransitionPage helper.

Apply it to Breathing, EQ Sort, Reading, Math, Logic Loop, Calm Corner, Mood Mirror, Closet, Trunk, and Reward:

forward duration: 320 ms;
reverse duration: 260 ms;
fade: 0→1;
slide: Offset(0, 0.035)→Offset.zero with Curves.easeOutCubic;
reverse uses Curves.easeInCubic;
no scale or spin;
reduced-motion duration: zero.
Use context.push for room-to-activity navigation so Android Back and activity Back return to the existing room naturally. Keep replacement navigation only for onboarding completion and flows where returning to the completed activity would be incorrect.

On room entry/resume, fade the stage from 0→1 and translate y 8→0 over 300 ms. Do not animate the root character SVGs as part of this transition; transition the route/stage container.

6. Execution order and file-level plan
5.5a — child controls and layout
Add core/theme/app_tokens.dart and shared ChildActionButton/RoomInteractive widgets.
Extract RoomStage and constrain composition to 820:400.
Replace _ChromeBtn with the five-action dock and labeled Sound utility.
Add Closet and Feelings entry points; restore yarn interaction.
Add targeted Feed/Play mode and shared CareActionController.
Enlarge status, mood, badge, close, and care-sheet controls.
Hide the developer menu by default.
Gate: no interactive control in room_screen.dart or care_sheet.dart measures below 56×56; all primary controls are at least 64 px and have icon, visible word, and semantic label.

5.5b — room liveliness
Introduce shared motion tokens and reduced-motion handling.
Refactor painter internals into the required ordered part groups.
Implement breathing/blink/secondary motion for all four characters without root transforms.
Apply staggered cues to every interactive room item.
Amplify plant/dust/window motion.
Add minute/resume time refresh and 1.2-second lighting cross-fade.
Gate: all four characters visibly move during a 6-second observation; every interactive room item emits a discoverability cue within 10 seconds; no ground shadow, face detail, text, or root character is incorrectly transformed or textured.

5.5c — transition polish
Add the shared GoRouter transition page.
Replace room outbound go calls with push where appropriate.
Add room entrance/resume fade-slide.
Verify Back from every room destination returns once to Room, with no duplicate routes.
Gate: no room/activity change is abrupt; no transition exceeds 320 ms; Back-stack behavior is deterministic.

5.5d — validation and informal child check
Automated checks:

flutter analyze with zero issues;
existing tests remain green;
widget tests assert all primary targets ≥64 and secondary targets ≥56;
semantics tests find Feed, Play, Calm, Closet, Trunk, Sound, and Feelings;
behavior tests cover Feed/Play selection, cancellation, exactly-once XP/state updates, locked/pending Trunk, Closet, Calm, Feelings, and yarn routing;
fake-clock tests cover 05:59/06:00, 10:59/11:00, 16:59/17:00, and 19:59/20:00;
transition tests verify push/back behavior and reduced motion;
layout tests at 800×360, 1280×720, 2533×887, and the available 900×600 browser viewport verify no overflow, clipping, obscured labels, or overlapping hit rectangles.
Golden strategy:

follow test/character_painters_golden_test.dart;
add painter-only goldens for each character’s neutral pose, blink keyframe, and secondary-motion keyframe, plus morning/dusk/night room painter states;
do not rely on full-widget GoogleFonts goldens because runtime font fetching is unreliable in this environment.
Informal check:

Use one child aged approximately 4–6 with guardian consent; do not collect identifying data or require video.
Start from a reset room in landscape and provide no coaching for the first 60 seconds.
Ask the child to: feed a cat, play with a cat, open Calm, open Closet, find Feelings, open a seeded pending Trunk, start the yarn activity, and return to Room.
Record only task completion, first-tap target, time to first correct tap, and any spoken confusion.
Pass criteria: at least 6 of 7 tasks completed without adult direction; each dock action identified within 10 seconds; Feed/Play completed with at most one mistaken character tap; activity Back returns unaided; no control is repeatedly missed because of size or obstruction.
If the same control causes two failures or one task cannot be completed, fix it and repeat the short check before Phase 6.
7. Documentation changes to make in Act mode
project_state.md
Change Current Phase to Phase 5.5 — Engagement & Child-Usability Pass.
Set status to Not started initially, then track 5.5a–d independently.
Insert Phase 5.5 between completed Phase 5 and paused Phase 6 in the status table.
Mark Phase 6 and Phase 7 Paused until Phase 5.5 exit gate.
Add the four detailed checklists and gates above.
Correct stale completed claims about an AppBar Closet button, _RoomItem yarn interaction, current mute control, and placeholder/invisible character state.
Add a changelog entry dated when implementation begins and another when the child-usability gate passes.
project_spec.md
Insert a full Phase 5.5 — Engagement & Child-Usability Pass section after Phase 5 with subsections 5.5a–d.
Add the 64/56 px target contract, five-button dock, targeted Feed/Play behavior, renderer invariants, exact motion specs, transition specs, reduced-motion behavior, responsive stage, and acceptance criteria.
Leave Phase 6’s accessibility review in place as final release verification, but state that foundational room touch-target remediation occurs in Phase 5.5.
Mark Phase 6 and 7 as deferred rather than current work.
Concept/progress_plan.md
Preserve it as historical planning, but append a short reconciliation note: painter visibility and mood poster issues are resolved; the current room regressed from the documented yarn/Closet controls; Phase 5.5 now owns those repairs. Do not rewrite unrelated MG-3, audio, or release tasks into this phase.
No files have been changed in Plan Mode. To implement this approved plan, manually toggle to Act Mode