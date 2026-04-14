import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/player_profile.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';

/// Shown after any minigame completes. XP has already been awarded by the
/// minigame screen before navigating here — this screen just celebrates.
class RewardScreen extends ConsumerWidget {
  const RewardScreen({super.key, required this.xpEarned});

  /// XP awarded by the minigame that just completed.
  final int xpEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            // ── Celebration ───────────────────────────────────────────
            const Center(
              child: Text('🎉', style: TextStyle(fontSize: 80)),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Great job, ${profile.name}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '+$xpEarned XP  ⭐',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Total: ${profile.totalXp} XP',
                style: const TextStyle(fontSize: 14, color: Colors.black45),
              ),
            ),

            const Spacer(),

            // ── Purr-gress bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Purr-gress',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: profile.cycleXp / PlayerProfile.xpPerCycle,
                      minHeight: 16,
                      backgroundColor: Colors.purple.shade50,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.purple.shade300),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${profile.cycleXp} / ${PlayerProfile.xpPerCycle} XP to next trunk 🧳',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black38),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Trunk CTA (when a cycle just completed) ───────────────
            if (profile.pendingTrunks > 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                child: _TrunkBanner(onTap: () => context.go(AppRoutes.trunk)),
              ),

            // ── Back button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FilledButton(
                onPressed: () => context.go(AppRoutes.room),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Back to Room 🏠',
                    style: TextStyle(fontSize: 17)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Trunk banner ──────────────────────────────────────────────────────────────

class _TrunkBanner extends StatelessWidget {
  const _TrunkBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.purple.shade700],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withAlpha(80),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('🧳', style: TextStyle(fontSize: 40)),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trunk Unlocked!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Tap to open and claim your reward',
                    style: TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
