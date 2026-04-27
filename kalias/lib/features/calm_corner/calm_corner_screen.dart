import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/audio_service.dart';

// ── Activity enum ─────────────────────────────────────────────────────────────

enum _Activity { hub, breathe, popIts, sand }

// ── Screen ────────────────────────────────────────────────────────────────────

class CalmCornerScreen extends ConsumerStatefulWidget {
  const CalmCornerScreen({super.key});

  @override
  ConsumerState<CalmCornerScreen> createState() => _CalmCornerScreenState();
}

class _CalmCornerScreenState extends ConsumerState<CalmCornerScreen> {
  _Activity _activity = _Activity.hub;

  @override
  void initState() {
    super.initState();
    // Switch to calm BGM when entering the Calm Corner
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(audioServiceProvider).playBgm(AudioAssets.calmBgm, volume: 0.3);
    });
  }

  @override
  void dispose() {
    // Resume room BGM when leaving
    ref.read(audioServiceProvider).playBgm(AudioAssets.roomBgm);
    super.dispose();
  }

  void _go(_Activity a) => setState(() => _activity = a);
  void _hub()           => setState(() => _activity = _Activity.hub);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _activity == _Activity.hub
            ? BackButton(
                color: Colors.white,
                onPressed: () => context.go(AppRoutes.room),
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: _hub,
              ),
        title: Text(
          _activity == _Activity.hub ? '🌙 Calm Corner' : '',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final audio = ref.watch(audioServiceProvider);
              return IconButton(
                icon: Icon(
                  audio.isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white70,
                ),
                onPressed: audio.toggleMute,
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: switch (_activity) {
          _Activity.hub     => _HubView(onSelect: _go),
          _Activity.breathe => _BreathView(onBack: _hub),
          _Activity.popIts  => _PopItsView(onBack: _hub),
          _Activity.sand    => _KineticSandView(onBack: _hub),
        },
      ),
    );
  }
}

// ── Hub ───────────────────────────────────────────────────────────────────────

class _HubView extends StatelessWidget {
  const _HubView({required this.onSelect});
  final ValueChanged<_Activity> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        key: const ValueKey('hub'),
        children: [
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'What would you like to do?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: _ActivityTile(
                      emoji: '🌬️',
                      label: 'Breathe',
                      subtitle: 'Take a calming breath',
                      color: const Color(0xFF26A69A),
                      onTap: () => onSelect(_Activity.breathe),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: _ActivityTile(
                      emoji: '🫧',
                      label: 'Pop-Its',
                      subtitle: 'Pop some soothing bubbles',
                      color: const Color(0xFF7B1FA2),
                      onTap: () => onSelect(_Activity.popIts),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: _ActivityTile(
                      emoji: '🏖️',
                      label: 'Calm Sand',
                      subtitle: 'Draw in the sand',
                      color: const Color(0xFFF57F17),
                      onTap: () => onSelect(_Activity.sand),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.moodMirror),
              icon: const Text('🪞', style: TextStyle(fontSize: 18)),
              label: const Text('How am I feeling?'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(200),
          borderRadius: BorderRadius.circular(22),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 13, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Breathing activity ────────────────────────────────────────────────────────
// Free-play mode — 4 cycles, no DDA, no XP. Just calming.

enum _BreathPhase { idle, inhale, hold, exhale, done }

const _totalCycles = 4;
const _inhaleSecs  = Duration(seconds: 4);
const _holdSecs    = Duration(seconds: 2);
const _exhaleSecs  = Duration(seconds: 4);

class _BreathView extends StatefulWidget {
  const _BreathView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_BreathView> createState() => _BreathViewState();
}

class _BreathViewState extends State<_BreathView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(vsync: this);
  late Animation<double> _scale;
  _BreathPhase _phase = _BreathPhase.idle;
  int _cycle = 0;
  late String _label;

  @override
  void initState() {
    super.initState();
    _scale = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
    _label = 'Tap to begin';
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _start() {
    if (_phase == _BreathPhase.idle || _phase == _BreathPhase.done) {
      _cycle = 0;
      _inhale();
    }
  }

  void _inhale() {
    setState(() { _phase = _BreathPhase.inhale; _label = 'Breathe in…'; });
    _ctrl.animateTo(1.0, duration: _inhaleSecs, curve: Curves.easeIn)
        .then((_) { if (mounted) _hold(); });
  }

  void _hold() {
    setState(() { _phase = _BreathPhase.hold; _label = 'Hold…'; });
    Future.delayed(_holdSecs, _exhale);
  }

  void _exhale() {
    if (!mounted) return;
    setState(() { _phase = _BreathPhase.exhale; _label = 'Breathe out…'; });
    _ctrl.animateTo(0.4, duration: _exhaleSecs, curve: Curves.easeOut)
        .then((_) => _nextCycle());
  }

  void _nextCycle() {
    if (!mounted) return;
    _cycle++;
    if (_cycle >= _totalCycles) {
      setState(() { _phase = _BreathPhase.done; _label = 'Well done! 🌟'; });
    } else {
      _inhale();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color circleColor = switch (_phase) {
      _BreathPhase.inhale => const Color(0xFF4FC3F7),
      _BreathPhase.hold   => const Color(0xFF81D4FA),
      _BreathPhase.exhale => const Color(0xFF26A69A),
      _                   => const Color(0xFF4DD0E1),
    };

    return Column(
      key: const ValueKey('breathe'),
      children: [
        const Spacer(),
        Text(
          'Cycle ${_phase == _BreathPhase.idle ? 1 : min(_cycle + 1, _totalCycles)} of $_totalCycles',
          style: const TextStyle(fontSize: 14, color: Colors.white38),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: _phase == _BreathPhase.idle || _phase == _BreathPhase.done
              ? _start
              : null,
          child: AnimatedBuilder(
            animation: _scale,
            builder: (context, _) => Container(
              width: 200 + 100 * _scale.value,
              height: 200 + 100 * _scale.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: circleColor.withAlpha(
                    (_phase == _BreathPhase.hold) ? 180 : 140),
                boxShadow: [
                  BoxShadow(
                    color: circleColor.withAlpha(80),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          _label,
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white),
        ),
        const Spacer(),
        if (_phase == _BreathPhase.done)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: FilledButton(
              onPressed: widget.onBack,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: const Color(0xFF26A69A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Back', style: TextStyle(fontSize: 17)),
            ),
          ),
        if (_phase == _BreathPhase.done) const SizedBox(height: 40),
      ],
    );
  }
}

// ── Pop-Its ───────────────────────────────────────────────────────────────────

const _popRows    = 5;
const _popCols    = 6;
const _popTotal   = _popRows * _popCols;

const _popColors = [
  Color(0xFFCE93D8), // purple
  Color(0xFF80DEEA), // teal
  Color(0xFFFFCC80), // orange
  Color(0xFFA5D6A7), // green
  Color(0xFFF48FB1), // pink
  Color(0xFF90CAF9), // blue
];

class _PopItsView extends ConsumerStatefulWidget {
  const _PopItsView({required this.onBack});
  final VoidCallback onBack;

  @override
  ConsumerState<_PopItsView> createState() => _PopItsViewState();
}

class _PopItsViewState extends ConsumerState<_PopItsView> {
  late List<bool> _popped;
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    _popped = List.filled(_popTotal, false);
  }

  void _pop(int index) {
    if (_popped[index] || _celebrating) return;
    ref.read(audioServiceProvider).playSfx(AudioAssets.pop, volume: 0.5);
    setState(() => _popped[index] = true);
    if (_popped.every((p) => p)) {
      setState(() => _celebrating = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() {
          _popped = List.filled(_popTotal, false);
          _celebrating = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('pop'),
      children: [
        const SizedBox(height: 12),
        if (_celebrating)
          const Text('🎉 All popped! Resetting…',
              style: TextStyle(fontSize: 18, color: Colors.white)),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _popCols,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemCount: _popTotal,
            itemBuilder: (context, i) {
              final color = _popColors[i % _popColors.length];
              return _PopBubble(
                color: color,
                popped: _popped[i],
                onTap: () => _pop(i),
              );
            },
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _PopBubble extends StatefulWidget {
  const _PopBubble({
    required this.color,
    required this.popped,
    required this.onTap,
  });
  final Color color;
  final bool popped;
  final VoidCallback onTap;

  @override
  State<_PopBubble> createState() => _PopBubbleState();
}

class _PopBubbleState extends State<_PopBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
  );
  late final Animation<double> _scale =
      Tween<double>(begin: 1.0, end: 0.55).animate(
          CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));

  @override
  void didUpdateWidget(_PopBubble old) {
    super.didUpdateWidget(old);
    if (widget.popped && !old.popped) _ctrl.forward();
    if (!widget.popped && old.popped) _ctrl.reverse();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: ReverseAnimation(_scale), // 1→popped = 1.0→0.55
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.popped
                ? widget.color.withAlpha(50)
                : widget.color,
            boxShadow: widget.popped
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 4,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.white.withAlpha(60),
                      blurRadius: 4,
                      offset: const Offset(-2, -2),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}

// ── Kinetic Sand ──────────────────────────────────────────────────────────────

const _sandPalette = [
  Color(0xFFFF8A65), // coral
  Color(0xFFFFD54F), // yellow
  Color(0xFF81C784), // green
  Color(0xFF64B5F6), // blue
  Color(0xFFCE93D8), // purple
  Color(0xFFF06292), // pink
];

class _SandPoint {
  final Offset pos;
  final Color color;
  final double radius;
  _SandPoint(this.pos, this.color, this.radius);
}

class _KineticSandView extends StatefulWidget {
  const _KineticSandView({required this.onBack});
  final VoidCallback onBack;

  @override
  State<_KineticSandView> createState() => _KineticSandViewState();
}

class _KineticSandViewState extends State<_KineticSandView> {
  final List<_SandPoint> _points = [];
  Color _selected = _sandPalette[0];
  final _rand = Random();

  void _addPoint(Offset pos) {
    setState(() {
      for (var i = 0; i < 5; i++) {
        final dx = (_rand.nextDouble() - 0.5) * 14;
        final dy = (_rand.nextDouble() - 0.5) * 14;
        final r  = 4 + _rand.nextDouble() * 8;
        _points.add(_SandPoint(pos.translate(dx, dy), _selected, r));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('sand'),
      children: [
        const SizedBox(height: 8),
        // ── Canvas ────────────────────────────────────────────────────
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Container(
                color: const Color(0xFF120A30),
                child: GestureDetector(
                  onPanUpdate: (d) => _addPoint(d.localPosition),
                  onTapDown: (d) => _addPoint(d.localPosition),
                  child: CustomPaint(
                    painter: _SandPainter(_points),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // ── Palette ───────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _sandPalette
              .map((c) => GestureDetector(
                    onTap: () => setState(() => _selected = c),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: _selected == c ? 38 : 30,
                      height: _selected == c ? 38 : 30,
                      decoration: BoxDecoration(
                        color: c,
                        shape: BoxShape.circle,
                        border: _selected == c
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _points.clear()),
          child: const Text('✕ Clear',
              style: TextStyle(color: Colors.white38, fontSize: 14)),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SandPainter extends CustomPainter {
  _SandPainter(this.points);
  final List<_SandPoint> points;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in points) {
      canvas.drawCircle(
        p.pos,
        p.radius,
        Paint()
          ..color = p.color.withAlpha(200)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(_SandPainter old) => true;
}
