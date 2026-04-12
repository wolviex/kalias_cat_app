import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/player_profile.dart';
import '../../core/providers/player_profile_provider.dart';

/// Displays the Purr-gress bar — XP progress toward the next Magical Trunk unlock.
/// Shown at the bottom of the room screen.
class PurrProgressBar extends ConsumerWidget {
  const PurrProgressBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final progress = profile.cycleXp / PlayerProfile.xpPerCycle;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🧶', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Purr-gress',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${profile.cycleXp} / ${PlayerProfile.xpPerCycle} XP',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: Colors.purple.shade50,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purple.shade300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Trunk icon — will animate in Phase 4 when bar fills
          const Text('🧳', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}
