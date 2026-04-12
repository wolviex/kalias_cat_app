import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import '../models/cat_state.dart';

const _hungerDecay = 3;
const _energyDecay = 2;
const _tickInterval = Duration(seconds: 30);

// Hive box key constants
const _boxName = 'cat_states';
const _savedAtKey = 'saved_at';

String _hungerKey(CatId id) => '${id.name}_hunger';
String _energyKey(CatId id) => '${id.name}_energy';

final catsProvider =
    NotifierProvider<CatsNotifier, Map<CatId, CatState>>(CatsNotifier.new);

class CatsNotifier extends Notifier<Map<CatId, CatState>> {
  @override
  Map<CatId, CatState> build() {
    final timer = Timer.periodic(_tickInterval, (_) => _tick());
    ref.onDispose(timer.cancel);
    return _loadWithRetroactiveDecay();
  }

  // ── Persistence ─────────────────────────────────────────────────────────────

  /// Loads cat states from Hive and applies retroactive decay for time elapsed
  /// since last save. Caps at 8 hours to avoid punishing long absences.
  Map<CatId, CatState> _loadWithRetroactiveDecay() {
    final box = Hive.box(_boxName);
    final savedAtStr = box.get(_savedAtKey) as String?;

    int elapsedTicks = 0;
    if (savedAtStr != null) {
      final savedAt = DateTime.tryParse(savedAtStr);
      if (savedAt != null) {
        final elapsed = DateTime.now().difference(savedAt);
        final cappedSeconds =
            elapsed.inSeconds.clamp(0, 8 * 60 * 60); // 8h cap
        elapsedTicks = cappedSeconds ~/ _tickInterval.inSeconds;
      }
    }

    return {
      for (final id in CatId.values)
        id: CatState(
          id: id,
          hungerLevel: ((box.get(_hungerKey(id)) as int? ?? 80) -
                  elapsedTicks * _hungerDecay)
              .clamp(0, 100),
          energyLevel: ((box.get(_energyKey(id)) as int? ?? 80) -
                  elapsedTicks * _energyDecay)
              .clamp(0, 100),
        ),
    };
  }

  void _saveToHive() {
    final box = Hive.box(_boxName);
    box.put(_savedAtKey, DateTime.now().toIso8601String());
    for (final entry in state.entries) {
      box.put(_hungerKey(entry.key), entry.value.hungerLevel);
      box.put(_energyKey(entry.key), entry.value.energyLevel);
    }
  }

  // ── Decay ───────────────────────────────────────────────────────────────────

  void _tick() {
    state = {
      for (final entry in state.entries)
        entry.key: entry.value.copyWith(
          hungerLevel:
              (entry.value.hungerLevel - _hungerDecay).clamp(0, 100),
          energyLevel:
              (entry.value.energyLevel - _energyDecay).clamp(0, 100),
        ),
    };
    _saveToHive();
  }

  // ── Care actions ─────────────────────────────────────────────────────────────

  /// Feed [id], restoring [amount] hunger. Sets a brief reaction animation.
  void feed(CatId id, {int amount = 25}) {
    final cat = state[id]!;
    state = {
      ...state,
      id: cat.copyWith(
        hungerLevel: (cat.hungerLevel + amount).clamp(0, 100),
        lastReaction: CareReaction.fed,
      ),
    };
    _saveToHive();
    _scheduleReactionClear(id);
  }

  /// Play with [id], restoring [amount] energy. Sets a brief reaction animation.
  void play(CatId id, {int amount = 25}) {
    final cat = state[id]!;
    state = {
      ...state,
      id: cat.copyWith(
        energyLevel: (cat.energyLevel + amount).clamp(0, 100),
        lastReaction: CareReaction.played,
      ),
    };
    _saveToHive();
    _scheduleReactionClear(id);
  }

  /// Called by a minigame on successful completion to restore cat stats.
  void restoreAfterMinigame(CatId id, {int hunger = 0, int energy = 0}) {
    final cat = state[id]!;
    state = {
      ...state,
      id: cat.copyWith(
        hungerLevel: (cat.hungerLevel + hunger).clamp(0, 100),
        energyLevel: (cat.energyLevel + energy).clamp(0, 100),
      ),
    };
    _saveToHive();
  }

  void _scheduleReactionClear(CatId id) {
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (state[id]?.lastReaction != null) {
        state = {...state, id: state[id]!.copyWith(clearReaction: true)};
      }
    });
  }
}
