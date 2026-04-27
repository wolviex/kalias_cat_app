// CustomPainter props for the watercolor storybook room.
// All painters use the 820×400 prototype's proportional coordinates.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'room_provider.dart';

// ── Design tokens ─────────────────────────────────────────────────────────────

const kInk = Color(0xFF3D2E23);
const kPaper = Color(0xFFFBF5EA);
const kPaper2 = Color(0xFFEEE1CB);
const kBlush = Color(0xFFE8B4A0);
const kSage = Color(0xFFA8C5A0);
const kButter = Color(0xFFF0D090);
const kLilac = Color(0xFFB8A5D0);
const kDusk = Color(0xFFD88A7A);
const kStream = Color(0xFF8FB8C7);

Color wallColorFor(RoomTimeOfDay tod) => switch (tod) {
      RoomTimeOfDay.morning => const Color(0xFFF0DCE8),
      RoomTimeOfDay.afternoon => const Color(0xFFE2D0E8),
      RoomTimeOfDay.dusk => const Color(0xFFD0A8B8),
      RoomTimeOfDay.night => const Color(0xFF453850),
    };

(Color, Color) floorColorsFor(RoomTimeOfDay tod) => switch (tod) {
      RoomTimeOfDay.morning =>
        (const Color(0xFFE8C89A), const Color(0xFFD8A878)),
      RoomTimeOfDay.afternoon =>
        (const Color(0xFFE8C89A), const Color(0xFFC89860)),
      RoomTimeOfDay.dusk =>
        (const Color(0xFFC89868), const Color(0xFFA06838)),
      RoomTimeOfDay.night =>
        (const Color(0xFF3D3238), const Color(0xFF2A2028)),
    };

Color overlayColorFor(RoomTimeOfDay tod) => switch (tod) {
      RoomTimeOfDay.morning => const Color(0x0AFFDC00),
      RoomTimeOfDay.afternoon => Colors.transparent,
      RoomTimeOfDay.dusk => const Color(0x24E68C5A),
      RoomTimeOfDay.night => const Color(0x40323C78),
    };

// ── RoomBackdropPainter ───────────────────────────────────────────────────────
// Wall (top 66%) with paw-print wallpaper + wood floor (bottom 34%) + baseboard.

class RoomBackdropPainter extends CustomPainter {
  final RoomTimeOfDay timeOfDay;

  const RoomBackdropPainter(this.timeOfDay);

  @override
  void paint(Canvas canvas, Size size) {
    final isNight = timeOfDay == RoomTimeOfDay.night;
    final wallH = size.height * 0.66;
    final (floorTop, floorBot) = floorColorsFor(timeOfDay);

    // Wall
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, wallH),
      Paint()..color = wallColorFor(timeOfDay),
    );

    // Paw-print wallpaper
    _drawPaws(canvas, size, wallH, isNight);

    // Floor gradient
    final floorRect =
        Rect.fromLTWH(0, wallH, size.width, size.height - wallH);
    canvas.drawRect(
      floorRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [floorTop, floorBot],
        ).createShader(floorRect),
    );

    // Floor plank lines
    _drawPlanks(canvas, size, wallH);

    // Baseboard
    canvas.drawRect(
      Rect.fromLTWH(0, wallH - 4, size.width, 8),
      Paint()..color = kPaper.withAlpha(229),
    );
  }

  void _drawPaws(
      Canvas canvas, Size size, double wallH, bool isNight) {
    final scale = size.width / 820;
    final pW = 70.0 * scale;
    final pH = 70.0 * scale;
    final pawColor = isNight
        ? const Color(0xFF6A5A78).withAlpha(51)
        : const Color(0xFFD0BEDC).withAlpha(89);
    final paint = Paint()..color = pawColor;

    final cols = (size.width / pW).ceil() + 1;
    final rows = (wallH / pH).ceil() + 1;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        _drawOnePaw(canvas, paint, c * pW, r * pH, scale);
      }
    }
  }

  void _drawOnePaw(
      Canvas canvas, Paint p, double ox, double oy, double s) {
    canvas.drawCircle(Offset(ox + 20 * s, oy + 22 * s), 4 * s, p);
    canvas.drawCircle(Offset(ox + 12 * s, oy + 14 * s), 2 * s, p);
    canvas.drawCircle(Offset(ox + 28 * s, oy + 14 * s), 2 * s, p);
    canvas.drawCircle(Offset(ox + 10 * s, oy + 26 * s), 2 * s, p);
    canvas.drawCircle(Offset(ox + 30 * s, oy + 26 * s), 2 * s, p);
  }

  void _drawPlanks(Canvas canvas, Size size, double floorY) {
    final vp = Paint()
      ..color = const Color(0xFF7A4820).withAlpha(89)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (final xPct in [0.0, 25.0, 50.0, 75.0, 100.0]) {
      final x1 = size.width * xPct / 100;
      final x2 = x1 - size.width * 0.08;
      canvas.drawLine(Offset(x1, floorY), Offset(x2, size.height), vp);
    }
    final hp = Paint()
      ..color = const Color(0xFF7A4820).withAlpha(54)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (final yPct in [22.0, 55.0]) {
      final y1 = floorY + (size.height - floorY) * yPct / 100;
      final y2 = floorY + (size.height - floorY) * (yPct + 2) / 100;
      canvas.drawLine(Offset(0, y1), Offset(size.width, y2), hp);
    }
  }

  @override
  bool shouldRepaint(RoomBackdropPainter old) =>
      old.timeOfDay != timeOfDay;
}

// ── WindowPainter ─────────────────────────────────────────────────────────────

class WindowPainter extends CustomPainter {
  final RoomTimeOfDay timeOfDay;

  const WindowPainter(this.timeOfDay);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final isNight = timeOfDay == RoomTimeOfDay.night;

    final (skyTop, skyBot) = switch (timeOfDay) {
      RoomTimeOfDay.morning =>
        (const Color(0xFFFCE4BA), const Color(0xFFF4B88A)),
      RoomTimeOfDay.afternoon =>
        (const Color(0xFFBCDFF2), const Color(0xFFE8D5B0)),
      RoomTimeOfDay.dusk =>
        (const Color(0xFFE8A878), const Color(0xFFD88A7A)),
      RoomTimeOfDay.night =>
        (const Color(0xFF2A3450), const Color(0xFF5D5070)),
    };

    // Frame bounds — leave room for curtains + rod
    final fL = w * 0.17, fT = h * 0.08, fR = w * 0.83, fB = h * 0.88;
    final skyRect = Rect.fromLTRB(fL, fT, fR, fB);

    // Sky gradient
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [skyTop, skyBot],
        ).createShader(skyRect),
    );

    // Sun or moon
    final sunX = switch (timeOfDay) {
      RoomTimeOfDay.morning => w * 0.34,
      RoomTimeOfDay.dusk => w * 0.72,
      _ => w * 0.68,
    };
    canvas.drawCircle(
      Offset(sunX, h * 0.30),
      w * 0.066,
      Paint()
        ..color = isNight
            ? const Color(0xFFFBF5EA)
            : const Color(0xFFFFE89C),
    );

    // Clouds (day only)
    if (!isNight) {
      final cp = Paint()..color = Colors.white.withAlpha(230);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * 0.36, h * 0.27),
              width: w * 0.15,
              height: h * 0.09),
          cp);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * 0.54, h * 0.40),
              width: w * 0.17,
              height: h * 0.08),
          cp);
    }

    // Rolling hills
    final hillC =
        isNight ? const Color(0xFF3D3050) : const Color(0xFF7BA078);
    final hp = Path()
      ..moveTo(fL, fB)
      ..lineTo(fL, h * 0.68)
      ..quadraticBezierTo(w * 0.50, h * 0.52, fR, h * 0.68)
      ..lineTo(fR, fB)
      ..close();
    canvas.drawPath(hp, Paint()..color = hillC);
    final tc =
        isNight ? const Color(0xFF2A2240) : const Color(0xFF7BA078);
    canvas.drawCircle(Offset(w * 0.32, h * 0.58), w * 0.068,
        Paint()..color = tc);
    canvas.drawCircle(Offset(w * 0.68, h * 0.54), w * 0.080,
        Paint()..color = tc);

    // Window frame + mullion cross
    final fp = Paint()
      ..color = const Color(0xFFE8D5B0)
      ..strokeWidth = w * 0.033
      ..style = PaintingStyle.stroke;
    canvas.drawRect(skyRect, fp);
    canvas.drawLine(Offset(w * 0.50, fT), Offset(w * 0.50, fB), fp);
    canvas.drawLine(Offset(fL, h * 0.50), Offset(fR, h * 0.50), fp);

    // Curtains
    final curtainFill = Paint()..color = const Color(0xFFF5C0CC);
    final curtainStroke = Paint()
      ..color = kInk
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final lc = Path()
      ..moveTo(fL, fT)
      ..quadraticBezierTo(w * 0.10, h * 0.50, w * 0.16, fB)
      ..lineTo(w * 0.05, fB)
      ..quadraticBezierTo(w * 0.03, h * 0.50, w * 0.08, fT)
      ..close();
    canvas.drawPath(lc, curtainFill);
    canvas.drawPath(lc, curtainStroke);

    final rc = Path()
      ..moveTo(fR, fT)
      ..quadraticBezierTo(w * 0.90, h * 0.50, w * 0.84, fB)
      ..lineTo(w * 0.95, fB)
      ..quadraticBezierTo(w * 0.97, h * 0.50, w * 0.92, fT)
      ..close();
    canvas.drawPath(rc, curtainFill);
    canvas.drawPath(rc, curtainStroke);

    // Curtain rod
    const rodColor = Color(0xFFB88858);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(0, fT - h * 0.042, w, h * 0.042),
          const Radius.circular(4)),
      Paint()..color = rodColor,
    );
    canvas.drawCircle(
        Offset(w * 0.04, fT - h * 0.021), w * 0.028, Paint()..color = rodColor);
    canvas.drawCircle(
        Offset(w * 0.96, fT - h * 0.021), w * 0.028, Paint()..color = rodColor);

    // Curtain ties
    const tieColor = Color(0xFFD8A0B0);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.17, h * 0.55),
            width: w * 0.09,
            height: h * 0.08),
        Paint()..color = tieColor);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.83, h * 0.55),
            width: w * 0.09,
            height: h * 0.08),
        Paint()..color = tieColor);
  }

  @override
  bool shouldRepaint(WindowPainter old) => old.timeOfDay != timeOfDay;
}

// ── MoodChartPainter ──────────────────────────────────────────────────────────

class MoodChartPainter extends CustomPainter {
  const MoodChartPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Card
    final rrect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, w, h), const Radius.circular(6));
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFFBF5EA));
    canvas.drawRRect(
        rrect,
        Paint()
          ..color = const Color(0xFFB88858)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke);

    // 6 mood faces: 3 cols × 2 rows
    const faceColors = [
      Color(0xFFF0D090), // happy
      Color(0xFF8FB8C7), // sad
      Color(0xFFE87E8A), // mad
      Color(0xFFB8A5D0), // shy
      Color(0xFF7BC4A8), // calm
      Color(0xFFE8B4A0), // ok
    ];
    final cellW = (w - 16) / 3;
    final cellH = (h - 22) / 2;
    final r = math.min(cellW, cellH) * 0.36;

    for (var i = 0; i < 6; i++) {
      final cx = 8 + cellW * (i % 3) + cellW / 2;
      final cy = 20 + cellH * (i ~/ 3) + cellH / 2;

      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = faceColors[i]);
      canvas.drawCircle(
          Offset(cx, cy),
          r,
          Paint()
            ..color = kInk
            ..strokeWidth = 1.4
            ..style = PaintingStyle.stroke);
      canvas.drawCircle(
          Offset(cx - r * 0.28, cy - r * 0.15), r * 0.11, Paint()..color = kInk);
      canvas.drawCircle(
          Offset(cx + r * 0.28, cy - r * 0.15), r * 0.11, Paint()..color = kInk);

      final sp = Path()
        ..moveTo(cx - r * 0.32, cy + r * 0.22)
        ..quadraticBezierTo(cx, cy + r * 0.48, cx + r * 0.32, cy + r * 0.22);
      canvas.drawPath(
          sp,
          Paint()
            ..color = kInk
            ..strokeWidth = 0.9
            ..style = PaintingStyle.stroke);
    }
  }

  @override
  bool shouldRepaint(MoodChartPainter _) => false;
}

// ── PlantPainter ──────────────────────────────────────────────────────────────
// Rendered with Transform.rotate wrapping the CustomPaint for the sway.

class PlantPainter extends CustomPainter {
  const PlantPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final ls = Paint()
      ..color = kInk
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Left leaf
    final l1 = Path()
      ..moveTo(w * 0.50, h * 0.78)
      ..quadraticBezierTo(w * 0.16, h * 0.44, w * 0.12, h * 0.12)
      ..quadraticBezierTo(w * 0.36, h * 0.42, w * 0.46, h * 0.74);
    canvas.drawPath(l1, Paint()..color = const Color(0xFF7BA078));
    canvas.drawPath(l1, ls);

    // Right leaf
    final l2 = Path()
      ..moveTo(w * 0.50, h * 0.78)
      ..quadraticBezierTo(w * 0.84, h * 0.42, w * 0.88, h * 0.10)
      ..quadraticBezierTo(w * 0.64, h * 0.40, w * 0.54, h * 0.74);
    canvas.drawPath(l2, Paint()..color = const Color(0xFFA8C5A0));
    canvas.drawPath(l2, ls);

    // Centre leaf
    final l3 = Path()
      ..moveTo(w * 0.50, h * 0.78)
      ..quadraticBezierTo(w * 0.52, h * 0.44, w * 0.52, h * 0.06)
      ..quadraticBezierTo(w * 0.56, h * 0.40, w * 0.54, h * 0.74);
    canvas.drawPath(l3, Paint()..color = const Color(0xFF7BA078));
    canvas.drawPath(l3, ls);

    // Pot
    final potPath = Path()
      ..moveTo(w * 0.22, h * 0.78)
      ..lineTo(w * 0.78, h * 0.78)
      ..lineTo(w * 0.70, h * 0.98)
      ..lineTo(w * 0.30, h * 0.98)
      ..close();
    canvas.drawPath(potPath, Paint()..color = kLilac);
    canvas.drawPath(
        potPath,
        Paint()
          ..color = kInk
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.5, h * 0.78),
            width: w * 0.56,
            height: h * 0.07),
        Paint()..color = const Color(0xFFD0BEE0));
  }

  @override
  bool shouldRepaint(PlantPainter _) => false;
}

// ── RugPainter ────────────────────────────────────────────────────────────────

class RugPainter extends CustomPainter {
  const RugPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, cy),
            width: size.width * 0.98,
            height: size.height * 0.90),
        Paint()..color = const Color(0xFFC8B5D8));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(cx, cy),
            width: size.width * 0.88,
            height: size.height * 0.72),
        Paint()..color = const Color(0xFFFBF0E2));
  }

  @override
  bool shouldRepaint(RugPainter _) => false;
}

// ── YarnBasketPainter ─────────────────────────────────────────────────────────

class YarnBasketPainter extends CustomPainter {
  const YarnBasketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Cat bed (left side) — purple with two ear humps
    final bedPath = Path()
      ..moveTo(w * 0.24, h * 0.44)
      ..lineTo(w * 0.20, h * 0.26) // left ear
      ..lineTo(w * 0.34, h * 0.38)
      ..quadraticBezierTo(w * 0.48, h * 0.30, w * 0.60, h * 0.38)
      ..lineTo(w * 0.58, h * 0.24) // right ear
      ..lineTo(w * 0.66, h * 0.42)
      ..quadraticBezierTo(w * 0.72, h * 0.52, w * 0.66, h * 0.70)
      ..quadraticBezierTo(w * 0.48, h * 0.82, w * 0.26, h * 0.70)
      ..quadraticBezierTo(w * 0.18, h * 0.56, w * 0.24, h * 0.44)
      ..close();
    canvas.drawPath(bedPath, Paint()..color = kLilac);
    canvas.drawPath(
        bedPath,
        Paint()
          ..color = kInk
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
    // Darker cushion
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.43, h * 0.58),
            width: w * 0.34,
            height: h * 0.26),
        Paint()..color = const Color(0xFF8B7AAE));
    // Light pillow
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.43, h * 0.58),
            width: w * 0.22,
            height: h * 0.16),
        Paint()..color = const Color(0xFFD0C0E0));

    // Basket body (right side)
    final bx = w * 0.80, by = h * 0.72;
    final bPaint = Paint()..color = const Color(0xFFB88858);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(bx, by), width: w * 0.38, height: h * 0.38),
        bPaint);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(bx, by), width: w * 0.38, height: h * 0.38),
        Paint()
          ..color = kInk
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);
    // Weave lines
    final wv = Paint()
      ..color = const Color(0xFF8B5E3C)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(bx, by - h * 0.04),
            width: w * 0.36,
            height: h * 0.06),
        wv);
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(bx, by + h * 0.04),
            width: w * 0.38,
            height: h * 0.06),
        wv);

    // Yarn balls in basket
    const balls = [
      (0.74, 0.56, Color(0xFFE87E8A)),
      (0.82, 0.53, Color(0xFFF0D090)),
      (0.88, 0.58, Color(0xFF7BC4A8)),
      (0.76, 0.64, Color(0xFF8A9BD8)),
      (0.85, 0.67, Color(0xFFB8A5D0)),
    ];
    for (final (bxp, byp, bc) in balls) {
      canvas.drawCircle(
          Offset(w * bxp, h * byp), w * 0.055, Paint()..color = bc);
      canvas.drawCircle(
          Offset(w * bxp, h * byp),
          w * 0.055,
          Paint()
            ..color = kInk
            ..strokeWidth = 1.5
            ..style = PaintingStyle.stroke);
    }

    // Loose yarn ball
    canvas.drawCircle(
        Offset(w * 0.60, h * 0.82), w * 0.05,
        Paint()..color = const Color(0xFFF0B270));
    canvas.drawCircle(
        Offset(w * 0.60, h * 0.82),
        w * 0.05,
        Paint()
          ..color = kInk
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);

    // Mouse toy
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.47, h * 0.90),
            width: w * 0.09,
            height: h * 0.07),
        Paint()..color = const Color(0xFF8A8090));
    canvas.drawOval(
        Rect.fromCenter(
            center: Offset(w * 0.47, h * 0.90),
            width: w * 0.09,
            height: h * 0.07),
        Paint()
          ..color = kInk
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke);
    // Mouse tail
    final tail = Path()
      ..moveTo(w * 0.52, h * 0.90)
      ..quadraticBezierTo(w * 0.60, h * 0.93, w * 0.62, h * 0.97);
    canvas.drawPath(
        tail,
        Paint()
          ..color = const Color(0xFFE87E8A)
          ..strokeWidth = 1.3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(YarnBasketPainter _) => false;
}

// ── MagicalTrunkPainter ───────────────────────────────────────────────────────

class MagicalTrunkPainter extends CustomPainter {
  final bool pending;

  const MagicalTrunkPainter({required this.pending});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Body
    final bodyRRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.48, w * 0.76, h * 0.48),
        const Radius.circular(4));
    canvas.drawRRect(bodyRRect, Paint()..color = const Color(0xFF8B5E3C));
    canvas.drawRRect(
        bodyRRect,
        Paint()
          ..color = kInk
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    // Domed lid
    final lid = Path()
      ..moveTo(w * 0.12, h * 0.48)
      ..quadraticBezierTo(w * 0.12, h * 0.20, w * 0.50, h * 0.20)
      ..quadraticBezierTo(w * 0.88, h * 0.20, w * 0.88, h * 0.48)
      ..close();
    canvas.drawPath(lid, Paint()..color = const Color(0xFFA87048));
    canvas.drawPath(
        lid,
        Paint()
          ..color = kInk
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke);

    // Gold bands
    final bandStroke = Paint()
      ..color = kInk
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (final bx in [w * 0.20, w * 0.75]) {
      canvas.drawRect(
          Rect.fromLTWH(bx, h * 0.20, w * 0.05, h * 0.76),
          Paint()..color = kButter);
      canvas.drawRect(
          Rect.fromLTWH(bx, h * 0.20, w * 0.05, h * 0.76), bandStroke);
    }

    // Lock plate
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(
                center: Offset(w * 0.5, h * 0.60),
                width: w * 0.10,
                height: h * 0.16),
            const Radius.circular(2)),
        Paint()..color = kButter);
    canvas.drawCircle(
        Offset(w * 0.5, h * 0.58), w * 0.02, Paint()..color = kInk);

    // Sparkles when pending
    if (pending) {
      final sp = Paint()..color = kButter.withAlpha(200);
      canvas.drawCircle(Offset(w * 0.22, h * 0.12), 2.5, sp);
      canvas.drawCircle(Offset(w * 0.80, h * 0.10), 2.0, sp);
      canvas.drawCircle(Offset(w * 0.50, h * 0.06), 2.5, sp);
    }
  }

  @override
  bool shouldRepaint(MagicalTrunkPainter old) => old.pending != pending;
}
