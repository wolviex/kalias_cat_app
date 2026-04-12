import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/cat_state.dart';
import '../../../core/models/difficulty_tier.dart';
import '../../../core/providers/cats_provider.dart';
import '../../../core/providers/player_profile_provider.dart';
import '../../../core/router/app_router.dart';

const _minigameXp = 15;

// ── Problem model ─────────────────────────────────────────────────────────────

class _FoodItem {
  final String emoji;
  final String name;
  const _FoodItem(this.emoji, this.name);
}

const _foods = [
  _FoodItem('🐟', 'fish'),
  _FoodItem('🍗', 'chicken'),
  _FoodItem('🧀', 'cheese'),
  _FoodItem('🥩', 'meat'),
  _FoodItem('🐠', 'tuna'),
  _FoodItem('🦐', 'shrimp'),
];

class _SnackProblem {
  final _FoodItem food1;
  final int target1;
  final _FoodItem? food2;
  final int? target2;
  final String prompt;

  const _SnackProblem({
    required this.food1,
    required this.target1,
    this.food2,
    this.target2,
    required this.prompt,
  });

  bool get isTwoFood => food2 != null && target2 != null;

  int get totalTarget => target1 + (target2 ?? 0);
}

// ── Problem generation ────────────────────────────────────────────────────────

List<_SnackProblem> _generateProblems(DifficultyTier tier, Random rng) {
  return switch (tier) {
    DifficultyTier.sprout => List.generate(3, (_) {
        final n = rng.nextInt(5) + 1; // 1–5
        final food = _foods[rng.nextInt(3)];
        return _SnackProblem(
          food1: food,
          target1: n,
          prompt: 'Give Loaf Cat $n ${food.name}!',
        );
      }),
    DifficultyTier.seedling || DifficultyTier.bloom => List.generate(3, (_) {
        final n1 = rng.nextInt(5) + 1; // 1–5
        final n2 = rng.nextInt(4) + 1; // 1–4
        final f1 = _foods[rng.nextInt(3)];
        _FoodItem f2;
        do {
          f2 = _foods[rng.nextInt(_foods.length)];
        } while (f2.emoji == f1.emoji);
        return _SnackProblem(
          food1: f1,
          target1: n1,
          food2: f2,
          target2: n2,
          prompt: '$n1 ${f1.name} and $n2 ${f2.name} for Loaf Cat!',
        );
      }),
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────

class MathScreen extends ConsumerStatefulWidget {
  const MathScreen({super.key});

  @override
  ConsumerState<MathScreen> createState() => _MathScreenState();
}

class _MathScreenState extends ConsumerState<MathScreen> {
  late List<_SnackProblem> _problems;
  int _problemIndex = 0;
  int _count1 = 0;
  int _count2 = 0;
  bool _completed = false;
  bool _showSuccess = false;

  _SnackProblem get _current => _problems[_problemIndex];

  @override
  void initState() {
    super.initState();
    final tier = ref.read(playerProfileProvider).difficultyTier;
    _problems = _generateProblems(tier, Random());
  }

  void _tapFood(bool isFood2) {
    if (_showSuccess) return;
    setState(() {
      if (isFood2) {
        if (_count2 < _current.target2!) _count2++;
      } else {
        if (_count1 < _current.target1) _count1++;
      }
    });
    _checkAnswer();
  }

  void _checkAnswer() {
    final food2Done =
        !_current.isTwoFood || _count2 == _current.target2;
    if (_count1 == _current.target1 && food2Done) {
      setState(() => _showSuccess = true);
      Future.delayed(const Duration(milliseconds: 1200), _advance);
    }
  }

  void _advance() {
    if (!mounted) return;
    if (_problemIndex < _problems.length - 1) {
      setState(() {
        _problemIndex++;
        _count1 = 0;
        _count2 = 0;
        _showSuccess = false;
      });
    } else {
      _onComplete();
    }
  }

  Future<void> _onComplete() async {
    if (_completed) return;
    setState(() => _completed = true);

    ref.read(catsProvider.notifier).restoreAfterMinigame(
          CatId.loafCat,
          hunger: 40,
        );
    await ref.read(playerProfileProvider.notifier).addXp(_minigameXp);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) context.go(AppRoutes.reward, extra: _minigameXp);
  }

  @override
  Widget build(BuildContext context) {
    if (_completed) {
      return const Scaffold(
        backgroundColor: Color(0xFFFFF8E1),
        body: Center(
          child: Text('🎉 Well done!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.go(AppRoutes.room),
                ),
                const Spacer(),
                Text("Loaf Cat's Snack Stack",
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text(
                  '${_problemIndex + 1} / ${_problems.length}',
                  style: const TextStyle(
                      fontSize: 14, color: Colors.black45),
                ),
                const SizedBox(width: 8),
              ]),
            ),

            // ── Loaf Cat ───────────────────────────────────────────
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.18,
              child: Image.asset(
                'assets/characters/Loaf Cat.png',
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Center(child: Text('😸', style: TextStyle(fontSize: 60))),
              ),
            ),

            // ── Prompt ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  _current.prompt,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            // ── Plate ──────────────────────────────────────────────
            Expanded(
              child: _Plate(
                problem: _current,
                count1: _count1,
                count2: _count2,
                success: _showSuccess,
              ),
            ),

            // ── Food buttons ───────────────────────────────────────
            _FoodButtons(
              problem: _current,
              count1: _count1,
              count2: _count2,
              onTap: _tapFood,
              enabled: !_showSuccess,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Plate widget ──────────────────────────────────────────────────────────────

class _Plate extends StatelessWidget {
  const _Plate({
    required this.problem,
    required this.count1,
    required this.count2,
    required this.success,
  });
  final _SnackProblem problem;
  final int count1;
  final int count2;
  final bool success;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: success ? Colors.green.shade50 : Colors.white,
          border: Border.all(
            color: success ? Colors.green : Colors.orange.shade200,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12,
            ),
          ],
        ),
        child: Center(
          child: success
              ? const Text('😸', style: TextStyle(fontSize: 64))
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    ...List.generate(count1,
                        (_) => Text(problem.food1.emoji,
                            style: const TextStyle(fontSize: 28))),
                    if (problem.isTwoFood)
                      ...List.generate(count2,
                          (_) => Text(problem.food2!.emoji,
                              style: const TextStyle(fontSize: 28))),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Food tap buttons ──────────────────────────────────────────────────────────

class _FoodButtons extends StatelessWidget {
  const _FoodButtons({
    required this.problem,
    required this.count1,
    required this.count2,
    required this.onTap,
    required this.enabled,
  });
  final _SnackProblem problem;
  final int count1;
  final int count2;
  final void Function(bool isFood2) onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FoodButton(
            food: problem.food1,
            current: count1,
            target: problem.target1,
            onTap: enabled ? () => onTap(false) : null,
          ),
          if (problem.isTwoFood) ...[
            const SizedBox(width: 24),
            _FoodButton(
              food: problem.food2!,
              current: count2,
              target: problem.target2!,
              onTap: enabled ? () => onTap(true) : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _FoodButton extends StatelessWidget {
  const _FoodButton({
    required this.food,
    required this.current,
    required this.target,
    required this.onTap,
  });
  final _FoodItem food;
  final int current;
  final int target;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = current >= target;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: done ? Colors.green.shade100 : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: done ? Colors.green : Colors.orange.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(food.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 4),
            Text(
              '$current / $target',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: done ? Colors.green.shade700 : Colors.orange.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
