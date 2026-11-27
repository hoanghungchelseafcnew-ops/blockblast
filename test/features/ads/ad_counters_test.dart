import 'package:block_blast/core/log/gj_log.dart';
import 'package:block_blast/features/ads/services/ad_counters.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';

void main() {
  late List<String> logs;
  late GjLogSink previousSink;

  setUp(() {
    logs = <String>[];
    previousSink = GjLog.sink;
    GjLog.sink = logs.add;
  });

  tearDown(() => GjLog.sink = previousSink);

  group('AdCounters', () {
    test('starts from zero on a fresh install', () async {
      final counters = AdCounters(FakeProgressStore());
      await counters.load();
      expect(counters.appOpenCount, 0);
      expect(counters.startCount, 0);
      expect(counters.interstitialCarriedDue, isFalse);
    });

    test('each start and app open adds exactly one (BR4.1, BR5.1)', () async {
      final store = FakeProgressStore();
      final counters = AdCounters(store);
      await counters.recordStart();
      await counters.recordStart();
      await counters.recordAppOpen();
      expect(counters.startCount, 2);
      expect(counters.appOpenCount, 1);
      expect(store.data[AdCounters.startKey], 2);
      expect(store.data[AdCounters.appOpenKey], 1);
    });

    test(
      'keeps its values after the app is closed and reopened (AC2.1.2)',
      () async {
        final store = FakeProgressStore();
        final first = AdCounters(store);
        await first.recordStart();
        await first.recordStart();
        await first.setInterstitialCarriedDue(true);

        final reopened = AdCounters(store);
        await reopened.recordStart();

        expect(reopened.startCount, 3);
        expect(reopened.interstitialCarriedDue, isTrue);
      },
    );

    test('ignores negative or corrupt stored values', () async {
      final store = FakeProgressStore(
        initial: <String, Object>{
          AdCounters.startKey: -4,
          AdCounters.appOpenKey: 'seven',
        },
      );
      final counters = AdCounters(store);
      await counters.load();
      expect(counters.startCount, 0);
      expect(counters.appOpenCount, 0);
    });

    test('a write failure is logged and does not throw', () async {
      final store = FakeProgressStore()..failingKeys.add(AdCounters.startKey);
      final counters = AdCounters(store);
      await counters.recordStart();
      expect(counters.startCount, 1);
      expect(logs.single, contains('saving ${AdCounters.startKey} failed'));
    });

    test('a store that cannot open still counts in memory', () async {
      final store = FakeProgressStore()..initAlwaysFails = true;
      final counters = AdCounters(store);
      await counters.recordStart();
      await counters.setInterstitialCarriedDue(true);
      expect(counters.startCount, 1);
      expect(counters.interstitialCarriedDue, isTrue);
      expect(store.data, isEmpty);
      expect(logs.single, contains('loading counters failed'));
    });

    test('load runs only once', () async {
      final store = FakeProgressStore();
      final counters = AdCounters(store);
      await Future.wait([counters.load(), counters.load(), counters.load()]);
      expect(store.initCalls, 1);
    });
  });
}
