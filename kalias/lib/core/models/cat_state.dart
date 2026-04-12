import 'package:flutter/material.dart';

/// Brief visual reaction shown on the mood bubble after a care action.
enum CareReaction { fed, played }

/// Identifies one of the three companion cats.
/// Kalia is the player avatar and is handled separately.
enum CatId {
  noodles,
  loafCat,
  robotCat;

  String get displayName => switch (this) {
        CatId.noodles => 'Noodles',
        CatId.loafCat => 'Loaf Cat',
        CatId.robotCat => 'Robot Cat',
      };

  String get assetPath => switch (this) {
        CatId.noodles => 'assets/characters/Noodles the Cat.png',
        CatId.loafCat => 'assets/characters/Loaf Cat.png',
        CatId.robotCat => 'assets/characters/Robot Cat.png',
      };

  String get pillar => switch (this) {
        CatId.noodles => 'Spelling & Letters',
        CatId.loafCat => 'Math & Counting',
        CatId.robotCat => 'Logic & Sequencing',
      };

  String get personality => switch (this) {
        CatId.noodles => 'High energy & goofy',
        CatId.loafCat => 'Calm & always hungry',
        CatId.robotCat => 'Curious & logical',
      };
}

/// The emotional/physical state a cat can be in.
/// These gate minigame triggers and animate the status bubble.
enum MoodState {
  happy,
  neutral,
  grumpy,
  sad,
  zoomies,
  overloaded;

  String get emoji => switch (this) {
        MoodState.happy => '😸',
        MoodState.neutral => '😺',
        MoodState.grumpy => '😾',
        MoodState.sad => '😿',
        MoodState.zoomies => '🌀',
        MoodState.overloaded => '😤',
      };

  String get label => switch (this) {
        MoodState.happy => 'Happy',
        MoodState.neutral => 'Chill',
        MoodState.grumpy => 'Grumpy',
        MoodState.sad => 'Sad',
        MoodState.zoomies => 'Zoomies!',
        MoodState.overloaded => 'Overwhelmed',
      };

  Color get color => switch (this) {
        MoodState.happy => const Color(0xFF66BB6A),
        MoodState.neutral => const Color(0xFF42A5F5),
        MoodState.grumpy => const Color(0xFFFF7043),
        MoodState.sad => const Color(0xFF78909C),
        MoodState.zoomies => const Color(0xFFAB47BC),
        MoodState.overloaded => const Color(0xFFEF5350),
      };
}

/// Persisted + in-memory status for a single cat.
class CatState {
  final CatId id;

  /// 0–100. Decreases over time. Feed the cat to restore.
  final int hungerLevel;

  /// 0–100. Decreases over time. Play with the cat to restore.
  final int energyLevel;

  /// Set briefly after a care action to drive the mood bubble reaction animation.
  /// Cleared automatically by CatsNotifier after 1.5 seconds.
  final CareReaction? lastReaction;

  const CatState({
    required this.id,
    this.hungerLevel = 80,
    this.energyLevel = 80,
    this.lastReaction,
  });

  /// Mood is computed — never stored — so it always reflects the current state.
  MoodState get moodState {
    // Noodles gets Zoomies when over-energized and well-fed (triggers MG-1).
    if (id == CatId.noodles && energyLevel >= 85 && hungerLevel >= 60) {
      return MoodState.zoomies;
    }
    final avg = (hungerLevel + energyLevel) ~/ 2;
    if (avg >= 70) return MoodState.happy;
    if (avg >= 50) return MoodState.neutral;
    if (avg >= 30) return MoodState.grumpy;
    if (avg >= 15) return MoodState.sad;
    return MoodState.overloaded;
  }

  /// Whether this cat's current mood should trigger a minigame.
  bool get minigameTriggered => switch (id) {
        CatId.noodles => moodState == MoodState.zoomies,
        CatId.loafCat => moodState == MoodState.grumpy ||
            moodState == MoodState.sad ||
            moodState == MoodState.overloaded,
        CatId.robotCat => moodState == MoodState.grumpy ||
            moodState == MoodState.sad ||
            moodState == MoodState.overloaded,
      };

  CatState copyWith({
    int? hungerLevel,
    int? energyLevel,
    CareReaction? lastReaction,
    bool clearReaction = false,
  }) =>
      CatState(
        id: id,
        hungerLevel: hungerLevel ?? this.hungerLevel,
        energyLevel: energyLevel ?? this.energyLevel,
        lastReaction: clearReaction ? null : (lastReaction ?? this.lastReaction),
      );
}
