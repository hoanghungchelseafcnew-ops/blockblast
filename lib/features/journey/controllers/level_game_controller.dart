import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/log/gj_log.dart';
import '../../game/engine/board_engine.dart';
import '../../game/models/block_model.dart';
import '../../game/models/cell_model.dart';
import '../../game/services/game_feedback.dart';
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
    this.resolveTimeout = const Duration(seconds: 3),
    this.comboTextDuration = const Duration(seconds: 1),
    String Function()? roundIdFactory,
  })  : _journey = journey,
        _progress = progress,
        _engine = engine ?? BoardEngine(),
        _feedback = feedback,
        _roundIdFactory = roundIdFactory ?? _defaultRoundId;

  final JourneyController _journey;
  final ProgressRepository _progress;
  final BoardEngine _engine;
  final GameFeedback _feedback;
  final String Function() _roundIdFactory;

  /// Trần chờ `onLevelWon` ở trạng thái `resolving` (BR5.9).
  final Duration resolveTimeout;
  final Duration comboTextDuration;

  static int _roundCounter = 0;
  static String _defaultRoundId() =>
      '${DateTime.now().microsecondsSinceEpoch}-${_roundCounter++}';

  Level? _level;
  int _targetScore = 1;
  String _roundId = '';
  LevelStatus _status = LevelStatus.playing;
  bool _clearing = false;
  bool _revived = false;
  JourneyOutcome? _outcome;
  bool _tutorialActive = false;
  String? _comboText;
  BlockModel? _activeBlock;
  Timer? _comboTimer;
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
  bool get revived => _revived;
  JourneyOutcome? get outcome => _outcome;
  bool get tutorialActive => _tutorialActive;
  String? get comboText => _comboText;
  BlockModel? get activeBlock => _activeBlock;

  List<List<CellModel>> get board => _engine.board;
  List<BlockModel> get tray => _engine.tray;
  int get score => _engine.score;
  int get comboStreak => _engine.comboStreak;

  /// U1 luôn 0 và UI ẩn BEST; U2 điền giá trị thật (contract C2).
  int get bestScore => 0;

  /// Phần trăm làm tròn xuống, tối đa 99 trước khi đạt mốc (BR5.6).
  int get progressPercent {
    if (score >= _targetScore) return 100;
    return math.min(99, (score * 100) ~/ _targetScore);
  }

  bool get canRevive => _status == LevelStatus.lost && !_revived;

  // ----- Hành động -----

  /// Bắt đầu một ván mới ở [level] (WF2): round mới, mốc điểm được chốt.
  void start(Level level) {
    _epoch++;
    _comboTimer?.cancel();
    _level = level;
    if (level.targetScore < 1) {
      GjLog.error('Game', 'target below 1, raised to 1: levelId=${level.levelIndex}');
    }
    _targetScore = math.max(1, level.targetScore);
    _roundId = _roundIdFactory();
    _status = LevelStatus.playing;
    _clearing = false;
    _revived = false;
    _outcome = null;
    _activeBlock = null;
    _comboText = null;
    _tutorialActive = !_progress.tutorialCompleted;
    _engine.reset();
    _notify();
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
      await _resolveWin(round, animation);
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
      // Người chơi bấm back trong lúc animation (BR5.8).
      _notify();
      return;
    }

    _engine.refillTrayIfEmpty();
    if (!_engine.hasMoves) {
      _status = LevelStatus.lost;
      _feedback.gameOver();
    }
    _notify();
  }

  /// Xử lý nút back (WF6). Trả true nếu được phép rời màn hình.
  bool requestBack() {
    switch (_status) {
      case LevelStatus.resolving:
        return false;
      case LevelStatus.playing:
        _status = LevelStatus.quit;
        _activeBlock = null;
        _engine.clearPreview();
        _notify();
        return true;
      case LevelStatus.won:
      case LevelStatus.lost:
      case LevelStatus.quit:
        return true;
    }
  }

  /// REVIVE một lần: xóa vùng 3×3 giữa bảng rồi chơi tiếp (BR5.7).
  void revive() {
    if (!canRevive) return;
    _engine.clearCenter();
    _revived = true;
    _status = LevelStatus.playing;
    _notify();
  }

  /// PLAY AGAIN: round mới cùng level (BR5.7).
  void playAgain() {
    if (_status != LevelStatus.lost) return;
    start(level);
  }

  /// CONTINUE sau Victory: sang level kế, hoặc chơi lại level 36 (WF4.5).
  void continueAfterWin() {
    if (_status != LevelStatus.won) return;
    start(_outcome?.nextLevel ?? level);
  }

  // ----- Nội bộ -----

  Future<void> _resolveWin(int round, Future<void>? animation) async {
    final won = level;
    JourneyOutcome? saved;
    final save = _journey.onLevelWon(won, score).then((o) => saved = o);
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
      GjLog.error('Game', 'resolving failed: levelId=${won.levelIndex}', e);
    } finally {
      timer.cancel();
    }
    if (_isStale(round)) return;
    if (saved == null) {
      GjLog.warn(
        'Game',
        'resolving timed out, using cached outcome: levelId=${won.levelIndex}',
      );
    }
    _outcome = saved ?? _journey.outcomeFor(won);
    _clearing = false;
    _status = LevelStatus.won;
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
    super.dispose();
  }
}
