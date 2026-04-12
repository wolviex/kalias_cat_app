import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/cat_state.dart';
import '../../../core/models/difficulty_tier.dart';
import '../../../core/providers/cats_provider.dart';
import '../../../core/providers/player_profile_provider.dart';
import '../../../core/router/app_router.dart';

const _minigameXp = 15;

enum _BreathPhase { idle, inhale, hold, exhale, rest, complete }

/// DDA configuration for the breathing minigame.
class _BreathConfig {
  final int totalCycles;
  final Duration inhaleDuration;
  final Duration exhaleDuration;
  final bool requiresInteraction; // Sprout = watch only; others = hold to breathe

  const _BreathConfig({
    required this.totalCycles,
    required this.inhaleDuration,
    required this.exhaleDuration,
    required this.requiresInteraction,
  });

  static _BreathConfig forTier(DifficultyTier tier) => switch (tier) {
        DifficultyTier.sprout => const _BreathConfig(
            totalCycles: 2,
            inhaleDuration: Duration(seconds: 3),
            exhaleDuration: Duration(seconds: 3),
            requiresInteraction: false,
          ),
        DifficultyTier.seedling => const _BreathConfig(
            totalCycles: 3,
            inhaleDuration: Duration(seconds: 4),
            exhaleDuration: Duration(seconds: 4),
            requiresInteraction: true,
          ),
        DifficultyTier.bloom => const _BreathConfig(
            totalCycles: 4,
            inhaleDuration: Duration(milliseconds: 3500),
            exhaleDuration: Duration(milliseconds: 3500),
            requiresInteraction: true,
          ),
      };
}

class BreathingScreen extends ConsumerStatefulWidget {
  const BreathingScreen({super.key});

  @override
  ConsumerState<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends ConsumerState<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _sizeController;
  late _BreathConfig _config;
  _BreathPhase _phase = _BreathPhase.idle;
  int _cyclesComplete = 0;
  bool _isHolding = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    final tier = ref.read(playerProfileProvider).difficultyTier;
    _config = _BreathConfig.forTier(tier);

    _sizeController = AnimationController(
      vsync: this,
      value: 0.2,
    );

    // Brief pause so player sees the screen before breathing starts
    Future.delayed(const Duration(milliseconds: 800), _runCycle);
  }

  @override
  void dispose() {
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _runCycle() async {
    if (!mounted || _completed) return;

    // Inhale
    setState(() => _phase = _BreathPhase.inhale);
    HapticFeedback.lightImpact();
    await _sizeController.animateTo(
      1.0,
      duration: _config.inhaleDuration,
      curve: Curves.easeInOut,
    );
    if (!mounted) return;

    // Hold
    setState(() => _phase = _BreathPhase.hold);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Exhale
    setState(() => _phase = _BreathPhase.exhale);
    HapticFeedback.lightImpact();
    await _sizeController.animateTo(
      0.2,
      duration: _config.exhaleDuration,
      curve: Curves.easeInOut,
    );
    if (!mounted) return;

    // Rest
    setState(() => _phase = _BreathPhase.rest);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    setState(() => _cyclesComplete++);

    if (_cyclesComplete >= _config.totalCycles) {
      _onComplete();
    } else {
      _runCycle();
    }
  }

  Future<void> _onComplete() async {
    if (!mounted || _completed) return;
    setState(() {
      _phase = _BreathPhase.complete;
      _completed = true;
    });
    HapticFeedback.mediumImpact();

    ref.read(catsProvider.notifier).restoreAfterMinigame(
          CatId.noodles,
          energy: 40,
        );
    await ref.read(playerProfileProvider.notifier).addXp(_minigameXp);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) context.go(AppRoutes.reward, extra: _minigameXp);
  }

  String get _instructionText => switch (_phase) {
        _BreathPhase.idle => 'Get ready...',
        _BreathPhase.inhale =>
          _config.requiresInteraction ? 'Breathe in... 🌬️\nHold the circle!' : 'Breathe in... 🌬️',
        _BreathPhase.hold => 'Hold... ✨',
        _BreathPhase.exhale =>
          _config.requiresInteraction ? 'Breathe out... 💨\nLet go!' : 'Breathe out... 💨',
        _BreathPhase.rest => 'Nice work!',
        _BreathPhase.complete => 'Amazing! 🎉\nNoodles feels much better!',
      };

  Color get _circleColor => switch (_phase) {
        _BreathPhase.inhale => const Color(0xFF9C27B0),
        _BreathPhase.hold => const Color(0xFF7B1FA2),
        _BreathPhase.exhale => const Color(0xFF5C6BC0),
        _ => const Color(0xFFAB47BC),
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final maxCircle = size.width * 0.65;
    final minCircle = maxCircle * 0.25;
    final circleSize =
        minCircle + (maxCircle - minCircle) * _sizeController.value;

    return Scaffold(
      backgroundColor: const Color(0xFFEDE7F6),
      body: SafeArea(
        child: GestureDetector(
          onTapDown: _config.requiresInteraction
              ? (_) => setState(() => _isHolding = true)
              : null,
          onTapUp: _config.requiresInteraction
              ? (_) => setState(() => _isHolding = false)
              : null,
          onTapCancel: _config.requiresInteraction
              ? () => setState(() => _isHolding = false)
              : null,
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.go(AppRoutes.room),
                  ),
                  const Spacer(),
                  Text(
                    'Calming the Zoomies',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ]),
              ),

              // ── Noodles image ────────────────────────────────────────
              SizedBox(
                height: size.height * 0.18,
                child: Image.asset(
                  'assets/characters/Noodles the Cat.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Text('🐱', style: TextStyle(fontSize: 60)),
                ),
              ),

              // ── Cycle progress dots ──────────────────────────────────
              _CycleDots(
                  total: _config.totalCycles, completed: _cyclesComplete),
              const SizedBox(height: 24),

              // ── Breathing circle ─────────────────────────────────────
              Expanded(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _sizeController,
                    builder: (_, _) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _circleColor.withAlpha(
                              _isHolding ? 200 : 160),
                          boxShadow: [
                            BoxShadow(
                              color: _circleColor.withAlpha(80),
                              blurRadius: 32,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            switch (_phase) {
                              _BreathPhase.inhale => '🌬️',
                              _BreathPhase.hold => '✨',
                              _BreathPhase.exhale => '💨',
                              _BreathPhase.complete => '🎉',
                              _ => '🌀',
                            },
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── Instruction text ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
                child: Text(
                  _instructionText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4A148C),
                      height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleDots extends StatelessWidget {
  const _CycleDots({required this.total, required this.completed});
  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final done = i < completed;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: done ? 16 : 12,
          height: done ? 16 : 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done
                ? const Color(0xFF7B1FA2)
                : Colors.purple.shade100,
          ),
        );
      }),
    );
  }
}
