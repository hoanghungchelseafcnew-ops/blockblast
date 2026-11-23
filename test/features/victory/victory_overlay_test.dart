import 'dart:async';

import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/victory/models/victory_variant.dart';
import 'package:block_blast/features/victory/widgets/confetti_layer.dart';
import 'package:block_blast/features/victory/widgets/victory_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';

final _catalog = LevelCatalog.from(DefaultLevelConfig.config);

Future<void> _pump(
  WidgetTester tester, {
  required VictoryVariant variant,
  required Level level,
  VoidCallback? onContinue,
  VoidCallback? onBackToMenu,
  Future<void> Function()? onShare,
  bool reducedMotion = false,
}) async {
  tester.view.physicalSize = const Size(400, 860);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(400, 860),
          disableAnimations: reducedMotion,
        ),
        child: Scaffold(
          body: VictoryOverlay(
            variant: variant,
            level: level,
            score: 4350,
            target: 4200,
            best: 4350,
            onContinue: onContinue,
            onBackToMenu: onBackToMenu,
            onShare: onShare,
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _finish(WidgetTester tester) =>
    tester.pump(const Duration(seconds: 3));

void main() {
  setUp(() => LogCapture().start());

  testWidgets('W-4 sub-level: texts, BEST, focused CONTINUE >= 48dp '
      '(AC3.1.1, AC3.1.3, AC3.4.2)', (tester) async {
    await _pump(
      tester,
      variant: VictoryVariant.sub,
      level: _catalog.byIndex(9),
      onContinue: () {},
    );
    expect(find.text('Level Complete!'), findsOneWidget);
    expect(find.text('Congratulations! Shaping Completed!'), findsOneWidget);
    expect(find.text('4350 / 4200 · BEST 4350'), findsOneWidget);
    expect(find.byKey(const Key('victory-image')), findsOneWidget);
    final button = find.byKey(const Key('victory-continue-button'));
    expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    final elevated = tester.widget<ButtonStyleButton>(
      find.descendant(
        of: button,
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      ),
    );
    expect(elevated.autofocus, isTrue);
    expect(find.byKey(const Key('victory-unlock-text')), findsNothing);
    expect(find.byKey(const Key('confetti-layer')), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('W-5 gem unlock: unlock text and 2D gem animation (AC3.2.1, '
      'AC3.2.3)', (tester) async {
    await _pump(
      tester,
      variant: VictoryVariant.gemUnlock,
      level: _catalog.byIndex(12),
      onContinue: () {},
    );
    expect(find.text('🎉 Amethyst Unlocked!'), findsOneWidget);
    expect(find.byKey(const Key('gem-unlock-icon')), findsOneWidget);
    expect(find.text('Level Complete!'), findsOneWidget);
    expect(find.byKey(const Key('victory-continue-button')), findsOneWidget);
    await _finish(tester);
  });

  testWidgets('W-5a journey complete: BACK TO MENU only, no CONTINUE '
      '(AC3.3.1, AC3.3.2)', (tester) async {
    var menu = 0;
    await _pump(
      tester,
      variant: VictoryVariant.journeyComplete,
      level: _catalog.byIndex(36),
      onBackToMenu: () => menu++,
    );
    expect(find.text('JOURNEY COMPLETE!'), findsOneWidget);
    expect(find.text('🎉 Ruby Unlocked!'), findsOneWidget);
    expect(find.text('You have collected all 6 gems'), findsOneWidget);
    expect(find.byKey(const Key('victory-gems-row')), findsOneWidget);
    expect(find.byIcon(Icons.diamond), findsNWidgets(6));
    expect(find.byKey(const Key('victory-continue-button')), findsNothing);
    await _finish(tester);
    await tester.tap(find.byKey(const Key('victory-menu-button')));
    expect(menu, 1);
  });

  testWidgets('CONTINUE only reacts to the first tap (interaction-spec)', (
    tester,
  ) async {
    var taps = 0;
    await _pump(
      tester,
      variant: VictoryVariant.sub,
      level: _catalog.byIndex(2),
      onContinue: () => taps++,
    );
    final button = find.byKey(const Key('victory-continue-button'));
    await tester.tap(button);
    await tester.pump();
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();
    expect(taps, 1);
    expect(
      find.byType(ConfettiLayer),
      findsNothing,
      reason: 'confetti stops when leaving',
    );
    await _finish(tester);
  });

  testWidgets('reduced motion drops the confetti but keeps every text', (
    tester,
  ) async {
    await _pump(
      tester,
      variant: VictoryVariant.gemUnlock,
      level: _catalog.byIndex(6),
      onContinue: () {},
      reducedMotion: true,
    );
    expect(find.byType(ConfettiLayer), findsNothing);
    expect(find.text('🎉 Rose Quartz Unlocked!'), findsOneWidget);
    expect(find.text('Level Complete!'), findsOneWidget);
    await _finish(tester);
  });

  group('SHARE (FR3, US3.1-US3.4)', () {
    const share = Key('victory-share-button');

    for (final (variant, index) in [
      (VictoryVariant.sub, 9),
      (VictoryVariant.gemUnlock, 12),
      (VictoryVariant.journeyComplete, 36),
    ]) {
      testWidgets('${variant.name}: SHARE is shown, >= 48dp, and calls '
          'onShare (AC3.1.1, AC3.2.1, AC3.3.1)', (tester) async {
        var calls = 0;
        await _pump(
          tester,
          variant: variant,
          level: _catalog.byIndex(index),
          onContinue: () {},
          onBackToMenu: () {},
          onShare: () async => calls++,
        );
        expect(find.byKey(share), findsOneWidget);
        expect(find.text('SHARE'), findsOneWidget);
        expect(
          tester.getSize(find.byKey(share)).height,
          greaterThanOrEqualTo(48),
        );
        await _finish(tester);
        await tester.tap(find.byKey(share));
        await tester.pump();
        expect(calls, 1);
      });
    }

    testWidgets('no onShare hides the SHARE button', (tester) async {
      await _pump(
        tester,
        variant: VictoryVariant.sub,
        level: _catalog.byIndex(2),
        onContinue: () {},
      );
      expect(find.byKey(share), findsNothing);
      await _finish(tester);
    });

    testWidgets('a second tap while sharing is ignored, then CONTINUE still '
        'works (AC3.4.2)', (tester) async {
      final pending = Completer<void>();
      var calls = 0;
      var continues = 0;
      await _pump(
        tester,
        variant: VictoryVariant.sub,
        level: _catalog.byIndex(2),
        onContinue: () => continues++,
        onShare: () {
          calls++;
          return pending.future;
        },
      );
      await _finish(tester);
      await tester.tap(find.byKey(share));
      await tester.pump();
      await tester.tap(find.byKey(share), warnIfMissed: false);
      await tester.pump();
      expect(calls, 1);
      pending.complete();
      await tester.pump();
      await tester.tap(find.byKey(const Key('victory-continue-button')));
      await tester.pump();
      expect(continues, 1);
    });

    testWidgets('a failing share is logged and the screen stays usable '
        '(AC3.4.1)', (tester) async {
      var continues = 0;
      await _pump(
        tester,
        variant: VictoryVariant.sub,
        level: _catalog.byIndex(2),
        onContinue: () => continues++,
        onShare: () async => throw StateError('share failed'),
      );
      await _finish(tester);
      await tester.tap(find.byKey(share));
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('victory-overlay')), findsOneWidget);
      await tester.tap(find.byKey(share));
      await tester.pump();
      await tester.tap(find.byKey(const Key('victory-continue-button')));
      await tester.pump();
      expect(continues, 1);
    });
  });

  testWidgets('the confetti stops by itself after 2.5 seconds (AC3.4.1)', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ConfettiLayer(colors: [Colors.red, Colors.white]),
      ),
    );
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byKey(const Key('confetti-paint')), findsOneWidget);
    await tester.pump(ConfettiLayer.defaultDuration);
    await tester.pump();
    expect(find.byKey(const Key('confetti-paint')), findsNothing);
  });
}
