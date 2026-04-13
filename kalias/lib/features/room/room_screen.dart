import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/cat_state.dart';
import '../../core/models/difficulty_tier.dart';
import '../../core/providers/cats_provider.dart';
import '../../core/models/kalia_sprites.dart';
import '../../core/models/player_profile.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/cat_sprite.dart';
import '../../shared/widgets/purr_progress_bar.dart';
import '../../shared/widgets/sprite_sheet_animator.dart';

// Approximate height of the PurrProgressBar (padding 20px + content ~36px).
// Used to keep characters' feet above the bar.
const _purrBarH = 56.0;

class RoomScreen extends ConsumerWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(30),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go(AppRoutes.home),
        ),
        title: Text(
          "${profile.name}'s Room",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sports_esports_outlined, color: Colors.white),
            tooltip: 'Games (dev)',
            onPressed: () => _showGamesMenu(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;

          // ── Character slot sizes (proportional to screen width) ──────────
          // Heights use a 1:1.35 ratio — suits the portrait-ish cat sprites.
          // Kalia uses 1:1.4 to match her 160×180 sprite sheet frames.
          final noodlesW = w * 0.27;
          final loafW    = w * 0.23;
          final kaliaW   = w * 0.27;
          final robotW   = w * 0.25;

          return Stack(
            children: [
              // ── Room background — wall ──────────────────────────────────
              Positioned.fill(
                child: Image.asset(
                  'assets/backgrounds/bg_room_wall.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  errorBuilder: (_, _, _) =>
                      Container(color: const Color(0xFFEDE7F6)),
                ),
              ),

              // ── Room background — floor ─────────────────────────────────
              // Anchored bottom-center so baseboard lines up with the wall.
              Positioned.fill(
                child: Image.asset(
                  'assets/backgrounds/bg_room_floor.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),

              // ── Yarn corner — Noodles' interactive item ──────────────────
              // Square asset (1024×1024), anchor bottom-center, sits on floor.
              // Pulses when Noodles' minigame is triggered; always tappable.
              Positioned(
                left: 0,
                bottom: _purrBarH,
                width: w * 0.33,
                height: w * 0.33,
                child: Consumer(
                  builder: (context, ref, _) {
                    final triggered =
                        ref.watch(catsProvider)[CatId.noodles]!.minigameTriggered;
                    return _RoomItem(
                      assetPath: 'assets/backgrounds/item_yarn_corner.png',
                      isActive: triggered,
                      onTap: () => context.go(AppRoutes.breathing),
                    );
                  },
                ),
              ),

              // ── Noodles — left, slightly raised (depth) ─────────────────
              Positioned(
                left: w * 0.01,
                bottom: _purrBarH + 16,
                width: noodlesW,
                height: noodlesW * 1.35,
                child: CatSprite(catId: CatId.noodles),
              ),

              // ── Loaf Cat — center-left, on the rug ──────────────────────
              Positioned(
                left: w * 0.27,
                bottom: _purrBarH + 4,
                width: loafW,
                height: loafW * 1.35,
                child: CatSprite(catId: CatId.loafCat),
              ),

              // ── Kalia — center, protagonist ──────────────────────────────
              Positioned(
                left: w * 0.43,
                bottom: _purrBarH,
                width: kaliaW,
                height: kaliaW * 1.4,
                child: _KaliaSprite(name: profile.name),
              ),

              // ── Robot Cat — right side, slightly raised (depth) ──────────
              Positioned(
                right: w * 0.01,
                bottom: _purrBarH + 10,
                width: robotW,
                height: robotW * 1.35,
                child: CatSprite(catId: CatId.robotCat),
              ),

              // ── Purr-gress bar ───────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: const PurrProgressBar(),
                ),
              ),
            ],
          );
        },
      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Kalia — the player avatar. Tap shows profile sheet.
// Sized explicitly by the Positioned parent, so no Expanded or size hacks needed.
// ─────────────────────────────────────────────────────────────────────────────

class _KaliaSprite extends ConsumerWidget {
  const _KaliaSprite({required this.name});
  final String name;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showProfileSheet(context, ref),
      child: Column(
        children: [
          Expanded(
            child: SpriteSheetAnimator(
              assetPath: KaliaSprites.assetPath,
              frames: KaliaSprites.idleWaveCheer,
              frameDuration: const Duration(milliseconds: 250),
              fallback: Container(
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text('🧒\nKalia',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54)),
                ),
              ),
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 3)],
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _KaliaProfileSheet(ref: ref),
    );
  }
}

class _KaliaProfileSheet extends ConsumerWidget {
  const _KaliaProfileSheet({required this.ref});
  // ignore: unused_field
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final notifier = ref.read(playerProfileProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            const Text('🧒', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(profile.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text(profile.difficultyTier.label,
                  style: const TextStyle(fontSize: 13, color: Colors.black54)),
            ]),
          ]),
          const SizedBox(height: 20),
          _ProfileStat(label: 'Total XP', value: '${profile.totalXp} ✨'),
          _ProfileStat(
              label: 'Purr-gress',
              value: '${profile.cycleXp} / ${PlayerProfile.xpPerCycle}'),
          _ProfileStat(
              label: 'Trunks Opened', value: '${profile.trunkOpenCount} 🧳'),
          const SizedBox(height: 20),
          const Text('Change difficulty level:',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: DifficultyTier.values.map((tier) {
              final selected = profile.difficultyTier == tier;
              return ChoiceChip(
                label: Text(tier.label),
                selected: selected,
                onSelected: (_) async {
                  await notifier.setDifficultyTier(tier);
                  if (context.mounted) Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive room item — furniture/object that triggers a minigame on tap.
// Shows a pulsing glow when [isActive] (cat's minigame trigger is true).
// ─────────────────────────────────────────────────────────────────────────────

class _RoomItem extends StatefulWidget {
  const _RoomItem({
    required this.assetPath,
    required this.onTap,
    this.isActive = false,
  });

  final String assetPath;
  final VoidCallback onTap;
  final bool isActive;

  @override
  State<_RoomItem> createState() => _RoomItemState();
}

class _RoomItemState extends State<_RoomItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isActive)
            FadeTransition(
              opacity: Tween<double>(begin: 0.2, end: 0.7).animate(_pulse),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade300,
                      blurRadius: 28,
                      spreadRadius: 14,
                    ),
                  ],
                ),
              ),
            ),
          Image.asset(
            widget.assetPath,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dev-only games menu
// ─────────────────────────────────────────────────────────────────────────────

class _GamesMenu extends StatelessWidget {
  const _GamesMenu();

  @override
  Widget build(BuildContext context) {
    final games = [
      (emoji: '🫧', label: 'Calming the Zoomies',      route: AppRoutes.breathing),
      (emoji: '😊', label: "Robot Cat's Logic Loop",    route: AppRoutes.eqSort),
      (emoji: '📖', label: "Noodles' Laser Letters",    route: AppRoutes.reading),
      (emoji: '🔢', label: "Loaf Cat's Snack Stack",    route: AppRoutes.math),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '🎮 Minigames',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dev shortcut — triggered by cat states in Phase 2',
            style: TextStyle(fontSize: 12, color: Colors.black38),
          ),
          const SizedBox(height: 16),
          ...games.map(
            (g) => ListTile(
              leading: Text(g.emoji, style: const TextStyle(fontSize: 24)),
              title: Text(g.label),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
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
