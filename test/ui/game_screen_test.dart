import 'dart:async';

import 'package:block_blast/core/theme/gem_theme.dart';
import 'package:block_blast/features/game/engine/board_geometry.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/widgets/block_palette.dart';
import 'package:block_blast/features/game/widgets/game_board.dart';
import 'package:block_blast/features/journey/controllers/level_game_controller.dart';
import 'package:block_blast/features/journey/services/background_image_service.dart';
import 'package:block_blast/shared/widgets/level_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/ads/ads_fakes.dart';
import '../features/game/engine/engine_test_helpers.dart';
import '../fakes/fake_images.dart';
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

    testWidgets(
      'lifted drag: the dragged block is board-sized, 1.5 cells above '
      'the finger, and the preview is under the block (user request)',
      (tester) async {
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
        final block = h.controller.tray.first;
        final boardBox = tester.getRect(find.byType(GameBoard));
        final size = BoardGeometry.cellSize(boardBox.width);
        // Ngón tay ở chỗ mà khối (đã nâng) phủ đúng ô (2, 3).
        final anchor = BoardGeometry.feedbackAnchor(size, block);
        final pointer =
            Offset(
              boardBox.left + BoardGeometry.innerPadding + 3 * size,
              boardBox.top + BoardGeometry.innerPadding + 2 * size,
            ) +
            anchor;

        final gesture = await tester.startGesture(blockCenter);
        await tester.pump();
        await gesture.moveTo(pointer);
        await tester.pump();

        final feedback = tester.getRect(find.byKey(const Key('drag-feedback')));
        expect(feedback.width, closeTo(block.cols * size, 0.5));
        expect(feedback.height, closeTo(block.rows * size, 0.5));
        expect(feedback.center.dx, closeTo(pointer.dx, 0.5));
        expect(
          pointer.dy - feedback.bottom,
          closeTo(1.5 * size, 0.5),
          reason: 'the finger stays below the block',
        );
        expect(
          h.engine.board[2][3].preview,
          isTrue,
          reason: 'preview is under the drawn block',
        );

        await gesture.up();
        await tester.pump(const Duration(milliseconds: 300));
        expect(h.engine.board[2][3].filled, isTrue);
        expect(h.controller.score, greaterThan(0));
      },
    );

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

  group('victory (U3, FR6, AC3.x)', () {
    Future<GameHarness> win(WidgetTester tester, int levelIndex) async {
      final h = await GameHarness.create(levelIndex: levelIndex, target: 10);
      await pumpGameScreen(tester, h);
      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 500));
      return h;
    }

    testWidgets('a sub-level win shows the full victory with CONTINUE '
        '(AC3.1.1, AC3.1.3)', (tester) async {
      final h = await win(tester, 1);
      expect(h.controller.status, LevelStatus.won);
      expect(find.byKey(const Key('victory-overlay')), findsOneWidget);
      expect(find.text('Level Complete!'), findsOneWidget);
      expect(
        find.text('Congratulations! Rough Stone Completed!'),
        findsOneWidget,
      );
      expect(_text(tester, 'victory-score'), '10 / 10 · BEST 10');
      expect(
        tester.getSize(find.byKey(const Key('victory-continue-button'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(find.byKey(const Key('victory-unlock-text')), findsNothing);
      expect(find.byKey(const Key('game-over-overlay')), findsNothing);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('CONTINUE starts the next level', (tester) async {
      final h = await win(tester, 1);
      await tester.tap(find.byKey(const Key('victory-continue-button')));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byKey(const Key('victory-overlay')), findsNothing);
      expect(_text(tester, 'game-level-name'), 'Rose Quartz · Slabbing');
      expect(_text(tester, 'game-score-target'), '0 / 800');
      expect(h.repo.progress.currentLevelIndex, 2);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('a Bling win shows the gem unlock (AC3.2.1)', (tester) async {
      await win(tester, 6);
      expect(_text(tester, 'victory-unlock-text'), '🎉 Rose Quartz Unlocked!');
      expect(find.byKey(const Key('gem-unlock-icon')), findsOneWidget);
      expect(find.byKey(const Key('victory-continue-button')), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('level 36 shows JOURNEY COMPLETE with BACK TO MENU only '
        '(AC3.3.1, AC3.3.2)', (tester) async {
      final h = await win(tester, 36);
      expect(find.text('JOURNEY COMPLETE!'), findsOneWidget);
      expect(find.text('You have collected all 6 gems'), findsOneWidget);
      expect(find.byKey(const Key('victory-continue-button')), findsNothing);
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key('victory-menu-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(h.repo.progress.journeyCompleted, isTrue);
    });

    testWidgets('SHARE on victory shares the screen with the level name and '
        'score (AC3.1.2, AC3.1.3)', (tester) async {
      final h = await win(tester, 1);
      expect(h.share.victoryShared, 0, reason: 'nothing is shared unasked');
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.byKey(const Key('victory-share-button')));
      await tester.pump();
      expect(h.share.victoryShared, 1);
      expect(h.share.lastLevelName, 'Rose Quartz · Rough Stone');
      expect(h.share.lastScore, h.controller.score);
      expect(h.share.shared, 0);
      expect(find.byKey(const Key('victory-overlay')), findsOneWidget);
    });

    testWidgets('SHARE is also on the gem unlock and journey complete '
        'screens (AC3.2.1, AC3.3.1)', (tester) async {
      await win(tester, 6);
      expect(find.byKey(const Key('victory-share-button')), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });
  });

  group('game over (FR11.3, US2.6, US2.7)', () {
    // Level 9 = Amethyst · Shaping; thua thì về Amethyst · Rough Stone.
    Future<GameHarness> lostGame(
      WidgetTester tester, {
      FakeAdsService? ads,
    }) async {
      final h = await GameHarness.create(levelIndex: 9, target: 11);
      if (ads == null) {
        await pumpGameScreen(tester, h);
      } else {
        await pumpGameScreen(tester, h, ads: ads);
      }
      h.fillBoardLeavingIsolatedGaps();
      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 500));
      return h;
    }

    testWidgets('shows score, target, the Rough Stone to return to and three '
        'actions, without REVIVE (AC2.6.1, AC2.6.2)', (tester) async {
      final h = await lostGame(tester);
      expect(h.controller.status, LevelStatus.lost);
      expect(find.byKey(const Key('game-over-overlay')), findsOneWidget);
      expect(find.text('GAME OVER'), findsOneWidget);
      expect(_text(tester, 'game-over-score'), 'FINAL SCORE: 10');
      expect(_text(tester, 'game-over-target'), 'Target: 11');
      expect(find.text('You will return to'), findsOneWidget);
      expect(_text(tester, 'game-over-return-level'), 'Amethyst · Rough Stone');
      expect(
        tester
            .widget<Text>(find.byKey(const Key('game-over-return-level')))
            .style!
            .color,
        GemTheme.forGem('amethyst').primary,
      );
      expect(find.byKey(const Key('game-over-share-button')), findsOneWidget);
      expect(
        find.byKey(const Key('game-over-play-again-button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('game-over-menu-button')), findsOneWidget);
      expect(find.textContaining('REVIVE'), findsNothing);
      expect(find.byKey(const Key('victory-overlay')), findsNothing);
      expect(h.repo.progress.currentLevelIndex, 7, reason: 'saved on loss');
      for (final key in [
        'game-over-share-button',
        'game-over-play-again-button',
        'game-over-menu-button',
      ]) {
        expect(
          tester.getSize(find.byKey(Key(key))).height,
          greaterThanOrEqualTo(48),
          reason: key,
        );
      }
      // flutter_animate starts a timer when an overlay mounts; let it finish.
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('PLAY AGAIN restarts at the Rough Stone from zero', (
      tester,
    ) async {
      final h = await lostGame(tester);
      final before = h.controller.roundId;
      await tester.tap(find.byKey(const Key('game-over-play-again-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(h.controller.roundId, isNot(before));
      expect(h.controller.level.levelIndex, 7);
      expect(_text(tester, 'game-level-name'), 'Amethyst · Rough Stone');
      expect(find.byKey(const Key('game-over-overlay')), findsNothing);
    });

    testWidgets('PLAY AGAIN shows a due interstitial first, then restarts '
        '(u1-ads-core, AC2.1.1)', (tester) async {
      final ads = FakeAdsService()..holdInterstitial = Completer<void>();
      final h = await lostGame(tester, ads: ads);
      final before = h.controller.roundId;

      await tester.tap(find.byKey(const Key('game-over-play-again-button')));
      await tester.pump();
      expect(ads.interstitialCalls, 1);
      expect(h.controller.roundId, before, reason: 'waits for the ad to close');

      // Bấm lại trong lúc quảng cáo đang hiện không tính là lần bấm thứ hai.
      await tester.tap(find.byKey(const Key('game-over-play-again-button')));
      await tester.pump();
      expect(ads.interstitialCalls, 1);

      ads.holdInterstitial!.complete();
      await tester.pump(const Duration(milliseconds: 500));
      expect(h.controller.roundId, isNot(before));
      expect(find.byKey(const Key('game-over-overlay')), findsNothing);
    });

    testWidgets('SHARE SCORE marks the return from the share sheet so it is '
        'not counted as an app open (BR5.3)', (tester) async {
      final ads = FakeAdsService();
      final h = await lostGame(tester, ads: ads);
      await tester.tap(find.byKey(const Key('game-over-share-button')));
      await tester.pump();
      expect(ads.suppressCalls, 1);
      expect(h.share.shared, 1);
      await tester.pump(const Duration(seconds: 1));
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

    testWidgets('BACK TO MENU leaves without asking, progress already saved '
        '(AC1.5.1)', (tester) async {
      final h = await lostGame(tester);
      await tester.tap(find.byKey(const Key('game-over-menu-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('quit-dialog')), findsNothing);
      expect(find.text('base-route'), findsOneWidget);
      expect(h.controller.status, LevelStatus.lost);
      expect(h.repo.progress.currentLevelIndex, 7);
    });
  });

  group('BEST on the header (FR11.1, AC1.7.1)', () {
    testWidgets('shows the saved high score of the level', (tester) async {
      final h = await GameHarness.create(
        levelIndex: 9,
        target: 100000,
        initial: {'high_scores': '{"9":1300}'},
      );
      await pumpGameScreen(tester, h);
      expect(_text(tester, 'game-best-score'), 'BEST 1300');
    });
  });

  group('quit dialog (FR11.2, US2.5)', () {
    Future<void> openDialog(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('game-back-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    testWidgets('the back arrow asks "Quit this level?" with CANCEL and QUIT '
        '(AC2.5.1)', (tester) async {
      final h = await GameHarness.create();
      await pumpGameScreen(tester, h);
      await openDialog(tester);
      expect(find.byKey(const Key('quit-dialog')), findsOneWidget);
      expect(find.text('Quit this level?'), findsOneWidget);
      for (final key in ['quit-cancel-button', 'quit-confirm-button']) {
        final size = tester.getSize(find.byKey(Key(key)));
        expect(size.height, greaterThanOrEqualTo(48), reason: key);
      }
      final cancel = tester.widget<TextButton>(
        find.byKey(const Key('quit-cancel-button')),
      );
      expect(cancel.autofocus, isTrue);
      expect(h.controller.status, LevelStatus.playing);
    });

    testWidgets('CANCEL keeps playing with the same score (AC2.5.2)', (
      tester,
    ) async {
      final h = await GameHarness.create(target: 100000);
      await pumpGameScreen(tester, h);
      h.controller.onDragStart(h.controller.tray[1]);
      await h.controller.placeAt(2, 2);
      await tester.pump();
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('quit-cancel-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('quit-dialog')), findsNothing);
      expect(find.text('base-route'), findsNothing);
      expect(h.controller.status, LevelStatus.playing);
      expect(h.controller.score, 20);
    });

    testWidgets('QUIT leaves without counting as a loss (AC2.5.3)', (
      tester,
    ) async {
      final h = await GameHarness.create(levelIndex: 9);
      await pumpGameScreen(tester, h);
      await openDialog(tester);
      await tester.tap(find.byKey(const Key('quit-confirm-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(h.controller.status, LevelStatus.quit);
      expect(
        h.store.attempts.toSet(),
        {'session_level'},
        reason: 'QUIT saves only the unfinished game, never progress',
      );
    });

    testWidgets('the system back button opens the same dialog', (tester) async {
      final h = await GameHarness.create();
      await pumpGameScreen(tester, h);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('quit-dialog')), findsOneWidget);
      await tester.tap(find.byKey(const Key('quit-confirm-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(h.controller.status, LevelStatus.quit);
    });
  });

  group('background and gem colours (FR5.3, FR12.1, AC7.3.1)', () {
    testWidgets('the level image is blurred and dimmed behind the board', (
      tester,
    ) async {
      final h = await GameHarness.create(levelIndex: 17);
      await pumpGameScreen(tester, h);
      final bg = tester.widget<LevelBackground>(find.byType(LevelBackground));
      expect(bg.level.levelIndex, 17);
      expect(bg.blurred, isTrue);
      expect(bg.overlay, BackgroundOverlay.dim);
      expect(find.byKey(const Key('level-bg-blur')), findsOneWidget);
    });

    testWidgets('the progress bar uses the colour of the current gem', (
      tester,
    ) async {
      final h = await GameHarness.create(levelIndex: 26);
      await pumpGameScreen(tester, h);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byKey(const Key('game-progress-bar')),
      );
      expect(bar.color, GemTheme.forGem('sapphire').primary);
      expect(find.byKey(const Key('game-progress-border')), findsOneWidget);
    });

    testWidgets('the next level background is precached once per level', (
      tester,
    ) async {
      final factory = FakeNetworkImageFactory();
      final h = await GameHarness.create(levelIndex: 3);
      await pumpGameScreen(
        tester,
        h,
        images: BackgroundImageService(networkFactory: factory.call),
      );
      expect(h.controller.upcomingLevel!.levelIndex, 4);
      await tester.pump();
      expect(tester.takeException(), isNull);
      // Không có URL trong config mặc định: chỉ asset được nạp sẵn.
      expect(factory.calls, isEmpty);
    });

    testWidgets('the QUIT button of the dialog uses the gem button colour', (
      tester,
    ) async {
      final h = await GameHarness.create(levelIndex: 8);
      await pumpGameScreen(tester, h);
      await tester.tap(find.byKey(const Key('game-back-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final quit = tester.widget<ElevatedButton>(
        find.byKey(const Key('quit-confirm-button')),
      );
      expect(
        quit.style!.backgroundColor!.resolve(<WidgetState>{}),
        const Color(0xFF7A4FB0),
      );
      // Tiêu đề và hai nút cùng họ font.
      final title = tester.widget<Text>(
        find.byKey(const Key('quit-dialog-title')),
      );
      expect(title.style!.fontFamily, 'Montserrat');
      expect(
        tester.widget<Text>(find.text('CANCEL')).style!.fontFamily,
        'Montserrat',
      );
      expect(
        tester.widget<Text>(find.text('QUIT')).style!.fontFamily,
        'Montserrat',
      );
    });
  });

  group('back navigation (BR5.4)', () {
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

  group('reward on game over (u2-reward-ads, US3.1)', () {
    Future<GameHarness> lostWithReward(
      WidgetTester tester,
      FakeAdsService ads, {
      bool rewardEnabled = true,
    }) async {
      final h = await GameHarness.create(
        levelIndex: 9,
        target: 11,
        ads: ads,
        rewardEnabled: rewardEnabled,
      );
      await pumpGameScreen(tester, h, ads: ads);
      h.fillBoardLeavingIsolatedGaps();
      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 500));
      return h;
    }

    testWidgets('shows the reward button and its hint in English (AC3.1.1)', (
      tester,
    ) async {
      await lostWithReward(tester, FakeAdsService());
      expect(find.byKey(const Key('game-over-reward-button')), findsOneWidget);
      expect(find.text('WATCH AD TO TRY AGAIN'), findsOneWidget);
      expect(find.text('Watch an ad to stay on this level'), findsOneWidget);
      expect(
        find.byKey(const Key('game-over-play-again-button')),
        findsOneWidget,
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('no reward button when reward_enabled is false (AC3.1.2)', (
      tester,
    ) async {
      await lostWithReward(tester, FakeAdsService(), rewardEnabled: false);
      expect(find.byKey(const Key('game-over-overlay')), findsOneWidget);
      expect(find.byKey(const Key('game-over-reward-button')), findsNothing);
      expect(find.text('Watch an ad to stay on this level'), findsNothing);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('tapping it shows the ad, then replays the same level '
        '(AC3.1.3)', (tester) async {
      final ads = FakeAdsService()..holdReward = Completer<void>();
      final h = await lostWithReward(tester, ads);

      await tester.tap(find.byKey(const Key('game-over-reward-button')));
      await tester.pump();
      expect(ads.rewardCalls, 1);
      final button = tester.widget<ElevatedButton>(
        find.descendant(
          of: find.byKey(const Key('game-over-reward-button')),
          matching: find.byWidgetPredicate((w) => w is ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull, reason: 'locked while the ad shows');

      ads.holdReward!.complete();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('game-over-overlay')), findsNothing);
      expect(h.controller.level.levelIndex, 9);
      expect(h.controller.score, 0);
      expect(_text(tester, 'game-score-target'), '0 / 11');
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('BACK TO MENU records the loss before leaving (BR6.2)', (
      tester,
    ) async {
      final h = await lostWithReward(tester, FakeAdsService());
      await tester.tap(find.byKey(const Key('game-over-menu-button')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(h.repo.progress.currentLevelIndex, 7);
      expect(find.text('base-route'), findsOneWidget);
    });
  });

  group('banner (u3-banner, US4.1)', () {
    Future<GameHarness> pumpWithBanner(
      WidgetTester tester,
      FakeAdsService ads,
    ) async {
      final h = await GameHarness.create(levelIndex: 9, target: 11);
      await pumpGameScreen(tester, h, ads: ads);
      await tester.pump();
      await tester.pump();
      return h;
    }

    testWidgets('shows the banner below the board and tray (AC4.1.2)', (
      tester,
    ) async {
      final ads = FakeAdsService()..eligible = true;
      await pumpWithBanner(tester, ads);
      final banner = tester.getRect(find.byKey(const Key('ad-banner-slot')));
      expect(banner.height, 50);
      expect(
        banner.top,
        greaterThanOrEqualTo(tester.getRect(find.byType(BlockPalette)).bottom),
      );
      expect(
        banner.top,
        greaterThanOrEqualTo(tester.getRect(find.byType(GameBoard)).bottom),
      );
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('no banner keeps the layout unchanged (AC4.1.5)', (
      tester,
    ) async {
      final ads = FakeAdsService()
        ..eligible = true
        ..bannerResultHeight = null;
      await pumpWithBanner(tester, ads);
      final withoutAds = tester.getRect(find.byType(BlockPalette));
      expect(find.byKey(const Key('ad-banner-slot')), findsNothing);
      expect(ads.bannerCalls, 1);
      final h = await GameHarness.create(levelIndex: 9, target: 11);
      await pumpGameScreen(tester, h);
      await tester.pump();
      expect(tester.getRect(find.byType(BlockPalette)), withoutAds);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('on a short 360 x 640 screen nothing is covered (AC4.1.6)', (
      tester,
    ) async {
      final ads = FakeAdsService()..eligible = true;
      final h = await GameHarness.create(levelIndex: 9, target: 11);
      await pumpGameScreen(tester, h, ads: ads);
      tester.view.physicalSize = const Size(360, 640);
      await tester.pump();
      await tester.pump();
      final banner = tester.getRect(find.byKey(const Key('ad-banner-slot')));
      final tray = tester.getRect(find.byType(BlockPalette));
      expect(banner.top, greaterThanOrEqualTo(tray.bottom));
      expect(banner.bottom, lessThanOrEqualTo(640));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('the Game Over overlay covers the banner (BR7.6)', (
      tester,
    ) async {
      final ads = FakeAdsService()..eligible = true;
      final h = await pumpWithBanner(tester, ads);
      h.fillBoardLeavingIsolatedGaps();
      h.controller.onDragStart(h.controller.tray.first);
      await h.controller.placeAt(0, 0);
      await tester.pump(const Duration(milliseconds: 500));
      final overlay = tester.getRect(
        find.byKey(const Key('game-over-overlay')),
      );
      final banner = tester.getRect(find.byKey(const Key('ad-banner-slot')));
      expect(overlay.contains(banner.center), isTrue);
      expect(ads.bannerCalls, 1, reason: 'kept across the round');
      await tester.pump(const Duration(seconds: 1));
    });
  });
}
