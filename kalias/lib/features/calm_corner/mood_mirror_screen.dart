import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';

// ── Data ──────────────────────────────────────────────────────────────────────

class _Feeling {
  const _Feeling({
    required this.emoji,
    required this.label,
    required this.color,
    required this.affirmation,
    required this.suggestionBreath,
  });

  final String emoji;
  final String label;
  final Color color;
  final String affirmation;
  final bool suggestionBreath; // true = offer "Let's breathe together"
}

const _feelings = <_Feeling>[
  _Feeling(
    emoji: '😄',
    label: 'Happy',
    color: Color(0xFFFDD835),
    affirmation: "That's wonderful! Your joy lights up the whole room. ✨",
    suggestionBreath: false,
  ),
  _Feeling(
    emoji: '😌',
    label: 'Calm',
    color: Color(0xFF80DEEA),
    affirmation: "Feeling calm is a superpower. You're doing great. 🌸",
    suggestionBreath: false,
  ),
  _Feeling(
    emoji: '😢',
    label: 'Sad',
    color: Color(0xFF90CAF9),
    affirmation: "It's okay to feel sad sometimes. You're not alone. 💙",
    suggestionBreath: true,
  ),
  _Feeling(
    emoji: '😠',
    label: 'Angry',
    color: Color(0xFFEF9A9A),
    affirmation: "It's okay to feel angry. Let's slow down and breathe. 🌬️",
    suggestionBreath: true,
  ),
  _Feeling(
    emoji: '😟',
    label: 'Worried',
    color: Color(0xFFCE93D8),
    affirmation: "Worries are just feelings — they can't control you. 💜",
    suggestionBreath: true,
  ),
  _Feeling(
    emoji: '😴',
    label: 'Tired',
    color: Color(0xFFA5D6A7),
    affirmation: "Rest is important. It's okay to take things slow. 🌙",
    suggestionBreath: false,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class MoodMirrorScreen extends ConsumerStatefulWidget {
  const MoodMirrorScreen({super.key});

  @override
  ConsumerState<MoodMirrorScreen> createState() => _MoodMirrorScreenState();
}

class _MoodMirrorScreenState extends ConsumerState<MoodMirrorScreen> {
  _Feeling? _picked;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1040),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => context.go(AppRoutes.calmCorner),
        ),
      ),
      body: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _picked == null
              ? _PickView(name: profile.name, onPick: (f) => setState(() => _picked = f))
              : _AffirmView(
                  feeling: _picked!,
                  onBreathe: () => context.go(AppRoutes.calmCorner),
                  onDone: () => context.go(AppRoutes.room),
                ),
        ),
      ),
    );
  }
}

// ── Feeling picker ────────────────────────────────────────────────────────────

class _PickView extends StatelessWidget {
  const _PickView({required this.name, required this.onPick});
  final String name;
  final ValueChanged<_Feeling> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('pick'),
      children: [
        const SizedBox(height: 8),
        const Text('🪞', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'How are you feeling right now, $name?',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: _feelings
                  .map((f) => _FeelingCard(feeling: f, onTap: () => onPick(f)))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FeelingCard extends StatelessWidget {
  const _FeelingCard({required this.feeling, required this.onTap});
  final _Feeling feeling;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: feeling.color.withAlpha(55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: feeling.color.withAlpha(120), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(feeling.emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 6),
            Text(
              feeling.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Affirmation view ──────────────────────────────────────────────────────────

class _AffirmView extends StatefulWidget {
  const _AffirmView({
    required this.feeling,
    required this.onBreathe,
    required this.onDone,
  });
  final _Feeling feeling;
  final VoidCallback onBreathe;
  final VoidCallback onDone;

  @override
  State<_AffirmView> createState() => _AffirmViewState();
}

class _AffirmViewState extends State<_AffirmView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Column(
        key: const ValueKey('affirm'),
        children: [
          const Spacer(),
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.feeling.color.withAlpha(50),
              border: Border.all(
                  color: widget.feeling.color.withAlpha(180), width: 3),
            ),
            child: Center(
              child: Text(widget.feeling.emoji,
                  style: const TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.feeling.affirmation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                if (widget.feeling.suggestionBreath)
                  FilledButton(
                    onPressed: widget.onBreathe,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: const Color(0xFF26A69A),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Let\'s breathe together 🌬️',
                        style: TextStyle(fontSize: 16)),
                  ),
                if (widget.feeling.suggestionBreath) const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: widget.onDone,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Room 🏠',
                      style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
