import 'package:hive_ce/hive.dart';
import 'difficulty_tier.dart';

part 'player_profile.g.dart';

/// Persisted player state. One box, one object (single-child app).
///
/// Stored locally via Hive. Future cloud-save will serialize/deserialize
/// this same model to/from a parent-account backend.
@HiveType(typeId: 0)
class PlayerProfile extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  /// Which cat character the player chose (matches filename stem in assets/characters/).
  @HiveField(2)
  String characterId;

  /// DDA tier — stored as int index, surfaced via [DifficultyTier].
  @HiveField(3)
  int difficultyIndex;

  /// Total XP accumulated across all sessions.
  @HiveField(4)
  int totalXp;

  /// XP accumulated in the current Purr-gress bar cycle (0–100).
  @HiveField(5)
  int cycleXp;

  /// Number of times the Magical Trunk has been opened (unlocks earned).
  @HiveField(6)
  int trunkOpenCount;

  /// ISO-8601 string of last play session, for streak tracking.
  @HiveField(7)
  String? lastPlayedAt;

  /// Trunks earned (cycle completed) but not yet opened by the player.
  @HiveField(8)
  int pendingTrunks;

  /// IDs of all reward items the player owns.
  @HiveField(9)
  List<String> inventory;

  /// Slot key → reward item ID for currently equipped items.
  @HiveField(10)
  Map<String, String> equipped;

  PlayerProfile({
    required this.id,
    required this.name,
    required this.characterId,
    required this.difficultyIndex,
    this.totalXp = 0,
    this.cycleXp = 0,
    this.trunkOpenCount = 0,
    this.lastPlayedAt,
    this.pendingTrunks = 0,
    List<String>? inventory,
    Map<String, String>? equipped,
  })  : inventory = inventory ?? [],
        equipped  = equipped  ?? {};

  DifficultyTier get difficultyTier =>
      DifficultyTierX.fromIndex(difficultyIndex);

  set difficultyTier(DifficultyTier tier) => difficultyIndex = tier.index;

  /// XP required to complete a Purr-gress cycle (fill the bar).
  static const int xpPerCycle = 100;

  /// Add [amount] XP, queue any completed cycles as pending trunks,
  /// and return how many cycles were completed.
  int addXp(int amount) {
    totalXp += amount;
    cycleXp += amount;
    int cycles = 0;
    while (cycleXp >= xpPerCycle) {
      cycleXp -= xpPerCycle;
      cycles++;
    }
    pendingTrunks += cycles;
    return cycles;
  }

  /// Override equality so that Riverpod's Notifier always treats an in-place
  /// mutation as a state change when `state = state` is called.
  /// HiveObject storage is not affected by this — Hive tracks objects by key.
  @override
  bool operator ==(Object other) => false;

  @override
  int get hashCode => identityHashCode(this);

  factory PlayerProfile.defaults({
    required String id,
    required String name,
  }) =>
      PlayerProfile(
        id: id,
        name: name,
        characterId: 'kalia',
        difficultyIndex: DifficultyTier.seedling.index,
      );
}
