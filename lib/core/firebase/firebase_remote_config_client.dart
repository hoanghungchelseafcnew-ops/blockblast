import 'package:firebase_remote_config/firebase_remote_config.dart';

import '../config/remote_config_client.dart';

/// Adapter thật của [RemoteConfigClient] trên `firebase_remote_config`.
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
  String? readLevelConfig() => readString(levelConfigKey);

  @override
  String? readString(String key) {
    final value = _remoteConfig.getValue(key);
    if (value.source != ValueSource.valueRemote) return null;
    final text = value.asString();
    return text.isEmpty ? null : text;
  }

  /// Đọc từ chuỗi thô thay vì `asInt()`: `asInt()` trả 0 cho giá trị không
  /// phải số, không phân biệt được với số 0 thật.
  @override
  int? readInt(String key) {
    final text = readString(key);
    if (text == null) return null;
    return int.tryParse(text.trim());
  }

  @override
  bool? readBool(String key) {
    final text = readString(key);
    if (text == null) return null;
    switch (text.trim().toLowerCase()) {
      case 'true':
        return true;
      case 'false':
        return false;
      default:
        return null;
    }
  }
}
