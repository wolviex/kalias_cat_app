// Watercolor care sheet — full-screen overlay rendered inside the Room's Stack.
// Handles backdrop, slide-in panel, mood-reactive buttons, particles, and toast.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/models/cat_state.dart';
import '../../core/models/difficulty_tier.dart';
import '../../core/models/player_profile.dart';
import '../../core/providers/cats_provider.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/character_painters.dart';
import 'room_painters.dart' show kInk, kBlush, kSage, kLilac, kButter;
import 'room_provider.dart';

// ── Mood-vocabulary ───────────────────────────────────────────────────────────

typedef _Vocab = ({String feed, String play, String pet, String toast});

const _vocab = <String, _Vocab>{
  'happy':   (feed: '🍓', play: '✨', pet: '❤️', toast: 'purr purr'),
  'calm':    (feed: '🥛', play: '🍃', pet: '❤️', toast: 'cozy'),
  'grumpy':  (feed: '🍗', play: '🪀', pet: '✨', toast: 'feeling better'),
  'sad':     (feed: '🥞', play: '🎈', pet: '🤗', toast: 'cheered up'),
  'zoomies': (feed: '🐟', play: '⚡', pet: '💫', toast: 'zoom zoom!'),
  'neutral': (feed: '🍓', play: '🪶', pet: '❤️', toast: 'nice'),
};

String _moodKey(MoodState m) => switch (m) {
      MoodState.happy => 'happy',
      MoodState.neutral => 'neutral',
      MoodState.grumpy || MoodState.overloaded => 'grumpy',
      MoodState.sad => 'sad',
      MoodState.zoomies => 'zoomies',
    };

// ── Static cat info ───────────────────────────────────────────────────────────

typedef _Info = ({String name, String blurb, String pillar, Color color});

const _catInfo = <String, _Info>{
  'noodles': (
    name: 'Noodles',
    blurb: 'a zoomy orange storm',
    pillar: 'Spelling · Letters',
    color: Color(0xFFF0B278),
  ),
  'loafCat': (
    name: 'Loaf Cat',
    blurb: 'soft, slow, always hungry',
    pillar: 'Math · Counting',
    color: Color(0xFFE8D5B0),
  ),
  'robotCat': (
    name: 'Robot Cat',
    blurb: 'curious circuits, tidy mind',
    pillar: 'Logic · Sequences',
    color: Color(0xFFC8B8DC),
  ),
  'kalia': (
    name: 'Kalia',
    blurb: 'the gentle guide',
    pillar: 'You!',
    color: Color(0xFFF0D090),
  ),
};

CatId? _toCatId(String id) => switch (id) {
      'noodles' => CatId.noodles,
      'loafCat' => CatId.loafCat,
      'robotCat' => CatId.robotCat,
      _ => null,
    };

String? _needsOf(CatState cat) {
  if (cat.hungerLevel < 35) return 'hungry';
  if (cat.energyLevel < 35) return 'tired';
  return null;
}

String _minigameRoute(CatId id) => switch (id) {
      CatId.noodles => AppRoutes.breathing,
      CatId.loafCat => AppRoutes.math,
      CatId.robotCat => AppRoutes.eqSort,
    };

// ── Particle model ────────────────────────────────────────────────────────────

class _Particle {
  final int id;
  final String glyph;
  final double drift; // horizontal offset from center
  final int idx;

  const _Particle({
    required this.id,
    required this.glyph,
    required this.drift,
    required this.idx,
  });
}

// ── CareSheet ─────────────────────────────────────────────────────────────────

/// Full-screen overlay (backdrop + panel + particles + toast).
/// Mount as a [Positioned.fill] child in the Room's Stack.
class CareSheet extends ConsumerStatefulWidget {
  const CareSheet({super.key, required this.catId});

  /// 'noodles' | 'loafCat' | 'robotCat' | 'kalia'
  final String catId;

  @override
  ConsumerState<CareSheet> createState() => _CareSheetState();
}

class _CareSheetState extends ConsumerState<CareSheet>
    with SingleTickerProviderStateMixin {
  List<_Particle> _particles = [];
  String? _toast;
  final _rand = math.Random();
  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideCtrl,
      curve: const Cubic(0.2, 0.8, 0.2, 1),
    ));
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    _slideCtrl.reverse().then((_) {
      if (mounted) ref.read(focusedCatProvider.notifier).state = null;
    });
  }

  void _fire(String kind, _Vocab vocab) {
    final catId = _toCatId(widget.catId);
    final glyph = switch (kind) {
      'feed' => vocab.feed,
      'play' => vocab.play,
      _ => vocab.pet,
    };

    if (catId != null) {
      if (kind == 'feed') {
        ref.read(catsProvider.notifier).feed(catId);
        ref.read(playerProfileProvider.notifier).addXp(5);
      } else if (kind == 'play') {
        ref.read(catsProvider.notifier).play(catId);
        ref.read(playerProfileProvider.notifier).addXp(5);
      }
    }

    final toastText = kind == 'pet'
        ? '✨  $glyph ${vocab.toast}'
        : '+5 ✦  $glyph ${vocab.toast}';

    final newParticles = List.generate(
      8,
      (i) => _Particle(
        id: DateTime.now().millisecondsSinceEpoch + i,
        glyph: i % 4 == 3 ? '✨' : glyph,
        drift: (_rand.nextDouble() - 0.5) * 70,
        idx: i,
      ),
    );

    setState(() {
      _toast = toastText;
      _particles = [..._particles, ...newParticles];
    });

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _particles = []);
    });
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sheetMaxH = size.height * 0.72;
    final isKalia = widget.catId == 'kalia';
    final catId = _toCatId(widget.catId);
    final cat = catId != null ? ref.watch(catsProvider)[catId] : null;
    final profile = ref.watch(playerProfileProvider);
    final info = _catInfo[widget.catId]!;
    final moodKey = cat != null ? _moodKey(cat.moodState) : 'neutral';
    final vocab = _vocab[moodKey] ?? _vocab['neutral']!;
    final needs = cat != null ? _needsOf(cat) : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Dimmed backdrop ───────────────────────────────────────────────
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(color: const Color(0x473D2E23)),
          ),
        ),

        // ── Toast ─────────────────────────────────────────────────────────
        if (_toast != null)
          Positioned(
            bottom: sheetMaxH + 10,
            left: 0,
            right: 0,
            child: Center(child: _ToastPill(text: _toast!)),
          ),

        // ── Particles ─────────────────────────────────────────────────────
        for (final p in _particles)
          _ParticleWidget(
            particle: p,
            baseBottom: sheetMaxH - 16,
            screenWidth: size.width,
          ),

        // ── Sheet panel ───────────────────────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: _slideAnim,
            child: _SheetPanel(
              info: info,
              catId: widget.catId,
              cat: cat,
              profile: profile,
              isKalia: isKalia,
              moodKey: moodKey,
              vocab: vocab,
              needs: needs,
              sheetMaxH: sheetMaxH,
              onDismiss: _dismiss,
              onFire: (kind) => _fire(kind, vocab),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Sheet panel ───────────────────────────────────────────────────────────────

class _SheetPanel extends StatelessWidget {
  const _SheetPanel({
    required this.info,
    required this.catId,
    required this.cat,
    required this.profile,
    required this.isKalia,
    required this.moodKey,
    required this.vocab,
    required this.needs,
    required this.sheetMaxH,
    required this.onDismiss,
    required this.onFire,
  });

  final _Info info;
  final String catId;
  final CatState? cat;
  final PlayerProfile profile;
  final bool isKalia;
  final String moodKey;
  final _Vocab vocab;
  final String? needs;
  final double sheetMaxH;
  final VoidCallback onDismiss;
  final void Function(String kind) onFire;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: sheetMaxH),
      decoration: const BoxDecoration(
        color: Color(0xFFFBF5EA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x403D2E23),
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Grabber
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 10),
            child: Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D0B8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header row
                  _Header(
                    info: info,
                    catId: catId,
                    mood: cat?.moodState ?? MoodState.neutral,
                    onDismiss: onDismiss,
                  ),
                  const SizedBox(height: 16),

                  if (!isKalia && cat != null) ...[
                    // Stat tiles
                    Row(children: [
                      Expanded(
                        child: _StatTile(
                          label: 'Fullness',
                          icon: '🍓',
                          value: cat!.hungerLevel,
                          color: const Color(0xFFD88A7A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatTile(
                          label: 'Energy',
                          icon: '✧',
                          value: cat!.energyLevel,
                          color: const Color(0xFFA8C5A0),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 16),

                    // Needs banner
                    if (needs != null) ...[
                      _NeedsBanner(
                          needs: needs!, catId: catId, onDismiss: onDismiss),
                      const SizedBox(height: 14),
                    ],

                    // Mood label
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFA39282),
                          letterSpacing: 1.2,
                        ),
                        children: [
                          const TextSpan(text: "THEY'RE FEELING "),
                          TextSpan(
                            text: moodKey.toUpperCase(),
                            style: const TextStyle(color: kInk),
                          ),
                          const TextSpan(text: ' — TRY:'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Care buttons
                    Row(children: [
                      Expanded(
                        child: _CareBtn(
                          icon: vocab.feed,
                          label: 'Feed',
                          tint: kBlush,
                          onTap: () => onFire('feed'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CareBtn(
                          icon: vocab.play,
                          label: 'Play',
                          tint: kSage,
                          onTap: () => onFire('play'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _CareBtn(
                          icon: vocab.pet,
                          label: 'Pet',
                          tint: kLilac,
                          onTap: () => onFire('pet'),
                        ),
                      ),
                    ]),
                  ],

                  if (isKalia) _KaliaCard(profile: profile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.info,
    required this.catId,
    required this.mood,
    required this.onDismiss,
  });

  final _Info info;
  final String catId;
  final MoodState mood;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Portrait circle — painted character head, framed by the tinted circle
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: info.color,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F3D2E23),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CharacterPortrait(id: catId, mood: mood),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.name,
                style: GoogleFonts.caveat(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: kInk,
                  height: 1,
                ),
              ),
              Text(
                info.blurb,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B5A4A),
                ),
              ),
              Text(
                info.pillar.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFA39282),
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onDismiss,
          child: Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFEEE1CB),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '×',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF6B5A4A),
                  height: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
  });

  final String label, icon;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEE1CB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF6B5A4A),
                letterSpacing: 1.0,
              ),
            ),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFF5ECDE),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$value/100',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFFA39282),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Needs banner ──────────────────────────────────────────────────────────────

class _NeedsBanner extends StatelessWidget {
  const _NeedsBanner({
    required this.needs,
    required this.catId,
    required this.onDismiss,
  });

  final String needs;
  final String catId;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final isHungry = needs == 'hungry';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFCE9D6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFD88A7A),
            width: 1.5,
            style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Text(isHungry ? '🥣' : '💤',
              style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHungry ? 'a little hungry' : 'feeling low on spark',
                  style: GoogleFonts.caveat(
                    fontSize: 20,
                    color: kInk,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Play the minigame to help them feel better.',
                  style: TextStyle(fontSize: 11, color: Color(0xFF6B5A4A)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              final id = _toCatId(catId);
              if (id != null) {
                final route = _minigameRoute(id);
                onDismiss();
                if (context.mounted) context.go(route);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kInk,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Text(
                'Help →',
                style: TextStyle(
                  color: Color(0xFFFBF5EA),
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Care button ───────────────────────────────────────────────────────────────

class _CareBtn extends StatefulWidget {
  const _CareBtn({
    required this.icon,
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final String icon, label;
  final Color tint;
  final VoidCallback onTap;

  @override
  State<_CareBtn> createState() => _CareBtnState();
}

class _CareBtnState extends State<_CareBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.tint,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x243D2E23),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Kalia card ────────────────────────────────────────────────────────────────

class _KaliaCard extends ConsumerWidget {
  const _KaliaCard({required this.profile});
  final PlayerProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(playerProfileProvider.notifier);
    final current = ref.watch(playerProfileProvider);

    return Column(
      children: [
        Text(
          "That's you!",
          style: GoogleFonts.caveat(
            fontSize: 26,
            color: kInk,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Total XP · ${current.totalXp} ✦  ·  Trunks · ${current.trunkOpenCount} 🧳',
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B5A4A)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: DifficultyTier.values.map((tier) {
            final selected = current.difficultyTier == tier;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => notifier.setDifficultyTier(tier),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? kButter : Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color:
                          selected ? kInk : const Color(0xFFE0D0B8),
                      width: selected ? 2 : 1.5,
                    ),
                  ),
                  child: Text(
                    tier.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: kInk,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Particle widget ───────────────────────────────────────────────────────────

class _ParticleWidget extends StatelessWidget {
  const _ParticleWidget({
    required this.particle,
    required this.baseBottom,
    required this.screenWidth,
  });

  final _Particle particle;
  final double baseBottom;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(particle.id),
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        final opacity = t < 0.2
            ? t / 0.2
            : (t > 0.65 ? (1.0 - t) / 0.35 : 1.0);
        final bottom = baseBottom + t * 130;
        return Positioned(
          left: screenWidth / 2 + particle.drift - 12,
          bottom: bottom,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Text(
              particle.glyph,
              style: TextStyle(fontSize: 18.0 + (particle.idx % 3) * 2),
            ),
          ),
        );
      },
    );
  }
}

// ── Toast pill ────────────────────────────────────────────────────────────────

class _ToastPill extends StatelessWidget {
  const _ToastPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: const [
          BoxShadow(
            color: Color(0x243D2E23),
            blurRadius: 28,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.caveat(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: kInk,
        ),
      ),
    );
  }
}
