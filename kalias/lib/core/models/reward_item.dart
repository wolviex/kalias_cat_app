/// Static catalog of all earnable reward items.
///
/// Items are never stored in full — only their [id] strings are persisted in
/// [PlayerProfile.inventory] and [PlayerProfile.equipped].
library;

enum RewardCategory { kaliaGear, catCostume, toy }

class RewardItem {
  const RewardItem({
    required this.id,
    required this.emoji,
    required this.name,
    required this.category,
    required this.slot, // equipped slot key; '' = decorative / no room overlay
  });

  final String id;
  final String emoji;
  final String name;
  final RewardCategory category;
  final String slot;
}

// ── Slot key constants ────────────────────────────────────────────────────────

abstract final class RewardSlots {
  static const kaliaHat        = 'kalia_hat';
  static const kaliaScarf      = 'kalia_scarf';
  static const kaliaAccessory  = 'kalia_acc';
  static const noodlesHat      = 'noodles_hat';
  static const noodlesAcc      = 'noodles_acc';
  static const loafHat         = 'loaf_hat';
  static const loafAcc         = 'loaf_acc';
  static const robotAcc        = 'robot_acc';
}

// ── Catalog ───────────────────────────────────────────────────────────────────

abstract final class RewardCatalog {
  // ── Kalia Gear — trunks 1-5 ────────────────────────────────────────────────
  static const _kaliaGear = <RewardItem>[
    RewardItem(id: 'kalia_hat_bow',     emoji: '🎀', name: 'Bow Headband',      category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaHat),
    RewardItem(id: 'kalia_hat_star',    emoji: '⭐', name: 'Star Crown',         category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaHat),
    RewardItem(id: 'kalia_hat_flower',  emoji: '🌸', name: 'Flower Crown',       category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaHat),
    RewardItem(id: 'kalia_hat_magic',   emoji: '🪄', name: 'Wizard Hat',         category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaHat),
    RewardItem(id: 'kalia_scarf_rainbow', emoji: '🌈', name: 'Rainbow Scarf',   category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaScarf),
    RewardItem(id: 'kalia_scarf_heart', emoji: '💕', name: 'Heart Scarf',        category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaScarf),
    RewardItem(id: 'kalia_glasses',     emoji: '🕶️', name: 'Cool Shades',       category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaAccessory),
    RewardItem(id: 'kalia_wings',       emoji: '🦋', name: 'Butterfly Wings',    category: RewardCategory.kaliaGear, slot: RewardSlots.kaliaAccessory),
  ];

  // ── Cat Costumes — trunks 6-10 ─────────────────────────────────────────────
  static const _catCostumes = <RewardItem>[
    RewardItem(id: 'noodles_hat_party', emoji: '🎉', name: 'Party Hat (Noodles)',      category: RewardCategory.catCostume, slot: RewardSlots.noodlesHat),
    RewardItem(id: 'noodles_bow',       emoji: '🎀', name: 'Fancy Bow (Noodles)',      category: RewardCategory.catCostume, slot: RewardSlots.noodlesAcc),
    RewardItem(id: 'noodles_crown',     emoji: '🌟', name: 'Star Tiara (Noodles)',     category: RewardCategory.catCostume, slot: RewardSlots.noodlesHat),
    RewardItem(id: 'loaf_crown',        emoji: '👑', name: 'Golden Crown (Loaf Cat)',  category: RewardCategory.catCostume, slot: RewardSlots.loafHat),
    RewardItem(id: 'loaf_collar',       emoji: '💎', name: 'Crystal Collar (Loaf Cat)', category: RewardCategory.catCostume, slot: RewardSlots.loafAcc),
    RewardItem(id: 'loaf_chef',         emoji: '👨‍🍳', name: 'Chef Hat (Loaf Cat)',    category: RewardCategory.catCostume, slot: RewardSlots.loafHat),
    RewardItem(id: 'robot_antennae',    emoji: '📡', name: 'Scan Antennae (Robot Cat)', category: RewardCategory.catCostume, slot: RewardSlots.robotAcc),
    RewardItem(id: 'robot_cape',        emoji: '🦸', name: 'Hero Cape (Robot Cat)',    category: RewardCategory.catCostume, slot: RewardSlots.robotAcc),
  ];

  // ── Interactive Toys — trunks 11+ ──────────────────────────────────────────
  static const _toys = <RewardItem>[
    RewardItem(id: 'toy_sparkle', emoji: '✨', name: 'Sparkle Wand',    category: RewardCategory.toy, slot: ''),
    RewardItem(id: 'toy_shooting_star', emoji: '🌠', name: 'Shooting Star', category: RewardCategory.toy, slot: ''),
    RewardItem(id: 'toy_rainbow',  emoji: '🌈', name: 'Rainbow Maker',  category: RewardCategory.toy, slot: ''),
    RewardItem(id: 'toy_bubble',   emoji: '🫧', name: 'Bubble Machine', category: RewardCategory.toy, slot: ''),
    RewardItem(id: 'toy_music',    emoji: '🎵', name: 'Music Box',      category: RewardCategory.toy, slot: ''),
  ];

  static const all = [..._kaliaGear, ..._catCostumes, ..._toys];

  static RewardItem? byId(String id) {
    for (final item in all) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Returns the item pool for a given 1-based trunk number.
  static List<RewardItem> poolForTrunk(int trunkNumber) {
    if (trunkNumber <= 5)  return _kaliaGear;
    if (trunkNumber <= 10) return _catCostumes;
    return _toys;
  }
}
