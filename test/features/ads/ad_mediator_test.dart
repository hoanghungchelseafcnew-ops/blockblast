import 'dart:async';

import 'package:block_blast/core/log/gj_log.dart';
import 'package:block_blast/features/ads/models/ads_settings.dart';
import 'package:block_blast/features/ads/services/ad_counters.dart';
import 'package:block_blast/features/ads/services/ad_mediator.dart';
import 'package:block_blast/features/ads/services/ad_network_adapter.dart';
import 'package:block_blast/features/ads/services/consent_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';
import 'ads_fakes.dart';

void main() {
  late GjLogSink previousSink;

  setUp(() {
    previousSink = GjLog.sink;
    GjLog.sink = (_) {};
  });

  tearDown(() => GjLog.sink = previousSink);

  late FakeProgressStore store;
  late AdCounters counters;

  AdMediator build({
    required List<FakeAdNetwork> networks,
    AdsSettings settings = const AdsSettings(interstitialEveryNStarts: 3),
    FakeConsentGateway? gateway,
    Duration timeout = const Duration(milliseconds: 20),
  }) {
    store = FakeProgressStore();
    counters = AdCounters(store);
    return AdMediator(
      settings: settings,
      counters: counters,
      consent: ConsentService(gateway ?? FakeConsentGateway()),
      adapters: networks,
      perNetworkTimeout: timeout,
    );
  }

  Future<List<InterstitialOutcome>> pressStart(
    AdMediator ads,
    int times,
  ) async {
    final outcomes = <InterstitialOutcome>[];
    for (var i = 0; i < times; i++) {
      outcomes.add(await ads.interstitialIfDue());
      await pumpEventQueue();
    }
    return outcomes;
  }

  group('AdMediator start', () {
    test(
      'counts the cold start, asks consent, then preloads (BR4.6)',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob);
        final gateway = FakeConsentGateway();
        final ads = build(networks: [admob], gateway: gateway);

        await ads.start();

        expect(counters.appOpenCount, 1);
        expect(gateway.calls, 1);
        expect(admob.initCalls, 1);
        expect(ads.interstitialReady, isTrue);
      },
    );

    test(
      'passes the non-personalized choice to every network (NFR2.6)',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob);
        final ads = build(
          networks: [admob],
          gateway: FakeConsentGateway(
            result: const ConsentResult(
              state: ConsentState.denied,
              personalizedAllowed: false,
            ),
          ),
        );
        await ads.start();
        expect(admob.lastPersonalized, isFalse);
        expect(ads.interstitialReady, isTrue);
      },
    );

    test('runs only once', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(networks: [admob]);
      await Future.wait([ads.start(), ads.start()]);
      expect(counters.appOpenCount, 1);
      expect(admob.initCalls, 1);
    });

    test(
      'a network that fails to initialize does not stop the others',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob)
          ..initError = StateError('x');
        final unity = FakeAdNetwork(AdNetwork.unity);
        final ads = build(networks: [admob, unity]);
        await ads.start();
        expect(unity.initCalls, 1);
      },
    );
  });

  group('AdMediator network order (US1.2)', () {
    test('tries networks in ads_priority order (AC1.2.1)', () async {
      final admob = FakeAdNetwork(
        AdNetwork.admob,
        loads: [AdLoadResult.noFill],
      );
      final unity = FakeAdNetwork(AdNetwork.unity);
      final ads = build(
        networks: [admob, unity],
        settings: const AdsSettings(
          adsPriority: [AdNetwork.unity, AdNetwork.admob],
        ),
      );
      await ads.start();
      expect(unity.loadCalls, 1);
      expect(admob.loadCalls, 0);
    });

    test('moves to the next network when the first has no ad', () async {
      final admob = FakeAdNetwork(
        AdNetwork.admob,
        loads: [AdLoadResult.noFill],
      );
      final unity = FakeAdNetwork(AdNetwork.unity);
      final ads = build(networks: [admob, unity]);
      await ads.start();
      expect(admob.loadCalls, 1);
      expect(unity.loadCalls, 1);
      expect(ads.interstitialReady, isTrue);
    });

    test('moves on after the per-network timeout (BR2.5)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)..hangLoad = true;
      final unity = FakeAdNetwork(AdNetwork.unity);
      final ads = build(networks: [admob, unity]);
      await ads.start();
      expect(unity.loadCalls, 1);
      expect(ads.interstitialReady, isTrue);
    });

    test('a throwing network is treated as having no ad (NFR2.1)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)..loadError = StateError('x');
      final ads = build(networks: [admob]);
      await ads.start();
      expect(ads.interstitialReady, isFalse);
    });

    test('no ad anywhere leaves the game running (AC1.2.4)', () async {
      final admob = FakeAdNetwork(
        AdNetwork.admob,
        loads: [AdLoadResult.noFill],
      );
      final ads = build(networks: [admob]);
      await ads.start();
      final outcomes = await pressStart(ads, 3);
      expect(outcomes.last, InterstitialOutcome.skipped);
      expect(admob.showCalls, 0);
    });
  });

  group('AdMediator interstitial (US2.1)', () {
    test('shows on every Nth start and not in between (AC2.1.1)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(networks: [admob]);
      await ads.start();

      final outcomes = await pressStart(ads, 6);

      expect(outcomes, [
        InterstitialOutcome.notDue,
        InterstitialOutcome.notDue,
        InterstitialOutcome.shown,
        InterstitialOutcome.notDue,
        InterstitialOutcome.notDue,
        InterstitialOutcome.shown,
      ]);
      expect(admob.showCalls, 2);
    });

    test(
      'a due turn that is not ready is skipped and carried (BR4.4)',
      () async {
        final admob = FakeAdNetwork(
          AdNetwork.admob,
          loads: [
            AdLoadResult.noFill,
            AdLoadResult.noFill,
            AdLoadResult.noFill,
            AdLoadResult.ready,
          ],
        );
        final ads = build(networks: [admob]);
        await ads.start();

        final outcomes = await pressStart(ads, 4);

        expect(outcomes[2], InterstitialOutcome.skipped);
        expect(outcomes[3], InterstitialOutcome.shown);
        expect(counters.interstitialCarriedDue, isFalse);
      },
    );

    test(
      'never waits for an ad to load before letting the player in',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob)..hangLoad = true;
        final ads = build(
          networks: [admob],
          timeout: const Duration(hours: 1),
          settings: const AdsSettings(interstitialEveryNStarts: 1),
        );
        // Không chờ start: tải trước đang treo.
        unawaited(ads.start());
        await pumpEventQueue();
        final outcome = await ads.interstitialIfDue().timeout(
          const Duration(seconds: 1),
        );
        expect(outcome, InterstitialOutcome.skipped);
      },
    );

    test('no ad is requested before consent is processed (BR3.1)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(
        networks: [admob],
        settings: const AdsSettings(interstitialEveryNStarts: 1),
      );
      final outcome = await ads.interstitialIfDue();
      expect(outcome, InterstitialOutcome.skipped);
      expect(admob.loadCalls, 0);
      expect(admob.showCalls, 0);
    });

    test('a failed show is carried to the next start', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)..showResult = false;
      final ads = build(
        networks: [admob],
        settings: const AdsSettings(interstitialEveryNStarts: 1),
      );
      await ads.start();
      expect(await ads.interstitialIfDue(), InterstitialOutcome.skipped);
      expect(counters.interstitialCarriedDue, isTrue);
    });

    test(
      'two interstitials may follow each other with no gap (AC2.1.5)',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob);
        final ads = build(
          networks: [admob],
          settings: const AdsSettings(interstitialEveryNStarts: 1),
        );
        await ads.start();
        final outcomes = await pressStart(ads, 2);
        expect(outcomes, everyElement(InterstitialOutcome.shown));
      },
    );
  });

  group('AdMediator app opens (BR5.1, BR5.3)', () {
    test('a return from the background counts as an app open', () async {
      final ads = build(networks: [FakeAdNetwork(AdNetwork.admob)]);
      await ads.start();
      await ads.onAppResumed();
      expect(counters.appOpenCount, 2);
    });

    test('the return after an interstitial or share is not counted', () async {
      final ads = build(
        networks: [FakeAdNetwork(AdNetwork.admob)],
        settings: const AdsSettings(interstitialEveryNStarts: 1),
      );
      await ads.start();
      ads.suppressNextResume();
      await ads.onAppResumed();
      expect(counters.appOpenCount, 1);
      await ads.onAppResumed();
      expect(counters.appOpenCount, 2);
    });

    test('the noop service is inactive and never shows anything', () async {
      const noop = NoopAdsService();
      expect(noop.isActive, isFalse);
      expect(await noop.interstitialIfDue(), InterstitialOutcome.notDue);
      await noop.preloadReward();
      expect(await noop.reward(), RewardOutcome.noAd);
    });
  });

  group('AdMediator reward (u2-reward-ads)', () {
    test('preloads the reward at start and an earned view is earned', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(networks: [admob]);
      await ads.start();
      await pumpEventQueue();
      expect(ads.rewardReady, isTrue);

      expect(await ads.reward(), RewardOutcome.earned);
      expect(admob.rewardShowCalls, 1);
    });

    test('closing early is reported so the player can retry (BR6.4)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)
        ..rewardShowResult = RewardShowResult.closedEarly;
      final ads = build(networks: [admob]);
      await ads.start();
      await pumpEventQueue();
      expect(await ads.reward(), RewardOutcome.closedEarly);
    });

    test(
      'no ready ad returns noAd at once without waiting (ADR-007)',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob)..hangRewardLoad = true;
        final ads = build(networks: [admob], timeout: const Duration(hours: 1));
        await ads.start();
        final outcome = await ads.reward().timeout(const Duration(seconds: 1));
        expect(outcome, RewardOutcome.noAd);
        expect(admob.rewardShowCalls, 0);
      },
    );

    test('tries the next network when the first has no reward ad', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)
        ..rewardLoads = [AdLoadResult.noFill];
      final unity = FakeAdNetwork(AdNetwork.unity);
      final ads = build(networks: [admob, unity]);
      await ads.start();
      await pumpEventQueue();
      expect(admob.rewardLoadCalls, 1);
      expect(unity.rewardLoadCalls, 1);
      expect(await ads.reward(), RewardOutcome.earned);
      expect(unity.rewardShowCalls, 1);
    });

    test('loads a new reward ad after one is shown', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(networks: [admob]);
      await ads.start();
      await pumpEventQueue();
      await ads.reward();
      await pumpEventQueue();
      expect(admob.rewardLoadCalls, 2);
      expect(ads.rewardReady, isTrue);
    });

    test(
      'no reward ad is requested before consent is processed (BR3.1)',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob);
        final ads = build(networks: [admob]);
        await ads.preloadReward();
        expect(await ads.reward(), RewardOutcome.noAd);
        expect(admob.rewardLoadCalls, 0);
      },
    );

    test('a failing show counts as no ad (NFR2.1, ADR-007)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)
        ..rewardShowError = StateError('x');
      final ads = build(networks: [admob]);
      await ads.start();
      await pumpEventQueue();
      expect(await ads.reward(), RewardOutcome.noAd);
    });

    test('nothing is loaded when reward_enabled is false (FR3.2)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(
        networks: [admob],
        settings: const AdsSettings(rewardEnabled: false),
      );
      await ads.start();
      await ads.preloadReward();
      expect(admob.rewardLoadCalls, 0);
    });
  });

  group('AdMediator banner (u3-banner)', () {
    const reached = AdsSettings(bannerStartVisit: 1);

    test('hidden before the Nth app open (AC4.1.1)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(
        networks: [admob],
        settings: const AdsSettings(bannerStartVisit: 3),
      );
      await ads.start();
      expect(ads.bannerEligible, isFalse);
      final result = await ads.banner(360);
      expect(result.isShown, isFalse);
      expect(admob.bannerLoadCalls, 0);
    });

    test('shown from the Nth app open, counting returns (AC4.1.2)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob);
      final ads = build(
        networks: [admob],
        settings: const AdsSettings(bannerStartVisit: 2),
      );
      await ads.start();
      await ads.onAppResumed();
      expect(ads.bannerEligible, isTrue);
      final result = await ads.banner(360);
      expect(result.isShown, isTrue);
      expect(result.banner!.height, 50);
    });

    test(
      'no banner is requested before consent is processed (NFR2.19)',
      () async {
        final admob = FakeAdNetwork(AdNetwork.admob);
        final ads = build(networks: [admob], settings: reached);
        expect((await ads.banner(360)).isShown, isFalse);
        expect(admob.bannerLoadCalls, 0);
      },
    );

    test('tries the next network in ads_priority (BR7.3)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)..bannerHeight = null;
      final applovin = FakeAdNetwork(AdNetwork.applovin);
      final ads = build(networks: [admob, applovin], settings: reached);
      await ads.start();
      final result = await ads.banner(360);
      expect(admob.bannerLoadCalls, 1);
      expect(applovin.bannerLoadCalls, 1);
      expect(result.isShown, isTrue);
    });

    test('a hanging network times out and a late banner is disposed', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)
        ..holdBanner = Completer<void>();
      final ads = build(networks: [admob], settings: reached);
      await ads.start();
      expect((await ads.banner(360)).isShown, isFalse);
      admob.holdBanner!.complete();
      await pumpEventQueue();
      expect(admob.banners.single.disposeCalls, 1);
    });

    test('a throwing network leaves the banner hidden (NFR2.20)', () async {
      final admob = FakeAdNetwork(AdNetwork.admob)
        ..bannerError = StateError('x');
      final ads = build(networks: [admob], settings: reached);
      await ads.start();
      expect((await ads.banner(360)).isShown, isFalse);
    });

    test(
      'notifies after start and after each counted app open (BR7.2)',
      () async {
        final ads = build(
          networks: [FakeAdNetwork(AdNetwork.admob)],
          settings: reached,
        );
        var notified = 0;
        ads.bannerChanges.addListener(() => notified++);
        await ads.start();
        expect(notified, 1);
        await ads.onAppResumed();
        expect(notified, 2);
      },
    );

    test('the noop service never offers a banner', () async {
      const noop = NoopAdsService();
      expect(noop.bannerEligible, isFalse);
      expect((await noop.banner(360)).isShown, isFalse);
      noop.bannerChanges.addListener(() {});
      noop.bannerChanges.removeListener(() {});
    });
  });

  group('AdMediator for the update popup (u4-update-and-share)', () {
    test(
      'reports app opens and when startup is settled (BR8.4, BR8.5)',
      () async {
        final ads = build(networks: [FakeAdNetwork(AdNetwork.admob)]);
        expect(ads.startupSettled, isFalse);
        await ads.start();
        expect(ads.startupSettled, isTrue);
        expect(ads.appOpenCount, 1);
        await ads.onAppResumed();
        expect(ads.appOpenCount, 2);
      },
    );

    test('startup is settled even when consent fails', () async {
      final ads = build(
        networks: [FakeAdNetwork(AdNetwork.admob)],
        gateway: FakeConsentGateway(error: StateError('x')),
      );
      await ads.start();
      expect(ads.startupSettled, isTrue);
    });

    test('the noop service is always settled with no opens', () {
      const noop = NoopAdsService();
      expect(noop.startupSettled, isTrue);
      expect(noop.appOpenCount, 0);
    });
  });
}
