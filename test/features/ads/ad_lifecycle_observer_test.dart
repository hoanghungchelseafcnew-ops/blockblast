import 'package:block_blast/features/ads/services/ad_lifecycle_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'ads_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdLifecycleObserver', () {
    test('a return from the background is reported once', () {
      final ads = FakeAdsService();
      final observer = AdLifecycleObserver(ads);
      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      observer.didChangeAppLifecycleState(AppLifecycleState.paused);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(ads.resumeCalls, 1);
    });

    test('a short loss of focus is not an app open', () {
      final ads = FakeAdsService();
      final observer = AdLifecycleObserver(ads);
      observer.didChangeAppLifecycleState(AppLifecycleState.inactive);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(ads.resumeCalls, 0);
    });

    test('repeated resumed events after one background count once', () {
      final ads = FakeAdsService();
      final observer = AdLifecycleObserver(ads);
      observer.didChangeAppLifecycleState(AppLifecycleState.hidden);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(ads.resumeCalls, 1);
    });

    test('attach and detach register with the binding', () {
      final ads = FakeAdsService();
      final observer = AdLifecycleObserver(ads)..attach();
      observer.detach();
      expect(ads.resumeCalls, 0);
    });
  });
}
