import 'dart:convert';

import 'package:block_blast/core/config/remote_config_client.dart';
import 'package:block_blast/core/firebase/firebase_remote_config_client.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake tối thiểu của SDK: chỉ ba hàm mà adapter dùng.
class _FakeFirebaseRemoteConfig implements FirebaseRemoteConfig {
  RemoteConfigSettings? appliedSettings;
  int fetchCalls = 0;
  bool fetchResult = true;
  RemoteConfigValue value = RemoteConfigValue(null, ValueSource.valueStatic);

  /// Giá trị theo khóa cho các tham số ngoài `level_config` (u1-ads-core).
  final Map<String, RemoteConfigValue> byKey = <String, RemoteConfigValue>{};

  @override
  Future<void> setConfigSettings(RemoteConfigSettings configSettings) async {
    appliedSettings = configSettings;
  }

  @override
  Future<bool> fetchAndActivate() async {
    fetchCalls++;
    return fetchResult;
  }

  @override
  RemoteConfigValue getValue(String key) {
    final keyed = byKey[key];
    if (keyed != null) return keyed;
    expect(key, levelConfigKey);
    return value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeFirebaseRemoteConfig sdk;
  late FirebaseRemoteConfigClient client;

  setUp(() {
    sdk = _FakeFirebaseRemoteConfig();
    client = FirebaseRemoteConfigClient(instance: sdk);
  });

  group('FirebaseRemoteConfigClient', () {
    test(
      'configure sets a 12 hour minimum fetch interval and a 2 second timeout',
      () async {
        await client.configure();
        expect(
          sdk.appliedSettings!.minimumFetchInterval,
          const Duration(hours: 12),
        );
        expect(sdk.appliedSettings!.fetchTimeout, const Duration(seconds: 2));
      },
    );

    test(
      'fetchAndActivate delegates to the SDK and returns its result',
      () async {
        expect(await client.fetchAndActivate(), isTrue);
        sdk.fetchResult = false;
        expect(await client.fetchAndActivate(), isFalse);
        expect(sdk.fetchCalls, 2);
      },
    );

    test('readLevelConfig returns the remote value as text', () {
      sdk.value = RemoteConfigValue(
        utf8.encode('{"version":1}'),
        ValueSource.valueRemote,
      );
      expect(client.readLevelConfig(), '{"version":1}');
    });

    test('readLevelConfig ignores static and default values', () {
      sdk.value = RemoteConfigValue(
        utf8.encode('{"version":1}'),
        ValueSource.valueDefault,
      );
      expect(client.readLevelConfig(), isNull);
      sdk.value = RemoteConfigValue(null, ValueSource.valueStatic);
      expect(client.readLevelConfig(), isNull);
    });

    test('readLevelConfig treats an empty remote value as missing', () {
      sdk.value = RemoteConfigValue(utf8.encode(''), ValueSource.valueRemote);
      expect(client.readLevelConfig(), isNull);
    });
  });

  group('FirebaseRemoteConfigClient typed reads (u1-ads-core)', () {
    RemoteConfigValue remote(String text) =>
        RemoteConfigValue(utf8.encode(text), ValueSource.valueRemote);

    test('readString returns remote text and ignores default values', () {
      sdk.byKey['ads_priority'] = remote('unity,admob');
      sdk.byKey['android_url'] = RemoteConfigValue(
        utf8.encode('https://example.com'),
        ValueSource.valueDefault,
      );
      expect(client.readString('ads_priority'), 'unity,admob');
      expect(client.readString('android_url'), isNull);
    });

    test('readInt parses integers and rejects non-numbers', () {
      sdk.byKey['banner_start_visit'] = remote(' 5 ');
      sdk.byKey['interstitial_every_n_starts'] = remote('three');
      expect(client.readInt('banner_start_visit'), 5);
      expect(client.readInt('interstitial_every_n_starts'), isNull);
    });

    test('readInt keeps a real zero distinct from a missing value', () {
      sdk.byKey['banner_start_visit'] = remote('0');
      expect(client.readInt('banner_start_visit'), 0);
      sdk.byKey['banner_start_visit'] = remote('');
      expect(client.readInt('banner_start_visit'), isNull);
    });

    test('readBool accepts true and false only', () {
      sdk.byKey['reward_enabled'] = remote('FALSE');
      expect(client.readBool('reward_enabled'), isFalse);
      sdk.byKey['reward_enabled'] = remote('true');
      expect(client.readBool('reward_enabled'), isTrue);
      sdk.byKey['reward_enabled'] = remote('yes');
      expect(client.readBool('reward_enabled'), isNull);
    });

    test('typed reads return null for a static (never fetched) value', () {
      sdk.byKey['reward_enabled'] = RemoteConfigValue(
        null,
        ValueSource.valueStatic,
      );
      expect(client.readBool('reward_enabled'), isNull);
      expect(client.readInt('reward_enabled'), isNull);
      expect(client.readString('reward_enabled'), isNull);
    });
  });
}
