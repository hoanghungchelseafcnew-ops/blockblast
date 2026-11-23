import 'dart:async';
import 'dart:convert';

import '../../../core/log/gj_log.dart';
import '../../endless/models/endless_state.dart';
import '../../game/models/game_snapshot.dart';
import '../models/high_scores.dart';
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
  static const String highScoresKey = 'high_scores';
  static const String soundMutedKey = 'sound_muted';
  static const String totalPlayTimeKey = 'total_play_time';
  static const String endlessSavedKey = 'endless_saved_score';
  static const String endlessHighKey = 'endless_high_score';
  static const String levelSessionKey = 'session_level';
  static const String endlessSessionKey = 'session_endless';

  /// Key cũ được gỡ mỗi lần khởi động (E3): điểm cao kiểu cũ, điểm của chế độ
  /// đã gỡ, theme đã chọn (FR12.2) và ngày nhận Daily Gift (FR10.2).
  ///
  /// Tên key điểm của chế độ đã gỡ được ghép từ hai phần: AC2.1.2 yêu cầu
  /// `lib/` không chứa nguyên văn tên đó, còn E3 yêu cầu xóa key này khỏi máy
  /// người chơi. Đây là chỗ tham chiếu duy nhất và chỉ dùng để xóa.
  static const String _legacyScoreKey = 'high_score';
  static const List<String> legacyKeys = <String>[
    _legacyScoreKey,
    '${_legacyScoreKey}_time',
    'theme_index',
    'last_login_date',
  ];

  /// Số lần tự thử lại tối đa cho một key dirty (BR3.3).
  static const int maxAutoRetries = 3;

  final ProgressStore _store;

  PlayerProgress _progress = PlayerProgress.initial;
  bool _tutorialCompleted = false;
  bool _soundMuted = false;
  int _totalPlayTime = 0;
  EndlessState _endless = EndlessState.initial;
  HighScores _highScores = HighScores.empty;
  GameSnapshot? _levelSession;
  GameSnapshot? _endlessSession;

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

  /// Người chơi đã tắt âm thanh (FR13.2, contract C5).
  bool get soundMuted => _soundMuted;

  /// Tổng thời gian chơi, tính bằng giây (FR8.1, E3).
  int get totalPlayTime => _totalPlayTime;

  /// Điểm endless đã lưu và high score của endless (C5, E3).
  EndlessState get endlessState => _endless;

  /// Ván level đang chơi dở, hoặc null nếu không có (hoặc bản lưu hỏng).
  GameSnapshot? get levelSession => _levelSession;

  /// Ván Endless đang chơi dở, hoặc null.
  GameSnapshot? get endlessSession => _endlessSession;
  bool get isReadOnly => _readOnly;
  bool get isLoaded => _loaded;

  /// Các key đang dirty (bản sao), dùng cho test và chẩn đoán.
  Set<String> get dirtyKeys => Set<String>.unmodifiable(_dirty.keys);

  /// High score của [levelIndex], hoặc 0 nếu chưa có (contract C5).
  int highScore(int levelIndex) => _highScores.of(levelIndex);

  /// Mọi high score đã biết (bản chỉ đọc).
  HighScores get highScores => _highScores;

  // ----- Load -----

  /// Đọc `progress`, `tutorial_completed` và `high_scores`. Không bao giờ
  /// throw. Lỗi thì thử lại một lần rồi vào chế độ chỉ-đọc với giá trị mặc
  /// định (D-R5). Sau khi đọc xong, các key cũ được gỡ qua hàng đợi (E3).
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
        _applyHighScores(_store.read(highScoresKey));
        _soundMuted = _readBool(soundMutedKey);
        _totalPlayTime = _readSeconds(totalPlayTimeKey);
        _endless = EndlessState(
          savedScore: _readSeconds(endlessSavedKey),
          highScore: _readSeconds(endlessHighKey),
        );
        _levelSession = _readSession(levelSessionKey, GameMode.level);
        _endlessSession = _readSession(endlessSessionKey, GameMode.endless);
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
      _soundMuted = false;
      _totalPlayTime = 0;
      _endless = EndlessState.initial;
      _highScores = HighScores.empty;
      _levelSession = null;
      _endlessSession = null;
      _enterReadOnly('read failed', lastError);
    }
    _finishLoad();
    if (ok) unawaited(_removeLegacyKeys());
  }

  /// Bootstrap hết hạn chót khi `load()` chưa xong: dùng mặc định và chuyển
  /// chỉ-đọc để KHÔNG ghi đè dữ liệu thật chưa đọc được bằng giá trị mặc định.
  void abandonLoad() {
    if (_loaded) return;
    _abandoned = true;
    _progress = PlayerProgress.initial;
    _tutorialCompleted = false;
    _soundMuted = false;
    _totalPlayTime = 0;
    _endless = EndlessState.initial;
    _highScores = HighScores.empty;
    _levelSession = null;
    _endlessSession = null;
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

  /// Đọc một key bool; thiếu thì `false`, sai kiểu thì `false` kèm log.
  bool _readBool(String key) {
    final raw = _store.read(key);
    if (raw == null) return false;
    if (raw is bool) return raw;
    GjLog.warn('Progress', 'key $key is not a bool, using default');
    return false;
  }

  /// Đọc một key số giây không âm; thiếu thì 0, sai kiểu hoặc âm thì 0 kèm log.
  int _readSeconds(String key) {
    final raw = _store.read(key);
    if (raw == null) return 0;
    if (raw is int && raw >= 0) return raw;
    GjLog.warn('Progress', 'key $key invalid, using default');
    return 0;
  }

  /// Đọc bản lưu ván dở của [key]. Thiếu, sai kiểu, hỏng hoặc sai chế độ thì
  /// trả null (kèm log), không bao giờ throw.
  GameSnapshot? _readSession(String key, GameMode mode) {
    final raw = _store.read(key);
    if (raw == null) return null;
    if (raw is! String) {
      GjLog.warn('Progress', 'key $key is not a string, dropping session');
      return null;
    }
    try {
      final parsed = GameSnapshot.tryParse(jsonDecode(raw));
      if (parsed == null || parsed.mode != mode) {
        GjLog.warn('Progress', 'key $key invalid, dropping session');
        return null;
      }
      return parsed;
    } catch (e) {
      GjLog.warn('Progress', 'key $key unreadable, dropping session', e);
      return null;
    }
  }

  void _applyHighScores(Object? raw) {
    if (raw == null) {
      _highScores = HighScores.empty;
      return;
    }
    final parsed = HighScores.tryParse(raw);
    if (parsed == null) {
      GjLog.warn('Progress', 'key $highScoresKey invalid, using default');
      _highScores = HighScores.empty;
    } else {
      _highScores = parsed;
    }
  }

  /// Gỡ các key cũ, idempotent. Lỗi chỉ được log, không đánh dấu dirty.
  Future<void> _removeLegacyKeys() {
    return _enqueue(() async {
      if (_readOnly) return;
      for (final key in legacyKeys) {
        if (_store.read(key) == null) continue;
        try {
          await _store.remove(key);
          GjLog.info('Progress', 'removed legacy key $key');
        } catch (e) {
          GjLog.warn('Progress', 'removing legacy key $key failed', e);
        }
      }
    });
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

  /// Lưu trạng thái tắt âm thanh (FR13.2, AC5.3.2).
  Future<void> setSoundMuted(bool value) {
    _soundMuted = value;
    return _enqueueWrite(soundMutedKey);
  }

  /// Cộng [seconds] vào tổng thời gian chơi (C5, AC1.6.2). Giá trị ≤ 0 bị bỏ
  /// qua.
  Future<void> addPlayTime(int seconds) {
    if (seconds <= 0) return Future<void>.value();
    _totalPlayTime += seconds;
    return _enqueueWrite(totalPlayTimeKey);
  }

  /// Lưu điểm endless (ER4..ER7). Cache cập nhật ngay; hai key đi qua cùng
  /// hàng đợi FIFO và hoàn tất khi cả hai đã ghi xong hoặc đã lỗi.
  Future<void> saveEndlessState(EndlessState state) {
    _endless = state;
    return Future.wait<void>([
      _enqueueWrite(endlessSavedKey),
      _enqueueWrite(endlessHighKey),
    ]);
  }

  /// Ghi [value] cho ván level dở; null thì xóa bản lưu. Cache cập nhật ngay.
  Future<void> saveLevelSession(GameSnapshot? value) {
    _levelSession = value;
    return _enqueueWrite(levelSessionKey);
  }

  /// Ghi [value] cho ván Endless dở; null thì xóa bản lưu.
  Future<void> saveEndlessSession(GameSnapshot? value) {
    _endlessSession = value;
    return _enqueueWrite(endlessSessionKey);
  }

  /// Ghi [score] cho [levelIndex] nếu cao hơn điểm đã lưu (FR2.3b, AC1.7.2).
  /// Điểm không cao hơn thì không ghi gì.
  Future<void> saveHighScore(int levelIndex, int score) {
    final updated = _highScores.withScore(levelIndex, score);
    if (identical(updated, _highScores)) return Future<void>.value();
    _highScores = updated;
    return _enqueueWrite(highScoresKey);
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

  /// Ghi bản lưu ván dở của [key]; [value] null thì xóa key.
  Future<void> _writeSession(String key, GameSnapshot? value) {
    if (value == null) return _store.remove(key);
    return _store.writeString(key, jsonEncode(value.toJson()));
  }

  /// Ghi giá trị hiện tại trong cache của [key]. Trả true nếu thành công.
  Future<bool> _tryWrite(String key) async {
    try {
      switch (key) {
        case progressKey:
          await _store.writeString(key, _progress.toJsonString());
        case highScoresKey:
          await _store.writeString(key, _highScores.toJsonString());
        case soundMutedKey:
          await _store.writeBool(key, _soundMuted);
        case totalPlayTimeKey:
          await _store.writeInt(key, _totalPlayTime);
        case endlessSavedKey:
          await _store.writeInt(key, _endless.savedScore);
        case endlessHighKey:
          await _store.writeInt(key, _endless.highScore);
        case levelSessionKey:
          await _writeSession(key, _levelSession);
        case endlessSessionKey:
          await _writeSession(key, _endlessSession);
        default:
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
