import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/cat_state.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/cat_sprite.dart';
import '../../shared/widgets/purr_progress_bar.dart';

class RoomScreen extends ConsumerWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
        title: Text(
          "${profile.name}'s Room",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Dev shortcut — lets us navigate to minigame stubs while
          // proper trigger logic is built in Phase 2+.
          IconButton(
            icon: const Icon(Icons.sports_esports_outlined),
            tooltip: 'Games (dev)',
            onPressed: () => _showGamesMenu(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Character scene ────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                children: [
                  // Top row — Noodles & Robot Cat
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CatSprite(catId: CatId.noodles),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CatSprite(catId: CatId.robotCat),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Bottom row — Loaf Cat & Kalia (player avatar)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: CatSprite(catId: CatId.loafCat),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _KaliaSprite(name: profile.name),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Purr-gress bar ─────────────────────────────────────────────
          const PurrProgressBar(),
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

class _KaliaSprite extends StatelessWidget {
  const _KaliaSprite({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("That's you, $name! 🌟"),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Spacer to align with mood bubbles above cats
          const SizedBox(height: 30),
          Expanded(
            child: Image.asset(
              'assets/characters/Kalia.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Container(
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
          const Text(
            'Kalia',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54),
          ),
          const SizedBox(height: 4),
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
