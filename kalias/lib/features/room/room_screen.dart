// Watercolor storybook Room — landscape 16:9, fullscreen, no AppBar.
// Backdrop + props are drawn via CustomPainters in room_painters.dart.
// Characters use existing PNG/sprite-sheet assets.
// Care sheet is an in-Stack overlay managed by focusedCatProvider.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/cat_state.dart';
import '../../core/models/kalia_sprites.dart';
import '../../core/models/noodles_sprites.dart';
import '../../core/providers/cats_provider.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/sprite_sheet_animator.dart';
import 'care_sheet.dart';
import 'room_painters.dart';
import 'room_provider.dart';

// ── Room screen ───────────────────────────────────────────────────────────────

class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key});

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen>
    with TickerProviderStateMixin {
  // Plant sway — 6s ease-in-out loop
  late final AnimationController _plantCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  )..repeat(reverse: true);

  // Trunk bob — 1.8s loop (only active when pendingTrunks > 0)
  late final AnimationController _trunkCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  // Character breathe — 4s loop
  late final AnimationController _breatheCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4000),
  )..repeat(reverse: true);

  // Dust mote controller — cycling offset for stagger
  late final AnimationController _dustCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _plantCtrl.dispose();
    _trunkCtrl.dispose();
    _breatheCtrl.dispose();
    _dustCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final room = ref.watch(roomProvider);
    final profile = ref.watch(playerProfileProvider);
    final cats = ref.watch(catsProvider);
    final focusedCat = ref.watch(focusedCatProvider);

    // Start/stop trunk bob based on pending trunks
    if (profile.pendingTrunks > 0 && room.motion != MotionLevel.minimal) {
      if (!_trunkCtrl.isAnimating) _trunkCtrl.repeat(reverse: true);
    } else {
      _trunkCtrl.stop();
      _trunkCtrl.reset();
    }

    final isNight = room.isNight;
    final motion = room.motion;

    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // ── 1. Room backdrop (wall + paw pattern + floor) ───────────
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: RoomBackdropPainter(room.timeOfDay),
                    ),
                  ),
                ),
              ),

              // ── 2. Window — L3% T8% W22% H46% ──────────────────────────
              Positioned(
                left: w * 0.03,
                top: h * 0.08,
                width: w * 0.22,
                height: h * 0.46,
                child: CustomPaint(
                  painter: WindowPainter(room.timeOfDay),
                ),
              ),

              // ── 3. Mood chart poster — R4% T10% W16% H32% ───────────────
              Positioned(
                right: w * 0.04,
                top: h * 0.10,
                width: w * 0.16,
                height: h * 0.32,
                child: Stack(
                  children: [
                    const CustomPaint(painter: MoodChartPainter()),
                    // Title text overlay
                    Positioned(
                      top: 6,
                      left: 0,
                      right: 0,
                      child: Text(
                        'HOW ARE YOU\nFEELING?',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 6,
                          fontWeight: FontWeight.w800,
                          color: kLilac,
                          height: 1.3,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── 4. Plant — R2% Bottom30% W8% H28% ───────────────────────
              Positioned(
                right: w * 0.02,
                bottom: h * 0.30,
                width: w * 0.08,
                height: h * 0.28,
                child: AnimatedBuilder(
                  animation: _plantCtrl,
                  builder: (_, child) => Transform.rotate(
                    angle: (_plantCtrl.value - 0.5) * 0.014, // ±0.8°
                    alignment: Alignment.bottomCenter,
                    child: child,
                  ),
                  child: const CustomPaint(painter: PlantPainter()),
                ),
              ),

              // ── 5. Cream rug — L18% R18% Bottom4% H24% ──────────────────
              Positioned(
                left: w * 0.18,
                right: w * 0.18,
                bottom: h * 0.04,
                height: h * 0.24,
                child: const CustomPaint(painter: RugPainter()),
              ),

              // ── 6. Yarn basket — L2% Bottom2% W20% H40% ─────────────────
              Positioned(
                left: w * 0.02,
                bottom: h * 0.02,
                width: w * 0.20,
                height: h * 0.40,
                child: const CustomPaint(painter: YarnBasketPainter()),
              ),

              // ── 7. Magical trunk — R22% Bottom4% W11% H22% ──────────────
              AnimatedBuilder(
                animation: _trunkCtrl,
                builder: (_, child) {
                  final dy = _trunkCtrl.isAnimating
                      ? (_trunkCtrl.value - 0.5) * 4.0 // ±2px bob
                      : 0.0;
                  return Positioned(
                    right: w * 0.22,
                    bottom: h * 0.04 - dy,
                    width: w * 0.11,
                    height: h * 0.22,
                    child: child!,
                  );
                },
                child: GestureDetector(
                  onTap: profile.pendingTrunks > 0
                      ? () => context.go(AppRoutes.trunk)
                      : null,
                  child: CustomPaint(
                    painter: MagicalTrunkPainter(
                        pending: profile.pendingTrunks > 0),
                  ),
                ),
              ),

              // ── 8. Dust motes ─────────────────────────────────────────────
              if (motion != MotionLevel.minimal && !isNight)
                _DustMotes(
                  ctrl: _dustCtrl,
                  count: motion == MotionLevel.lots ? 10 : 6,
                ),

              // ── 9. Night overlay ──────────────────────────────────────────
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  color: overlayColorFor(room.timeOfDay),
                ),
              ),

              // ── 10. Characters ────────────────────────────────────────────

              // Noodles — L18% Bottom4% W16%
              _CharacterSlot(
                left: w * 0.18,
                bottom: h * 0.04,
                width: w * 0.16,
                catId: 'noodles',
                cat: cats[CatId.noodles],
                breatheCtrl: _breatheCtrl,
                focused: focusedCat == 'noodles',
                onTap: () => _focus('noodles'),
                child: _NoodlesSprite(
                  cat: cats[CatId.noodles]!,
                  width: w * 0.16,
                ),
              ),

              // Loaf Cat — L33% Bottom2% W17%
              _CharacterSlot(
                left: w * 0.33,
                bottom: h * 0.02,
                width: w * 0.17,
                catId: 'loafCat',
                cat: cats[CatId.loafCat],
                breatheCtrl: _breatheCtrl,
                focused: focusedCat == 'loafCat',
                onTap: () => _focus('loafCat'),
                child: Image.asset(
                  CatId.loafCat.assetPath,
                  width: w * 0.17,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _PlaceholderChar('🍞'),
                ),
              ),

              // Kalia — L48% Bottom2% W15%
              _KaliaSlot(
                left: w * 0.48,
                bottom: h * 0.02,
                width: w * 0.15,
                breatheCtrl: _breatheCtrl,
                focused: focusedCat == 'kalia',
                onTap: () => _focus('kalia'),
              ),

              // Robot Cat — L64% Bottom3% W15%
              _CharacterSlot(
                left: w * 0.64,
                bottom: h * 0.03,
                width: w * 0.15,
                catId: 'robotCat',
                cat: cats[CatId.robotCat],
                breatheCtrl: _breatheCtrl,
                focused: focusedCat == 'robotCat',
                onTap: () => _focus('robotCat'),
                child: Image.asset(
                  CatId.robotCat.assetPath,
                  width: w * 0.15,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _PlaceholderChar('🤖'),
                ),
              ),

              // ── 11. Chrome layer ──────────────────────────────────────────
              if (room.showChrome)
                Positioned.fill(
                  child: _ChromeLayer(room: room, profile: profile),
                ),

              // ── 12. Care sheet overlay ────────────────────────────────────
              if (focusedCat != null)
                Positioned.fill(
                  child: CareSheet(catId: focusedCat),
                ),
            ],
          );
        },
      ),
    );
  }

  void _focus(String id) {
    ref.read(focusedCatProvider.notifier).state = id;
  }
}

// ── Character slot ─────────────────────────────────────────────────────────────
// Positions the sprite + mood bubble + needs indicator.

class _CharacterSlot extends StatelessWidget {
  const _CharacterSlot({
    required this.left,
    required this.bottom,
    required this.width,
    required this.catId,
    required this.cat,
    required this.breatheCtrl,
    required this.focused,
    required this.onTap,
    required this.child,
  });

  final double left, bottom, width;
  final String catId;
  final CatState? cat;
  final AnimationController breatheCtrl;
  final bool focused;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mood = cat?.moodState;
    final needs = cat != null ? _needsHint(cat!) : null;

    // Breathe animation — each character gets a slightly different phase
    final phase = catId.hashCode % 4 * 0.25;
    final breathAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(
        parent: breatheCtrl,
        curve: Interval(phase, (phase + 0.5).clamp(0, 1),
            curve: Curves.easeInOut),
      ),
    );

    return Positioned(
      left: left,
      bottom: bottom,
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: focused ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 350),
          curve: const Cubic(0.2, 0.8, 0.2, 1),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              // Mood bubble
              if (mood != null)
                Positioned(
                  top: -24,
                  left: 0,
                  right: 0,
                  child: Center(child: _MoodBubble(mood: mood)),
                ),

              // Needs indicator
              if (needs != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _NeedsIndicator(needs: needs),
                ),

              // Sprite with shadow + breathe
              AnimatedBuilder(
                animation: breatheCtrl,
                builder: (_, sprite) => Transform.scale(
                  scale: breathAnim.value,
                  alignment: Alignment.bottomCenter,
                  child: sprite,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: kInk.withAlpha(focused ? 77 : 36),
                        blurRadius: focused ? 20 : 8,
                        offset: Offset(0, focused ? 10 : 3),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String? _needsHint(CatState cat) {
    if (cat.hungerLevel < 35) return 'hungry';
    if (cat.energyLevel < 35) return 'tired';
    return null;
  }
}

// ── Kalia slot ────────────────────────────────────────────────────────────────

class _KaliaSlot extends StatelessWidget {
  const _KaliaSlot({
    required this.left,
    required this.bottom,
    required this.width,
    required this.breatheCtrl,
    required this.focused,
    required this.onTap,
  });

  final double left, bottom, width;
  final AnimationController breatheCtrl;
  final bool focused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      bottom: bottom,
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: focused ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 350),
          curve: const Cubic(0.2, 0.8, 0.2, 1),
          child: AnimatedBuilder(
            animation: breatheCtrl,
            builder: (_, child) => Transform.scale(
              scale: 1.0 +
                  (breatheCtrl.value - 0.5).abs() * 0.015,
              alignment: Alignment.bottomCenter,
              child: child,
            ),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: kInk.withAlpha(focused ? 77 : 36),
                    blurRadius: focused ? 20 : 8,
                    offset: Offset(0, focused ? 10 : 3),
                  ),
                ],
              ),
              child: SpriteSheetAnimator(
                assetPath: KaliaSprites.assetPath,
                frames: KaliaSprites.idleWaveCheer,
                frameDuration: const Duration(milliseconds: 250),
                fallback: Image.asset(
                  'assets/characters/Kalia.png',
                  width: width,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => _PlaceholderChar('🧒'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Noodles sprite (mood-animated) ────────────────────────────────────────────

class _NoodlesSprite extends StatelessWidget {
  const _NoodlesSprite({required this.cat, required this.width});
  final CatState cat;
  final double width;

  @override
  Widget build(BuildContext context) {
    final frames = switch (cat.moodState) {
      MoodState.zoomies => NoodlesSprites.run,
      MoodState.happy || MoodState.neutral => NoodlesSprites.standDance,
      _ => NoodlesSprites.idleSleep,
    };
    final fps = switch (cat.moodState) {
      MoodState.zoomies => const Duration(milliseconds: 120),
      MoodState.happy || MoodState.neutral =>
        const Duration(milliseconds: 180),
      _ => const Duration(milliseconds: 280),
    };
    return SpriteSheetAnimator(
      assetPath: NoodlesSprites.assetPath,
      frames: frames,
      frameDuration: fps,
      fallback: Image.asset(
        CatId.noodles.assetPath,
        width: width,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _PlaceholderChar('🐈'),
      ),
    );
  }
}

// ── Mood bubble ───────────────────────────────────────────────────────────────

class _MoodBubble extends StatelessWidget {
  const _MoodBubble({required this.mood});
  final MoodState mood;

  String get _glyph => switch (mood) {
        MoodState.happy => '♡',
        MoodState.neutral => '∙',
        MoodState.grumpy || MoodState.overloaded => '⌢',
        MoodState.sad => '•',
        MoodState.zoomies => '⚡',
      };

  Color get _color => switch (mood) {
        MoodState.happy => const Color(0xFFD88A7A),
        MoodState.neutral => const Color(0xFFA39282),
        MoodState.grumpy || MoodState.overloaded => const Color(0xFFB25C20),
        MoodState.sad => const Color(0xFF8FB8C7),
        MoodState.zoomies => const Color(0xFFE87E8A),
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E3D2E23),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        _glyph,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: _color,
          height: 1,
        ),
      ),
    );
  }
}

// ── Needs indicator ───────────────────────────────────────────────────────────

class _NeedsIndicator extends StatefulWidget {
  const _NeedsIndicator({required this.needs});
  final String needs;

  @override
  State<_NeedsIndicator> createState() => _NeedsIndicatorState();
}

class _NeedsIndicatorState extends State<_NeedsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bob = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bob.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bob,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, (_bob.value - 0.5) * 3),
        child: child,
      ),
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: kBlush, width: 1.6),
          boxShadow: const [
            BoxShadow(
              color: Color(0x393D2E23),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.needs == 'hungry' ? '🥣' : '💤',
            style: const TextStyle(fontSize: 10, height: 1),
          ),
        ),
      ),
    );
  }
}

// ── Chrome layer ──────────────────────────────────────────────────────────────

class _ChromeLayer extends ConsumerWidget {
  const _ChromeLayer({required this.room, required this.profile});

  final RoomState room;
  final dynamic profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final isNight = room.isNight;

    return Stack(
      children: [
        // Title pill — top left
        Positioned(
          top: 10,
          left: 16,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF5EA).withAlpha(179),
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F3D2E23),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Kalia's room",
                  style: GoogleFonts.caveat(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: kInk,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  room.timeLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B5A4A),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Action dots — top right
        Positioned(
          top: 10,
          right: 16,
          child: Row(
            children: [
              _ChromeBtn(
                icon: '🧘',
                isNight: isNight,
                onTap: () => context.go(AppRoutes.calmCorner),
              ),
              const SizedBox(width: 6),
              _ChromeBtn(
                icon: '🧳',
                isNight: isNight,
                badge: profile.pendingTrunks > 0
                    ? profile.pendingTrunks
                    : null,
                onTap: () => context.go(AppRoutes.trunk),
              ),
              const SizedBox(width: 6),
              _ChromeBtn(
                icon: '♪',
                isNight: isNight,
                onTap: () => _showGamesMenu(context),
              ),
            ],
          ),
        ),

        // Purr-gress bar — bottom left
        Positioned(
          left: 16,
          bottom: 10,
          width: 260,
          child: _PurrBar(
            xp: profile.totalXp,
            level: profile.totalXp ~/ 100,
            cycleXp: profile.cycleXp,
          ),
        ),
      ],
    );
  }

  void _showGamesMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _GamesMenu(),
    );
  }
}

// ── Chrome action button ──────────────────────────────────────────────────────

class _ChromeBtn extends StatelessWidget {
  const _ChromeBtn({
    required this.icon,
    required this.isNight,
    required this.onTap,
    this.badge,
  });

  final String icon;
  final bool isNight;
  final int? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFFBF5EA).withAlpha(230),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2E3D2E23),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 15)),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Color(0xFFD88A7A),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Purr-gress bar ────────────────────────────────────────────────────────────

class _PurrBar extends StatelessWidget {
  const _PurrBar({
    required this.xp,
    required this.level,
    required this.cycleXp,
  });

  final int xp, level, cycleXp;

  @override
  Widget build(BuildContext context) {
    final pct = cycleXp / 100;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF5EA).withAlpha(245),
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E3D2E23),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: kBlush,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$level',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PURR-GRESS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6B5A4A),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 5,
                    backgroundColor: kPaper2,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFE8B4A0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$xp ✦',
            style: GoogleFonts.caveat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: kInk,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dust motes ────────────────────────────────────────────────────────────────

class _DustMotes extends AnimatedWidget {
  const _DustMotes({required AnimationController ctrl, required this.count})
      : super(listenable: ctrl);

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = (listenable as AnimationController).value;

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _DustMotePainter(t: t, count: count),
        ),
      ),
    );
  }
}

class _DustMotePainter extends CustomPainter {
  final double t;
  final int count;

  const _DustMotePainter({required this.t, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFBF5EA)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

    for (var i = 0; i < count; i++) {
      final phase = (t + i / count) % 1.0;
      final startX = size.width * (0.08 + (i * 0.09) % 0.84);
      final startY = size.height * (0.18 + (i % 3) * 0.22);
      final dy = -phase * size.height * 0.25;
      final dx = (i % 2 == 0 ? 1 : -1) * phase * size.width * 0.05;
      final opacity = phase < 0.2
          ? phase / 0.2 * 0.55
          : (phase > 0.8 ? (1.0 - phase) / 0.2 * 0.55 : 0.55);
      paint.color = Color.fromRGBO(251, 245, 234, opacity);
      canvas.drawCircle(
          Offset(startX + dx, startY + dy), 2, paint);
    }
  }

  @override
  bool shouldRepaint(_DustMotePainter old) => old.t != t;
}

// ── Placeholder ───────────────────────────────────────────────────────────────

class _PlaceholderChar extends StatelessWidget {
  const _PlaceholderChar(this.emoji);
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5ECDE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// ── Dev games menu ────────────────────────────────────────────────────────────

class _GamesMenu extends StatelessWidget {
  const _GamesMenu();

  @override
  Widget build(BuildContext context) {
    final games = [
      (emoji: '🫧', label: 'Calming the Zoomies', route: AppRoutes.breathing),
      (emoji: '😊', label: "Robot Cat's Feelings Sort", route: AppRoutes.eqSort),
      (emoji: '🤖', label: "Robot Cat's Logic Loop", route: AppRoutes.logicLoop),
      (emoji: '📖', label: "Noodles' Laser Letters", route: AppRoutes.reading),
      (emoji: '🔢', label: "Loaf Cat's Snack Stack", route: AppRoutes.math),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFBF5EA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0D0B8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '🎮 Minigames',
            style: GoogleFonts.caveat(
                fontSize: 26, fontWeight: FontWeight.w700, color: kInk),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dev shortcut — triggered by cat states in gameplay',
            style: TextStyle(fontSize: 12, color: Color(0xFFA39282)),
          ),
          const SizedBox(height: 16),
          ...games.map(
            (g) => ListTile(
              leading:
                  Text(g.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(g.label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: kInk)),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 14, color: Color(0xFFA39282)),
              onTap: () {
                Navigator.of(context).pop();
                context.go(g.route);
              },
            ),
          ),
        ],
      ),
    );
  }
}
