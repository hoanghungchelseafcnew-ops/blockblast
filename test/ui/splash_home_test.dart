import 'package:block_blast/app.dart';
import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/features/home/screens/home_screen.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_progress_store.dart';
import '../fakes/log_capture.dart';
import 'ui_test_helpers.dart';

Future<void> _settle(WidgetTester tester) async {
  // pumpAndSettle không dùng được: nền động và hiệu ứng lặp không bao giờ dừng.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  setUp(() {
    LogCapture().start();
    mockPrefsWithoutDailyGift();
  });

  group('Splash', () {
    testWidgets('shows the logo and a progress indicator, then opens Home',
        (tester) async {
      useMobileScreen(tester);
      await tester.pumpWidget(
        withTheme(BlockBlastApp(bootstrap: fakeBootstrap())),
      );
      expect(find.byKey(const Key('splash-logo')), findsOneWidget);
      expect(find.byKey(const Key('splash-progress')), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      await _settle(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('splash-logo')), findsNothing);
      expect(find.text('Rose Quartz · Rough Stone'), findsOneWidget);
    });

    testWidgets('still reaches Home when Firebase fails (plays offline)',
        (tester) async {
      useMobileScreen(tester);
      final failing = BlockBlastApp(
        bootstrap: fakeBootstrap(
          gateway: FirebaseGateway(
            initializer: () async => throw StateError('no firebase'),
          ),
        ),
      );
      await tester.pumpWidget(withTheme(failing));
      await _settle(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('home-level-label')), findsOneWidget);
    });
  });

  group('Home', () {
    testWidgets('shows the current level label and a PLAY button of 48dp or more',
        (tester) async {
      useMobileScreen(tester);
      final store = FakeProgressStore(
        initial: {progressKey: progressJson(current: 8)},
      );
      final services = await buildServices(store: store);
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);

      final label = tester.widget<Text>(find.byKey(const Key('home-level-label')));
      expect(label.data, 'Amethyst · Slabbing');
      final size = tester.getSize(find.byKey(const Key('home-play-button')));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('no longer shows the Classic and Time Attack mode cards',
        (tester) async {
      useMobileScreen(tester);
      final services = await buildServices();
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);

      expect(find.text('CLASSIC MODE'), findsNothing);
      expect(find.text('TIME ATTACK'), findsNothing);
      expect(find.textContaining('BEST'), findsNothing);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('PLAY opens the game at the current level with target and percent',
        (tester) async {
      useMobileScreen(tester);
      final services = await buildServices(
        store: FakeProgressStore(
          initial: {progressKey: progressJson(current: 2)},
        ),
      );
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);

      await tester.tap(find.byKey(const Key('home-play-button')));
      await _settle(tester);

      expect(find.byKey(const Key('game-score-target')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('game-score-target'))).data,
        '0 / 800',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('game-progress-label'))).data,
        '0%',
      );
      expect(find.text('Rose Quartz · Slabbing'), findsOneWidget);
    });

    testWidgets('back from a game returns to Home and keeps the level label',
        (tester) async {
      useMobileScreen(tester);
      final services = await buildServices();
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);
      await tester.tap(find.byKey(const Key('home-play-button')));
      await _settle(tester);

      await tester.tap(find.byKey(const Key('game-back-button')));
      await _settle(tester);

      expect(find.byKey(const Key('home-level-label')), findsOneWidget);
      expect(find.byKey(const Key('game-score-target')), findsNothing);
      expect(services.progress.progress.currentLevelIndex, 1,
          reason: 'quitting never changes progress');
    });

    testWidgets('the Daily Gift dialog still appears on the first launch of a day',
        (tester) async {
      useMobileScreen(tester);
      mockPrefsDailyGiftDue();
      final services = await buildServices();
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);

      expect(find.text('DAILY GIFT!'), findsOneWidget);
      await tester.tap(find.text('CLAIM'));
      await _settle(tester);
      expect(find.text('DAILY GIFT!'), findsNothing);
    });

    testWidgets('settings opens and a theme can be picked', (tester) async {
      useMobileScreen(tester);
      final services = await buildServices();
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);

      await tester.tap(find.byIcon(Icons.settings));
      await _settle(tester);
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);

      await tester.tap(find.text('Wood'));
      await _settle(tester);
      expect(find.text('Wood'), findsOneWidget);
    });

    testWidgets('app going to the background flushes dirty progress (WF7)',
        (tester) async {
      useMobileScreen(tester);
      final store = FakeProgressStore()..failingKeys.add(progressKey);
      final services = await buildServices(store: store);
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);

      await services.progress.savePlayerProgress(
        services.progress.progress.copyWith(
          currentLevelIndex: 3,
          highestLevelReached: 3,
        ),
      );
      expect(services.progress.dirtyKeys, {ProgressRepository.progressKey});

      store.failingKeys.clear();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      await tester.pump();

      expect(services.progress.dirtyKeys, isEmpty);
      expect(store.data[ProgressRepository.progressKey], isNotNull);
    });

    testWidgets('going to the background with nothing dirty writes nothing',
        (tester) async {
      useMobileScreen(tester);
      final store = FakeProgressStore();
      final services = await buildServices(store: store);
      await tester.pumpWidget(
        withTheme(MaterialApp(home: HomeScreen(services: services))),
      );
      await _settle(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(store.attempts, isEmpty);
      // Các trạng thái khác không làm gì.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(store.attempts, isEmpty);
    });
  });
}
