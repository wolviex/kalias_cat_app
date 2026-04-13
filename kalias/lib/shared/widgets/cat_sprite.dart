import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/cat_state.dart';
import '../../core/models/noodles_sprites.dart';
import '../../core/providers/cats_provider.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';
import 'sprite_sheet_animator.dart';

/// XP awarded for a single care action (feed or play).
const _careXp = 5;

/// Displays a cat sprite with animated mood bubble. Tap → status sheet.
class CatSprite extends ConsumerWidget {
  const CatSprite({super.key, required this.catId});
  final CatId catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(catsProvider)[catId]!;

    return GestureDetector(
      onTap: () => _showStatusSheet(context),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AnimatedMoodBubble(cat: cat),
              const SizedBox(height: 4),
              Expanded(child: _buildSprite(cat)),
              Text(
                catId.displayName,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54),
              ),
              const SizedBox(height: 4),
            ],
          ),
          // Pulsing alert badge when minigame is triggered
          if (cat.minigameTriggered)
            Positioned(
              top: 0,
              right: 0,
              child: _TriggerBadge(catId: catId),
            ),
        ],
      ),
    );
  }

  Widget _buildSprite(CatState cat) {
    if (catId == CatId.noodles) {
      final frames = switch (cat.moodState) {
        MoodState.zoomies                      => NoodlesSprites.run,
        MoodState.happy || MoodState.neutral   => NoodlesSprites.standDance,
        _                                      => NoodlesSprites.idleSleep,
      };
      final fps = switch (cat.moodState) {
        MoodState.zoomies => const Duration(milliseconds: 120),
        MoodState.happy || MoodState.neutral => const Duration(milliseconds: 180),
        _ => const Duration(milliseconds: 280),
      };
      return SpriteSheetAnimator(
        assetPath: NoodlesSprites.assetPath,
        frames: frames,
        frameDuration: fps,
        fallback: _PlaceholderSprite(catId: catId),
      );
    }
    return Image.asset(
      catId.assetPath,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _PlaceholderSprite(catId: catId),
    );
  }

  void _showStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CatStatusSheet(catId: catId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mood bubble — shows care reaction emoji briefly, then reverts to mood emoji.
// Uses AnimatedSwitcher for a smooth crossfade.
// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedMoodBubble extends StatelessWidget {
  const _AnimatedMoodBubble({required this.cat});
  final CatState cat;

  String get _displayEmoji {
    if (cat.lastReaction == CareReaction.fed) return '🍖';
    if (cat.lastReaction == CareReaction.played) return '⚡';
    return cat.moodState.emoji;
  }

  Color get _displayColor {
    if (cat.lastReaction != null) return const Color(0xFF66BB6A);
    return cat.moodState.color;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(_displayEmoji),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _displayColor.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _displayColor.withAlpha(80)),
        ),
        child: Text(_displayEmoji, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing exclamation badge shown when a minigame is triggered.
// ─────────────────────────────────────────────────────────────────────────────

class _TriggerBadge extends StatefulWidget {
  const _TriggerBadge({required this.catId});
  final CatId catId;

  @override
  State<_TriggerBadge> createState() => _TriggerBadgeState();
}

class _TriggerBadgeState extends State<_TriggerBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.5, end: 1.0).animate(_pulse),
      child: Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFFEF5350),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text('!', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CatStatusSheet extends ConsumerWidget {
  const _CatStatusSheet({required this.catId});
  final CatId catId;

  String get _triggeredGameLabel => switch (catId) {
        CatId.noodles => 'Calming the Zoomies 🌀',
        CatId.loafCat => "Loaf Cat's Snack Stack 🍖",
        CatId.robotCat => 'Feelings Sort 😊',
      };

  String get _triggeredRoute => switch (catId) {
        CatId.noodles => AppRoutes.breathing,
        CatId.loafCat => AppRoutes.math,
        CatId.robotCat => AppRoutes.eqSort,
      };

  String get _triggeredPrompt => switch (catId) {
        CatId.noodles => 'Noodles has the Zoomies! Help them calm down.',
        CatId.loafCat => 'Loaf Cat is hungry! Time to stack some snacks.',
        CatId.robotCat => 'Robot Cat is grumpy! Help sort those feelings.',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(catsProvider)[catId]!;
    final catsNotifier = ref.read(catsProvider.notifier);
    final profileNotifier = ref.read(playerProfileProvider.notifier);
    final mood = cat.moodState;

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
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Minigame trigger banner
          if (cat.minigameTriggered) ...[
            _MinigameBanner(
              prompt: _triggeredPrompt,
              buttonLabel: _triggeredGameLabel,
              onPlay: () {
                Navigator.of(context).pop();
                context.go(_triggeredRoute);
              },
            ),
            const SizedBox(height: 16),
          ],

          // Header
          Row(children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(catId.displayName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              Text('${mood.label} · ${catId.personality}',
                  style: TextStyle(fontSize: 13, color: mood.color)),
            ]),
          ]),
          const SizedBox(height: 20),

          _StatusBar(icon: '🍖', label: 'Hunger',
              value: cat.hungerLevel / 100,
              color: const Color(0xFFFF8A65)),
          const SizedBox(height: 10),
          _StatusBar(icon: '⚡', label: 'Energy',
              value: cat.energyLevel / 100,
              color: const Color(0xFFFFD54F)),
          const SizedBox(height: 24),

          // Care buttons
          Row(children: [
            Expanded(
              child: _CareButton(
                emoji: '🍖',
                label: 'Feed  +${_careXp}xp',
                onTap: () async {
                  catsNotifier.feed(catId);
                  await profileNotifier.addXp(_careXp);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _CareButton(
                emoji: '⚡',
                label: 'Play  +${_careXp}xp',
                onTap: () async {
                  catsNotifier.play(catId);
                  await profileNotifier.addXp(_careXp);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _MinigameBanner extends StatelessWidget {
  const _MinigameBanner({
    required this.prompt,
    required this.buttonLabel,
    required this.onPlay,
  });
  final String prompt;
  final String buttonLabel;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(prompt,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: onPlay,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange.shade600,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final String icon;
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 8),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${(value * 100).round()}%',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 10,
              backgroundColor: Colors.black.withAlpha(20),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _CareButton extends StatelessWidget {
  const _CareButton(
      {required this.emoji, required this.label, required this.onTap});
  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text('$emoji  $label', style: const TextStyle(fontSize: 15)),
    );
  }
}

class _PlaceholderSprite extends StatelessWidget {
  const _PlaceholderSprite({required this.catId});
  final CatId catId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(16)),
      child: Center(
        child: Text('🐱\n${catId.displayName}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ),
    );
  }
}
