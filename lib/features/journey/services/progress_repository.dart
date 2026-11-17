import 'dart:async';

import '../../../core/log/gj_log.dart';
import '../models/player_progress.dart';
import 'progress_store.dart';

/// Bộ đọc/ghi duy nhất của dữ liệu bền vững (contract C5, ADR-009).
///
/// - `load()` đọc một lần; sau đó mọi lần đọc là đồng bộ từ cache.
/// - Mọi lần ghi (và `flushDirty`) đi qua CÙNG một hàng đợi FIFO (BR3.2).
/// - Ghi lỗi thì giữ giá trị trong cache, đánh dấu dirty và thử lại (BR3.3).
/// - Đọc lỗi hai lần thì vào chế độ chỉ-đọc: bỏ qua mọi lần ghi (D-R5).
class ProgressRepository {
  ProgressRepository(this._store);

  static const String progressKey = 'progress';
  static const String tutorialKey = 'tutorial_completed';

  /// Số lần tự thử lại tối đa cho một key dirty (BR3.3).
  static const int maxAutoRetries = 3;

  final ProgressStore _store;

  PlayerProgress _progress = PlayerProgress.initial;
  bool _tutorialCompleted = false;

  bool _loaded = false;
  bool _abandoned = false;
  bool _readOnly = false;
  bool _readOnlyWriteLogged = false;

  /// key -> số lần tự thử lại đã dùng. Có mặt trong map nghĩa là dirty.
  final Map<String, int> _dirty = <String, int>{};

  /// Hàng đợi ghi chỉ mở sau `load()` (NFR6.8).
  final Completer<void> _gate = Completer<void>();
  late Future<void> _tail = _gate.future;

  // ----- Đọc đồng bộ từ cache -----

  PlayerProgress get progress => _progress;
  bool get tutorialCompleted => _tutorialCompleted;
  bool get isReadOnly => _readOnly;
  bool get isLoaded => _loaded;

  /// Các key đang dirty (bản sao), dùng cho test và chẩn đoán.
  Set<String> get dirtyKeys => Set<String>.unmodifiable(_dirty.keys);

  /// `highScore` có từ U1 và luôn trả 0 cho tới U2 (contract C5).
  int highScore(int levelIndex) => 0;

  // ----- Load -----

  /// Đọc `progress` và `tutorial_completed`. Không bao giờ throw. Lỗi thì thử
  /// lại một lần rồi vào chế độ chỉ-đọc với giá trị mặc định (D-R5).
  Future<void> load() async {
    if (_loaded) return;
    Object? lastError;
    var ok = false;
    for (var attempt = 1; attempt <= 2 && !ok; attempt++) {
      try {
        await _store.init();
        if (_abandoned) return;
        _applyProgress(_store.read(progressKey));
        _applyTutorial(_store.read(tutorialKey));
        ok = true;
      } catch (e) {
        lastError = e;
        GjLog.warn('Progress', 'load attempt $attempt failed', e);
      }
    }
    if (_abandoned) return;
    if (!ok) {
      _progress = PlayerProgress.initial;
      _tutorialCompleted = false;
      _enterReadOnly('read failed', lastError);
    }
    _finishLoad();
  }

  /// Bootstrap hết hạn chót khi `load()` chưa xong: dùng mặc định và chuyển
  /// chỉ-đọc để KHÔNG ghi đè dữ liệu thật chưa đọc được bằng giá trị mặc định.
  void abandonLoad() {
    if (_loaded) return;
    _abandoned = true;
    _progress = PlayerProgress.initial;
    _tutorialCompleted = false;
    _enterReadOnly('load deadline');
    _finishLoad();
  }

  void _finishLoad() {
    _loaded = true;
    if (!_gate.isCompleted) _gate.complete();
  }

  void _enterReadOnly(String reason, [Object? err]) {
    _readOnly = true;
    GjLog.warn('Progress', 'read-only mode: $reason', err);
  }

  void _applyProgress(Object? raw) {
    if (raw == null) {
      _progress = PlayerProgress.initial;
      return;
    }
    final parsed = PlayerProgress.tryParse(raw);
    if (parsed == null) {
      GjLog.warn('Progress', 'key $progressKey invalid, using default');
      _progress = PlayerProgress.initial;
    } else {
      _progress = parsed;
    }
  }

  void _applyTutorial(Object? raw) {
    if (raw == null) {
      _tutorialCompleted = false;
    } else if (raw is bool) {
      _tutorialCompleted = raw;
    } else {
      GjLog.warn('Progress', 'key $tutorialKey is not a bool, using default');
      _tutorialCompleted = false;
    }
  }

  // ----- Ghi -----

  /// Cập nhật cache NGAY, rồi xếp lần ghi vào hàng đợi. Future hoàn tất khi đã
  /// ghi đĩa hoặc khi lần ghi thất bại (đã đánh dấu dirty). Không throw.
  Future<void> savePlayerProgress(PlayerProgress value) {
    _progress = value;
    return _enqueueWrite(progressKey);
  }

  Future<void> setTutorialCompleted(bool value) {
    _tutorialCompleted = value;
    return _enqueueWrite(tutorialKey);
  }

  /// Thử ghi mọi key dirty một lần, bất kể bộ đếm. Dùng khi app vào nền (WF7).
  Future<void> flushDirty() {
    return _enqueue(() async {
      if (_readOnly) return;
      for (final key in _dirty.keys.toList()) {
        await _tryWrite(key);
      }
    });
  }

  Future<void> _enqueueWrite(String key) {
    return _enqueue(() async {
      if (_readOnly) {
        if (!_readOnlyWriteLogged) {
          _readOnlyWriteLogged = true;
          GjLog.warn('Progress', 'write skipped in read-only mode (key $key)');
        }
        return;
      }
      // Ghi lại các key dirty khác trước, mỗi lần tăng bộ đếm của key đó.
      for (final other in _dirty.keys.toList()) {
        if (other == key) continue;
        final used = _dirty[other] ?? 0;
        if (used >= maxAutoRetries) continue;
        _dirty[other] = used + 1;
        await _tryWrite(other);
      }
      final failed = !await _tryWrite(key);
      if (failed) _dirty[key] = 0;
    });
  }

  /// Ghi giá trị hiện tại trong cache của [key]. Trả true nếu thành công.
  Future<bool> _tryWrite(String key) async {
    try {
      if (key == progressKey) {
        await _store.writeString(key, _progress.toJsonString());
      } else {
        await _store.writeBool(key, _tutorialCompleted);
      }
      _dirty.remove(key);
      return true;
    } catch (e) {
      GjLog.warn('Progress', 'write failed for key $key, marked dirty', e);
      _dirty.putIfAbsent(key, () => 0);
      return false;
    }
  }

  /// Nối [op] vào cuối hàng đợi FIFO. `op` không bao giờ làm hỏng chuỗi.
  Future<void> _enqueue(Future<void> Function() op) {
    final next = _tail.then((_) async {
      try {
        await op();
      } catch (e) {
        GjLog.error('Progress', 'queued operation failed', e);
      }
    });
    _tail = next;
    return next;
  }
}
