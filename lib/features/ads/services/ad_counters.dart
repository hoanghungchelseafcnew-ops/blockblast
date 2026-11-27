import 'dart:async';

import '../../../core/log/gj_log.dart';
import '../../journey/services/progress_store.dart';

/// Bộ đếm lưu bền cho quảng cáo (entities.md `AdCounterState`).
///
/// Chỉ lưu hai số và một cờ, không lưu dữ liệu cá nhân (NFR2.7). Các bộ đếm
/// chỉ tăng. Lỗi đọc hoặc ghi được ghi log và không làm hỏng luồng chơi.
class AdCounters {
  AdCounters(this._store);

  static const String appOpenKey = 'ads_app_open_count';
  static const String startKey = 'ads_start_count';
  static const String carriedKey = 'ads_interstitial_carried_due';

  static const String _log = 'AdCounters';

  final ProgressStore _store;
  Future<void>? _loading;
  bool _storeReady = false;

  int _appOpenCount = 0;
  int _startCount = 0;
  bool _interstitialCarriedDue = false;

  int get appOpenCount => _appOpenCount;
  int get startCount => _startCount;
  bool get interstitialCarriedDue => _interstitialCarriedDue;

  /// Mở kho lưu và đọc giá trị đã lưu. Gọi nhiều lần chỉ chạy một lần.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      await _store.init();
      _storeReady = true;
      _appOpenCount = _readCount(appOpenKey);
      _startCount = _readCount(startKey);
      _interstitialCarriedDue = _store.read(carriedKey) == true;
    } catch (e) {
      GjLog.warn(_log, 'loading counters failed, starting from zero', e);
    }
  }

  int _readCount(String key) {
    final value = _store.read(key);
    return value is int && value > 0 ? value : 0;
  }

  /// Một lần mở ứng dụng (BR5.1).
  Future<void> recordAppOpen() async {
    await load();
    _appOpenCount++;
    await _writeInt(appOpenKey, _appOpenCount);
  }

  /// Một lần bấm Start (BR4.1).
  Future<void> recordStart() async {
    await load();
    _startCount++;
    await _writeInt(startKey, _startCount);
  }

  /// Đánh dấu hoặc bỏ đánh dấu một lượt interstitial cần bù (BR4.4).
  Future<void> setInterstitialCarriedDue(bool value) async {
    await load();
    if (_interstitialCarriedDue == value) return;
    _interstitialCarriedDue = value;
    if (!_storeReady) return;
    try {
      await _store.writeBool(carriedKey, value);
    } catch (e) {
      GjLog.warn(_log, 'saving $carriedKey failed', e);
    }
  }

  Future<void> _writeInt(String key, int value) async {
    if (!_storeReady) return;
    try {
      await _store.writeInt(key, value);
    } catch (e) {
      GjLog.warn(_log, 'saving $key failed', e);
    }
  }
}
