import 'dart:convert';

import 'package:block_blast/core/config/remote_config_client.dart';
import 'package:block_blast/core/firebase/firebase_remote_config_client.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake tối thiểu của SDK: chỉ ba hàm mà adapter dùng.
class _FakeFirebaseRemoteConfig implements FirebaseRemoteConfig {
  RemoteConfigSettings? settings;
  int fetchCalls = 0;
  bool fetchResult = true;
  RemoteConfigValue value = RemoteConfigValue(null, ValueSource.valueStatic);

  @override
  Future<void> setConfigSettings(RemoteConfigSettings configSettings) async {
    settings = configSettings;
  }

  @override
  Future<bool> fetchAndActivate() async {
    fetchCalls++;
    return fetchResult;
  }

  @override
  RemoteConfigValue getValue(String key) {
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
    test('configure sets a 12 hour minimum fetch interval and a 2 second timeout',
        () async {
      await client.configure();
      expect(sdk.settings!.minimumFetchInterval, const Duration(hours: 12));
      expect(sdk.settings!.fetchTimeout, const Duration(seconds: 2));
    });

    test('fetchAndActivate delegates to the SDK and returns its result',
        () async {
      expect(await client.fetchAndActivate(), isTrue);
      sdk.fetchResult = false;
      expect(await client.fetchAndActivate(), isFalse);
      expect(sdk.fetchCalls, 2);
    });

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
}
