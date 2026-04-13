import 'dart:ui' show Rect;

/// Frame rectangle data for noodles_sprite.png.
///
/// Actual sheet: 1536×921px · 4 columns × 3 rows · 384×307px per frame.
/// Frames are tightly packed (no gap). The metadata "padding: 2" refers to
/// internal transparent border within each frame, not sheet spacing.
/// Anchor: bottom_center — consistent across all frames.
///
/// Animation → mood mapping (used by CatSprite):
///   idle_sleep  → default / sad / overloaded
///   stand_dance → happy / neutral
///   run         → zoomies
abstract final class NoodlesSprites {
  static const String assetPath = 'assets/characters/noodles_sprite.png';

  static const double _fw = 384;
  static const double _fh = 307;

  static Rect _f(int col, int row) => Rect.fromLTWH(
        col * _fw,
        row * _fh,
        _fw,
        _fh,
      );

  /// Row 0 — idle / sleeping (4 frames)
  static final List<Rect> idleSleep = [_f(0,0), _f(1,0), _f(2,0), _f(3,0)];

  /// Row 1 — standing / dancing (4 frames)
  static final List<Rect> standDance = [_f(0,1), _f(1,1), _f(2,1), _f(3,1)];

  /// Row 2 — running / zoomies (4 frames)
  static final List<Rect> run = [_f(0,2), _f(1,2), _f(2,2), _f(3,2)];
}
