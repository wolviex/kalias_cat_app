import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/cat_state.dart';
import '../../../core/models/difficulty_tier.dart';
import '../../../core/providers/cats_provider.dart';
import '../../../core/providers/player_profile_provider.dart';
import '../../../core/router/app_router.dart';

const _mg2Xp = 15;

// ── Data model ────────────────────────────────────────────────────────────────

enum _BucketId { happy, sad, angry }

class _Emotion {
  const _Emotion({
    required this.emoji,
    required this.name,
    required this.bucket,
    required this.color,
  });
  final String emoji;
  final String name;
  final _BucketId bucket;
  final Color color;
}

class _SortBucket {
  const _SortBucket({
    required this.id,
    required this.emoji,
    required this.label,
    required this.color,
  });
  final _BucketId id;
  final String emoji;
  final String label;
  final Color color;
}

class _SortConfig {
  const _SortConfig({
    required this.emotions,
    required this.buckets,
    required this.showLabels,
    required this.cardSize,
  });
  final List<_Emotion> emotions;
  final List<_SortBucket> buckets;
  final bool showLabels; // false = Sprout picture-only mode
  final double cardSize;

  static const _threeBuckets = [
    _SortBucket(id: _BucketId.happy, emoji: '😊', label: 'Happy',  color: Color(0xFFFFD54F)),
    _SortBucket(id: _BucketId.sad,   emoji: '😢', label: 'Sad',    color: Color(0xFF90CAF9)),
    _SortBucket(id: _BucketId.angry, emoji: '😠', label: 'Angry',  color: Color(0xFFEF9A9A)),
  ];

  static _SortConfig forTier(DifficultyTier tier) => switch (tier) {
    DifficultyTier.sprout => const _SortConfig(
      // 3 cards, 2 buckets (positive / not-happy), no word labels
      buckets: [
        _SortBucket(id: _BucketId.happy, emoji: '😊', label: 'Happy!',       color: Color(0xFFFFD54F)),
        _SortBucket(id: _BucketId.sad,   emoji: '😟', label: 'Not happy...', color: Color(0xFF90CAF9)),
      ],
      emotions: [
        _Emotion(emoji: '😊', name: 'Happy', bucket: _BucketId.happy, color: Color(0xFFFFF9C4)),
        _Emotion(emoji: '😢', name: 'Sad',   bucket: _BucketId.sad,   color: Color(0xFFE3F2FD)),
        _Emotion(emoji: '😠', name: 'Angry', bucket: _BucketId.sad,   color: Color(0xFFFFEBEE)),
      ],
      showLabels: false,
      cardSize: 100,
    ),
    DifficultyTier.seedling => const _SortConfig(
      // 5 cards, 3 buckets, word labels
      buckets: _threeBuckets,
      emotions: [
        _Emotion(emoji: '😊', name: 'Happy',  bucket: _BucketId.happy, color: Color(0xFFFFF9C4)),
        _Emotion(emoji: '😌', name: 'Calm',   bucket: _BucketId.happy, color: Color(0xFFE8F5E9)),
        _Emotion(emoji: '😢', name: 'Sad',    bucket: _BucketId.sad,   color: Color(0xFFE3F2FD)),
        _Emotion(emoji: '😨', name: 'Scared', bucket: _BucketId.sad,   color: Color(0xFFEDE7F6)),
        _Emotion(emoji: '😠', name: 'Angry',  bucket: _BucketId.angry, color: Color(0xFFFFEBEE)),
      ],
      showLabels: true,
      cardSize: 88,
    ),
    DifficultyTier.bloom => const _SortConfig(
      // 6 nuanced emotions, 3 buckets, word labels
      buckets: _threeBuckets,
      emotions: [
        _Emotion(emoji: '😊', name: 'Happy',       bucket: _BucketId.happy, color: Color(0xFFFFF9C4)),
        _Emotion(emoji: '😤', name: 'Proud',        bucket: _BucketId.happy, color: Color(0xFFE8F5E9)),
        _Emotion(emoji: '😌', name: 'Calm',         bucket: _BucketId.happy, color: Color(0xFFE0F7FA)),
        _Emotion(emoji: '😰', name: 'Nervous',      bucket: _BucketId.sad,   color: Color(0xFFEDE7F6)),
        _Emotion(emoji: '😳', name: 'Embarrassed',  bucket: _BucketId.sad,   color: Color(0xFFFCE4EC)),
        _Emotion(emoji: '😠', name: 'Angry',        bucket: _BucketId.angry, color: Color(0xFFFFEBEE)),
      ],
      showLabels: true,
      cardSize: 80,
    ),
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────

class EqSortScreen extends ConsumerStatefulWidget {
  const EqSortScreen({super.key});

  @override
  ConsumerState<EqSortScreen> createState() => _EqSortScreenState();
}

class _EqSortScreenState extends ConsumerState<EqSortScreen> {
  late final _SortConfig _config;
  late List<_Emotion> _remaining;
  _BucketId? _wrongBucket; // flashes red for 500 ms on a wrong drop
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    final tier = ref.read(playerProfileProvider).difficultyTier;
    _config = _SortConfig.forTier(tier);
    _remaining = List.from(_config.emotions);
  }

  void _onDrop(_Emotion emotion, _SortBucket bucket) {
    if (emotion.bucket == bucket.id) {
      setState(() => _remaining.remove(emotion));
      if (_remaining.isEmpty && !_completing) {
        _completing = true;
        _onComplete();
      }
    } else {
      // Wrong bucket — flash it and card snaps back automatically
      setState(() => _wrongBucket = bucket.id);
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() => _wrongBucket = null);
      });
    }
  }

  Future<void> _onComplete() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    ref.read(catsProvider.notifier).restoreAfterMinigame(
      CatId.robotCat,
      energy: 40,
    );
    await ref.read(playerProfileProvider.notifier).addXp(_mg2Xp);
    if (mounted) context.go(AppRoutes.reward, extra: _mg2Xp);
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _config.emotions.length - _remaining.length;
    final total  = _config.emotions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCE93D8),
        elevation: 0,
        leading: BackButton(onPressed: () => context.go(AppRoutes.room)),
        title: const Text(
          '🤖 Feelings Sort',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Prompt ────────────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Help Robot Cat sort these feelings!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$sorted / $total sorted',
              style: const TextStyle(fontSize: 14, color: Colors.black45),
            ),

            // ── Card area ─────────────────────────────────────────────────
            Expanded(
              child: Center(
                child: _remaining.isEmpty
                    ? const Text('✨ All sorted!',
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: _remaining
                              .map((e) => _DraggableCard(
                                    emotion: e,
                                    showLabel: _config.showLabels,
                                    size: _config.cardSize,
                                  ))
                              .toList(),
                        ),
                      ),
              ),
            ),

            // ── Bucket row ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
              child: Row(
                children: _config.buckets
                    .map((b) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: _BucketTarget(
                              bucket: b,
                              isWrong: _wrongBucket == b.id,
                              onDrop: (e) => _onDrop(e, b),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Draggable emotion card ────────────────────────────────────────────────────

class _DraggableCard extends StatelessWidget {
  const _DraggableCard({
    required this.emotion,
    required this.showLabel,
    required this.size,
  });
  final _Emotion emotion;
  final bool showLabel;
  final double size;

  Widget _card({double opacity = 1.0, double scale = 1.0}) {
    final h = showLabel ? size + 28 : size;
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: h,
          decoration: BoxDecoration(
            color: emotion.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 6,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emotion.emoji,
                  style: TextStyle(fontSize: size * 0.44)),
              if (showLabel) ...[
                const SizedBox(height: 4),
                Text(emotion.name,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<_Emotion>(
      data: emotion,
      feedback: Material(color: Colors.transparent,
          child: _card(scale: 1.08)),
      childWhenDragging: _card(opacity: 0.25),
      child: _card(),
    );
  }
}

// ── Drop target bucket ────────────────────────────────────────────────────────

class _BucketTarget extends StatelessWidget {
  const _BucketTarget({
    required this.bucket,
    required this.isWrong,
    required this.onDrop,
  });
  final _SortBucket bucket;
  final bool isWrong;
  final ValueChanged<_Emotion> onDrop;

  @override
  Widget build(BuildContext context) {
    return DragTarget<_Emotion>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, candidates, _) {
        final hovered = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 104,
          decoration: BoxDecoration(
            color: isWrong
                ? Colors.red.shade100
                : hovered
                    ? bucket.color.withAlpha(210)
                    : bucket.color.withAlpha(90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isWrong
                  ? Colors.red.shade400
                  : hovered
                      ? bucket.color
                      : bucket.color.withAlpha(140),
              width: hovered ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(bucket.emoji,
                  style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 4),
              Text(bucket.label,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}
