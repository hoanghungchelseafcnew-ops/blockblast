import 'dart:async';

import 'package:block_blast/features/ads/models/ads_settings.dart';
import 'package:block_blast/features/ads/services/ad_mediator.dart';
import 'package:block_blast/features/home/screens/home_screen.dart';
import 'package:block_blast/features/update/services/app_update_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';
import '../../ui/ui_test_helpers.dart';
import '../ads/ads_fakes.dart';
import 'update_fakes.dart';

const _play = 'https://play.google.com/store/apps/details?id=com.h2.game';

const _newer = AdsSettings(androidVersion: '1.0.1', androidUrl: _play);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

class _Home {
  _Home(this.ads, this.launcher, this.reader);

  final FakeAdsService ads;
  final FakeStoreLauncher launcher;
  final FakeInstalledVersionReader reader;
}

Future<_Home> _pumpHome(
  WidgetTester tester, {
  AdsSettings settings = _newer,
  String installed = '1.0.0',
  FakeAdsService? ads,
}) async {
  useMobileScreen(tester);
  final fakeAds = ads ?? FakeAdsService();
  final reader = FakeInstalledVersionReader(installed);
  final launcher = FakeStoreLauncher();
  final services = await buildServices(
    ads: fakeAds,
    adsSettings: settings,
    updates: AppUpdateChecker(
      settings: settings,
      reader: reader,
      isIos: () => false,
    ),
  );
  await tester.pumpWidget(
    MaterialApp(
      home: HomeScreen(services: services, storeLauncher: launcher),
    ),
  );
  await _settle(tester);
  return _Home(fakeAds, launcher, reader);
}

void main() {
  setUp(() {
    LogCapture().start();
    mockEmptyPrefs();
  });

  group('update popup on Home (US5.1)', () {
    testWidgets('shows UPDATE and LATER in English when newer (AC5.1.1)', (
      tester,
    ) async {
      await _pumpHome(tester);
      expect(find.byKey(const Key('update-popup')), findsOneWidget);
      expect(find.text('Update available'), findsOneWidget);
      expect(find.text('UPDATE'), findsOneWidget);
      expect(find.text('LATER'), findsOneWidget);
    });

    testWidgets('no popup when the installed version is current (AC5.1.5)', (
      tester,
    ) async {
      await _pumpHome(tester, installed: '1.0.1');
      expect(find.byKey(const Key('update-popup')), findsNothing);
    });

    testWidgets('no popup when the link is invalid (FR6.4)', (tester) async {
      await _pumpHome(
        tester,
        settings: const AdsSettings(
          androidVersion: '1.0.1',
          androidUrl: 'market://details?id=x',
        ),
      );
      expect(find.byKey(const Key('update-popup')), findsNothing);
    });

    testWidgets('UPDATE opens the store link and closes (AC5.1.3)', (
      tester,
    ) async {
      final home = await _pumpHome(tester);
      await tester.tap(find.byKey(const Key('update-popup-update')));
      await _settle(tester);
      expect(home.launcher.opened, [_play]);
      expect(home.ads.suppressCalls, 1, reason: 'return is not an app open');
      expect(find.byKey(const Key('update-popup')), findsNothing);
    });

    testWidgets('LATER closes the popup (AC5.1.4)', (tester) async {
      final home = await _pumpHome(tester);
      await tester.tap(find.byKey(const Key('update-popup-later')));
      await _settle(tester);
      expect(find.byKey(const Key('update-popup')), findsNothing);
      expect(home.launcher.opened, isEmpty);
    });

    testWidgets('not shown again in the same app open, then shown after a '
        'new one (AC5.1.2)', (tester) async {
      final home = await _pumpHome(tester);
      await tester.tap(find.byKey(const Key('update-popup-later')));
      await _settle(tester);
      home.ads.notifyBannerChange();
      await _settle(tester);
      expect(find.byKey(const Key('update-popup')), findsNothing);

      home.ads.opens = 2;
      home.ads.notifyBannerChange();
      await _settle(tester);
      expect(find.byKey(const Key('update-popup')), findsOneWidget);
    });

    testWidgets('waits for the consent flow before showing (BR8.5)', (
      tester,
    ) async {
      final ads = FakeAdsService()..settled = false;
      final home = await _pumpHome(tester, ads: ads);
      expect(find.byKey(const Key('update-popup')), findsNothing);
      expect(home.reader.reads, 0);
      ads.settled = true;
      ads.notifyBannerChange();
      await _settle(tester);
      expect(find.byKey(const Key('update-popup')), findsOneWidget);
    });

    testWidgets('a slow version read never blocks PLAY (NFR1.2)', (
      tester,
    ) async {
      final hold = Completer<void>();
      final ads = FakeAdsService(outcome: InterstitialOutcome.notDue)
        ..settled = true;
      useMobileScreen(tester);
      final reader = _SlowReader(hold);
      final services = await buildServices(
        ads: ads,
        adsSettings: _newer,
        updates: AppUpdateChecker(
          settings: _newer,
          reader: reader,
          isIos: () => false,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(home: HomeScreen(services: services)),
      );
      await _settle(tester);
      await tester.tap(find.byKey(const Key('home-play-button')));
      await _settle(tester);
      expect(ads.interstitialCalls, 1);
      hold.complete();
      await _settle(tester);
      expect(
        find.byKey(const Key('update-popup')),
        findsNothing,
        reason: 'Home is no longer on top',
      );
    });
  });
}

class _SlowReader extends FakeInstalledVersionReader {
  _SlowReader(this.hold);

  final Completer<void> hold;

  @override
  Future<String> read() async {
    await hold.future;
    return '1.0.0';
  }
}
