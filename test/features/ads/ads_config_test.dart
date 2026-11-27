import 'package:block_blast/core/log/gj_log.dart';
import 'package:block_blast/features/ads/models/ads_settings.dart';
import 'package:block_blast/features/ads/services/ads_config.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_remote_config_client.dart';

void main() {
  late List<String> logs;
  late GjLogSink previousSink;

  setUp(() {
    logs = <String>[];
    previousSink = GjLog.sink;
    GjLog.sink = logs.add;
  });

  tearDown(() => GjLog.sink = previousSink);

  group('AdsConfig.read', () {
    test('uses valid remote values (BR1.1)', () {
      final client = FakeRemoteConfigClient()
        ..values.addAll(<String, Object>{
          AdsConfigKeys.bannerStartVisit: '5',
          AdsConfigKeys.rewardEnabled: 'false',
          AdsConfigKeys.interstitialEveryNStarts: 4,
          AdsConfigKeys.adsPriority: 'unity,applovin',
          AdsConfigKeys.androidVersion: '1.0.1',
          AdsConfigKeys.androidUrl: 'https://play.google.com/x',
          AdsConfigKeys.iosVersion: '1.0.2',
          AdsConfigKeys.iosUrl: 'https://apps.apple.com/x',
        });

      final settings = AdsConfig.read(client);

      expect(settings.bannerStartVisit, 5);
      expect(settings.rewardEnabled, isFalse);
      expect(settings.interstitialEveryNStarts, 4);
      expect(settings.adsPriority, [AdNetwork.unity, AdNetwork.applovin]);
      expect(settings.androidVersion, '1.0.1');
      expect(settings.iosUrl, 'https://apps.apple.com/x');
      expect(logs, isEmpty);
    });

    test('returns all defaults when no client is available (BR1.2)', () {
      final settings = AdsConfig.read(null);
      expect(settings.bannerStartVisit, 3);
      expect(settings.rewardEnabled, isTrue);
      expect(settings.interstitialEveryNStarts, 3);
      expect(settings.adsPriority, AdsSettings.defaultAdsPriority);
      expect(settings.androidUrl, isEmpty);
    });

    test('returns defaults when nothing was fetched (BR1.2)', () {
      final settings = AdsConfig.read(FakeRemoteConfigClient());
      expect(settings.interstitialEveryNStarts, 3);
      expect(settings.adsPriority, AdsSettings.defaultAdsPriority);
      expect(logs, isEmpty);
    });

    test(
      'replaces a non-positive or non-numeric value and logs it (BR1.3)',
      () {
        final client = FakeRemoteConfigClient()
          ..values.addAll(<String, Object>{
            AdsConfigKeys.bannerStartVisit: '0',
            AdsConfigKeys.interstitialEveryNStarts: 'three',
            AdsConfigKeys.rewardEnabled: 'maybe',
          });

        final settings = AdsConfig.read(client);

        expect(settings.bannerStartVisit, 3);
        expect(settings.interstitialEveryNStarts, 3);
        expect(settings.rewardEnabled, isTrue);
        expect(logs.where((l) => l.contains('[warn]')), hasLength(3));
        // Không ghi giá trị thô vào log.
        expect(logs.join(), isNot(contains('three')));
      },
    );

    test('falls back to defaults when the client throws', () {
      final client = FakeRemoteConfigClient(readError: StateError('boom'));
      final settings = AdsConfig.read(client);
      expect(settings.bannerStartVisit, 3);
      expect(logs.single, contains('using defaults'));
    });
  });

  group('AdsConfig.parsePriority', () {
    test('missing or blank value uses the default order (BR2.2)', () {
      expect(AdsConfig.parsePriority(null), AdsSettings.defaultAdsPriority);
      expect(AdsConfig.parsePriority('  '), AdsSettings.defaultAdsPriority);
    });

    test('ignores unknown names and keeps the rest in order (BR2.3)', () {
      expect(AdsConfig.parsePriority('ironsource, AppLovin ,admob'), [
        AdNetwork.applovin,
        AdNetwork.admob,
      ]);
      expect(logs.single, contains('1 unknown network'));
      expect(logs.single, isNot(contains('ironsource')));
    });

    test('drops duplicates and falls back when nothing is known', () {
      expect(AdsConfig.parsePriority('unity,unity'), [AdNetwork.unity]);
      expect(
        AdsConfig.parsePriority('foo,bar'),
        AdsSettings.defaultAdsPriority,
      );
    });
  });
}
