import 'dart:ui' show Rect;

/// Frame rectangle data for kalia_sprite.png, derived from kalia_metadata.json.
///
/// Sheet: 512×1024px · 3 columns × 4 rows · 160×180px per cell · 2px padding.
/// Anchor: bottom_center at (80, 168) within each cell.
///
/// Source rects use (left, top, width, height) in sheet pixel coordinates.
/// These map directly to canvas.drawImageRect() src arguments.
abstract final class KaliaSprites {
  static const String assetPath = 'assets/characters/kalia_sprite.png';

  /// Row 0 — idle, wave, cheer (3 frames)
  static const List<Rect> idleWaveCheer = [
    Rect.fromLTWH(14, 20, 160, 180),
    Rect.fromLTWH(176, 20, 160, 180),
    Rect.fromLTWH(338, 20, 160, 180),
  ];

  /// Row 1 — walk facing front (3 frames)
  static const List<Rect> walkFront = [
    Rect.fromLTWH(14, 202, 160, 180),
    Rect.fromLTWH(176, 202, 160, 180),
    Rect.fromLTWH(338, 202, 160, 180),
  ];

  /// Row 2 — walk facing side (3 frames)
  static const List<Rect> walkSide = [
    Rect.fromLTWH(14, 384, 160, 180),
    Rect.fromLTWH(176, 384, 160, 180),
    Rect.fromLTWH(338, 384, 160, 180),
  ];

  /// Row 3 — jump (2 frames; r3c2 is blank)
  static const List<Rect> jump = [
    Rect.fromLTWH(14, 566, 160, 180),
    Rect.fromLTWH(176, 566, 160, 180),
  ];
}
