import 'package:block_blast/core/theme/gem_theme.dart';
import 'package:block_blast/features/endless/controllers/endless_game_controller.dart';
import 'package:block_blast/features/endless/screens/endless_game_screen.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/services/game_feedback.dart';
import 'package:block_blast/features/home/screens/home_screen.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../features/game/engine/engine_test_helpers.dart';
import '../fakes/fake_progress_store.dart';
import '../fakes/log_capture.dart';
import 'ui_test_helpers.dart';

const _saved = ProgressRepository.endlessSavedKey;
const _high = ProgressRepository.endlessHighKey;

String _completedJson() =>
    '{"currentLevelIndex":36,"completedLevels":[],"unlockedGems":[],'
    '"journeyCompleted":true,"highestLevelReached":36}';

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

class _Endless {
  _Endless(this.store, this.repo, this.engine, this.controller, this.share);

  final FakeProgressStore store;
  final ProgressRepository repo;
  final BoardEngine engine;
  final EndlessGameController controller;
  final FakeShareService share;

  static Future<_Endless> create({Map<String, Object>? initial}) async {
    final store = FakeProgressStore(initial: initial);
    final repo = ProgressRepository(store);
    await repo.load();
    final engine = BoardEngine(
      blockSource: () => [single(), line(2), line(2)],
      clearDelay: Duration.zero,
    );
    final controller = EndlessGameController(
      progress: repo,
      engine: engine,
      feedback: const NoopGameFeedback(),
    )..start();
    addTearDown(controller.dispose);
    return _Endless(store, repo, engine, controller, FakeShareService());
  }

  void fillBoardLeavingIsolatedGaps() {
    for (final row in engine.board) {
      for (final cell in row) {
        cell.filled = true;
      }
    }
    for (var i = 0; i < engine.board.length; i++) {
      engine.board[i][i].filled = false;
      engine.board[i][(i + 4) % engine.board.length].filled = false;
    }
  }
}

Future<GlobalKey<NavigatorState>> _pumpEndless(
  WidgetTester tester,
  _Endless e,
) async {
  useMobileScreen(tester);
  mockEmptyPrefs();
  final catalog = LevelCatalog.from(DefaultLevelConfig.config);
  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navKey,
      home: const Scaffold(body: Text('base-route')),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<EndlessGameController>.value(
        value: e.controller,
        child: EndlessGameScreen(
          background: catalog.byIndex(Level.totalLevels),
          shareService: e.share,
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return navKey;
}

void main() {
  setUp(() {
    LogCapture().start();
  });

  group('endless screen (FR9)', () {
    testWidgets('header shows Endless, SCORE and BEST from the saved state', (
      tester,
    ) async {
      final e = await _Endless.create(initial: {_saved: 1200, _high: 3000});
      await _pumpEndless(tester, e);
      expect(_text(tester, 'endless-title'), 'Endless');
      expect(_text(tester, 'endless-score'), 'SCORE 1200');
      expect(_text(tester, 'endless-best'), 'BEST 3000');
      expect(find.text('TIME'), findsNothing);
    });

    testWidgets('placing a block updates SCORE and BEST', (tester) async {
      final e = await _Endless.create(initial: {_saved: 95, _high: 100});
      await _pumpEndless(tester, e);
      e.controller.onDragStart(e.controller.tray.first);
      await e.controller.placeAt(0, 0);
      await tester.pump();
      expect(_text(tester, 'endless-score'), 'SCORE 105');
      expect(_text(tester, 'endless-best'), 'BEST 105');
    });

    testWidgets('the back arrow asks "Quit?" and CANCEL keeps playing', (
      tester,
    ) async {
      final e = await _Endless.create(initial: {_saved: 300});
      await _pumpEndless(tester, e);
      await tester.tap(find.byKey(const Key('endless-back-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(_text(tester, 'quit-dialog-title'), 'Quit?');
      expect(find.text('Your score will be saved.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('quit-cancel-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(EndlessGameScreen), findsOneWidget);
      expect(e.controller.score, 300);
      expect(e.controller.needsQuitConfirmation, isTrue);
    });

    testWidgets('QUIT saves the score and returns to the previous screen', (
      tester,
    ) async {
      final e = await _Endless.create(initial: {_saved: 300, _high: 300});
      await _pumpEndless(tester, e);
      await tester.tap(find.byKey(const Key('endless-back-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('quit-confirm-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(e.store.data[_saved], 300);
    });

    testWidgets('the system back button opens the same dialog', (tester) async {
      final e = await _Endless.create();
      await _pumpEndless(tester, e);
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('quit-dialog')), findsOneWidget);
    });

    testWidgets('going to the background saves the score', (tester) async {
      final e = await _Endless.create(initial: {_saved: 40, _high: 40});
      await _pumpEndless(tester, e);
      e.controller.onDragStart(e.controller.tray.first);
      await e.controller.placeAt(0, 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(e.repo.endlessState.savedScore, 50);
      expect(find.byType(EndlessGameScreen), findsOneWidget);
    });

    testWidgets('losing shows FINAL SCORE and BEST without Target', (
      tester,
    ) async {
      final e = await _Endless.create(initial: {_saved: 800, _high: 700});
      await _pumpEndless(tester, e);
      e.fillBoardLeavingIsolatedGaps();
      e.controller.onDragStart(e.controller.tray.first);
      await e.controller.placeAt(0, 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(_text(tester, 'game-over-score'), 'FINAL SCORE: 810');
      expect(_text(tester, 'game-over-best'), 'BEST: 810');
      expect(find.byKey(const Key('game-over-target')), findsNothing);
      expect(find.text('You will return to'), findsNothing);
      expect(find.text('REVIVE'), findsNothing);
      expect(e.repo.endlessState.savedScore, 0);
    });

    testWidgets('PLAY AGAIN restarts from 0 and SHARE calls the service', (
      tester,
    ) async {
      final e = await _Endless.create(initial: {_saved: 800, _high: 700});
      await _pumpEndless(tester, e);
      e.fillBoardLeavingIsolatedGaps();
      e.controller.onDragStart(e.controller.tray.first);
      await e.controller.placeAt(0, 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byKey(const Key('game-over-share-button')));
      await tester.pump();
      expect(e.share.shared, 1);
      expect(e.share.lastScore, 810);

      await tester.tap(find.byKey(const Key('game-over-play-again-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(_text(tester, 'endless-score'), 'SCORE 0');
      expect(_text(tester, 'endless-best'), 'BEST 810');
      expect(find.byKey(const Key('game-over-overlay')), findsNothing);
    });

    testWidgets('BACK TO MENU after a loss leaves without asking', (
      tester,
    ) async {
      final e = await _Endless.create();
      await _pumpEndless(tester, e);
      e.fillBoardLeavingIsolatedGaps();
      e.controller.onDragStart(e.controller.tray.first);
      await e.controller.placeAt(0, 0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byKey(const Key('game-over-menu-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('base-route'), findsOneWidget);
      expect(find.byKey(const Key('quit-dialog')), findsNothing);
    });
  });

  group('Home State C (Journey Complete, FR9.1)', () {
    Future<void> pumpHome(
      WidgetTester tester, {
      Map<String, Object>? initial,
    }) async {
      useMobileScreen(tester);
      final services = await buildServices(
        store: FakeProgressStore(initial: initial),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: HomeScreen(
            services: services,
            feedback: const NoopGameFeedback(),
          ),
        ),
      );
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 250));
      }
    }

    testWidgets('shows six gems, "Journey Complete" and Best "—" at first', (
      tester,
    ) async {
      mockEmptyPrefs();
      await pumpHome(tester, initial: {progressKey: _completedJson()});
      expect(_text(tester, 'home-journey-complete'), 'Journey Complete');
      expect(_text(tester, 'home-endless-best'), 'Endless · Best —');
      expect(
        find.descendant(
          of: find.byKey(const Key('home-gem-row')),
          matching: find.byIcon(Icons.diamond),
        ),
        findsNWidgets(GemTheme.gemIds.length),
      );
      expect(find.byKey(const Key('home-level-label')), findsNothing);
      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('shows the best score and PLAY opens endless, BEST refreshes', (
      tester,
    ) async {
      mockEmptyPrefs();
      await pumpHome(
        tester,
        initial: {progressKey: _completedJson(), _saved: 500, _high: 12400},
      );
      expect(_text(tester, 'home-endless-best'), 'Endless · Best 12400');

      await tester.tap(find.byKey(const Key('home-play-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(EndlessGameScreen), findsOneWidget);
      expect(_text(tester, 'endless-score'), 'SCORE 500');
      expect(find.byKey(const Key('game-score-target')), findsNothing);

      await tester.tap(find.byKey(const Key('endless-back-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('quit-confirm-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(_text(tester, 'home-endless-best'), 'Endless · Best 12400');
    });
  });
}
