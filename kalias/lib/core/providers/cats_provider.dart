import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cat_state.dart';

/// How much hunger drops per decay tick.
const _hungerDecay = 3;

/// How much energy drops per decay tick.
const _energyDecay = 2;

/// Decay ticks every 30 seconds of active play.
const _tickInterval = Duration(seconds: 30);

final catsProvider =
    NotifierProvider<CatsNotifier, Map<CatId, CatState>>(CatsNotifier.new);

class CatsNotifier extends Notifier<Map<CatId, CatState>> {
  @override
  Map<CatId, CatState> build() {
    final timer = Timer.periodic(_tickInterval, (_) => _tick());
    ref.onDispose(timer.cancel);
    return {for (final id in CatId.values) id: CatState(id: id)};
  }

  void _tick() {
    state = {
      for (final entry in state.entries)
        entry.key: entry.value.copyWith(
          hungerLevel: (entry.value.hungerLevel - _hungerDecay).clamp(0, 100),
          energyLevel: (entry.value.energyLevel - _energyDecay).clamp(0, 100),
        ),
    };
  }

  /// Restore [amount] hunger to [id]. Called when player feeds the cat.
  void feed(CatId id, {int amount = 25}) {
    final cat = state[id]!;
    state = {
      ...state,
      id: cat.copyWith(hungerLevel: (cat.hungerLevel + amount).clamp(0, 100)),
    };
  }

  /// Restore [amount] energy to [id]. Called when player plays with the cat.
  void play(CatId id, {int amount = 25}) {
    final cat = state[id]!;
    state = {
      ...state,
      id: cat.copyWith(energyLevel: (cat.energyLevel + amount).clamp(0, 100)),
    };
  }
}
