import 'package:block_blast/core/theme/gem_theme.dart';
import 'package:block_blast/shared/widgets/gem_primary_button.dart';
import 'package:block_blast/shared/widgets/level_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(child: SizedBox(width: 320, child: child)),
      ),
    ),
  );
}

void main() {
  group('GemPrimaryButton', () {
    final amethyst = GemTheme.forGem('amethyst');

    testWidgets('is at least 56dp high and uses the gem button colours', (
      tester,
    ) async {
      var taps = 0;
      await _pump(
        tester,
        GemPrimaryButton(
          key: const Key('btn'),
          label: 'PLAY',
          icon: Icons.play_arrow,
          palette: amethyst,
          onPressed: () => taps++,
        ),
      );
      expect(
        tester.getSize(find.byKey(const Key('btn'))).height,
        greaterThanOrEqualTo(56),
      );
      final button = tester.widget<ButtonStyleButton>(
        find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(
        button.style!.backgroundColor!.resolve(<WidgetState>{}),
        const Color(0xFF7A4FB0),
      );
      expect(
        tester.widget<Text>(find.text('PLAY')).style!.color,
        amethyst.onPrimary,
      );
      await tester.tap(find.byKey(const Key('btn')));
      expect(taps, 1);
    });

    testWidgets('a long label like CONTINUE stays on one line in 220dp', (
      tester,
    ) async {
      await _pump(
        tester,
        GemPrimaryButton(
          key: const Key('btn'),
          label: 'CONTINUE',
          icon: Icons.arrow_forward,
          palette: GemTheme.forGem('amethyst'),
          onPressed: () {},
        ),
      );
      final text = tester.widget<Text>(find.text('CONTINUE'));
      expect(text.maxLines, 1);
      expect(text.softWrap, isFalse);
      // Một dòng chữ title (20) cao dưới 40dp; hai dòng sẽ cao hơn.
      expect(tester.getSize(find.text('CONTINUE')).height, lessThan(40));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a height below 56 is raised to 56, and works without icon', (
      tester,
    ) async {
      await _pump(
        tester,
        GemPrimaryButton(
          key: const Key('btn'),
          label: 'GO',
          palette: GemTheme.forGem('ruby'),
          height: 30,
          onPressed: () {},
        ),
      );
      expect(
        tester.getSize(find.byKey(const Key('btn'))).height,
        greaterThanOrEqualTo(56),
      );
      expect(find.byType(Icon), findsNothing);
    });
  });

  group('LevelProgressBar (design-system-mapping)', () {
    testWidgets('fills with the gem primary, white border and % label', (
      tester,
    ) async {
      final sapphire = GemTheme.forGem('sapphire');
      await _pump(tester, LevelProgressBar(percent: 67, palette: sapphire));
      final bar = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('game-progress-bar')),
      );
      expect(bar.value, closeTo(0.67, 1e-9));
      expect(bar.color, sapphire.primary);
      expect(bar.backgroundColor, LevelProgressBar.track);
      final border = tester.widget<DecoratedBox>(
        find.byKey(const Key('game-progress-border')),
      );
      final box = border.decoration as BoxDecoration;
      expect(box.border!.top.color, Colors.white);
      expect(box.border!.top.width, LevelProgressBar.borderWidth);
      expect(find.text('67%'), findsOneWidget);
    });

    testWidgets('clamps the bar between 0 and 1', (tester) async {
      await _pump(
        tester,
        LevelProgressBar(percent: 140, palette: GemTheme.forGem('ruby')),
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('game-progress-bar')),
      );
      expect(bar.value, 1);
    });
  });
}
