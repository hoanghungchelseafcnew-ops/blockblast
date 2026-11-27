import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:block_blast/core/analytics/analytics_service.dart';
import 'package:block_blast/core/config/level_config.dart';
import 'package:block_blast/core/config/level_config_service.dart';
import 'package:block_blast/core/config/remote_config_client.dart';
import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/features/ads/models/ads_settings.dart';
import 'package:block_blast/features/ads/services/ad_mediator.dart';
import 'package:block_blast/features/ads/services/ads_config.dart';
import 'package:block_blast/features/ads/services/pending_loss_store.dart';
import 'package:block_blast/features/update/services/app_update_checker.dart';
import 'package:block_blast/features/journey/services/app_bootstrap.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_analytics.dart';
import '../../fakes/fake_clock.dart';
import '../../fakes/fake_progress_store.dart';
import '../../fakes/fake_remote_config_client.dart';
import '../../fakes/log_capture.dart';

String _remoteJson(int rough) {
  final cfg =
      jsonDecode(
            File('test/fixtures/level_config_valid.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  ((cfg['levels'] as Map<String, dynamic>)['rose_quartz']
          as Map<
            String,
            dynamic
          >)['sub_levels']['rough_stone']['target_score'] =
      rough;
  return jsonEncode(cfg);
}

const _savedProgress =
    '{"currentLevelIndex":4,"completedLevels":[1,2,3],"unlockedGems":[],'
    '"journeyCompleted":false,"highestLevelReached":4}';

AppBootstrap _bootstrap({
  required FirebaseGateway gateway,
  required FakeProgressStore store,
  RemoteConfigClient Function()? factory,
  FakeClock? clock,
  Duration deadline = const Duration(milliseconds: 3500),
  Duration progressTimeout = const Duration(milliseconds: 500),
  Duration fetchMax = const Duration(seconds: 2),
  AnalyticsService Function()? analytics,
  AdsService Function(AdsSettings settings)? ads,
  PendingLossStore? pendingLoss,
  AppUpdateChecker Function(AdsSettings settings)? updates,
}) {
  return AppBootstrap(
    gateway: gateway,
    remoteConfigFactory: factory ?? () => FakeRemoteConfigClient(),
    progress: ProgressRepository(store),
    clock: clock ?? FakeClock(),
    analyticsFactory: analytics ?? FakeAnalytics.new,
    deadline: deadline,
    progressTimeout: progressTimeout,
    fetchMax: fetchMax,
    adsFactory: ads,
    pendingLoss: pendingLoss,
    updateCheckerFactory: updates,
  );
}

FirebaseGateway _okGateway() => FirebaseGateway(initializer: () async {});

int _roughTarget(BootstrapResult r) =>
    r.services.catalog.byIndex(1).targetScore;

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  group('AppBootstrap analytics (C4, E2 config_source)', () {
    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('Firebase ok: the Firebase analytics is used and config_source is '
        'sent once', () async {
      final fake = FakeAnalytics();
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
        analytics: () => fake,
      ).run();
      await settle();
      expect(identical(result.services.analytics, fake), isTrue);
      expect(fake.configSource, isNotNull);
      expect(['remote', 'cached', 'default'], contains(fake.configSource));
      expect(result.services.session, isNotNull);
    });

    test(
      'Firebase failed: analytics is a no-op and nothing is built',
      () async {
        var built = 0;
        final result = await _bootstrap(
          gateway: FirebaseGateway(
            initializer: () async => throw StateError('no firebase'),
          ),
          store: FakeProgressStore(),
          analytics: () {
            built++;
            return FakeAnalytics();
          },
        ).run();
        expect(result.services.analytics, isA<NoopAnalyticsService>());
        expect(built, 0);
      },
    );

    test(
      'a failing analytics factory falls back to no-op with a log',
      () async {
        final result = await _bootstrap(
          gateway: _okGateway(),
          store: FakeProgressStore(),
          analytics: () => throw StateError('sdk missing'),
        ).run();
        expect(result.services.analytics, isA<NoopAnalyticsService>());
        expect(log.where('analytics unavailable'), hasLength(1));
      },
    );
  });

  group('AppBootstrap (WF1)', () {
    test(
      'everything succeeds: remote config, saved progress, 36 levels',
      () async {
        final store = FakeProgressStore(
          initial: {ProgressRepository.progressKey: _savedProgress},
        );
        final result = await _bootstrap(
          gateway: _okGateway(),
          store: store,
          factory: () =>
              FakeRemoteConfigClient(valueAfterFetch: _remoteJson(300)),
        ).run();

        expect(result.firebase, FirebaseStatus.ok);
        expect(result.fetch, FetchStatus.ok);
        expect(result.deadlineHit, isFalse);
        expect(result.services.config.source, ConfigSource.remote);
        expect(_roughTarget(result), 300);
        expect(result.services.catalog.levels.length, 36);
        expect(result.services.progress.progress.currentLevelIndex, 4);
        expect(result.services.journey.currentLevel.levelIndex, 4);
        expect(log.where('config_source=remote'), hasLength(1));
        expect(log.where('bootstrap done in'), hasLength(1));
        expect(log.where('firebase=ok, fetch=ok'), hasLength(1));
      },
    );

    test(
      'Firebase init failure plays offline with the default config (BR1.5)',
      () async {
        var factoryCalls = 0;
        final result = await _bootstrap(
          gateway: FirebaseGateway(
            initializer: () async => throw StateError('x'),
          ),
          store: FakeProgressStore(
            initial: {ProgressRepository.progressKey: _savedProgress},
          ),
          factory: () {
            factoryCalls++;
            return FakeRemoteConfigClient();
          },
        ).run();

        expect(result.firebase, FirebaseStatus.failed);
        expect(result.fetch, FetchStatus.skipped);
        expect(factoryCalls, 0, reason: 'Remote Config must not be touched');
        expect(result.services.config.source, ConfigSource.defaults);
        expect(_roughTarget(result), 500);
        expect(
          result.services.progress.progress.currentLevelIndex,
          4,
          reason: 'saved progress is still restored offline',
        );
        expect(log.where('config_source=default'), hasLength(1));
      },
    );

    test(
      'a hanging Firebase init times out and uses the default config',
      () async {
        final result = await _bootstrap(
          gateway: FirebaseGateway(
            initializer: () => Completer<void>().future,
            timeout: const Duration(milliseconds: 30),
          ),
          store: FakeProgressStore(),
        ).run();

        expect(result.firebase, FirebaseStatus.timeout);
        expect(result.services.config.source, ConfigSource.defaults);
        expect(result.deadlineHit, isFalse);
      },
    );

    test('a hanging fetch falls back to the cached config', () async {
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
        fetchMax: const Duration(milliseconds: 30),
        factory: () => FakeRemoteConfigClient(
          activatedValue: _remoteJson(450),
          hangFetch: true,
        ),
      ).run();

      expect(result.fetch, FetchStatus.timeout);
      expect(result.services.config.source, ConfigSource.cached);
      expect(_roughTarget(result), 450);
    });

    test(
      'a hanging fetch with nothing cached falls back to the default',
      () async {
        final result = await _bootstrap(
          gateway: _okGateway(),
          store: FakeProgressStore(),
          fetchMax: const Duration(milliseconds: 30),
          factory: () => FakeRemoteConfigClient(hangFetch: true),
        ).run();

        expect(result.services.config.source, ConfigSource.defaults);
        expect(_roughTarget(result), 500);
      },
    );

    test(
      'a failing Remote Config factory degrades to the default config',
      () async {
        final result = await _bootstrap(
          gateway: _okGateway(),
          store: FakeProgressStore(),
          factory: () => throw StateError('no instance'),
        ).run();

        expect(result.fetch, FetchStatus.error);
        expect(result.services.config.source, ConfigSource.defaults);
        expect(log.where('remote config unavailable'), hasLength(1));
      },
    );

    test(
      'the fetch is skipped when Firebase init used up the budget (fake clock)',
      () async {
        final clock = FakeClock();
        final client = FakeRemoteConfigClient(
          activatedValue: _remoteJson(410),
          valueAfterFetch: _remoteJson(999),
        );
        final result = await _bootstrap(
          clock: clock,
          gateway: FirebaseGateway(
            initializer: () async {
              clock.advance(const Duration(milliseconds: 3200));
            },
          ),
          store: FakeProgressStore(),
          factory: () => client,
        ).run();

        expect(result.fetch, FetchStatus.skipped);
        expect(client.fetchCalls, 0);
        expect(result.services.config.source, ConfigSource.cached);
        expect(_roughTarget(result), 410);
        expect(
          result.elapsed,
          lessThanOrEqualTo(const Duration(milliseconds: 3500)),
        );
      },
    );

    test('the fetch budget leaves 0.5s for local reads (fake clock)', () async {
      final clock = FakeClock();
      final client = FakeRemoteConfigClient(valueAfterFetch: _remoteJson(321));
      // 3500 - 500 - 2900 = 100ms còn lại: vẫn đủ để fetch giả (tức thì).
      final result = await _bootstrap(
        clock: clock,
        gateway: FirebaseGateway(
          initializer: () async {
            clock.advance(const Duration(milliseconds: 2900));
          },
        ),
        store: FakeProgressStore(),
        factory: () => client,
      ).run();
      expect(client.fetchCalls, 1);
      expect(result.fetch, FetchStatus.ok);
      expect(_roughTarget(result), 321);

      // 3500 - 500 - 3000 = 0: bị bỏ qua.
      final clock2 = FakeClock();
      final client2 = FakeRemoteConfigClient(valueAfterFetch: _remoteJson(321));
      final skipped = await _bootstrap(
        clock: clock2,
        gateway: FirebaseGateway(
          initializer: () async {
            clock2.advance(const Duration(milliseconds: 3000));
          },
        ),
        store: FakeProgressStore(),
        factory: () => client2,
      ).run();
      expect(client2.fetchCalls, 0);
      expect(skipped.fetch, FetchStatus.skipped);
    });

    test(
      'the deadline cuts a stuck step and the app still enters Home',
      () async {
        final store = FakeProgressStore(
          initial: {ProgressRepository.progressKey: _savedProgress},
        );
        final stopwatch = Stopwatch()..start();
        final result = await _bootstrap(
          deadline: const Duration(milliseconds: 80),
          gateway: FirebaseGateway(
            initializer: () => Future<void>.delayed(const Duration(seconds: 2)),
            timeout: const Duration(seconds: 5),
          ),
          store: store,
        ).run();
        stopwatch.stop();

        expect(result.deadlineHit, isTrue);
        expect(stopwatch.elapsedMilliseconds, lessThan(1500));
        expect(result.services.config.source, ConfigSource.defaults);
        expect(result.services.catalog.levels.length, 36);
        // Chưa đọc được tiến trình thật nên không được ghi đè: chỉ-đọc.
        expect(result.services.progress.isReadOnly, isTrue);
        expect(result.services.progress.progress.currentLevelIndex, 1);
        expect(log.where('deadline reached'), hasLength(1));
      },
    );

    test(
      'a slow local read is cut at its own budget and goes read-only',
      () async {
        final store = FakeProgressStore()..initHangs = true;
        final result = await _bootstrap(
          gateway: _okGateway(),
          store: store,
          progressTimeout: const Duration(milliseconds: 40),
        ).run();

        expect(result.deadlineHit, isFalse);
        expect(result.services.progress.isReadOnly, isTrue);
        expect(result.services.progress.isLoaded, isTrue);
        expect(log.where('progress load timed out'), hasLength(1));
      },
    );
  });

  group('AppBootstrap ads (u1-ads-core)', () {
    test('without an ads factory the app has no ads', () async {
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
      ).run();
      expect(result.services.ads, isA<NoopAdsService>());
      expect(result.services.adsSettings.interstitialEveryNStarts, 3);
    });

    test('reads ad settings from the fetched config (BR1.1)', () async {
      AdsSettings? received;
      final client = FakeRemoteConfigClient()
        ..values[AdsConfigKeys.interstitialEveryNStarts] = '5'
        ..values[AdsConfigKeys.adsPriority] = 'applovin';
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
        factory: () => client,
        ads: (settings) {
          received = settings;
          return const NoopAdsService();
        },
      ).run();
      expect(received!.interstitialEveryNStarts, 5);
      expect(received!.adsPriority, [AdNetwork.applovin]);
      expect(result.services.adsSettings.interstitialEveryNStarts, 5);
    });

    test('uses ad defaults when Firebase is down (BR1.2)', () async {
      AdsSettings? received;
      await _bootstrap(
        gateway: FirebaseGateway(
          initializer: () async => throw StateError('offline'),
        ),
        store: FakeProgressStore(),
        ads: (settings) {
          received = settings;
          return const NoopAdsService();
        },
      ).run();
      expect(received!.interstitialEveryNStarts, 3);
      expect(received!.adsPriority, AdsSettings.defaultAdsPriority);
    });

    test('a failing ads factory falls back to no ads (NFR2.1)', () async {
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
        ads: (_) => throw StateError('sdk missing'),
      ).run();
      expect(result.services.ads, isA<NoopAdsService>());
      expect(log.where('ads unavailable'), hasLength(1));
    });

    test('building ads does not slow the deadline (NFR1.1)', () async {
      final stopwatch = Stopwatch()..start();
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
        ads: (settings) => AdMediatorProbe(),
      ).run();
      expect(result.deadlineHit, isFalse);
      expect(result.services.ads, isA<AdMediatorProbe>());
      expect(stopwatch.elapsedMilliseconds, lessThan(1500));
    });
  });

  _pendingLossTests(() => log);
  _updateTests();
}

void _updateTests() {
  group('AppBootstrap update checker (u4-update-and-share)', () {
    test('no factory means no update check', () async {
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
      ).run();
      expect(result.services.updates, isNull);
    });

    test('the factory receives the ad settings read at start-up', () async {
      AdsSettings? received;
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
        updates: (settings) {
          received = settings;
          return AppUpdateChecker(settings: settings);
        },
      ).run();
      expect(result.services.updates, isNotNull);
      expect(received, same(result.services.adsSettings));
    });

    test('a failing factory falls back to no update check', () async {
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: FakeProgressStore(),
        updates: (_) => throw StateError('x'),
      ).run();
      expect(result.services.updates, isNull);
    });
  });
}

void _pendingLossTests(LogCapture Function() log) {
  // Level 6 = Rose Quartz · Bling; Rough Stone của Rose Quartz là level 1.
  const atLevel6 =
      '{"currentLevelIndex":6,"completedLevels":[1,2,3,4,5],'
      '"unlockedGems":[],"journeyCompleted":false,"highestLevelReached":6}';

  group('AppBootstrap pending loss (u2-reward-ads, BR6.7)', () {
    test('a pending loss is recorded and cleared before Home', () async {
      final pendingStore = FakeProgressStore(
        initial: {PendingLossStore.key: '6:250'},
      );
      final store = FakeProgressStore(
        initial: {ProgressRepository.progressKey: atLevel6},
      );
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: store,
        pendingLoss: PendingLossStore(pendingStore),
      ).run();
      final progress = result.services.progress;
      expect(progress.progress.currentLevelIndex, 1);
      expect(progress.highScore(6), 250);
      expect(pendingStore.data.containsKey(PendingLossStore.key), isFalse);
      expect(result.services.pendingLoss, isNotNull);
    });

    test('no mark leaves the progress unchanged', () async {
      final store = FakeProgressStore(
        initial: {ProgressRepository.progressKey: atLevel6},
      );
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: store,
        pendingLoss: PendingLossStore(FakeProgressStore()),
      ).run();
      expect(result.services.progress.progress.currentLevelIndex, 6);
    });

    test('a store that fails to open does not block start-up', () async {
      final pendingStore = FakeProgressStore()..initHangs = true;
      final store = FakeProgressStore(
        initial: {ProgressRepository.progressKey: atLevel6},
      );
      final result = await _bootstrap(
        gateway: _okGateway(),
        store: store,
        pendingLoss: PendingLossStore(pendingStore),
        progressTimeout: const Duration(milliseconds: 50),
      ).run();
      expect(result.services.progress.progress.currentLevelIndex, 6);
      expect(
        log().lines.where((l) => l.contains('pending loss not recorded')),
        isNotEmpty,
      );
    });
  });
}

/// Dịch vụ quảng cáo có `start()` không bao giờ xong: bootstrap không được
/// chờ nó.
class AdMediatorProbe extends AdsService {
  @override
  bool get isActive => true;

  @override
  Future<void> start() => Completer<void>().future;

  @override
  Future<InterstitialOutcome> interstitialIfDue() async =>
      InterstitialOutcome.notDue;

  @override
  Future<void> preloadReward() async {}

  @override
  Future<RewardOutcome> reward() async => RewardOutcome.noAd;

  @override
  bool get bannerEligible => false;

  @override
  Listenable get bannerChanges => ChangeNotifier();

  @override
  Future<BannerResult> banner(double width) async =>
      const BannerResult.hidden();

  @override
  int get appOpenCount => 0;

  @override
  bool get startupSettled => false;

  @override
  Future<void> onAppResumed() async {}

  @override
  void suppressNextResume() {}
}
