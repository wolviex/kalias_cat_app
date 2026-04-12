import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/cat_state.dart';
import '../../core/providers/cats_provider.dart';

/// Displays a cat character sprite with a mood bubble above it.
/// Tapping opens a bottom sheet with full status and care buttons.
class CatSprite extends ConsumerWidget {
  const CatSprite({super.key, required this.catId});

  final CatId catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(catsProvider)[catId]!;
    return GestureDetector(
      onTap: () => _showStatusSheet(context, ref, cat),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Mood bubble ──────────────────────────────────────────
          _MoodBubble(mood: cat.moodState),
          const SizedBox(height: 4),
          // ── Sprite ──────────────────────────────────────────────
          Expanded(
            child: Image.asset(
              catId.assetPath,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => _PlaceholderSprite(catId: catId),
            ),
          ),
          // ── Name label ──────────────────────────────────────────
          Text(
            catId.displayName,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  void _showStatusSheet(BuildContext context, WidgetRef ref, CatState cat) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _CatStatusSheet(catId: catId),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status bottom sheet — uses its own Consumer so it rebuilds on state changes
// while open.
// ─────────────────────────────────────────────────────────────────────────────

class _CatStatusSheet extends ConsumerWidget {
  const _CatStatusSheet({required this.catId});
  final CatId catId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(catsProvider)[catId]!;
    final notifier = ref.read(catsProvider.notifier);
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
          // ── Handle bar ──────────────────────────────────────────
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
          const SizedBox(height: 16),

          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(catId.displayName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    '${mood.label} · ${catId.personality}',
                    style: TextStyle(fontSize: 13, color: mood.color),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Hunger bar ──────────────────────────────────────────
          _StatusBar(
            icon: '🍖',
            label: 'Hunger',
            value: cat.hungerLevel / 100,
            color: const Color(0xFFFF8A65),
          ),
          const SizedBox(height: 10),

          // ── Energy bar ──────────────────────────────────────────
          _StatusBar(
            icon: '⚡',
            label: 'Energy',
            value: cat.energyLevel / 100,
            color: const Color(0xFFFFD54F),
          ),
          const SizedBox(height: 24),

          // ── Care buttons ────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _CareButton(
                  emoji: '🍖',
                  label: 'Feed',
                  onTap: () {
                    notifier.feed(catId);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CareButton(
                  emoji: '⚡',
                  label: 'Play',
                  onTap: () {
                    notifier.play(catId);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _MoodBubble extends StatelessWidget {
  const _MoodBubble({required this.mood});
  final MoodState mood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: mood.color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: mood.color.withAlpha(80)),
      ),
      child: Text(mood.emoji, style: const TextStyle(fontSize: 18)),
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
  final double value; // 0.0–1.0
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('${(value * 100).round()}%',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black45)),
                ],
              ),
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
            ],
          ),
        ),
      ],
    );
  }
}

class _CareButton extends StatelessWidget {
  const _CareButton({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text('$emoji  $label', style: const TextStyle(fontSize: 16)),
    );
  }
}

/// Shown when the asset image fails to load (placeholder art not yet final).
class _PlaceholderSprite extends StatelessWidget {
  const _PlaceholderSprite({required this.catId});
  final CatId catId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          '🐱\n${catId.displayName}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ),
    );
  }
}
