import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/reward_item.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TrunkScreen extends ConsumerStatefulWidget {
  const TrunkScreen({super.key});

  @override
  ConsumerState<TrunkScreen> createState() => _TrunkScreenState();
}

class _TrunkScreenState extends ConsumerState<TrunkScreen>
    with SingleTickerProviderStateMixin {
  // Phase: bounce → tap-to-open → card-pick → reward-reveal
  _Phase _phase = _Phase.bounce;
  late AnimationController _bounceCtrl;
  late Animation<double> _bounce;

  late List<RewardItem> _cards;
  RewardItem? _picked;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _bounce = Tween<double>(begin: 0, end: -16).animate(
      CurvedAnimation(parent: _bounceCtrl, curve: Curves.easeInOut),
    );

    _generateCards();
  }

  void _generateCards() {
    final profile = ref.read(playerProfileProvider);
    // trunkOpenCount is the number already opened; this is the next one (1-indexed)
    final trunkNumber = profile.trunkOpenCount + 1;
    final pool = List<RewardItem>.from(RewardCatalog.poolForTrunk(trunkNumber));

    // Prefer un-owned items, but allow duplicates if pool is too small
    final owned = profile.inventory.toSet();
    final unowned = pool.where((r) => !owned.contains(r.id)).toList();
    final source = unowned.length >= 3 ? unowned : pool;
    source.shuffle(Random());
    _cards = source.take(3).toList();
  }

  void _openTrunk() {
    _bounceCtrl.stop();
    setState(() => _phase = _Phase.cardPick);
  }

  Future<void> _pickCard(RewardItem item) async {
    await ref.read(playerProfileProvider.notifier).openTrunk(item.id);
    setState(() {
      _picked = item;
      _phase = _Phase.reveal;
    });
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A148C),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: switch (_phase) {
            _Phase.bounce   => _BounceView(bounce: _bounce, onTap: _openTrunk),
            _Phase.cardPick => _CardPickView(cards: _cards, onPick: _pickCard),
            _Phase.reveal   => _RevealView(item: _picked!, onDone: () => context.go(AppRoutes.room)),
          },
        ),
      ),
    );
  }
}

enum _Phase { bounce, cardPick, reveal }

// ── Bounce view ───────────────────────────────────────────────────────────────

class _BounceView extends StatelessWidget {
  const _BounceView({required this.bounce, required this.onTap});
  final Animation<double> bounce;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('bounce'),
      children: [
        const Spacer(),
        const Text(
          '🎉 Trunk Unlocked!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap the trunk to open your reward!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: AnimatedBuilder(
            animation: bounce,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, bounce.value),
              child: child,
            ),
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA000),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade300.withAlpha(180),
                    blurRadius: 32,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🧳', style: TextStyle(fontSize: 80)),
              ),
            ),
          ),
        ),
        const Spacer(),
        const Text(
          '↑ Tap to open ↑',
          style: TextStyle(fontSize: 14, color: Colors.white38),
        ),
        const SizedBox(height: 48),
      ],
    );
  }
}

// ── Card pick view ────────────────────────────────────────────────────────────

class _CardPickView extends StatelessWidget {
  const _CardPickView({required this.cards, required this.onPick});
  final List<RewardItem> cards;
  final ValueChanged<RewardItem> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('cards'),
      children: [
        const Spacer(),
        const Text(
          'Choose your reward!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap a card to claim it',
          style: TextStyle(fontSize: 15, color: Colors.white60),
        ),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: cards
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _RewardCard(item: item, onTap: () => onPick(item)),
                  ))
              .toList(),
        ),
        const Spacer(),
      ],
    );
  }
}

class _RewardCard extends StatefulWidget {
  const _RewardCard({required this.item, required this.onTap});
  final RewardItem item;
  final VoidCallback onTap;

  @override
  State<_RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<_RewardCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _hover = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 1.08).animate(_hover);

  @override
  void dispose() {
    _hover.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryLabel = switch (widget.item.category) {
      RewardCategory.kaliaGear   => 'Kalia Gear',
      RewardCategory.catCostume  => 'Cat Costume',
      RewardCategory.toy         => 'Toy',
    };
    return GestureDetector(
      onTapDown: (_) => _hover.forward(),
      onTapUp: (_) {
        _hover.reverse();
        widget.onTap();
      },
      onTapCancel: () => _hover.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 100,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.item.emoji,
                  style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  widget.item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                categoryLabel,
                style: const TextStyle(fontSize: 10, color: Colors.black45),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Reveal view ───────────────────────────────────────────────────────────────

class _RevealView extends StatefulWidget {
  const _RevealView({required this.item, required this.onDone});
  final RewardItem item;
  final VoidCallback onDone;

  @override
  State<_RevealView> createState() => _RevealViewState();
}

class _RevealViewState extends State<_RevealView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();
  late final Animation<double> _scale =
      CurvedAnimation(parent: _pop, curve: Curves.elasticOut);

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('reveal'),
      children: [
        const Spacer(),
        const Text(
          'You got it! 🎉',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        ScaleTransition(
          scale: _scale,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade200.withAlpha(180),
                  blurRadius: 40,
                  spreadRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: Text(widget.item.emoji,
                  style: const TextStyle(fontSize: 80)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          widget.item.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (widget.item.slot.isNotEmpty) ...[
          const SizedBox(height: 6),
          const Text(
            'Now equipped! ✨',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: FilledButton(
            onPressed: widget.onDone,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Back to Room 🏠',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
