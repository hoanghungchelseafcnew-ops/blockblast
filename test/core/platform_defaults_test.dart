import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/core/utils/clock.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/log_capture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SystemClock', () {
    test('returns the current wall-clock time', () {
      const clock = SystemClock();
      final before = DateTime.now();
      final now = clock.now();
      final after = DateTime.now();
      expect(now.isBefore(before), isFalse);
      expect(now.isAfter(after), isFalse);
    });

    test('is usable through the Clock interface', () {
      const Clock clock = SystemClock();
      expect(clock.now(), isA<DateTime>());
    });
  });

  group('FirebaseGateway default initializer (BR1.5)', () {
    test(
      'without a Firebase platform it reports failed instead of throwing',
      () async {
        final log = LogCapture()..start();
        final gateway = FirebaseGateway();
        // init() must complete (never throw) even though no plugin is present.
        final status = await gateway.init();
        expect(status, isNot(FirebaseStatus.ok));
        expect(log.leaksUrlOrRawJson, isFalse);
      },
    );
  });
}
