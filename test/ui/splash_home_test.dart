import 'dart:async';

import 'package:block_blast/app.dart';
import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/core/theme/gem_theme.dart';
import 'package:block_blast/features/home/screens/home_screen.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:block_blast/shared/widgets/level_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_analytics.dart';
import '../features/ads/ads_fakes.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_progress_store.dart';
import '../fakes/log_capture.dart';
import 'ui_test_helpers.dart';

Future<void> _settle(WidgetTester tester) async {
  // pumpAndSettle không dùng được: một số hiệu ứng lặp không bao giờ dừng.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

Future<void> _pumpHome(WidgetTester tester, {FakeProgressStore? store}) async {
  useMobileScreen(tester);
  final services = await buildServices(store: store);
  await tester.pumpWidget(MaterialApp(home: HomeScreen(services: services)));
  await _settle(tester);
}

void main() {
  setUp(() {
    LogCapture().start();
    mockEmptyPrefs();
  });

  group('Splash (mockup M-0)', () {
    testWidgets('shows logo, title, subtitle and a progress indicator, then '
        'opens Home', (tester) async {
      useMobileScreen(tester);
      await tester.pumpWidget(BlockBlastApp(bootstrap: fakeBootstrap()));
      expect(find.byKey(const Key('splash-logo')), findsOneWidget);
      expect(find.text('BLOCK JEWEL'), findsOneWidget);
      expect(find.text('◆ Gemstone Journey ◆'), findsOneWidget);
      expect(find.byKey(const Key('splash-progress')), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      await _settle(tester);

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('splash-logo')), findsNothing);
      expect(find.text('Rose Quartz · Rough Stone'), findsOneWidget);
    });

    testWidgets('app title is Block Jewel and splash uses the launch colour', (
      tester,
    ) async {
      useMobileScreen(tester);
      await tester.pumpWidget(BlockBlastApp(bootstrap: fakeBootstrap()));
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Block Jewel');
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, GemTheme.backgroundEnd);
      expect(find.textContaining('Crush'), findsNothing);
      await _settle(tester);
    });

    testWidgets('Home keeps the Gemstone Journey subtitle', (tester) async {
      await _pumpHome(tester);
      expect(find.text('◆ Gemstone Journey ◆'), findsOneWidget);
    });

    testWidgets('still reaches Home when Firebase fails (plays offline)', (
      tester,
    ) async {
      useMobileScreen(tester);
      final failing = BlockBlastApp(
        bootstrap: fakeBootstrap(
          gateway: FirebaseGateway(
            initializer: () async => throw StateError('no firebase'),
          ),
        ),
      );
      await tester.pumpWidget(failing);
      await _settle(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('home-level-label')), findsOneWidget);
    });
  });

  group('Home (mockup M-1)', () {
    testWidgets('shows the level label, "Level N of 36", the gem icon and a '
        'PLAY button of 48dp or more', (tester) async {
      await _pumpHome(
        tester,
        store: FakeProgressStore(
          initial: {progressKey: progressJson(current: 8)},
        ),
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('home-level-label'))).data,
        'Amethyst · Slabbing',
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('home-level-number'))).data,
        'Level 8 of 36',
      );
      final icon = tester.widget<Icon>(find.byKey(const Key('home-gem-icon')));
      expect(icon.color, GemTheme.forGem('amethyst').primary);
      final size = tester.getSize(find.byKey(const Key('home-play-button')));
      expect(size.height, greaterThanOrEqualTo(48));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('a fresh player sees Level 1 of 36 (State B)', (tester) async {
      await _pumpHome(tester);
      expect(find.text('Rose Quartz · Rough Stone'), findsOneWidget);
      expect(find.text('Level 1 of 36'), findsOneWidget);
    });

    testWidgets('uses the Emerald colours at an Emerald level (AC5.4.1)', (
      tester,
    ) async {
      await _pumpHome(
        tester,
        store: FakeProgressStore(
          initial: {progressKey: progressJson(current: 22)},
        ),
      );
      expect(find.text('Emerald · Sanding'), findsOneWidget);
      final emerald = GemTheme.forGem('emerald');
      final icon = tester.widget<Icon>(find.byKey(const Key('home-gem-icon')));
      expect(icon.color, emerald.primary);
      final background = tester.widget<LevelBackground>(
        find.byType(LevelBackground),
      );
      expect(background.level.gemId, 'emerald');
      expect(background.blurred, isTrue);
      expect(background.overlay, BackgroundOverlay.gem);
      final button = tester.widget<ButtonStyleButton>(
        find.descendant(
          of: find.byKey(const Key('home-play-button')),
          matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
        ),
      );
      expect(
        button.style!.backgroundColor!.resolve(<WidgetState>{}),
        emerald.buttonFill,
      );
    });

    testWidgets('no mode cards and no Daily Gift, even on a new day '
        '(FR10.2, AC5.2.1)', (tester) async {
      await _pumpHome(tester);
      expect(find.text('CLASSIC MODE'), findsNothing);
      expect(find.text('TIME ATTACK'), findsNothing);
      expect(find.textContaining('DAILY GIFT'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('turning Sound Effects off is saved (AC5.3.2)', (tester) async {
      final store = FakeProgressStore();
      useMobileScreen(tester);
      final services = await buildServices(store: store);
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await _settle(tester);
      await tester.tap(find.byKey(const Key('home-settings-button')));
      await _settle(tester);

      final toggle = find.byKey(const Key('settings-sound-switch'));
      expect(tester.widget<Switch>(toggle).value, isTrue);
      await tester.tap(toggle);
      await _settle(tester);
      expect(services.audio.isMuted, isTrue);
      expect(store.data[ProgressRepository.soundMutedKey], true);
      expect(tester.widget<Switch>(toggle).value, isFalse);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
    });

    testWidgets('Settings has only Sound Effects, no THEME (AC5.3.1)', (
      tester,
    ) async {
      await _pumpHome(tester);
      final settings = find.byKey(const Key('home-settings-button'));
      expect(tester.getSize(settings).height, greaterThanOrEqualTo(48));
      await tester.tap(settings);
      await _settle(tester);
      expect(find.text('SETTINGS'), findsOneWidget);
      expect(find.text('Sound Effects'), findsOneWidget);
      expect(find.text('THEME'), findsNothing);
      expect(find.text('Wood'), findsNothing);
      expect(find.text('Neon'), findsNothing);
      expect(find.byKey(const Key('settings-sound-switch')), findsOneWidget);
    });

    testWidgets(
      'PLAY opens the game at the current level with target and percent',
      (tester) async {
        await _pumpHome(
          tester,
          store: FakeProgressStore(
            initial: {progressKey: progressJson(current: 2)},
          ),
        );
        await tester.tap(find.byKey(const Key('home-play-button')));
        await _settle(tester);

        expect(
          tester.widget<Text>(find.byKey(const Key('game-score-target'))).data,
          '0 / 800',
        );
        expect(
          tester
              .widget<Text>(find.byKey(const Key('game-progress-label')))
              .data,
          '0%',
        );
        expect(find.text('Rose Quartz · Slabbing'), findsOneWidget);
      },
    );

    testWidgets('back from a game returns to Home and keeps the level label', (
      tester,
    ) async {
      useMobileScreen(tester);
      final services = await buildServices();
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await _settle(tester);
      await tester.tap(find.byKey(const Key('home-play-button')));
      await _settle(tester);

      await tester.tap(find.byKey(const Key('game-back-button')));
      await _settle(tester);
      await tester.tap(find.byKey(const Key('quit-confirm-button')));
      await _settle(tester);
      expect(find.byKey(const Key('home-level-label')), findsOneWidget);
      expect(find.byKey(const Key('game-score-target')), findsNothing);
      expect(
        services.progress.progress.currentLevelIndex,
        1,
        reason: 'quitting never changes progress',
      );
    });

    testWidgets('Home starts the ads once and PLAY waits for a due '
        'interstitial before opening the game (u1-ads-core, AC2.1.1)', (
      tester,
    ) async {
      useMobileScreen(tester);
      final ads = FakeAdsService()..holdInterstitial = Completer<void>();
      final services = await buildServices(ads: ads);
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await _settle(tester);
      expect(ads.startCalls, 1);

      await tester.tap(find.byKey(const Key('home-play-button')));
      await tester.pump();
      expect(ads.interstitialCalls, 1);
      expect(find.byKey(const Key('game-score-target')), findsNothing);

      ads.holdInterstitial!.complete();
      await _settle(tester);
      expect(find.byKey(const Key('game-score-target')), findsOneWidget);
    });

    testWidgets('a return from the background is reported to the ads '
        '(u1-ads-core, BR5.1)', (tester) async {
      useMobileScreen(tester);
      final ads = FakeAdsService();
      final services = await buildServices(ads: ads);
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await _settle(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(ads.resumeCalls, 1);
    });

    testWidgets('app going to the background flushes dirty progress (WF7)', (
      tester,
    ) async {
      useMobileScreen(tester);
      final store = FakeProgressStore()..failingKeys.add(progressKey);
      final services = await buildServices(store: store);
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
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

    testWidgets('going to the background ends the session: game_session and '
        'total_play_time (AC6.4.1, AC1.6.2)', (tester) async {
      useMobileScreen(tester);
      final analytics = FakeAnalytics();
      final clock = FakeClock();
      final store = FakeProgressStore();
      final services = await buildServices(
        store: store,
        analytics: analytics,
        clock: clock,
      );
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await _settle(tester);
      clock.advance(const Duration(seconds: 75));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      await tester.pump();
      expect(analytics.sessions, [75]);
      expect(store.data[ProgressRepository.totalPlayTimeKey], 75);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      clock.advance(const Duration(seconds: 5));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      await tester.pump();
      expect(analytics.sessions, [75, 5]);
    });

    testWidgets('PLAY sends level_start for the current level (AC6.3.1)', (
      tester,
    ) async {
      useMobileScreen(tester);
      final analytics = FakeAnalytics();
      final services = await buildServices(
        store: FakeProgressStore(
          initial: {progressKey: progressJson(current: 5)},
        ),
        analytics: analytics,
      );
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await _settle(tester);
      await tester.tap(find.byKey(const Key('home-play-button')));
      await _settle(tester);
      expect(analytics.calls, ['start:5']);
    });

    testWidgets('going to the background with nothing dirty writes nothing', (
      tester,
    ) async {
      final store = FakeProgressStore();
      await _pumpHome(tester, store: store);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(store.attempts, isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(store.attempts, isEmpty);
    });
  });
}
