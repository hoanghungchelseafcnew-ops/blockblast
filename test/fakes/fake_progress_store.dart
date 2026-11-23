import 'dart:async';

import 'package:block_blast/features/journey/services/progress_store.dart';

/// Kho lưu trữ giả: giả lập đọc lỗi, ghi lỗi và ghi chậm.
class FakeProgressStore implements ProgressStore {
  FakeProgressStore({Map<String, Object>? initial})
    : data = Map<String, Object>.of(initial ?? const {});

  final Map<String, Object> data;

  /// Số lần `init` đầu tiên sẽ ném lỗi.
  int initFailures = 0;

  /// Nếu true, `init` luôn ném lỗi.
  bool initAlwaysFails = false;

  /// Nếu true, `init` không bao giờ hoàn tất.
  bool initHangs = false;

  /// Các key mà mọi lần ghi sẽ ném lỗi.
  final Set<String> failingKeys = <String>{};

  /// Độ trễ ghi theo key (để kiểm tra FIFO).
  final Map<String, Duration> writeDelay = <String, Duration>{};

  /// Độ trễ của `init` (để kiểm tra load bị bỏ giữa chừng).
  Duration? initDelay;

  int initCalls = 0;

  /// Mọi lần thử ghi (kể cả lỗi), theo thứ tự bắt đầu.
  final List<String> attempts = <String>[];

  /// Các lần ghi thành công, theo thứ tự hoàn tất.
  final List<String> completed = <String>[];

  @override
  Future<void> init() async {
    initCalls++;
    if (initHangs) return Completer<void>().future;
    final delay = initDelay;
    if (delay != null) await Future<void>.delayed(delay);
    if (initAlwaysFails) throw StateError('init failed');
    if (initFailures > 0) {
      initFailures--;
      throw StateError('init failed once');
    }
  }

  @override
  Object? read(String key) => data[key];

  @override
  Future<void> writeString(String key, String value) => _write(key, value);

  @override
  Future<void> writeBool(String key, bool value) => _write(key, value);

  @override
  Future<void> writeInt(String key, int value) => _write(key, value);

  Future<void> _write(String key, Object value) async {
    attempts.add(key);
    final delay = writeDelay[key];
    if (delay != null) await Future<void>.delayed(delay);
    if (failingKeys.contains(key)) throw StateError('write failed');
    data[key] = value;
    completed.add(key);
  }

  /// Các key mà `remove` sẽ ném lỗi.
  final Set<String> failingRemovals = <String>{};

  /// Các key đã bị `remove` thành công, theo thứ tự.
  final List<String> removed = <String>[];

  @override
  Future<void> remove(String key) async {
    if (failingRemovals.contains(key)) throw StateError('remove failed');
    data.remove(key);
    removed.add(key);
  }

  int attemptsFor(String key) => attempts.where((k) => k == key).length;
}
