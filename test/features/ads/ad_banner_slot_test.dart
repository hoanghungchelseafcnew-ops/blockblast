import 'dart:async';

import 'package:block_blast/features/ads/services/ad_mediator.dart';
import 'package:block_blast/features/ads/widgets/ad_banner_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';
import 'ads_fakes.dart';

Future<void> _pumpSlot(WidgetTester tester, AdsService ads) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            const Expanded(child: SizedBox(key: Key('board'))),
            AdBannerSlot(ads: ads),
          ],
        ),
      ),
    ),
  );
}

double _slotHeight(WidgetTester tester) =>
    tester.getSize(find.byType(AdBannerSlot)).height;

void main() {
  setUp(() => LogCapture().start());

  group('AdBannerSlot (u3-banner)', () {
    testWidgets('takes no space when not eligible (AC4.1.1)', (tester) async {
      final ads = FakeAdsService();
      await _pumpSlot(tester, ads);
      await tester.pump();
      expect(_slotHeight(tester), 0);
      expect(ads.bannerCalls, 0);
    });

    testWidgets('shows the banner at its height when eligible (AC4.1.2)', (
      tester,
    ) async {
      final ads = FakeAdsService()
        ..eligible = true
        ..bannerResultHeight = 60;
      await _pumpSlot(tester, ads);
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const Key('ad-banner-slot')), findsOneWidget);
      expect(_slotHeight(tester), 60);
    });

    testWidgets('no space while loading, then grows once (BR7.4)', (
      tester,
    ) async {
      final ads = FakeAdsService()
        ..eligible = true
        ..holdBanner = Completer<void>();
      await _pumpSlot(tester, ads);
      await tester.pump();
      expect(_slotHeight(tester), 0);
      ads.holdBanner!.complete();
      await tester.pump();
      await tester.pump();
      expect(_slotHeight(tester), 50);
    });

    testWidgets('hidden result takes no space and is not retried (BR7.5)', (
      tester,
    ) async {
      final ads = FakeAdsService()
        ..eligible = true
        ..bannerResultHeight = null;
      await _pumpSlot(tester, ads);
      await tester.pump();
      ads.notifyBannerChange();
      await tester.pump();
      expect(_slotHeight(tester), 0);
      expect(ads.bannerCalls, 1);
    });

    testWidgets('reaching the threshold while open loads at once (BR7.2)', (
      tester,
    ) async {
      final ads = FakeAdsService();
      await _pumpSlot(tester, ads);
      await tester.pump();
      expect(ads.bannerCalls, 0);
      ads.eligible = true;
      ads.notifyBannerChange();
      await tester.pump();
      await tester.pump();
      expect(ads.bannerCalls, 1);
      expect(_slotHeight(tester), 50);
    });

    testWidgets('rebuilding keeps the same banner (BR7.7)', (tester) async {
      final ads = FakeAdsService()..eligible = true;
      await _pumpSlot(tester, ads);
      await tester.pump();
      await tester.pump();
      await _pumpSlot(tester, ads);
      ads.notifyBannerChange();
      await tester.pump();
      expect(ads.bannerCalls, 1);
    });

    testWidgets('closing the screen disposes the banner (NFR2.21)', (
      tester,
    ) async {
      final ads = FakeAdsService()..eligible = true;
      await _pumpSlot(tester, ads);
      await tester.pump();
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      expect(ads.banners.single.disposeCalls, 1);
    });

    testWidgets('a banner that arrives after closing is disposed', (
      tester,
    ) async {
      final ads = FakeAdsService()
        ..eligible = true
        ..holdBanner = Completer<void>();
      await _pumpSlot(tester, ads);
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
      ads.holdBanner!.complete();
      await tester.pump();
      expect(ads.banners.single.disposeCalls, 1);
    });
  });
}
