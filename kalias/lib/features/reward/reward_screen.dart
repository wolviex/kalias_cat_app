import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/player_profile.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';

/// Shown after completing any minigame. Awards XP and returns to Room.
class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen> {
  bool _awarded = false;

  @override
  void initState() {
    super.initState();
    _awardXp();
  }

  Future<void> _awardXp() async {
    await ref.read(playerProfileProvider.notifier).addXp(10);
    if (mounted) setState(() => _awarded = true);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Great job, ${profile.name}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (_awarded) ...[
                const SizedBox(height: 8),
                Text('+10 XP  •  Total: ${profile.totalXp} XP'),
                const SizedBox(height: 4),
                Text('Purr-gress: ${profile.cycleXp} / ${PlayerProfile.xpPerCycle}'),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.room),
                child: const Text('Back to Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
