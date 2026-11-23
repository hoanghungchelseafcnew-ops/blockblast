import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/log/gj_log.dart';
import '../../game/engine/board_engine.dart';
import '../../game/models/block_model.dart';
import '../../game/models/cell_model.dart';
import '../../game/models/game_snapshot.dart';
import '../../game/services/game_feedback.dart';
import '../../victory/models/victory_variant.dart';
import '../models/journey_outcome.dart';
import '../models/level.dart';
import '../services/progress_repository.dart';
import 'journey_controller.dart';

/// Vòng đời một ván level (contract C2, ADR-008).
///
/// Mọi `switch` trên giá trị này phải liệt kê đủ 5 case, không dùng `default`.
enum LevelStatus { playing, resolving, won, lost, quit }

/// State và quy tắc của ván chơi. Widget chỉ render và chuyển tọa độ thành ô.
class LevelGameController extends ChangeNotifier {
  LevelGameController({
    required JourneyController journey,
    required ProgressRepository progress,
    BoardEngine? engine,
    GameFeedback feedback = const NoopGameFeedback(),
    AnalyticsService analytics = const NoopAnalyticsService(),
    this.resolveTimeout = const Duration(seconds: 3),
    this.comboTextDuration = const Duration(seconds: 1),
    this.unlockDelay = const Duration(milliseconds: 600),
    String Function()? roundIdFactory,
  }) : _journey = journey,
       _progress = progress,
       _engine = engine ?? BoardEngine(),
       _feedback = feedback,
       _analytics = analytics,
       _roundIdFactory = roundIdFactory ?? _defaultRoundId;

  final JourneyController _journey;
  final ProgressRepository _progress;
  final BoardEngine _engine;
  final GameFeedback _feedback;
  final AnalyticsService _analytics;
  final String Function() _roundIdFactory;

  /// Trần chờ `onLevelWon` ở trạng thái `resolving` (BR5.9).
  final Duration resolveTimeout;
  final Duration comboTextDuration;

  /// Độ trễ giữa âm thanh victory và unlock (interaction-spec, VictoryScreen).
  final Duration unlockDelay;

  static int _roundCounter = 0;
  static String _defaultRoundId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_roundCounter++}';

  Level? _level;
  int _targetScore = 1;
  int _bestAtStart = 0;
  String _roundId = '';
  LevelStatus _status = LevelStatus.playing;
  bool _clearing = false;
  JourneyOutcome? _outcome;
  bool _tutorialActive = false;
  String? _comboText;
  BlockModel? _activeBlock;
  Timer? _comboTimer;
  Timer? _unlockTimer;
  int _epoch = 0;
  bool _disposed = false;

  // ----- State cho UI -----

  /// Level đang chơi. Chỉ hợp lệ sau [start].
  Level get level {
    final current = _level;
    if (current == null) throw StateError('start() was not called');
    return current;
  }

  bool get hasLevel => _level != null;
  int get targetScore => _targetScore;
  String get roundId => _roundId;
  LevelStatus get status => _status;
  bool get clearing => _clearing;
  JourneyOutcome? get outcome => _outcome;
  bool get tutorialActive => _tutorialActive;
  String? get comboText => _comboText;
  BlockModel? get activeBlock => _activeBlock;

  List<List<CellModel>> get board => _engine.board;
  List<BlockModel> get tray => _engine.tray;
  int get score => _engine.score;
  int get comboStreak => _engine.comboStreak;

  /// BEST của level: high score đã lưu lúc bắt đầu round, hoặc điểm hiện tại
  /// nếu cao hơn (contract C2, AC1.7.1). UI ẩn BEST khi bằng 0.
  int get bestScore => math.max(_bestAtStart, score);

  /// Rough Stone của gem đang chơi: nơi người chơi quay về khi thua (FR2.4).
  Level get returnLevel => _journey.returnLevelFor(level);

  /// Level kế tiếp trong hành trình, để UI nạp sẵn ảnh nền (FR5.4, AC7.3.1).
  Level? get upcomingLevel => _journey.nextLevelFor(level);

  /// Phần trăm làm tròn xuống, tối đa 99 trước khi đạt mốc (BR5.6).
  int get progressPercent {
    if (score >= _targetScore) return 100;
    return math.min(99, (score * 100) ~/ _targetScore);
  }

  /// Back hệ thống khi đang chơi phải hỏi "Quit this level?" trước (FR11.2).
  bool get needsQuitConfirmation => _status == LevelStatus.playing;

  /// Biến thể màn Victory của round vừa thắng (C1, interaction-spec).
  VictoryVariant get victoryVariant {
    final o = _outcome;
    return o == null ? VictoryVariant.sub : VictoryVariant.of(o);
  }

  // ----- Hành động -----

  /// Bắt đầu một ván mới ở [level] (WF2): round mới, mốc điểm được chốt.
  ///
  /// Với [resumeSaved] true, nếu có bản lưu ván dở của đúng level này thì nạp
  /// lại bảng, khay, điểm và combo thay vì bắt đầu từ đầu. Mặc định (ván mới,
  /// PLAY AGAIN, CONTINUE) xóa bản lưu cũ.
  void start(Level level, {bool resumeSaved = false}) {
    _epoch++;
    _comboTimer?.cancel();
    _unlockTimer?.cancel();
    _level = level;
    if (level.targetScore < 1) {
      GjLog.error(
        'Game',
        'target below 1, raised to 1: levelId=${level.levelIndex}',
      );
    }
    _targetScore = math.max(1, level.targetScore);
    _bestAtStart = _journey.bestScoreFor(level);
    _roundId = _roundIdFactory();
    _status = LevelStatus.playing;
    _clearing = false;
    _outcome = null;
    _activeBlock = null;
    _comboText = null;
    _tutorialActive = !_progress.tutorialCompleted;
    _engine.difficultyLevel = level.levelIndex;
    _engine.reset();
    final saved = _progress.levelSession;
    final resumed =
        resumeSaved && saved != null && saved.levelIndex == level.levelIndex;
    if (resumed) {
      _engine.restore(saved);
    } else if (saved != null) {
      unawaited(_progress.saveLevelSession(null));
    }
    if (!resumed) {
      _track('level_start', () => _analytics.logLevelStart(level));
    }
    final round = _epoch;
    if (resumed) {
      // Bản lưu cũ có thể đã đạt mốc mới (mốc bị hạ) hoặc hết nước đi.
      if (_engine.score >= _targetScore) {
        _status = LevelStatus.resolving;
        unawaited(_resolve(round, null, won: true));
      } else if (!_engine.hasMoves) {
        _status = LevelStatus.resolving;
        unawaited(_resolve(round, null, won: false));
      }
    }
    _notify();
  }

  /// Gửi analytics mà không chặn ván chơi. Contract C4 cam kết không throw;
  /// lớp bọc này vẫn log nếu một bản triển khai vi phạm điều đó.
  void _track(String what, Future<void> Function() call) {
    void report(Object e) => GjLog.warn('Game', 'analytics $what failed', e);
    try {
      unawaited(call().catchError(report));
    } catch (e) {
      report(e);
    }
  }

  /// Gửi event thắng/thua và user property tiến trình, mỗi round một lần
  /// (FR4.1, FR4.2, AC6.4.2).
  void _trackResult(Level played, int score, bool won, JourneyOutcome o) {
    final target = _targetScore;
    if (won) {
      _track(
        'level_complete',
        () => _analytics.logLevelComplete(played, score, target),
      );
    } else {
      _track(
        'level_fail',
        () => _analytics.logLevelFail(played, score, target),
      );
    }
    final majorLevel = (o.nextLevel ?? played).gemId;
    _track(
      'progress properties',
      () => _analytics.setProgressProperties(majorLevel, o.highestLevelReached),
    );
  }

  bool get _canPlay => _status == LevelStatus.playing && !_clearing;

  void onDragStart(BlockModel block) {
    if (!_canPlay) return;
    _activeBlock = block;
    _notify();
  }

  /// Hiện preview tại ô ([row], [col]) khi đang kéo.
  void updatePreview(int row, int col) {
    final block = _activeBlock;
    if (!_canPlay || block == null) return;
    _engine.showPreview(block, row, col);
    _notify();
  }

  /// Hủy lần kéo hiện tại mà không đặt khối.
  void cancelDrag() {
    _engine.clearPreview();
    _activeBlock = null;
    _notify();
  }

  /// Thả khối đang kéo xuống ([row], [col]) (WF3). Bị bỏ qua khi
  /// `status != playing` hoặc đang `clearing` (BR5.4, BR5.10).
  Future<void> placeAt(int row, int col) async {
    final block = _activeBlock;
    if (!_canPlay || block == null) {
      if (block != null) cancelDrag();
      return;
    }
    _engine.clearPreview();
    _activeBlock = null;
    final result = _engine.place(block, row, col);
    if (result == null) {
      _notify();
      return;
    }

    _feedback.placed();
    if (_tutorialActive) {
      _tutorialActive = false;
      unawaited(_progress.setTutorialCompleted(true));
    }
    if (result.clearedAnyLine) {
      _feedback.cleared();
      if (result.comboStreak > 1) {
        _feedback.combo();
        _showCombo(result.comboStreak);
      }
    }

    final round = _epoch;

    // BR5.3: kiểm tra thắng NGAY sau khi tính điểm, trước animation.
    if (_engine.score >= _targetScore) {
      _status = LevelStatus.resolving;
      _clearing = result.clearedAnyLine;
      _notify();
      final animation = result.clearedAnyLine ? _engine.applyClear() : null;
      await _resolve(round, animation, won: true);
      return;
    }

    if (result.clearedAnyLine) {
      _clearing = true;
      _notify();
      await _engine.applyClear();
      if (_isStale(round)) return;
      _clearing = false;
    }
    if (_status != LevelStatus.playing) {
      // Người chơi đã xác nhận QUIT trong lúc animation (BR5.8). Bảng đã ổn
      // định, lưu để lần sau chơi tiếp đúng chỗ này.
      _saveSession();
      _notify();
      return;
    }

    _engine.refillTrayIfEmpty();
    if (!_engine.hasMoves) {
      // FR2.3: thua thì lưu việc quay về Rough Stone trước khi hiện Game Over.
      _status = LevelStatus.resolving;
      _notify();
      await _resolve(round, null, won: false);
      return;
    }
    _saveSession();
    _notify();
  }

  /// Xử lý nút back (WF6). Trả true nếu được phép rời màn hình ngay.
  ///
  /// Khi đang chơi, trả false: UI phải hỏi "Quit this level?" rồi gọi
  /// [confirmQuit] (FR11.2). Khi `resolving`, back bị bỏ qua (BR5.4).
  bool requestBack() {
    switch (_status) {
      case LevelStatus.resolving:
      case LevelStatus.playing:
        return false;
      case LevelStatus.won:
        // Rời màn Victory (BACK TO MENU ở level 36): dừng âm thanh.
        _stopCelebration();
        return true;
      case LevelStatus.lost:
      case LevelStatus.quit:
        return true;
    }
  }

  /// QUIT trong dialog: bỏ ván, không tính là thua, tiến trình giữ nguyên
  /// (FR11.2, AC2.5.3). Trả true nếu ván đã chuyển sang `quit`.
  bool confirmQuit() {
    if (_status != LevelStatus.playing) return false;
    _status = LevelStatus.quit;
    _activeBlock = null;
    _engine.clearPreview();
    _saveSession();
    _notify();
    return true;
  }

  /// App vào nền khi đang chơi: lưu ván để chơi tiếp được dù app bị đóng.
  void saveOnPause() {
    if (_status != LevelStatus.playing) return;
    _engine.clearPreview();
    _saveSession();
  }

  /// Lưu bảng, khay, điểm và combo của ván đang chơi. Bỏ qua khi đang có hiệu
  /// ứng xóa dòng (bảng chưa ổn định); lần lưu sau animation sẽ bù lại.
  void _saveSession() {
    if (_disposed || _level == null || _clearing) return;
    unawaited(
      _progress.saveLevelSession(
        _engine.snapshot(
          mode: GameMode.level,
          levelIndex: _level!.levelIndex,
        ),
      ),
    );
  }

  /// PLAY AGAIN sau khi thua: round mới ở Rough Stone của gem (FR2.3).
  void playAgain() {
    if (_status != LevelStatus.lost) return;
    start(_outcome?.nextLevel ?? returnLevel);
  }

  /// CONTINUE sau Victory: dừng hiệu ứng và âm thanh, sang level kế
  /// (AC3.1.3). Chỉ có tác dụng một lần, vì round mới đổi trạng thái về
  /// `playing`. Ở level 36 không có CONTINUE (AC3.3.2).
  void continueAfterWin() {
    if (_status != LevelStatus.won || !victoryVariant.canContinue) return;
    _stopCelebration();
    start(_outcome?.nextLevel ?? level);
  }

  void _stopCelebration() {
    _unlockTimer?.cancel();
    _unlockTimer = null;
    _feedback.stopSfx();
  }

  // ----- Nội bộ -----

  /// Chờ animation (nếu có) và việc lưu kết quả, tối đa [resolveTimeout] cho
  /// phần lưu (ADR-008, BR5.9). Mỗi round chỉ được gọi một lần.
  Future<void> _resolve(
    int round,
    Future<void>? animation, {
    required bool won,
  }) async {
    final played = level;
    final finalScore = score;
    // Ván đã có kết quả: không còn gì để chơi tiếp.
    unawaited(_progress.saveLevelSession(null));
    JourneyOutcome? saved;
    final save =
        (won
                ? _journey.onLevelWon(played, finalScore)
                : _journey.onLevelLost(played, finalScore))
            .then((o) => saved = o);
    final timeout = Completer<void>();
    final timer = Timer(resolveTimeout, () {
      if (!timeout.isCompleted) timeout.complete();
    });
    try {
      await Future.wait<void>([
        animation ?? Future<void>.value(),
        Future.any<void>([save, timeout.future]),
      ]);
    } catch (e) {
      GjLog.error('Game', 'resolving failed: levelId=${played.levelIndex}', e);
    } finally {
      timer.cancel();
    }
    if (_isStale(round)) return;
    if (saved == null) {
      GjLog.warn(
        'Game',
        'resolving timed out, using cached outcome: '
            'levelId=${played.levelIndex}',
      );
    }
    _outcome =
        saved ??
        (won ? _journey.outcomeFor(played) : _journey.lostOutcomeFor(played));
    _trackResult(played, finalScore, won, _outcome!);
    _clearing = false;
    if (won) {
      _status = LevelStatus.won;
      _feedback.victory();
      if (victoryVariant.playsUnlock) {
        _unlockTimer = Timer(unlockDelay, () {
          if (!_isStale(round) && _status == LevelStatus.won) {
            _feedback.unlock();
          }
        });
      }
    } else {
      _status = LevelStatus.lost;
      _feedback.gameOver();
    }
    _notify();
  }

  void _showCombo(int streak) {
    _comboText = streak > 2 ? 'INCREDIBLE!' : 'COMBO x$streak';
    _comboTimer?.cancel();
    _comboTimer = Timer(comboTextDuration, () {
      _comboText = null;
      _notify();
    });
  }

  bool _isStale(int round) => _disposed || round != _epoch;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _comboTimer?.cancel();
    _unlockTimer?.cancel();
    super.dispose();
  }
}
