import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/cat_state.dart';
import '../../../core/models/difficulty_tier.dart';
import '../../../core/providers/cats_provider.dart';
import '../../../core/providers/player_profile_provider.dart';
import '../../../core/router/app_router.dart';

const _mg3Xp = 15;

// ── DDA config ────────────────────────────────────────────────────────────────

enum _Mode { letterMatch, wordSpell, sightWord }

class _LetterConfig {
  const _LetterConfig({
    required this.mode,
    required this.rounds,
    required this.distractorCount,
    required this.targetMoves,
  });
  final _Mode mode;
  final int rounds;          // number of prompts to complete
  final int distractorCount; // wrong letters/words shown alongside the target
  final bool targetMoves;    // whether targets drift around the screen

  static _LetterConfig forTier(DifficultyTier tier) => switch (tier) {
    DifficultyTier.sprout => const _LetterConfig(
      mode: _Mode.letterMatch,
      rounds: 4,
      distractorCount: 2,
      targetMoves: false,
    ),
    DifficultyTier.seedling => const _LetterConfig(
      mode: _Mode.wordSpell,
      rounds: 3,
      distractorCount: 3,
      targetMoves: false,
    ),
    DifficultyTier.bloom => const _LetterConfig(
      mode: _Mode.sightWord,
      rounds: 4,
      distractorCount: 3,
      targetMoves: true,
    ),
  };
}

// ── Sprout: single uppercase letter matching ──────────────────────────────────

const _sproutLetters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
  'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T'];

// ── Seedling: 3-letter CVC words ──────────────────────────────────────────────

const _cvcWords = [
  ['C', 'A', 'T'],
  ['D', 'O', 'G'],
  ['H', 'A', 'T'],
  ['B', 'I', 'G'],
  ['R', 'U', 'N'],
  ['S', 'U', 'N'],
  ['P', 'I', 'G'],
  ['F', 'O', 'X'],
];

// ── Bloom: sight words with sentence prompts ──────────────────────────────────

class _SightPrompt {
  const _SightPrompt({required this.sentence, required this.target});
  final String sentence;
  final String target;
}

const _sightPrompts = [
  _SightPrompt(sentence: 'Tap the word:', target: 'THE'),
  _SightPrompt(sentence: 'Find the word:', target: 'AND'),
  _SightPrompt(sentence: 'Tap the word:', target: 'PLAY'),
  _SightPrompt(sentence: 'Find the word:', target: 'JUMP'),
  _SightPrompt(sentence: 'Tap the word:', target: 'LOVE'),
  _SightPrompt(sentence: 'Find the word:', target: 'HELP'),
  _SightPrompt(sentence: 'Tap the word:', target: 'WITH'),
  _SightPrompt(sentence: 'Find the word:', target: 'FROM'),
];

const _sightDistractors = [
  'THE', 'AND', 'PLAY', 'JUMP', 'LOVE', 'HELP', 'WITH', 'FROM',
  'CAKE', 'FISH', 'TREE', 'STAR', 'BOOK', 'SHIP', 'BIRD',
];

// ── Floating target model ─────────────────────────────────────────────────────

class _FloatingItem {
  _FloatingItem({
    required this.label,
    required this.isTarget,
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.color,
  });
  final String label;
  final bool isTarget;
  double x;   // 0..1 fraction of available width
  double y;   // 0..1 fraction of available height
  double dx;  // velocity per tick (fractions/s)
  double dy;
  final Color color;

  bool popped = false;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ReadingScreen extends ConsumerStatefulWidget {
  const ReadingScreen({super.key});

  @override
  ConsumerState<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends ConsumerState<ReadingScreen> {
  late final _LetterConfig _config;
  final _rng = Random();

  // ── Sprout / Bloom state ────────────────────────────────────────────────────
  late int _roundsLeft;
  late List<_FloatingItem> _items;
  String _prompt = '';
  bool _wrongFlash = false;
  bool _completing = false;
  Timer? _driftTimer;

  // ── Seedling state — spell-by-tap ───────────────────────────────────────────
  late List<String> _wordLetters;   // full target word
  late List<String> _tapped;        // letters correctly tapped so far
  late List<_FloatingItem> _letterItems; // palette of letters

  @override
  void initState() {
    super.initState();
    final tier = ref.read(playerProfileProvider).difficultyTier;
    _config = _LetterConfig.forTier(tier);
    _roundsLeft = _config.rounds;
    _buildRound();
    if (_config.targetMoves) {
      _driftTimer = Timer.periodic(const Duration(milliseconds: 16), _tick);
    }
  }

  @override
  void dispose() {
    _driftTimer?.cancel();
    super.dispose();
  }

  // ── Build a fresh round ───────────────────────────────────────────────────
  void _buildRound() {
    switch (_config.mode) {
      case _Mode.letterMatch:
        _buildLetterMatchRound();
      case _Mode.wordSpell:
        _buildWordSpellRound();
      case _Mode.sightWord:
        _buildSightWordRound();
    }
  }

  void _buildLetterMatchRound() {
    final target = _sproutLetters[_rng.nextInt(_sproutLetters.length)];
    _prompt = 'Tap the letter   $target';

    final pool = List<String>.from(_sproutLetters)..remove(target);
    pool.shuffle(_rng);
    final distractors = pool.take(_config.distractorCount).toList();
    final all = [target, ...distractors]..shuffle(_rng);

    _items = all.map((l) => _makeItem(l, l == target)).toList();
  }

  void _buildWordSpellRound() {
    final word = _cvcWords[_rng.nextInt(_cvcWords.length)];
    _wordLetters = word;
    _tapped = [];
    _prompt = 'Spell the word:  ${word.join('')}';

    // Build palette: all letters of the word + extra distractors
    final pool = List.from(_sproutLetters)
      ..removeWhere((l) => word.contains(l));
    pool.shuffle(_rng);
    final extra = pool.take(_config.distractorCount).toList();
    final all = [...word, ...extra]..shuffle(_rng);
    _letterItems = all.map((l) => _makeItem(l, word.contains(l))).toList();
  }

  void _buildSightWordRound() {
    final prompt = _sightPrompts[_rng.nextInt(_sightPrompts.length)];
    _prompt = '${prompt.sentence}  ${prompt.target}';

    final pool = List<String>.from(_sightDistractors)..remove(prompt.target);
    pool.shuffle(_rng);
    final distractors = pool.take(_config.distractorCount).toList();
    final all = [prompt.target, ...distractors]..shuffle(_rng);

    _items = all.map((w) => _makeItem(w, w == prompt.target)).toList();
  }

  _FloatingItem _makeItem(String label, bool isTarget) {
    final colors = [
      const Color(0xFFA5D6A7), // green
      const Color(0xFF90CAF9), // blue
      const Color(0xFFFFCC80), // orange
      const Color(0xFFCE93D8), // purple
      const Color(0xFFF48FB1), // pink
      const Color(0xFF80DEEA), // teal
    ];
    return _FloatingItem(
      label: label,
      isTarget: isTarget,
      x: 0.1 + _rng.nextDouble() * 0.8,
      y: 0.1 + _rng.nextDouble() * 0.8,
      dx: (_rng.nextDouble() * 0.08 + 0.02) * (_rng.nextBool() ? 1 : -1),
      dy: (_rng.nextDouble() * 0.08 + 0.02) * (_rng.nextBool() ? 1 : -1),
      color: colors[_rng.nextInt(colors.length)],
    );
  }

  // ── Drift tick (Bloom only) ───────────────────────────────────────────────
  void _tick(Timer _) {
    if (!mounted) return;
    setState(() {
      for (final item in _items.where((i) => !i.popped)) {
        item.x += item.dx * 0.016;
        item.y += item.dy * 0.016;
        if (item.x < 0.05 || item.x > 0.88) item.dx *= -1;
        if (item.y < 0.05 || item.y > 0.85) item.dy *= -1;
        item.x = item.x.clamp(0.05, 0.88);
        item.y = item.y.clamp(0.05, 0.85);
      }
    });
  }

  // ── Tap handlers ─────────────────────────────────────────────────────────
  void _onTapItem(_FloatingItem item) {
    if (item.popped || _completing) return;
    if (_config.mode == _Mode.wordSpell) return; // spelling uses _onTapLetter

    if (item.isTarget) {
      setState(() => item.popped = true);
      _advanceRound();
    } else {
      _flashWrong();
    }
  }

  void _onTapLetter(String letter) {
    if (_completing) return;
    final expected = _wordLetters[_tapped.length];
    if (letter == expected) {
      setState(() => _tapped.add(letter));
      if (_tapped.length == _wordLetters.length) {
        _advanceRound();
      }
    } else {
      _flashWrong();
    }
  }

  void _advanceRound() {
    _roundsLeft--;
    if (_roundsLeft <= 0) {
      if (!_completing) {
        _completing = true;
        _driftTimer?.cancel();
        _onComplete();
      }
      return;
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(_buildRound);
    });
  }

  void _flashWrong() {
    setState(() => _wrongFlash = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _wrongFlash = false);
    });
  }

  Future<void> _onComplete() async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    ref.read(catsProvider.notifier).restoreAfterMinigame(
      CatId.noodles,
      energy: 40,
    );
    await ref.read(playerProfileProvider.notifier).addXp(_mg3Xp);
    if (mounted) context.go(AppRoutes.reward, extra: _mg3Xp);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D47A1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go(AppRoutes.room),
        ),
        title: const Text(
          '🐟 Laser Letters',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Progress dots ──────────────────────────────────────────────
            _ProgressDots(
              total: _config.rounds,
              remaining: _roundsLeft,
            ),
            const SizedBox(height: 12),

            // ── Prompt ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _config.mode == _Mode.wordSpell
                      ? _buildSpellPrompt()
                      : _prompt,
                  key: ValueKey(_prompt),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            if (_wrongFlash)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  'Not that one — try again! 🐟',
                  style: TextStyle(color: Color(0xFFFF8A65), fontSize: 13),
                ),
              ),

            const SizedBox(height: 8),

            // ── Play area ─────────────────────────────────────────────────
            Expanded(
              child: _config.mode == _Mode.wordSpell
                  ? _SpellArea(
                      items: _letterItems,
                      onTap: _onTapLetter,
                    )
                  : _FloatArea(
                      items: _items,
                      onTap: _onTapItem,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSpellPrompt() {
    final built = _tapped.join('');
    final remaining = _wordLetters.skip(_tapped.length).join('');
    return 'Spell: $built▮$remaining';
  }
}

// ── Progress dots ─────────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.total, required this.remaining});
  final int total;
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final done = total - remaining;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        return Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < done
                ? const Color(0xFF80DEEA)
                : Colors.white.withAlpha(40),
            border: Border.all(
              color: i < done ? const Color(0xFF80DEEA) : Colors.white30,
            ),
          ),
        );
      }),
    );
  }
}

// ── Float area — items drift freely (Sprout / Bloom) ─────────────────────────

class _FloatArea extends StatelessWidget {
  const _FloatArea({required this.items, required this.onTap});
  final List<_FloatingItem> items;
  final ValueChanged<_FloatingItem> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        return Stack(
          children: items
              .where((item) => !item.popped)
              .map((item) => Positioned(
                    left: item.x * w,
                    top: item.y * h,
                    child: _LetterBubble(
                      label: item.label,
                      color: item.color,
                      onTap: () => onTap(item),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ── Spell area — static palette for Seedling ─────────────────────────────────

class _SpellArea extends StatelessWidget {
  const _SpellArea({required this.items, required this.onTap});
  final List<_FloatingItem> items;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Wrap(
          spacing: 14,
          runSpacing: 14,
          alignment: WrapAlignment.center,
          children: items
              .map((item) => _LetterBubble(
                    label: item.label,
                    color: item.color,
                    onTap: () => onTap(item.label),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

// ── Letter / word bubble ──────────────────────────────────────────────────────

class _LetterBubble extends StatelessWidget {
  const _LetterBubble({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLong = label.length > 2;
    final size = isLong ? 72.0 : 64.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLong ? null : size,
        height: size,
        padding: isLong ? const EdgeInsets.symmetric(horizontal: 16) : null,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: Colors.white54, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(160),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLong ? 16 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
