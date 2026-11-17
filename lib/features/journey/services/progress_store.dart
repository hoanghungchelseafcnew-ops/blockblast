import 'package:shared_preferences/shared_preferences.dart';

/// Lớp bọc thay thế được quanh SharedPreferences, để test giả lập ghi lỗi
/// (ADR-009). Chỉ `ProgressRepository` dùng lớp này.
abstract class ProgressStore {
  /// Mở kho lưu trữ. Có thể throw; repository thử lại một lần.
  Future<void> init();

  /// Giá trị thô của [key] (đồng bộ sau [init]), hoặc null nếu chưa có.
  Object? read(String key);

  Future<void> writeString(String key, String value);

  Future<void> writeBool(String key, bool value);
}

/// Triển khai thật bằng SharedPreferences.
class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferences? _prefs;

  SharedPreferences get _ready {
    final prefs = _prefs;
    if (prefs == null) throw StateError('ProgressStore not initialised');
    return prefs;
  }

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Object? read(String key) => _ready.get(key);

  @override
  Future<void> writeString(String key, String value) async {
    if (!await _ready.setString(key, value)) {
      throw StateError('setString returned false');
    }
  }

  @override
  Future<void> writeBool(String key, bool value) async {
    if (!await _ready.setBool(key, value)) {
      throw StateError('setBool returned false');
    }
  }
}
