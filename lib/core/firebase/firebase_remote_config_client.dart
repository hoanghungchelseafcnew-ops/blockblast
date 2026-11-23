import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../config/remote_config_client.dart';

/// Triển khai [RemoteConfigClient] bằng `firebase_remote_config`.
///
/// Chỉ được tạo sau khi `FirebaseGateway.init()` báo `ok`, vì
/// `FirebaseRemoteConfig.instance` cần Firebase app đã khởi tạo.
class FirebaseRemoteConfigClient implements RemoteConfigClient {
  FirebaseRemoteConfigClient({FirebaseRemoteConfig? instance})
    : _remoteConfig = instance ?? FirebaseRemoteConfig.instance;

  final FirebaseRemoteConfig _remoteConfig;

  @override
  Future<void> configure() {
    return _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 2),
        minimumFetchInterval: const Duration(hours: 12),
      ),
    );
  }

  @override
  Future<bool> fetchAndActivate() => _remoteConfig.fetchAndActivate();

  @override
  String? readLevelConfig() {
    final value = _remoteConfig.getValue(levelConfigKey);
    if (value.source != ValueSource.valueRemote) return null;
    final text = value.asString();
    return text.isEmpty ? null : text;
  }
}
