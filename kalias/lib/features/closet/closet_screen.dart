import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/reward_item.dart';
import '../../core/providers/player_profile_provider.dart';
import '../../core/router/app_router.dart';

class ClosetScreen extends ConsumerWidget {
  const ClosetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(playerProfileProvider);
    final owned = profile.inventory.toSet();
    final equipped = profile.equipped;

    final ownedItems = RewardCatalog.all.where((r) => owned.contains(r.id)).toList();

    final Map<RewardCategory, List<RewardItem>> grouped = {};
    for (final item in ownedItems) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCE93D8),
        elevation: 0,
        leading: BackButton(onPressed: () => context.go(AppRoutes.room)),
        title: const Text('✨ Magic Closet',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ownedItems.isEmpty
          ? _EmptyCloset()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final category in RewardCategory.values)
                  if (grouped.containsKey(category)) ...[
                    _CategoryHeader(category: category),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: grouped[category]!
                          .map((item) => _ClosetTile(
                                item: item,
                                isEquipped: equipped[item.slot] == item.id,
                                onTap: item.slot.isEmpty
                                    ? null
                                    : () => _toggleEquip(ref, item, equipped),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
              ],
            ),
    );
  }

  void _toggleEquip(
      WidgetRef ref, RewardItem item, Map<String, String> equipped) {
    final currentlyEquipped = equipped[item.slot] == item.id;
    ref.read(playerProfileProvider.notifier).equip(
          item.slot,
          currentlyEquipped ? '' : item.id,
        );
  }
}

// ── Category header ───────────────────────────────────────────────────────────

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.category});
  final RewardCategory category;

  @override
  Widget build(BuildContext context) {
    final label = switch (category) {
      RewardCategory.kaliaGear  => '🧒 Kalia\'s Gear',
      RewardCategory.catCostume => '🐱 Cat Costumes',
      RewardCategory.toy        => '🪄 Toys',
    };
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

// ── Individual closet tile ────────────────────────────────────────────────────

class _ClosetTile extends StatelessWidget {
  const _ClosetTile({
    required this.item,
    required this.isEquipped,
    required this.onTap,
  });
  final RewardItem item;
  final bool isEquipped;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 88,
        height: 110,
        decoration: BoxDecoration(
          color: isEquipped ? Colors.purple.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEquipped ? Colors.purple.shade400 : Colors.black12,
            width: isEquipped ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.emoji, style: const TextStyle(fontSize: 36)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isEquipped) ...[
              const SizedBox(height: 4),
              const Text('Equipped',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.purple,
                      fontWeight: FontWeight.bold)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyCloset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧳', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'Nothing here yet!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete minigames to fill your\nPurr-gress bar and earn trunks.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
