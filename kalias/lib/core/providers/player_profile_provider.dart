import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/difficulty_tier.dart';
import '../models/player_profile.dart';

const _boxName = 'player_profile';
const _profileKey = 'profile';

/// Opens (or creates) the PlayerProfile Hive box.
/// Called once at startup after [Hive.initFlutter].
final hiveProfileBoxProvider = Provider<Box<PlayerProfile>>((ref) {
  return Hive.box<PlayerProfile>(_boxName);
});

/// The active [PlayerProfile]. Creates a default profile on first launch.
final playerProfileProvider =
    NotifierProvider<PlayerProfileNotifier, PlayerProfile>(
  PlayerProfileNotifier.new,
);

class PlayerProfileNotifier extends Notifier<PlayerProfile> {
  @override
  PlayerProfile build() {
    final box = ref.read(hiveProfileBoxProvider);
    final existing = box.get(_profileKey);
    if (existing != null) return existing;

    final profile = PlayerProfile.defaults(
      id: const Uuid().v4(),
      name: 'Player',
    );
    box.put(_profileKey, profile);
    return profile;
  }

  /// Persist any mutations made directly on [state] fields.
  Future<void> save() async => state.save();

  /// Add XP and persist. Returns number of Purr-gress cycles completed.
  Future<int> addXp(int amount) async {
    final cycles = state.addXp(amount);
    await save();
    return cycles;
  }

  Future<void> setCharacter(String characterId) async {
    state.characterId = characterId;
    await save();
  }

  Future<void> setDifficultyTier(DifficultyTier tier) async {
    state.difficultyTier = tier;
    await save();
  }

  Future<void> setName(String name) async {
    state.name = name;
    await save();
  }
}
