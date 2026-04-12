/// DDA (Dynamic Difficulty Adjustment) tiers.
///
/// Tier is chosen by the parent/caregiver at first launch and can be
/// adjusted at any time from the settings screen.
enum DifficultyTier {
  /// Ages 4–5. Simpler vocabulary, larger tap targets, more visual cues.
  sprout,

  /// Ages 5–6. Moderate challenge, default tier.
  seedling,

  /// Ages 6–8. Full word sets, tighter timing windows.
  bloom,
}

extension DifficultyTierX on DifficultyTier {
  String get label => switch (this) {
        DifficultyTier.sprout => 'Sprout (Ages 4–5)',
        DifficultyTier.seedling => 'Seedling (Ages 5–6)',
        DifficultyTier.bloom => 'Bloom (Ages 6–8)',
      };

  int get hiveIndex => index;

  static DifficultyTier fromIndex(int i) => DifficultyTier.values[i];
}
