import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/difficulty_tier.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  DifficultyTier _selectedTier = DifficultyTier.seedling;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final notifier = ref.read(playerProfileProvider.notifier);
    await notifier.setName(name);
    await notifier.setDifficultyTier(_selectedTier);
    if (mounted) context.go(AppRoutes.room);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '🐱 Welcome!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Let's set up Kalia's Room",
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // ── Name field ──────────────────────────────────────────────
              Text("What's your name?",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Type your name here',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 16),
                ),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),

              // ── Tier picker ─────────────────────────────────────────────
              Text('Pick your adventure level',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ...DifficultyTier.values.map(
                (tier) => _TierCard(
                  tier: tier,
                  selected: _selectedTier == tier,
                  onTap: () => setState(() => _selectedTier = tier),
                ),
              ),
              const SizedBox(height: 32),

              // ── Confirm ─────────────────────────────────────────────────
              ListenableBuilder(
                listenable: _nameController,
                builder: (context, _) {
                  final ready = _nameController.text.trim().isNotEmpty;
                  return FilledButton(
                    onPressed: ready ? _confirm : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Let's Go! 🚀",
                        style: TextStyle(fontSize: 18)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final DifficultyTier tier;
  final bool selected;
  final VoidCallback onTap;

  static const _descriptions = {
    DifficultyTier.sprout: 'Simple shapes, big buttons, no pressure.',
    DifficultyTier.seedling: 'Letters, numbers, and growing challenges.',
    DifficultyTier.bloom: 'Full words, math patterns, and coding basics.',
  };

  static const _icons = {
    DifficultyTier.sprout: '🌱',
    DifficultyTier.seedling: '🌿',
    DifficultyTier.bloom: '🌸',
  };

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(25) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.black12,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(_icons[tier]!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: selected ? color : Colors.black87,
                      )),
                  Text(_descriptions[tier]!,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
