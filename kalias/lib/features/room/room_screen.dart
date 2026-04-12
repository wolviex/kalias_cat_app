import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/cat_state.dart';
import '../../core/models/difficulty_tier.dart';
import '../../core/models/kalia_sprites.dart';
import '../../core/models/player_profile.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/cat_sprite.dart';
import '../../shared/widgets/purr_progress_bar.dart';
import '../../shared/widgets/sprite_sheet_animator.dart';

class RoomScreen extends ConsumerWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      // Transparent so the background image fills behind everything
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
      body: Stack(
        children: [
          // ── Room background — wall ───────────────────────────────────────
          // BoxFit.cover fills the screen; 16:9 image crops symmetrically on
          // portrait. Metadata confirms centre is kept clear for gameplay.
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/bg_room_wall.png',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => Container(
                color: const Color(0xFFEDE7F6),
              ),
            ),
          ),

          // ── Room background — floor ──────────────────────────────────────
          // Anchored bottom-center so the baseboard lines up with the wall
          // asset regardless of screen height. Characters sit on top.
          Positioned.fill(
            child: Image.asset(
              'assets/backgrounds/bg_room_floor.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),

          // ── Content (characters + purr-gress bar) ────────────────────────
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        // Top row — Noodles & Robot Cat
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: CatSprite(catId: CatId.noodles)),
                              const SizedBox(width: 12),
                              Expanded(child: CatSprite(catId: CatId.robotCat)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Bottom row — Loaf Cat & Kalia
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: CatSprite(catId: CatId.loafCat)),
                              const SizedBox(width: 12),
                              Expanded(child: _KaliaSprite(name: profile.name)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Purr-gress bar ───────────────────────────────────────
                const PurrProgressBar(),
              ],
            ),
          ),
        ],
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
// Kalia — the player avatar. No status bubble; tapping shows a friendly note.
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
          // Spacer aligns Kalia's top with the mood bubbles above the cats
          const SizedBox(height: 30),
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
                color: Colors.black54),
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
              value:
                  '${profile.cycleXp} / ${PlayerProfile.xpPerCycle}'),
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
              style:
                  const TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dev-only games menu — removes the need to re-implement minigame navigation
// before Phase 2 cat-state triggers are built.
// ─────────────────────────────────────────────────────────────────────────────

class _GamesMenu extends StatelessWidget {
  const _GamesMenu();

  @override
  Widget build(BuildContext context) {
    final games = [
      (
        emoji: '🫧',
        label: 'Calming the Zoomies',
        route: AppRoutes.breathing,
      ),
      (
        emoji: '😊',
        label: "Robot Cat's Logic Loop",
        route: AppRoutes.eqSort,
      ),
      (
        emoji: '📖',
        label: "Noodles' Laser Letters",
        route: AppRoutes.reading,
      ),
      (
        emoji: '🔢',
        label: "Loaf Cat's Snack Stack",
        route: AppRoutes.math,
      ),
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
            'Dev shortcut — will be triggered by cat states in Phase 2',
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
