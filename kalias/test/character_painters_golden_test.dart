// Renders the painted characters to golden PNGs for visual review.
// Regenerate with: flutter test --update-goldens test/character_painters_golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kalias/core/models/cat_state.dart';
import 'package:kalias/features/room/room_painters.dart';
import 'package:kalias/shared/widgets/character_painters.dart';

Widget _stage(List<Widget> children) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Container(
      color: const Color(0xFFE2D0E8),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final c in children) SizedBox(width: 150, child: c),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('all four characters, neutral/happy', (tester) async {
    await tester.binding.setSurfaceSize(const Size(820, 400));
    tester.view.physicalSize = const Size(820, 400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_stage([
      const PaintedCharacter(painter: NoodlesPainter(mood: MoodState.happy)),
      const PaintedCharacter(painter: LoafCatPainter(mood: MoodState.happy)),
      const PaintedCharacter(
        painter: KaliaPainter(),
        aspectRatio: KaliaPainter.aspectRatio,
      ),
      const PaintedCharacter(painter: RobotCatPainter(mood: MoodState.happy)),
    ]));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/characters_happy.png'),
    );
  });

  testWidgets('mood variants: zoomies / grumpy / sad', (tester) async {
    await tester.binding.setSurfaceSize(const Size(820, 400));
    tester.view.physicalSize = const Size(820, 400);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(_stage([
      const PaintedCharacter(painter: NoodlesPainter(mood: MoodState.zoomies)),
      const PaintedCharacter(painter: LoafCatPainter(mood: MoodState.grumpy)),
      const PaintedCharacter(painter: LoafCatPainter(mood: MoodState.sad)),
      const PaintedCharacter(painter: RobotCatPainter(mood: MoodState.grumpy)),
      const PaintedCharacter(painter: RobotCatPainter(mood: MoodState.sad)),
    ]));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/characters_moods.png'),
    );
  });

  testWidgets('care-sheet portraits — head framed in tinted circle',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 120));
    tester.view.physicalSize = const Size(400, 120);
    tester.view.devicePixelRatio = 1.0;

    Widget circle(String id, Color tint, MoodState mood) => Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
          child: CharacterPortrait(id: id, mood: mood),
        );

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        color: const Color(0xFFFBF5EA),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            circle('noodles', const Color(0xFFF0B278), MoodState.happy),
            circle('loafCat', const Color(0xFFE8D5B0), MoodState.grumpy),
            circle('kalia', const Color(0xFFF0D090), MoodState.neutral),
            circle('robotCat', const Color(0xFFC8B8DC), MoodState.happy),
          ],
        ),
      ),
    ));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/portraits.png'),
    );
  });

  testWidgets('mood-chart poster fills its slot (A6 fix)', (tester) async {
    await tester.binding.setSurfaceSize(const Size(200, 220));
    tester.view.physicalSize = const Size(200, 220);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ColoredBox(
        color: Color(0xFFE2D0E8),
        child: Center(
          child: SizedBox(
            width: 130,
            height: 110,
            child: CustomPaint(painter: MoodChartPainter()),
          ),
        ),
      ),
    ));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/mood_chart_poster.png'),
    );
  });
}
