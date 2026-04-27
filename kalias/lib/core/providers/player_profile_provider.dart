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

  /// Persist any mutations made directly on [state] fields and notify
  /// Riverpod listeners. Must be called after every field mutation.
  Future<void> _saveAndNotify() async {
    await state.save();
    // PlayerProfile.== always returns false, so this assignment
    // always triggers a rebuild in every watching widget.
    // ignore: invalid_use_of_protected_member
    state = state;
  }

  /// Add XP and persist. Returns number of Purr-gress cycles completed.
  Future<int> addXp(int amount) async {
    final cycles = state.addXp(amount);
    await _saveAndNotify();
    return cycles;
  }

  Future<void> setCharacter(String characterId) async {
    state.characterId = characterId;
    await _saveAndNotify();
  }

  Future<void> setDifficultyTier(DifficultyTier tier) async {
    state.difficultyTier = tier;
    await _saveAndNotify();
  }

  Future<void> setName(String name) async {
    state.name = name;
    await _saveAndNotify();
  }

  /// Award [itemId] to inventory and decrement pending trunks.
  Future<void> openTrunk(String itemId) async {
    state.inventory = [...state.inventory, itemId];
    if (state.pendingTrunks > 0) state.pendingTrunks--;
    state.trunkOpenCount++;
    await _saveAndNotify();
  }

  /// Equip [itemId] to its slot (unequips whatever was there before).
  /// Passing an empty [itemId] clears the slot.
  Future<void> equip(String slot, String itemId) async {
    final next = Map<String, String>.from(state.equipped);
    if (itemId.isEmpty) {
      next.remove(slot);
    } else {
      next[slot] = itemId;
    }
    state.equipped = next;
    await _saveAndNotify();
  }
}
