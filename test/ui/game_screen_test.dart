import 'package:block_blast/features/game/engine/board_geometry.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/widgets/block_palette.dart';
import 'package:block_blast/features/game/widgets/game_board.dart';
import 'package:block_blast/features/journey/controllers/level_game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/game/engine/engine_test_helpers.dart';
import '../fakes/log_capture.dart';
import 'ui_test_helpers.dart';

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  setUp(() {
    LogCapture().start();
  });

  group('header (BR5.6, FR11)', () {
    testWidgets(
      'shows the level name, "score / target" and the percent label',
      (tester) async {
        final h = await GameHarness.create(levelIndex: 8, target: 1000);
        await pumpGameScreen(tester, h);

        expect(_text(tester, 'game-level-name'), 'Amethyst · Slabbing');
        expect(_text(tester, 'game-score-target'), '0 / 1000');
        expect(_text(tester, 'game-progress-label'), '0%');
        expect(find.text('TIME'), findsNothing);
        expect(find.text('BEST'), findsNothing);
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byKey(const Key('game-progress-bar')),
              )
              .value,
          0,
        );
      },
    );

    testWidgets('updates score, target and percent after a placement', (
      tester,
    ) async {
      final h = await GameHarness.create(target: 200);
      await pumpGameScreen(tester, h);

      h.controller.onDragStart(h.controller.tray[1]);
      await h.controller.placeAt(2, 2);
      await tester.pump();

      expect(_text(tester, 'game-score-target'), '20 / 200');
      expect(_text(tester, 'game-progress-label'), '10%');
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byKey(const Key('game-progress-bar')),
            )
            .value,
        closeTo(0.1, 0.0001),
      );
    });

    testWidgets('shows the tutorial until the first placement', (tester) async {
      final h = await GameHarness.create();
      await pumpGameScreen(tester, h);
      expect(find.text('DRAG BLOCKS TO THE BOARD!'), findsOneWidget);

      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('DRAG BLOCKS TO THE BOARD!'), findsNothing);
    });

    testWidgets('shows the combo text after back-to-back clears', (
      tester,
    ) async {
      final h = await GameHarness.create(
        target: 100000,
        source: () => [single(), single(), single()],
      );
      await pumpGameScreen(tester, h);
      for (final row in [0, 1]) {
        for (var c = 1; c < 8; c++) {
          h.engine.board[row][c].filled = true;
        }
      }
      h.controller.onDragStart(h.controller.tray.first);
      final first = h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 50));
      await first;
      h.controller.onDragStart(h.controller.tray.first);
      final second = h.controller.placeAt(1, 0);
      await tester.pump(const Duration(milliseconds: 50));
      await second;
      await tester.pump();
      expect(find.text('COMBO x2'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
    });
  });

  group('drag and drop', () {
    testWidgets('dragging a block onto the board places it and scores', (
      tester,
    ) async {
      final h = await GameHarness.create(target: 100000);
      await pumpGameScreen(tester, h);

      final palette = find.byType(BlockPalette);
      final blockCenter = tester.getCenter(
        find
            .descendant(
              of: palette,
              matching: find.byType(Draggable<BlockModel>),
            )
            .first,
      );
      final boardBox = tester.getRect(find.byType(GameBoard));
      final size = BoardGeometry.cellSize(boardBox.width);
      final target = Offset(
        boardBox.left + BoardGeometry.innerPadding + size * 3.5,
        boardBox.top + BoardGeometry.innerPadding + size * 3.5,
      );

      final gesture = await tester.startGesture(blockCenter);
      await tester.pump();
      await gesture.moveTo(target);
      await tester.pump();
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 300));

      expect(h.controller.score, greaterThan(0));
      expect(h.controller.tray.length, 2);
    });

    testWidgets('dropping a block outside the board changes nothing', (
      tester,
    ) async {
      final h = await GameHarness.create(target: 100000);
      await pumpGameScreen(tester, h);

      final blockCenter = tester.getCenter(
        find
            .descendant(
              of: find.byType(BlockPalette),
              matching: find.byType(Draggable<BlockModel>),
            )
            .first,
      );
      final gesture = await tester.startGesture(blockCenter);
      await tester.pump();
      await gesture.moveTo(const Offset(5, 5));
      await tester.pump();
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 300));

      expect(h.controller.score, 0);
      expect(h.controller.tray.length, 3);
      expect(h.controller.activeBlock, isNull);
    });
  });

  group('victory (temporary, WF4)', () {
    testWidgets('shows Level Complete with the score and a CONTINUE button', (
      tester,
    ) async {
      final h = await GameHarness.create(target: 10);
      await pumpGameScreen(tester, h);

      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 500));

      expect(h.controller.status, LevelStatus.won);
      expect(find.byKey(const Key('victory-overlay')), findsOneWidget);
      expect(find.text('Level Complete!'), findsOneWidget);
      expect(_text(tester, 'victory-score'), '10 / 10');
      final size = tester.getSize(
        find.byKey(const Key('victory-continue-button')),
      );
      expect(size.height, greaterThanOrEqualTo(48));
      expect(find.byKey(const Key('game-over-overlay')), findsNothing);
      // flutter_animate starts a timer when an overlay mounts; let it finish.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('CONTINUE starts the next level', (tester) async {
      final h = await GameHarness.create(target: 10);
      await pumpGameScreen(tester, h);
      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byKey(const Key('victory-continue-button')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('victory-overlay')), findsNothing);
      expect(_text(tester, 'game-level-name'), 'Rose Quartz · Slabbing');
      expect(_text(tester, 'game-score-target'), '0 / 800');
      expect(h.repo.progress.currentLevelIndex, 2);
    });
  });

  group('game over (kept from before, BR5.7)', () {
    Future<GameHarness> lostGame(WidgetTester tester) async {
      final h = await GameHarness.create(target: 11);
      await pumpGameScreen(tester, h);
      h.fillBoardLeavingIsolatedGaps();
      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 500));
      return h;
    }

    testWidgets('appears when status is lost with all four actions', (
      tester,
    ) async {
      final h = await lostGame(tester);
      expect(h.controller.status, LevelStatus.lost);
      expect(find.byKey(const Key('game-over-overlay')), findsOneWidget);
      expect(find.text('GAME OVER'), findsOneWidget);
      expect(find.text('FINAL SCORE: 10'), findsOneWidget);
      expect(find.byKey(const Key('game-over-share-button')), findsOneWidget);
      expect(
        find.byKey(const Key('game-over-play-again-button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('game-over-revive-button')), findsOneWidget);
      expect(find.byKey(const Key('game-over-menu-button')), findsOneWidget);
      expect(find.byKey(const Key('victory-overlay')), findsNothing);
      // The first placement legitimately saves `tutorial_completed`.
      expect(
        h.store.attempts,
        isNot(contains('progress')),
        reason: 'progress is not touched',
      );
      // flutter_animate starts a timer when an overlay mounts; let it finish.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('REVIVE resumes play and hides the REVIVE button afterwards', (
      tester,
    ) async {
      final h = await lostGame(tester);
      await tester.tap(find.byKey(const Key('game-over-revive-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(h.controller.status, LevelStatus.playing);
      expect(find.byKey(const Key('game-over-overlay')), findsNothing);
      expect(h.controller.revived, isTrue);
    });

    testWidgets('PLAY AGAIN restarts the same level from zero', (tester) async {
      final h = await lostGame(tester);
      final before = h.controller.roundId;
      await tester.tap(find.byKey(const Key('game-over-play-again-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(h.controller.roundId, isNot(before));
      expect(h.controller.level.levelIndex, 1);
      expect(_text(tester, 'game-score-target'), '0 / 11');
    });

    testWidgets('SHARE SCORE calls the share service with the final score', (
      tester,
    ) async {
      final h = await lostGame(tester);
      await tester.tap(find.byKey(const Key('game-over-share-button')));
      await tester.pump();
      expect(h.share.shared, 1);
      expect(h.share.lastScore, 10);
      // flutter_animate starts a timer when an overlay mounts; let it finish.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('BACK TO MENU leaves the game screen', (tester) async {
      final h = await lostGame(tester);
      await tester.tap(find.byKey(const Key('game-over-menu-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(h.controller.status, LevelStatus.lost);
    });
  });

  group('back navigation (BR5.8, BR5.4)', () {
    testWidgets('the back arrow while playing quits to the previous screen', (
      tester,
    ) async {
      final h = await GameHarness.create();
      await pumpGameScreen(tester, h);
      expect(find.text('base-route'), findsNothing);
      await tester.tap(find.byKey(const Key('game-back-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(h.controller.status, LevelStatus.quit);
      expect(h.store.attempts, isEmpty);
    });

    testWidgets('the system back button also quits while playing', (
      tester,
    ) async {
      final h = await GameHarness.create();
      await pumpGameScreen(tester, h);
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(h.controller.status, LevelStatus.quit);
    });

    testWidgets('back is ignored while resolving', (tester) async {
      final h = await GameHarness.create(target: 10);
      h.store.writeDelay[progressKey] = const Duration(milliseconds: 400);
      await pumpGameScreen(tester, h);

      h.controller.onDragStart(h.controller.tray.first);
      final turn = h.controller.placeAt(0, 0);
      await tester.pump();
      expect(h.controller.status, LevelStatus.resolving);

      await tester.tap(find.byKey(const Key('game-back-button')));
      await tester.pump();
      expect(find.text('base-route'), findsNothing);
      expect(h.controller.status, LevelStatus.resolving);

      await tester.pump(const Duration(milliseconds: 500));
      await turn;
      await tester.pump(const Duration(milliseconds: 500));
      expect(h.controller.status, LevelStatus.won);
    });
  });
}
