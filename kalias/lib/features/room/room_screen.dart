import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text("Kalia's Room"),
        leading: BackButton(onPressed: () => context.go(AppRoutes.home)),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(24),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _MinigameCard(
            label: 'Breathing Buddies',
            emoji: '🫧',
            onTap: () => context.go(AppRoutes.breathing),
          ),
          _MinigameCard(
            label: 'Feelings Sort',
            emoji: '😊',
            onTap: () => context.go(AppRoutes.eqSort),
          ),
          _MinigameCard(
            label: 'Word Pond',
            emoji: '📖',
            onTap: () => context.go(AppRoutes.reading),
          ),
          _MinigameCard(
            label: 'Count & Crunch',
            emoji: '🔢',
            onTap: () => context.go(AppRoutes.math),
          ),
        ],
      ),
    );
  }
}

class _MinigameCard extends StatelessWidget {
  const _MinigameCard({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
