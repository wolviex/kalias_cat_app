import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animates through a list of source [Rect]s on a sprite sheet image.
///
/// Loads [assetPath] once as a [ui.Image], then cycles through [frames] at
/// [frameDuration] per frame using a [CustomPainter]. Falls back to a
/// placeholder if the image fails to load.
///
/// Usage:
/// ```dart
/// SpriteSheetAnimator(
///   assetPath: KaliaSprites.assetPath,
///   frames: KaliaSprites.idleWaveCheer,
///   frameDuration: const Duration(milliseconds: 250),
/// )
/// ```
class SpriteSheetAnimator extends StatefulWidget {
  const SpriteSheetAnimator({
    super.key,
    required this.assetPath,
    required this.frames,
    this.frameDuration = const Duration(milliseconds: 250),
    this.loop = true,
    this.onComplete,
    this.fallback,
  });

  final String assetPath;

  /// Source rects in the sprite sheet (pixels). Rendered in order.
  final List<Rect> frames;

  /// How long each frame is displayed.
  final Duration frameDuration;

  /// Whether the animation loops. If false, stops on the last frame.
  final bool loop;

  /// Called when a non-looping animation reaches its last frame.
  final VoidCallback? onComplete;

  /// Widget shown while the image is loading or if it fails to load.
  final Widget? fallback;

  @override
  State<SpriteSheetAnimator> createState() => _SpriteSheetAnimatorState();
}

class _SpriteSheetAnimatorState extends State<SpriteSheetAnimator> {
  ui.Image? _image;
  int _frameIndex = 0;
  Timer? _timer;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(SpriteSheetAnimator old) {
    super.didUpdateWidget(old);
    // If the frame list changed (e.g. animation switched), restart from frame 0.
    if (old.frames != widget.frames) {
      _frameIndex = 0;
      _timer?.cancel();
      if (_image != null) _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final data = await rootBundle.load(widget.assetPath);
      final bytes = data.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) return;
      setState(() => _image = frame.image);
      _startTimer();
    } catch (_) {
      if (mounted) setState(() => _loadError = true);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.frames.length <= 1) return; // static sprite — no timer needed
    _timer = Timer.periodic(widget.frameDuration, (_) {
      if (!mounted) return;
      setState(() {
        if (_frameIndex < widget.frames.length - 1) {
          _frameIndex++;
        } else if (widget.loop) {
          _frameIndex = 0;
        } else {
          _timer?.cancel();
          widget.onComplete?.call();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError) {
      return widget.fallback ?? const SizedBox.shrink();
    }
    if (_image == null) {
      // Show fallback (or transparent gap) while loading
      return widget.fallback ?? const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _SpritePainter(
        image: _image!,
        srcRect: widget.frames[_frameIndex],
      ),
      child: const SizedBox.expand(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SpritePainter extends CustomPainter {
  const _SpritePainter({required this.image, required this.srcRect});

  final ui.Image image;
  final Rect srcRect;

  @override
  void paint(Canvas canvas, Size size) {
    final srcAspect = srcRect.width / srcRect.height;
    final dstAspect = size.width / size.height;

    final Rect dst;
    if (srcAspect > dstAspect) {
      // Source is wider — fit to width, centre vertically
      final h = size.width / srcAspect;
      dst = Rect.fromLTWH(0, (size.height - h) / 2, size.width, h);
    } else {
      // Source is taller — fit to height, centre horizontally
      final w = size.height * srcAspect;
      dst = Rect.fromLTWH((size.width - w) / 2, 0, w, size.height);
    }

    canvas.drawImageRect(
      image,
      srcRect,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_SpritePainter old) => old.srcRect != srcRect;
}
