import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/cat_state.dart';
import '../../../core/models/difficulty_tier.dart';
import '../../../core/providers/cats_provider.dart';
import '../../../core/providers/player_profile_provider.dart';
import '../../../core/router/app_router.dart';

const _mg5Xp = 15;

// ── Data model ────────────────────────────────────────────────────────────────

class _Tile {
  const _Tile({
    required this.id,
    required this.symbol,
    required this.label,
    required this.color,
  });
  final String id;
  final String symbol;
  final String label;
  final Color color;
}

class _Problem {
  const _Problem({required this.solution, required this.mission});
  final List<String> solution; // tile IDs in order
  final String mission;        // shown instead of target for Bloom
}

class _LogicConfig {
  const _LogicConfig({
    required this.tiles,
    required this.problems,
    required this.showTarget,
  });
  final List<_Tile> tiles;
  final List<_Problem> problems;
  final bool showTarget; // false → show mission text only (Bloom)

  int get steps => problems.first.solution.length;

  // ── Shape tiles (Sprout / Seedling) ──────────────────────────────────────
  static const _shapeBase = [
    _Tile(id: 'yellow', symbol: '🟡', label: 'Circle',   color: Color(0xFFFFF9C4)),
    _Tile(id: 'blue',   symbol: '🔵', label: 'Drop',     color: Color(0xFFE3F2FD)),
    _Tile(id: 'star',   symbol: '⭐', label: 'Star',     color: Color(0xFFFFF8E1)),
    _Tile(id: 'purple', symbol: '🟣', label: 'Gem',      color: Color(0xFFEDE7F6)),
    _Tile(id: 'red',    symbol: '🔴', label: 'Red',      color: Color(0xFFFFEBEE)),
    _Tile(id: 'diamond',symbol: '💎', label: 'Crystal',  color: Color(0xFFE0F7FA)),
  ];

  // ── Robot command tiles (Bloom) ───────────────────────────────────────────
  static const _cmdTiles = [
    _Tile(id: 'power', symbol: '⚡', label: 'Power',    color: Color(0xFFFFF9C4)),
    _Tile(id: 'plug',  symbol: '🔌', label: 'Connect',  color: Color(0xFFE8F5E9)),
    _Tile(id: 'scan',  symbol: '📡', label: 'Scan',     color: Color(0xFFE3F2FD)),
    _Tile(id: 'think', symbol: '💡', label: 'Think',    color: Color(0xFFFFF8E1)),
    _Tile(id: 'arm',   symbol: '🦾', label: 'Reach',    color: Color(0xFFEDE7F6)),
    _Tile(id: 'fix',   symbol: '🔧', label: 'Fix',      color: Color(0xFFFFEBEE)),
  ];

  static _LogicConfig forTier(DifficultyTier tier) => switch (tier) {
    DifficultyTier.sprout => _LogicConfig(
      tiles: _shapeBase.sublist(0, 4), // 4 shapes, no distractors
      showTarget: true,
      problems: const [
        _Problem(solution: ['yellow', 'blue'],   mission: ''),
        _Problem(solution: ['star',   'purple'], mission: ''),
        _Problem(solution: ['blue',   'star'],   mission: ''),
      ],
    ),
    DifficultyTier.seedling => _LogicConfig(
      tiles: _shapeBase, // all 6 — 3 distractors per problem
      showTarget: true,
      problems: const [
        _Problem(solution: ['blue',   'star',   'red'],     mission: ''),
        _Problem(solution: ['yellow', 'purple', 'diamond'], mission: ''),
        _Problem(solution: ['star',   'blue',   'yellow'],  mission: ''),
      ],
    ),
    DifficultyTier.bloom => _LogicConfig(
      tiles: _cmdTiles,
      showTarget: false, // player reads the mission and figures it out
      problems: const [
        _Problem(
          solution: ['power', 'plug', 'scan'],
          mission: '⚡ Power up first,\nthen 🔌 connect,\nthen 📡 scan!',
        ),
        _Problem(
          solution: ['think', 'arm', 'power'],
          mission: '💡 Think first,\nthen 🦾 reach out,\nthen ⚡ power up!',
        ),
        _Problem(
          solution: ['plug', 'think', 'scan'],
          mission: '🔌 Connect first,\nthen 💡 think,\nthen 📡 scan!',
        ),
      ],
    ),
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────

class LogicLoopScreen extends ConsumerStatefulWidget {
  const LogicLoopScreen({super.key});

  @override
  ConsumerState<LogicLoopScreen> createState() => _LogicLoopScreenState();
}

class _LogicLoopScreenState extends ConsumerState<LogicLoopScreen> {
  late final _LogicConfig _config;
  late final _Problem _problem;
  late final List<_Tile?> _slots;
  bool _wrongFlash = false;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    final tier = ref.read(playerProfileProvider).difficultyTier;
    _config = _LogicConfig.forTier(tier);
    _problem = _config.problems[Random().nextInt(_config.problems.length)];
    _slots = List.filled(_problem.solution.length, null);
  }

  // ── Tile palette tap: add to next empty slot ─────────────────────────────
  void _tapTile(_Tile tile) {
    final idx = _slots.indexOf(null);
    if (idx == -1) return;
    setState(() => _slots[idx] = tile);
  }

  // ── Slot tap: remove tile and compact sequence ────────────────────────────
  void _removeSlot(int idx) {
    setState(() {
      for (int i = idx; i < _slots.length - 1; i++) {
        _slots[i] = _slots[i + 1];
      }
      _slots[_slots.length - 1] = null;
    });
  }

  // ── Validate sequence ─────────────────────────────────────────────────────
  void _validate() {
    final placed = _slots.map((t) => t?.id ?? '').toList();
    if (_listEquals(placed, _problem.solution)) {
      _completing = true;
      _onComplete();
    } else {
      setState(() => _wrongFlash = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => _wrongFlash = false);
      });
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _onComplete() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ref.read(catsProvider.notifier).restoreAfterMinigame(
      CatId.robotCat,
      energy: 40,
    );
    await ref.read(playerProfileProvider.notifier).addXp(_mg5Xp);
    if (mounted) context.go(AppRoutes.reward, extra: _mg5Xp);
  }

  bool get _allFilled => _slots.every((s) => s != null);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A237E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF283593),
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go(AppRoutes.room),
        ),
        title: const Text(
          '🤖 Logic Loop',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ── Prompt ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _config.showTarget
                    ? 'Build Robot Cat\'s power sequence!'
                    : 'Read the mission and build the sequence!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Target sequence (Sprout / Seedling) ─────────────────────
            if (_config.showTarget) _TargetRow(problem: _problem, tiles: _config.tiles),

            // ── Mission text (Bloom) ─────────────────────────────────────
            if (!_config.showTarget)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  _problem.mission,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    height: 1.6,
                  ),
                ),
              ),

            const Spacer(),

            // ── Slot row (player's sequence) ─────────────────────────────
            _SlotRow(
              slots: _slots,
              wrongFlash: _wrongFlash,
              onRemove: _removeSlot,
            ),

            const SizedBox(height: 24),

            // ── Tile palette ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: _config.tiles
                    .map((t) => _PaletteTile(
                          tile: t,
                          showLabel: !_config.showTarget,
                          onTap: () => _tapTile(t),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 28),

            // ── Power Up button ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: FilledButton.icon(
                onPressed: _allFilled && !_completing ? _validate : null,
                icon: const Text('⚡', style: TextStyle(fontSize: 20)),
                label: const Text(
                  'Power Up!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: Colors.black87,
                  disabledBackgroundColor: Colors.white12,
                  disabledForegroundColor: Colors.white30,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Target row — shows the answer for Sprout/Seedling ────────────────────────

class _TargetRow extends StatelessWidget {
  const _TargetRow({required this.problem, required this.tiles});
  final _Problem problem;
  final List<_Tile> tiles;

  @override
  Widget build(BuildContext context) {
    final tileMap = {for (final t in tiles) t.id: t};
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < problem.solution.length; i++) ...[
          if (i > 0)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text('→',
                  style: TextStyle(color: Colors.white54, fontSize: 20)),
            ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tileMap[problem.solution[i]]?.color ??
                  Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white38),
            ),
            child: Center(
              child: Text(
                tileMap[problem.solution[i]]?.symbol ?? '?',
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Slot row — player's current sequence ─────────────────────────────────────

class _SlotRow extends StatelessWidget {
  const _SlotRow({
    required this.slots,
    required this.wrongFlash,
    required this.onRemove,
  });
  final List<_Tile?> slots;
  final bool wrongFlash;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Your sequence',
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < slots.length; i++) ...[
              if (i > 0)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('→',
                      style: TextStyle(color: Colors.white38, fontSize: 18)),
                ),
              GestureDetector(
                onTap: slots[i] != null ? () => onRemove(i) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: wrongFlash
                        ? Colors.red.shade900.withAlpha(200)
                        : slots[i] != null
                            ? slots[i]!.color
                            : Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: wrongFlash
                          ? Colors.red.shade300
                          : slots[i] != null
                              ? Colors.white38
                              : Colors.white24,
                      width: wrongFlash ? 2 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: slots[i] != null
                        ? Text(slots[i]!.symbol,
                            style: const TextStyle(fontSize: 32))
                        : const Text('?',
                            style: TextStyle(
                                fontSize: 24, color: Colors.white24)),
                  ),
                ),
              ),
            ],
          ],
        ),
        if (wrongFlash)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Not quite — try again! ⚡',
                style: TextStyle(color: Colors.red, fontSize: 13)),
          ),
      ],
    );
  }
}

// ── Palette tile ──────────────────────────────────────────────────────────────

class _PaletteTile extends StatelessWidget {
  const _PaletteTile({
    required this.tile,
    required this.showLabel,
    required this.onTap,
  });
  final _Tile tile;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: showLabel ? 80 : 68,
        height: showLabel ? 90 : 68,
        decoration: BoxDecoration(
          color: tile.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 6,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tile.symbol, style: const TextStyle(fontSize: 30)),
            if (showLabel) ...[
              const SizedBox(height: 4),
              Text(tile.label,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}
