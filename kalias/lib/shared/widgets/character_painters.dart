// Watercolor-storybook characters, hand-tuned to match the target sprite
// sheets in /assets (Loaf Cat, Noodles/Long Cat, Robot Cat, Kalia child
// avatar). Each painter draws in a 200×220 viewBox space (Kalia 200×260) and
// scales to whatever size it is given, so callers only need to constrain
// width and wrap in [PaintedCharacter] for the correct aspect ratio.
//
// Rendering approach (see Concept/progress_plan.md, visual pass):
//  • Outline hierarchy — primary contours ~4.5, interior features ~2.5–3.5,
//    detail lines ~1.2–1.8, all with round caps/joins.
//  • Whiskers and limbs are tapered filled ribbons, not uniform strokes.
//  • Major fills carry subtle vertical gradients (soft overhead light).
//  • Blurred low-alpha washes create contact shadows (chin, loaf, ground).
//
// Eyes (and only eyes) react to the cat's MoodState:
//   Loaf/Robot — grumpy line-eyes, sad arc-eyes
//   Noodles    — zoomies wide-eyes, sad arc-eyes
// `overloaded` renders with the grumpy variant (frazzled).
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/models/cat_state.dart';

// Warm ink for the cats, cooler inks for Kalia / Robot.
const _catInk = Color(0xFF4A3222);
const _kaliaInk = Color(0xFF33281F);
const _robotInk = Color(0xFF223752);

Paint _fill(Color c) => Paint()..color = c;

Paint _line(Color c, double w) => Paint()
  ..color = c
  ..strokeWidth = w
  ..style = PaintingStyle.stroke
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Vertical two-stop gradient fill over [r] — a soft overhead light.
Paint _grad(Rect r, Color top, Color bottom) => Paint()
  ..shader = ui.Gradient.linear(r.topCenter, r.bottomCenter, [top, bottom]);

/// Blurred low-alpha wash for soft contact shadows / self-occlusion.
void _soft(Canvas canvas, Path p,
    {double blur = 4, Color color = const Color(0x1A000000)}) {
  canvas.drawPath(
      p, Paint()..color = color..maskFilter = MaskFilter.blur(BlurStyle.normal, blur));
}

void _groundShadow(Canvas canvas, Offset center, double w) {
  final p = Path()
    ..addOval(Rect.fromCenter(center: center, width: w, height: w * 0.115));
  _soft(canvas, p, blur: 3, color: const Color(0x21000000));
}

/// Filled ribbon along a quadratic Bézier whose width tapers w0 → w1.
/// Endpoints are blunt — cover them with a paw/hand blob, or taper to 0.
Path _taperedQuad(
    Offset p0, Offset c, Offset p1, double w0, double w1,
    {int samples = 18}) {
  Offset pt(double t) {
    final u = 1 - t;
    return Offset(
      u * u * p0.dx + 2 * u * t * c.dx + t * t * p1.dx,
      u * u * p0.dy + 2 * u * t * c.dy + t * t * p1.dy,
    );
  }

  Offset dv(double t) {
    final u = 1 - t;
    return Offset(
      2 * u * (c.dx - p0.dx) + 2 * t * (p1.dx - c.dx),
      2 * u * (c.dy - p0.dy) + 2 * t * (p1.dy - c.dy),
    );
  }

  final left = <Offset>[];
  final right = <Offset>[];
  for (var i = 0; i <= samples; i++) {
    final t = i / samples;
    final p = pt(t);
    var d = dv(t);
    final len = d.distance == 0 ? 1.0 : d.distance;
    final n = Offset(-d.dy / len, d.dx / len);
    final hw = (w0 + (w1 - w0) * t) / 2;
    left.add(p + n * hw);
    right.add(p - n * hw);
  }
  final path = Path()..moveTo(left.first.dx, left.first.dy);
  for (final o in left.skip(1)) {
    path.lineTo(o.dx, o.dy);
  }
  for (final o in right.reversed) {
    path.lineTo(o.dx, o.dy);
  }
  path.close();
  return path;
}

/// A whisker: fine tapered ribbon fading to a point.
void _whisker(Canvas canvas, Offset from, Offset to, Color color) {
  final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2 - 1.5);
  canvas.drawPath(_taperedQuad(from, mid, to, 1.6, 0.0), _fill(color));
}

/// Sizes a character painter to its slot width at the correct aspect ratio.
class PaintedCharacter extends StatelessWidget {
  const PaintedCharacter({
    super.key,
    required this.painter,
    this.aspectRatio = 200 / 220,
  });

  final CustomPainter painter;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: SizedBox.expand(
        child: CustomPaint(painter: painter),
      ),
    );
  }
}

/// The painter for a character id ('noodles' | 'loafCat' | 'robotCat' | 'kalia').
CustomPainter characterPainterFor(String id, MoodState mood) => switch (id) {
      'noodles' => NoodlesPainter(mood: mood),
      'loafCat' => LoafCatPainter(mood: mood),
      'robotCat' => RobotCatPainter(mood: mood),
      _ => const KaliaPainter(),
    };

/// Frames a character's head inside its parent (typically a [ClipOval] circle)
/// for use as a small portrait. Zooms in so the head roughly fills the frame
/// and aligns to the top so the ears sit just inside the rim.
class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({
    super.key,
    required this.id,
    this.mood = MoodState.neutral,
  });

  final String id;
  final MoodState mood;

  @override
  Widget build(BuildContext context) {
    final tall = id == 'kalia';
    final aspect = tall ? KaliaPainter.aspectRatio : 200 / 220;
    // Kalia's head sits lower in her (taller) viewBox, so she needs more zoom.
    final zoom = tall ? 2.05 : 1.7;
    return ClipOval(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final d = constraints.maxWidth;
          final charW = d * zoom;
          return OverflowBox(
            minWidth: 0,
            maxWidth: charW,
            minHeight: 0,
            maxHeight: charW / aspect,
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: d * 0.08),
              child: SizedBox(
                width: charW,
                child: PaintedCharacter(
                  painter: characterPainterFor(id, mood),
                  aspectRatio: aspect,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Noodles — long tan cat with cream face patch, sitting upright ────────────

class NoodlesPainter extends CustomPainter {
  const NoodlesPainter({this.mood = MoodState.neutral});

  final MoodState mood;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 220);
    const tan = Color(0xFFDEB077);
    const tanLight = Color(0xFFE8C08C);
    const tanDark = Color(0xFFC79A5E);
    const cream = Color(0xFFFBF3E2);
    const earPink = Color(0xFFF2A7B3);
    const nosePink = Color(0xFFE98FA0);

    _groundShadow(canvas, const Offset(100, 209), 104);

    // Tail — tapered ribbon curling up to the right, darker rounded tip.
    final tail = _taperedQuad(const Offset(138, 178), const Offset(184, 168),
        const Offset(180, 116), 15, 10.5);
    canvas.drawPath(tail, _fill(tan));
    canvas.drawCircle(const Offset(180.5, 118), 6.4, _fill(tanDark));
    canvas.drawPath(tail, _line(_catInk, 2.8));

    // Body — continuous pear silhouette with a soft inward waist.
    final body = Path()
      ..moveTo(61, 202)
      ..cubicTo(52, 162, 58, 130, 79, 118)
      ..cubicTo(88, 112, 112, 112, 121, 118)
      ..cubicTo(142, 131, 148, 163, 139, 202)
      ..quadraticBezierTo(100, 208, 61, 202)
      ..close();
    canvas.drawPath(body,
        _grad(const Rect.fromLTRB(52, 112, 148, 208), tanLight, tanDark));

    // Cream belly patch (no outline — soft interior shape).
    final belly = Path()
      ..moveTo(76, 200)
      ..cubicTo(72, 170, 80, 148, 100, 146)
      ..cubicTo(120, 148, 128, 170, 124, 200)
      ..quadraticBezierTo(100, 204, 76, 200)
      ..close();
    canvas.drawPath(belly, _fill(cream));
    canvas.drawPath(body, _line(_catInk, 4.2));

    // Front paws — cream blobs with fine toe lines.
    for (final cx in [80.0, 120.0]) {
      final paw = Rect.fromCenter(center: Offset(cx, 200), width: 27, height: 15);
      canvas.drawOval(paw, _fill(cream));
      canvas.drawOval(paw, _line(_catInk, 2.6));
      for (final dx in [-4.0, 4.0]) {
        canvas.drawLine(Offset(cx + dx, 195.5), Offset(cx + dx, 200.5),
            _line(_catInk.withAlpha(140), 1.2));
      }
    }

    // Ears — rounded triangles, drawn first so the head overlaps their base.
    final earL = Path()
      ..moveTo(63, 62)
      ..cubicTo(58, 42, 62, 27, 71, 21)
      ..cubicTo(81, 27, 89, 40, 92, 54)
      ..close();
    final earR = Path()
      ..moveTo(137, 62)
      ..cubicTo(142, 42, 138, 27, 129, 21)
      ..cubicTo(119, 27, 111, 40, 108, 54)
      ..close();
    for (final (ear, inner) in [
      (earL, const Offset(74, 38)),
      (earR, const Offset(126, 38)),
    ]) {
      canvas.drawPath(ear, _fill(tan));
      canvas.drawPath(ear, _line(_catInk, 3.4));
      final innerEar = Path()
        ..moveTo(inner.dx - 6, inner.dy + 12)
        ..quadraticBezierTo(inner.dx - 3, inner.dy - 5, inner.dx + 2, inner.dy - 8)
        ..quadraticBezierTo(inner.dx + 7, inner.dy, inner.dx + 8, inner.dy + 12)
        ..close();
      canvas.drawPath(innerEar, _fill(earPink));
    }

    // Head — chubby, cheeks bulge low; slight asymmetry.
    final head = Path()
      ..moveTo(56, 86)
      ..cubicTo(56, 57, 76, 44, 100, 44)
      ..cubicTo(125, 44, 144, 58, 144, 87)
      ..cubicTo(144, 107, 129, 120, 100, 120)
      ..cubicTo(70, 120, 56, 106, 56, 86)
      ..close();
    canvas.drawPath(
        head, _grad(const Rect.fromLTRB(56, 44, 144, 120), tanLight, tan));

    // Cream face patch — forehead wedge widening over the muzzle to the chin.
    final facePatch = Path()
      ..moveTo(90, 60)
      ..quadraticBezierTo(100, 54, 110, 60)
      ..cubicTo(120, 74, 130, 88, 128, 102)
      ..quadraticBezierTo(116, 118, 100, 118)
      ..quadraticBezierTo(84, 118, 72, 102)
      ..cubicTo(70, 88, 80, 74, 90, 60)
      ..close();
    canvas.drawPath(
        Path.combine(PathOperation.intersect, head, facePatch), _fill(cream));
    canvas.drawPath(head, _line(_catInk, 4.4));

    // Chin contact shadow onto the body.
    _soft(
        canvas,
        Path()
          ..addOval(Rect.fromCenter(
              center: const Offset(100, 123), width: 46, height: 9)),
        blur: 3.5,
        color: const Color(0x14000000));

    // Eyes.
    switch (mood) {
      case MoodState.sad:
        canvas.drawPath(
            Path()..moveTo(74, 88)..quadraticBezierTo(80, 83, 86, 88),
            _line(_catInk, 2.5));
        canvas.drawPath(
            Path()..moveTo(114, 88)..quadraticBezierTo(120, 83, 126, 88),
            _line(_catInk, 2.5));
      case MoodState.zoomies || MoodState.overloaded: // wide sparkly eyes
        for (final cx in [80.0, 120.0]) {
          canvas.drawOval(
              Rect.fromCenter(center: Offset(cx, 86), width: 13, height: 15),
              _fill(_catInk));
          canvas.drawCircle(Offset(cx + 2.4, 82.8), 2.2, _fill(Colors.white));
          canvas.drawCircle(Offset(cx - 2.2, 88.5), 1.2, _fill(Colors.white));
        }
      default:
        for (final cx in [80.0, 120.0]) {
          canvas.drawCircle(Offset(cx, 87), 5.0, _fill(_catInk));
          canvas.drawCircle(Offset(cx + 1.8, 85), 1.7, _fill(Colors.white));
        }
    }

    // Blush.
    for (final cx in [70.0, 130.0]) {
      final blushPath = Path()
        ..addOval(
            Rect.fromCenter(center: Offset(cx, 99), width: 11, height: 7));
      _soft(canvas, blushPath, blur: 2, color: const Color(0x55EE93A4));
    }

    // Muzzle — tiny pink nose, cusp mouth.
    final nose = Path()
      ..moveTo(95.5, 95.5)
      ..lineTo(104.5, 95.5)
      ..quadraticBezierTo(103.5, 100.5, 100, 101.8)
      ..quadraticBezierTo(96.5, 100.5, 95.5, 95.5)
      ..close();
    canvas.drawPath(nose, _fill(nosePink));
    canvas.drawPath(
        Path()..moveTo(100, 101.8)..quadraticBezierTo(96.5, 107.5, 92, 105.5),
        _line(_catInk, 1.7));
    canvas.drawPath(
        Path()..moveTo(100, 101.8)..quadraticBezierTo(103.5, 107.5, 108, 105.5),
        _line(_catInk, 1.7));

    // Whiskers — fine tapered ribbons.
    final wCol = _catInk.withAlpha(150);
    _whisker(canvas, const Offset(66, 94), const Offset(45, 90), wCol);
    _whisker(canvas, const Offset(66, 100), const Offset(46, 102), wCol);
    _whisker(canvas, const Offset(134, 94), const Offset(155, 90), wCol);
    _whisker(canvas, const Offset(134, 100), const Offset(154, 102), wCol);
  }

  @override
  bool shouldRepaint(NoodlesPainter old) => old.mood != mood;
}

// ── Loaf Cat — squishy cream cat with a scalloped golden bread-loaf hat ──────

class LoafCatPainter extends CustomPainter {
  const LoafCatPainter({this.mood = MoodState.neutral});

  final MoodState mood;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 220);
    const cream = Color(0xFFFDF6E8);
    const creamDark = Color(0xFFF1E2C4);
    const gold = Color(0xFFF0C355);
    const goldDark = Color(0xFFDCA436);
    const crustLine = Color(0xFFC08A2E);
    const orangePatch = Color(0xFFEBA84B);
    const grayPatch = Color(0xFFB4AEA6);
    const earPink = Color(0xFFE8B4A0);

    _groundShadow(canvas, const Offset(100, 210), 122);

    // Body — big squishy loaf sagging outward at the bottom.
    final body = Path()
      ..moveTo(38, 150)
      ..cubicTo(36, 118, 62, 100, 100, 98)
      ..cubicTo(138, 100, 164, 118, 162, 150)
      ..cubicTo(167, 176, 158, 197, 132, 202)
      ..quadraticBezierTo(100, 207, 68, 202)
      ..cubicTo(42, 197, 33, 176, 38, 150)
      ..close();
    canvas.drawPath(
        body, _grad(const Rect.fromLTRB(33, 98, 167, 207), cream, creamDark));
    canvas.drawPath(body, _line(_catInk, 4.4));

    // Tiny front paws peeking out.
    for (final cx in [80.0, 120.0]) {
      final paw = Rect.fromCenter(center: Offset(cx, 202), width: 23, height: 12);
      canvas.drawOval(paw, _fill(cream));
      canvas.drawOval(paw, _line(_catInk, 2.4));
    }

    // Ears — angled outward so they poke out from under the loaf sides.
    // Left ear orange-tinted, right ear gray-tinted.
    final earL = Path()
      ..moveTo(52, 82)
      ..cubicTo(42, 60, 42, 40, 50, 28)
      ..cubicTo(66, 38, 80, 52, 85, 66)
      ..close();
    final earR = Path()
      ..moveTo(148, 82)
      ..cubicTo(158, 60, 158, 40, 150, 28)
      ..cubicTo(134, 38, 120, 52, 115, 66)
      ..close();
    canvas.drawPath(earL, _fill(orangePatch));
    canvas.drawPath(earL, _line(_catInk, 3.2));
    canvas.drawPath(earR, _fill(grayPatch));
    canvas.drawPath(earR, _line(_catInk, 3.2));
    for (final (inner, flip) in [(const Offset(56, 50), 1.0), (const Offset(144, 50), -1.0)]) {
      final innerEar = Path()
        ..moveTo(inner.dx - 5 * flip, inner.dy + 12)
        ..quadraticBezierTo(
            inner.dx - 3 * flip, inner.dy - 5, inner.dx + 1 * flip, inner.dy - 8)
        ..quadraticBezierTo(
            inner.dx + 7 * flip, inner.dy, inner.dx + 10 * flip, inner.dy + 14)
        ..close();
      canvas.drawPath(innerEar, _fill(earPink));
    }

    // Head — chubby, cheeks bulging low, merges softly into the body.
    final head = Path()
      ..moveTo(54, 88)
      ..cubicTo(54, 58, 76, 44, 100, 44)
      ..cubicTo(124, 44, 146, 58, 146, 88)
      ..cubicTo(146, 110, 128, 124, 100, 124)
      ..cubicTo(72, 124, 54, 110, 54, 88)
      ..close();
    canvas.drawPath(
        head, _grad(const Rect.fromLTRB(54, 44, 146, 124), cream, creamDark));

    // Calico patches, clipped to the head so they follow its outline;
    // placed low on the sides so they stay visible below the loaf.
    final orangeBlob = Path()
      ..addOval(Rect.fromCenter(
          center: const Offset(57, 82), width: 42, height: 44));
    canvas.drawPath(Path.combine(PathOperation.intersect, head, orangeBlob),
        _fill(orangePatch.withAlpha(220)));
    final grayBlob = Path()
      ..addOval(Rect.fromCenter(
          center: const Offset(144, 80), width: 38, height: 40));
    canvas.drawPath(Path.combine(PathOperation.intersect, head, grayBlob),
        _fill(grayPatch.withAlpha(215)));
    canvas.drawPath(head, _line(_catInk, 4.4));

    // Bread loaf — golden dome sitting between the ears, scalloped crust.
    final loaf = Path()
      ..moveTo(56, 72)
      ..cubicTo(52, 42, 76, 24, 100, 23)
      ..cubicTo(124, 24, 148, 42, 144, 72)
      // scalloped bottom edge (right → left)
      ..quadraticBezierTo(134, 82, 120, 74)
      ..quadraticBezierTo(110, 83, 100, 75)
      ..quadraticBezierTo(90, 83, 80, 74)
      ..quadraticBezierTo(66, 82, 56, 72)
      ..close();
    // Contact shadow of the loaf onto the head.
    _soft(
        canvas,
        Path()
          ..addOval(Rect.fromCenter(
              center: const Offset(100, 78), width: 84, height: 13)),
        blur: 4,
        color: const Color(0x1A000000));
    canvas.drawPath(
        loaf, _grad(const Rect.fromLTRB(52, 23, 148, 84), gold, goldDark));
    // Crust highlight along the top-left.
    final crustHighlight = Path()
      ..moveTo(64, 50)
      ..cubicTo(66, 34, 82, 27, 98, 26.5)
      ..cubicTo(86, 30, 72, 40, 69, 54)
      ..close();
    canvas.drawPath(crustHighlight, _fill(const Color(0x59FBE3A0)));
    canvas.drawPath(loaf, _line(_catInk, 4.0));
    // Braided crust lines arcing up from the scallop cusps.
    for (final seg in [
      (const Offset(80, 74), const Offset(68, 46), const Offset(76, 30)),
      (const Offset(100, 75), const Offset(92, 44), const Offset(100, 26)),
      (const Offset(120, 74), const Offset(116, 46), const Offset(124, 30)),
    ]) {
      canvas.drawPath(
          Path()
            ..moveTo(seg.$1.dx, seg.$1.dy)
            ..quadraticBezierTo(seg.$2.dx, seg.$2.dy, seg.$3.dx, seg.$3.dy),
          _line(crustLine, 2.2));
    }

    // Eyes.
    switch (mood) {
      case MoodState.sad:
        canvas.drawPath(
            Path()..moveTo(72, 90)..quadraticBezierTo(80, 95, 88, 90),
            _line(_catInk, 2.6));
        canvas.drawPath(
            Path()..moveTo(112, 90)..quadraticBezierTo(120, 95, 128, 90),
            _line(_catInk, 2.6));
      case MoodState.grumpy || MoodState.overloaded:
        canvas.drawLine(
            const Offset(72, 93), const Offset(87, 87), _line(_catInk, 2.6));
        canvas.drawLine(
            const Offset(113, 87), const Offset(128, 93), _line(_catInk, 2.6));
      default: // content closed smile-eyes
        canvas.drawPath(
            Path()..moveTo(72, 91)..quadraticBezierTo(80, 83, 88, 91),
            _line(_catInk, 2.8));
        canvas.drawPath(
            Path()..moveTo(112, 91)..quadraticBezierTo(120, 83, 128, 91),
            _line(_catInk, 2.8));
    }

    // Nose + cusp mouth.
    final nose = Path()
      ..moveTo(96, 99)
      ..lineTo(104, 99)
      ..quadraticBezierTo(103, 103.5, 100, 104.5)
      ..quadraticBezierTo(97, 103.5, 96, 99)
      ..close();
    canvas.drawPath(nose, _fill(_catInk));
    canvas.drawPath(
        Path()..moveTo(100, 104.5)..quadraticBezierTo(95, 111, 89, 108),
        _line(_catInk, 1.8));
    canvas.drawPath(
        Path()..moveTo(100, 104.5)..quadraticBezierTo(105, 111, 111, 108),
        _line(_catInk, 1.8));

    // Whiskers.
    final wCol = _catInk.withAlpha(150);
    _whisker(canvas, const Offset(64, 96), const Offset(44, 93), wCol);
    _whisker(canvas, const Offset(64, 102), const Offset(45, 105), wCol);
    _whisker(canvas, const Offset(136, 96), const Offset(156, 93), wCol);
    _whisker(canvas, const Offset(136, 102), const Offset(155, 105), wCol);
  }

  @override
  bool shouldRepaint(LoafCatPainter old) => old.mood != mood;
}

// ── Robot Cat — soft blue plush-toy robot with inset chest panels ────────────

class RobotCatPainter extends CustomPainter {
  const RobotCatPainter({this.mood = MoodState.neutral});

  final MoodState mood;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 220);
    const blue = Color(0xFF4479B4);
    const blueLight = Color(0xFF5C90C8);
    const blueDark = Color(0xFF35619A);
    const panel = Color(0xFF2E5182);
    const heartRed = Color(0xFFE04848);

    _groundShadow(canvas, const Offset(100, 210), 108);

    // Legs — short rounded capsules with slightly darker feet.
    for (final lx in [68.0, 112.0]) {
      final leg = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(lx + 10, 196), width: 21, height: 26),
          const Radius.circular(9.5));
      canvas.drawRRect(leg, _fill(blue));
      canvas.drawRRect(leg, _line(_robotInk, 3.2));
      final foot = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(lx + 10, 204), width: 18, height: 8.5),
          const Radius.circular(4));
      canvas.drawRRect(foot, _fill(blueDark));
    }

    // Arms — raised tapered ribbons ending in rounded mitts.
    final armL = _taperedQuad(const Offset(64, 138), const Offset(38, 116),
        const Offset(34, 86), 16, 12);
    canvas.drawPath(armL, _fill(blue));
    canvas.drawPath(armL, _line(_robotInk, 3.2));
    canvas.drawCircle(const Offset(34, 84), 9, _fill(blueLight));
    canvas.drawCircle(const Offset(34, 84), 9, _line(_robotInk, 2.8));

    final armR = _taperedQuad(const Offset(136, 138), const Offset(162, 116),
        const Offset(166, 88), 16, 12);
    canvas.drawPath(armR, _fill(blue));
    canvas.drawPath(armR, _line(_robotInk, 3.2));
    // Maraca — green stick, red ball with yellow swirl stripes.
    canvas.drawLine(const Offset(167, 84), const Offset(172, 66),
        _line(const Color(0xFF4E9B62), 3.6));
    canvas.drawCircle(const Offset(174, 57), 11, _fill(heartRed));
    for (final sweep in [
      (const Offset(164.5, 54), const Offset(174, 47), const Offset(183.5, 54)),
      (const Offset(164.5, 61), const Offset(174, 68), const Offset(183.5, 61)),
    ]) {
      canvas.drawPath(
          Path()
            ..moveTo(sweep.$1.dx, sweep.$1.dy)
            ..quadraticBezierTo(sweep.$2.dx, sweep.$2.dy, sweep.$3.dx, sweep.$3.dy),
          _line(const Color(0xFFF2C24E), 3.4));
    }
    canvas.drawCircle(const Offset(174, 57), 11, _line(_robotInk, 2.6));
    canvas.drawCircle(const Offset(166, 88), 9, _fill(blueLight));
    canvas.drawCircle(const Offset(166, 88), 9, _line(_robotInk, 2.8));

    // Torso — soft rounded chassis with a gentle gradient.
    final torso = RRect.fromRectAndRadius(
        const Rect.fromLTRB(58, 116, 142, 196), const Radius.circular(22));
    canvas.drawRRect(
        torso,
        Paint()
          ..shader = ui.Gradient.linear(const Offset(100, 116),
              const Offset(100, 196), [blueLight, blueDark]));
    canvas.drawRRect(torso, _line(_robotInk, 4.2));

    // Inset panel grid (2 rows × 3 cols); heart in the bottom-middle cell.
    for (var row = 0; row < 2; row++) {
      for (var col = 0; col < 3; col++) {
        final r = Rect.fromLTWH(68.0 + col * 23, 130.0 + row * 27, 19, 22);
        final cell = RRect.fromRectAndRadius(r, const Radius.circular(5));
        canvas.drawRRect(cell, _fill(panel));
        // Inset depth: dark top-inner edge + light bottom-inner edge.
        canvas.drawLine(Offset(r.left + 3, r.top + 2.2),
            Offset(r.right - 3, r.top + 2.2), _line(const Color(0x66142948), 1.6));
        canvas.drawLine(
            Offset(r.left + 3, r.bottom - 1.8),
            Offset(r.right - 3, r.bottom - 1.8),
            _line(const Color(0x5578A8DC), 1.4));
        if (row == 1 && col == 1) {
          final heart = Path()
            ..moveTo(r.center.dx, r.center.dy + 5)
            ..cubicTo(r.center.dx - 7, r.center.dy - 1, r.center.dx - 4.5,
                r.center.dy - 6.5, r.center.dx, r.center.dy - 2.5)
            ..cubicTo(r.center.dx + 4.5, r.center.dy - 6.5, r.center.dx + 7,
                r.center.dy - 1, r.center.dx, r.center.dy + 5)
            ..close();
          canvas.drawPath(heart, _fill(heartRed));
        }
      }
    }

    // Ears — big rounded-tip triangles with darker inserts; head overlaps base.
    final earL = Path()
      ..moveTo(58, 56)
      ..cubicTo(51, 34, 53, 15, 60, 8)
      ..cubicTo(74, 17, 86, 33, 90, 48)
      ..close();
    final earR = Path()
      ..moveTo(142, 56)
      ..cubicTo(149, 34, 147, 15, 140, 8)
      ..cubicTo(126, 17, 114, 33, 110, 48)
      ..close();
    for (final ear in [earL, earR]) {
      canvas.drawPath(ear, _fill(blue));
      canvas.drawPath(ear, _line(_robotInk, 3.4));
    }
    canvas.drawPath(
        Path()
          ..moveTo(62, 46)
          ..cubicTo(58, 31, 60, 20, 63, 15)
          ..cubicTo(72, 22, 80, 34, 83, 44)
          ..close(),
        _fill(panel));
    canvas.drawPath(
        Path()
          ..moveTo(138, 46)
          ..cubicTo(142, 31, 140, 20, 137, 15)
          ..cubicTo(128, 22, 120, 34, 117, 44)
          ..close(),
        _fill(panel));

    // Neck contact shadow onto the torso.
    _soft(
        canvas,
        Path()
          ..addOval(Rect.fromCenter(
              center: const Offset(100, 118), width: 60, height: 10)),
        blur: 4,
        color: const Color(0x1F000000));

    // Head — soft rounded-square blob, wider than tall.
    final head = Path()
      ..moveTo(52, 84)
      ..cubicTo(50, 50, 72, 38, 100, 38)
      ..cubicTo(128, 38, 150, 50, 148, 84)
      ..cubicTo(148, 104, 133, 116, 100, 116)
      ..cubicTo(67, 116, 52, 104, 52, 84)
      ..close();
    canvas.drawPath(
        head, _grad(const Rect.fromLTRB(50, 38, 150, 116), blueLight, blue));
    canvas.drawPath(head, _line(_robotInk, 4.4));
    // Soft rim light along the top of the head.
    canvas.drawPath(
        Path()
          ..moveTo(68, 48)
          ..cubicTo(78, 42, 94, 40.5, 106, 41),
        _line(const Color(0x668FC0EE), 2.4));

    // Eyes — soft vertical ovals (glowing-display feel).
    switch (mood) {
      case MoodState.grumpy || MoodState.overloaded:
        canvas.drawPath(
            Path()..moveTo(72, 84)..quadraticBezierTo(80, 79, 88, 82),
            _line(_robotInk, 3.4));
        canvas.drawPath(
            Path()..moveTo(112, 82)..quadraticBezierTo(120, 79, 128, 84),
            _line(_robotInk, 3.4));
      case MoodState.sad:
        for (final cx in [80.0, 120.0]) {
          canvas.drawOval(
              Rect.fromCenter(center: Offset(cx, 83), width: 9, height: 11),
              _fill(_robotInk));
        }
        canvas.drawPath(
            Path()..moveTo(72, 71)..quadraticBezierTo(80, 76, 88, 71),
            _line(_robotInk, 1.9));
        canvas.drawPath(
            Path()..moveTo(112, 71)..quadraticBezierTo(120, 76, 128, 71),
            _line(_robotInk, 1.9));
      default:
        for (final cx in [80.0, 120.0]) {
          canvas.drawOval(
              Rect.fromCenter(center: Offset(cx, 81), width: 11, height: 14),
              _fill(_robotInk));
          canvas.drawCircle(Offset(cx + 2, 77.5), 1.8, _fill(Colors.white));
        }
    }

    // Nose + cusp smile.
    final nose = Path()
      ..moveTo(96.5, 92)
      ..lineTo(103.5, 92)
      ..quadraticBezierTo(102.5, 96, 100, 97)
      ..quadraticBezierTo(97.5, 96, 96.5, 92)
      ..close();
    canvas.drawPath(nose, _fill(_robotInk));
    canvas.drawPath(
        Path()..moveTo(100, 97)..quadraticBezierTo(95, 103.5, 89, 100.5),
        _line(_robotInk, 2.0));
    canvas.drawPath(
        Path()..moveTo(100, 97)..quadraticBezierTo(105, 103.5, 111, 100.5),
        _line(_robotInk, 2.0));
  }

  @override
  bool shouldRepaint(RobotCatPainter old) => old.mood != mood;
}

// ── Kalia — child with bulbous dark curls, floral dress, pink sleeves ────────

class KaliaPainter extends CustomPainter {
  const KaliaPainter();

  /// Kalia is taller than the cats: 200×260 viewBox.
  static const aspectRatio = 200 / 260;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 200, size.height / 260);
    const skin = Color(0xFFF0D2B2);
    const skinDark = Color(0xFFE5BE98);
    const hair = Color(0xFF3A2417);
    const hairDark = Color(0xFF2A1810);
    const dress = Color(0xFF43608A);
    const dressDark = Color(0xFF354E74);
    const sleevePink = Color(0xFFF5C9C4);
    const shoePink = Color(0xFFEE8E9A);

    _groundShadow(canvas, const Offset(100, 249), 90);

    // Legs — tapered tights, slightly asymmetric stance.
    final legL = _taperedQuad(const Offset(89, 196), const Offset(87, 216),
        const Offset(88, 238), 14, 10.5);
    final legR = _taperedQuad(const Offset(111, 196), const Offset(113, 216),
        const Offset(112, 238), 14, 10.5);
    for (final leg in [legL, legR]) {
      canvas.drawPath(leg, _fill(const Color(0xFF55505B)));
      canvas.drawPath(leg, _line(_kaliaInk, 2.4));
    }

    // Sneakers — rounded pink blobs with white soles and a lace hint.
    for (final (cx, flip) in [(85.0, -1.0), (115.0, 1.0)]) {
      final shoe = Path()
        ..moveTo(cx - 12 * flip, 236)
        ..quadraticBezierTo(cx - 15 * flip, 246, cx - 2 * flip, 247)
        ..lineTo(cx + 8 * flip, 247)
        ..quadraticBezierTo(cx + 12 * flip, 246, cx + 11 * flip, 238)
        ..quadraticBezierTo(cx, 234, cx - 12 * flip, 236)
        ..close();
      canvas.drawPath(shoe, _fill(shoePink));
      canvas.drawPath(shoe, _line(_kaliaInk, 2.4));
      canvas.drawLine(Offset(cx - 10 * flip, 244.5), Offset(cx + 9 * flip, 244.5),
          _line(Colors.white, 2.6));
    }

    // Dress — navy A-line with a softly curved hem.
    final dressPath = Path()
      ..moveTo(68, 134)
      ..quadraticBezierTo(100, 120, 132, 134)
      ..cubicTo(140, 158, 146, 180, 147, 197)
      ..quadraticBezierTo(124, 207, 100, 206)
      ..quadraticBezierTo(76, 207, 53, 197)
      ..cubicTo(54, 180, 60, 158, 68, 134)
      ..close();
    canvas.drawPath(dressPath,
        _grad(const Rect.fromLTRB(53, 120, 147, 207), dress, dressDark));
    // Skirt fold hints.
    for (final fx in [86.0, 114.0]) {
      canvas.drawPath(
          Path()
            ..moveTo(fx, 160)
            ..quadraticBezierTo(fx - 2, 180, fx - 1, 198),
          _line(const Color(0x33202E48), 2.0));
    }
    // Floral pattern — tiny 4-petal flowers + scattered dots.
    for (final (fx, fy) in [(82.0, 152.0), (116.0, 166.0), (95.0, 186.0)]) {
      for (final (dx, dy) in [(0.0, -3.0), (0.0, 3.0), (-3.0, 0.0), (3.0, 0.0)]) {
        canvas.drawCircle(
            Offset(fx + dx, fy + dy), 1.7, _fill(const Color(0xCCF5EFE2)));
      }
      canvas.drawCircle(Offset(fx, fy), 1.4, _fill(const Color(0xFFE8B4A0)));
    }
    for (final (dx, dy) in [
      (72.0, 168.0), (104.0, 148.0), (132.0, 152.0), (68.0, 190.0),
      (124.0, 184.0), (108.0, 198.0), (85.0, 170.0),
    ]) {
      canvas.drawCircle(Offset(dx, dy), 1.5, _fill(const Color(0xB3F5EFE2)));
    }
    canvas.drawPath(dressPath, _line(_kaliaInk, 3.6));

    // Sleeves — long pink arms curving down to small skin hands.
    final sleeveL = _taperedQuad(const Offset(72, 138), const Offset(58, 158),
        const Offset(59, 180), 14, 10);
    final sleeveR = _taperedQuad(const Offset(128, 138), const Offset(142, 158),
        const Offset(141, 180), 14, 10);
    for (final s in [sleeveL, sleeveR]) {
      canvas.drawPath(s, _fill(sleevePink));
      canvas.drawPath(s, _line(_kaliaInk, 2.6));
    }
    for (final hx in [59.0, 141.0]) {
      canvas.drawCircle(Offset(hx, 185), 6.5, _fill(skin));
      canvas.drawCircle(Offset(hx, 185), 6.5, _line(_kaliaInk, 2.2));
    }
    // Flutter-sleeve ruffles at the shoulders.
    for (final (sx, flip) in [(74.0, 1.0), (126.0, -1.0)]) {
      final ruffle = Path()
        ..moveTo(sx - 6 * flip, 140)
        ..quadraticBezierTo(sx - 10 * flip, 128, sx + 2 * flip, 126)
        ..quadraticBezierTo(sx + 10 * flip, 128, sx + 8 * flip, 138)
        ..quadraticBezierTo(sx, 143, sx - 6 * flip, 140)
        ..close();
      canvas.drawPath(ruffle, _fill(dress));
      canvas.drawPath(ruffle, _line(_kaliaInk, 2.4));
    }

    // Hair — back layer: union of overlapping bulbous curls, outlined once.
    var hairSil = Path();
    for (final (cx, cy, r) in [
      (100.0, 42.0, 27.0), (76.0, 36.0, 18.0), (124.0, 36.0, 18.0),
      (64.0, 50.0, 18.0), (136.0, 50.0, 18.0), (50.0, 72.0, 16.0),
      (150.0, 72.0, 16.0), (46.0, 96.0, 13.0), (154.0, 96.0, 13.0),
      (58.0, 112.0, 11.0), (142.0, 112.0, 11.0),
    ]) {
      hairSil = Path.combine(PathOperation.union, hairSil,
          Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r)));
    }
    canvas.drawPath(hairSil, _fill(hair));
    canvas.drawPath(hairSil, _line(hairDark, 3.4));
    // Curl depth: darker inner crescents.
    for (final (ax, ay, bx, by, cx2, cy2) in [
      (58.0, 70.0, 52.0, 84.0, 58.0, 96.0),
      (142.0, 70.0, 148.0, 84.0, 142.0, 96.0),
      (74.0, 44.0, 84.0, 36.0, 96.0, 36.0),
    ]) {
      canvas.drawPath(
          Path()
            ..moveTo(ax, ay)
            ..quadraticBezierTo(bx, by, cx2, cy2),
          _line(const Color(0x59201009), 3.0));
    }

    // Face — bottom-heavy with chubby cheeks and a soft chin.
    final face = Path()
      ..moveTo(62, 84)
      ..cubicTo(62, 60, 78, 50, 100, 50)
      ..cubicTo(122, 50, 138, 60, 138, 84)
      ..cubicTo(139, 104, 124, 117, 100, 117)
      ..cubicTo(76, 117, 61, 104, 62, 84)
      ..close();
    canvas.drawPath(
        face, _grad(const Rect.fromLTRB(61, 50, 139, 117), skin, skinDark));
    canvas.drawPath(face, _line(_kaliaInk, 3.0));
    // Chin/neck shadow onto the dress.
    _soft(
        canvas,
        Path()
          ..addOval(Rect.fromCenter(
              center: const Offset(100, 122), width: 36, height: 9)),
        blur: 3.5,
        color: const Color(0x17000000));

    // Bangs — scalloped fringe dipping to the brow, side curls over temples.
    final bangs = Path()
      ..moveTo(60, 82)
      ..cubicTo(60, 56, 78, 48, 100, 48)
      ..cubicTo(122, 48, 140, 56, 140, 82)
      ..quadraticBezierTo(133, 68, 123, 66)
      ..quadraticBezierTo(119, 72, 110, 70)
      ..quadraticBezierTo(106, 63, 100, 63)
      ..quadraticBezierTo(94, 63, 90, 70)
      ..quadraticBezierTo(81, 72, 77, 66)
      ..quadraticBezierTo(67, 68, 60, 82)
      ..close();
    canvas.drawPath(bangs, _fill(hair));
    for (final (cx, cy) in [(62.0, 84.0), (138.0, 84.0)]) {
      canvas.drawCircle(Offset(cx, cy), 9, _fill(hair));
    }

    // Eyes — brown irises with pupils and highlights.
    for (final cx in [84.0, 116.0]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 90), width: 11, height: 13),
          _fill(const Color(0xFF6B4423)));
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, 90), width: 11, height: 13),
          _line(_kaliaInk, 1.6));
      canvas.drawCircle(Offset(cx, 90.5), 3.0, _fill(const Color(0xFF241209)));
      canvas.drawCircle(Offset(cx + 2, 87.5), 1.6, _fill(Colors.white));
    }
    // Brows — faint soft arcs.
    canvas.drawPath(
        Path()..moveTo(78, 79)..quadraticBezierTo(84, 76.5, 90, 79),
        _line(const Color(0x803A2417), 1.8));
    canvas.drawPath(
        Path()..moveTo(110, 79)..quadraticBezierTo(116, 76.5, 122, 79),
        _line(const Color(0x803A2417), 1.8));

    // Blush.
    for (final cx in [72.0, 128.0]) {
      final blushPath = Path()
        ..addOval(
            Rect.fromCenter(center: Offset(cx, 101), width: 13, height: 8));
      _soft(canvas, blushPath, blur: 2, color: const Color(0x59F2A29B));
    }

    // Nose — tiny soft arc; mouth — small smile.
    canvas.drawPath(
        Path()..moveTo(98, 98)..quadraticBezierTo(100, 100.5, 102, 98),
        _line(const Color(0x66A87850), 1.6));
    canvas.drawPath(
        Path()..moveTo(92, 105)..quadraticBezierTo(100, 111, 108, 105),
        _line(_kaliaInk, 2.0));
  }

  @override
  bool shouldRepaint(KaliaPainter _) => false;
}
