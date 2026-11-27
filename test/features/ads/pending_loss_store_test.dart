import 'package:block_blast/core/log/gj_log.dart';
import 'package:block_blast/features/ads/services/pending_loss_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';

void main() {
  late GjLogSink previousSink;
  late List<String> logs;

  setUp(() {
    previousSink = GjLog.sink;
    logs = <String>[];
    GjLog.sink = logs.add;
  });

  tearDown(() => GjLog.sink = previousSink);

  group('PendingLossStore (BR6.7)', () {
    test('a mark survives a new store instance', () async {
      final store = FakeProgressStore();
      expect(await PendingLossStore(store).mark(7, 420), isTrue);

      final pending = await PendingLossStore(store).read();
      expect(pending?.levelIndex, 7);
      expect(pending?.score, 420);
    });

    test('reads null when nothing is marked', () async {
      expect(await PendingLossStore(FakeProgressStore()).read(), isNull);
    });

    test('clear removes the mark', () async {
      final store = FakeProgressStore();
      final pending = PendingLossStore(store);
      await pending.mark(3, 10);
      await pending.clear();
      expect(await pending.read(), isNull);
      expect(store.removed, [PendingLossStore.key]);
    });

    test('an invalid stored value is ignored and logged', () async {
      for (final raw in <Object>['x', '0:5', '4:-1', '4', 12]) {
        final store = FakeProgressStore(initial: {PendingLossStore.key: raw});
        expect(await PendingLossStore(store).read(), isNull, reason: '$raw');
      }
      expect(logs.where((l) => l.contains('invalid')), isNotEmpty);
    });

    test('a failed write returns false and does not throw', () async {
      final store = FakeProgressStore()..failingKeys.add(PendingLossStore.key);
      expect(await PendingLossStore(store).mark(2, 5), isFalse);
      expect(
        logs.where((l) => l.contains('saving pending loss failed')),
        isNotEmpty,
      );
    });

    test('a store that cannot open behaves as empty', () async {
      final store = FakeProgressStore()..initAlwaysFails = true;
      final pending = PendingLossStore(store);
      expect(await pending.mark(2, 5), isFalse);
      expect(await pending.read(), isNull);
      await pending.clear();
      expect(store.initCalls, 1);
    });

    test('a failed clear is logged and does not throw', () async {
      final store = FakeProgressStore()
        ..failingRemovals.add(PendingLossStore.key);
      await PendingLossStore(store).clear();
      expect(
        logs.where((l) => l.contains('clearing pending loss failed')),
        isNotEmpty,
      );
    });
  });
}
