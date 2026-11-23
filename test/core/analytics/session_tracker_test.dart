import 'package:block_blast/core/analytics/session_tracker.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_analytics.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';

class _Harness {
  _Harness(this.tracker, this.analytics, this.repo, this.store, this.clock);

  final SessionTracker tracker;
  final FakeAnalytics analytics;
  final ProgressRepository repo;
  final FakeProgressStore store;
  final FakeClock clock;

  static Future<_Harness> create() async {
    final store = FakeProgressStore();
    final repo = ProgressRepository(store);
    await repo.load();
    final analytics = FakeAnalytics();
    final clock = FakeClock();
    return _Harness(
      SessionTracker(analytics: analytics, progress: repo, clock: clock),
      analytics,
      repo,
      store,
      clock,
    );
  }
}

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  test('90 seconds then paused sends game_session and adds play time '
      '(AC6.4.1, AC1.6.2)', () async {
    final h = await _Harness.create();
    h.tracker.start();
    h.clock.advance(const Duration(seconds: 90));
    await h.tracker.pause();
    expect(h.analytics.sessions, [90]);
    expect(h.repo.totalPlayTime, 90);
    expect(h.store.data[ProgressRepository.totalPlayTimeKey], 90);
    expect(h.tracker.isRunning, isFalse);
  });

  test('paused twice counts the session once', () async {
    final h = await _Harness.create();
    h.tracker.start();
    h.clock.advance(const Duration(seconds: 30));
    await h.tracker.pause();
    h.clock.advance(const Duration(seconds: 30));
    await h.tracker.pause();
    expect(h.analytics.sessions, [30]);
    expect(h.repo.totalPlayTime, 30);
  });

  test('resumed starts a new session that adds up', () async {
    final h = await _Harness.create();
    h.tracker.start();
    h.clock.advance(const Duration(seconds: 40));
    await h.tracker.pause();
    h.clock.advance(const Duration(minutes: 10)); // nằm nền, không tính
    h.tracker.start();
    h.clock.advance(const Duration(seconds: 20));
    await h.tracker.pause();
    expect(h.analytics.sessions, [40, 20]);
    expect(h.repo.totalPlayTime, 60);
  });

  test('start while running keeps the first start time', () async {
    final h = await _Harness.create();
    h.tracker.start();
    h.clock.advance(const Duration(seconds: 10));
    h.tracker.start();
    h.clock.advance(const Duration(seconds: 5));
    await h.tracker.pause();
    expect(h.analytics.sessions, [15]);
  });

  test('a session under one second sends nothing', () async {
    final h = await _Harness.create();
    h.tracker.start();
    h.clock.advance(const Duration(milliseconds: 400));
    await h.tracker.pause();
    expect(h.analytics.sessions, isEmpty);
    expect(h.store.attempts, isEmpty);
  });

  test('pause without start does nothing', () async {
    final h = await _Harness.create();
    await h.tracker.pause();
    expect(h.analytics.sessions, isEmpty);
    expect(log.lines, isEmpty);
  });

  test('a failing play-time write still sends the event', () async {
    final h = await _Harness.create();
    h.store.failingKeys.add(ProgressRepository.totalPlayTimeKey);
    h.tracker.start();
    h.clock.advance(const Duration(seconds: 12));
    await h.tracker.pause();
    expect(h.analytics.sessions, [12]);
    expect(h.repo.dirtyKeys, {ProgressRepository.totalPlayTimeKey});
  });
}
