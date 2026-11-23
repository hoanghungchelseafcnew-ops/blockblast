import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../core/log/gj_log.dart';
import '../../game/engine/board_engine.dart';
import '../../game/logic/difficulty_constants.dart';
import '../../game/models/block_model.dart';
import '../../game/models/cell_model.dart';
import '../../game/models/game_snapshot.dart';
import '../../game/services/game_feedback.dart';
import '../../journey/services/progress_repository.dart';
import '../models/endless_state.dart';

/// Ván endless sau Journey Complete (FR9, quy tắc ER1..ER14 của U6).
///
/// Cùng quy tắc tính điểm với chế độ level nhưng không có target hay Victory.
/// Điểm được lưu khi QUIT và khi app vào nền; thua thì điểm lưu về 0. Không
/// nhận `AnalyticsService` nên không thể gửi event level (ER10).
class EndlessGameController extends ChangeNotifier {
  EndlessGameController({
    required ProgressRepository progress,
    BoardEngine? engine,
    GameFeedback feedback = const NoopGameFeedback(),
  }) : _progress = progress,
       _engine = engine ?? BoardEngine(),
       _feedback = feedback;

  final ProgressRepository _progress;
  final BoardEngine _engine;
  final GameFeedback _feedback;

  EndlessStatus _status = EndlessStatus.playing;
  bool _clearing = false;
  BlockModel? _activeBlock;
  int _epoch = 0;
  bool _disposed = false;

  // ----- State cho UI -----

  EndlessStatus get status => _status;
  bool get clearing => _clearing;
  BlockModel? get activeBlock => _activeBlock;
  List<List<CellModel>> get board => _engine.board;
  List<BlockModel> get tray => _engine.tray;
  int get score => _engine.score;

  /// BEST của endless: high score đã lưu hoặc điểm hiện tại nếu cao hơn (ER8).
  int get bestScore => math.max(_progress.endlessState.highScore, score);

  /// Back lúc đang chơi phải hỏi "Quit?" trước (ER4, ER14).
  bool get needsQuitConfirmation => _status == EndlessStatus.playing;

  bool get _canPlay => _status == EndlessStatus.playing && !_clearing;

  // ----- Hành động -----

  /// Ván mới từ điểm đã lưu, bảng trống, khay mới (ER2).
  ///
  /// Với [resumeSaved] true và có bản lưu ván dở thì nạp lại bảng, khay, điểm
  /// và combo; mặc định bỏ bản lưu cũ.
  void start({bool resumeSaved = false}) {
    _epoch++;
    _status = EndlessStatus.playing;
    _clearing = false;
    _activeBlock = null;
    _engine.difficultyLevel = DifficultyConstants.endlessLevel;
    _engine.reset(startScore: _progress.endlessState.savedScore);
    final saved = _progress.endlessSession;
    if (saved != null) {
      if (resumeSaved) {
        _engine.restore(saved);
      }
      if (!resumeSaved || !_engine.hasMoves) {
        // Ván mới, hoặc bản lưu không còn nước đi: bỏ bản lưu.
        if (resumeSaved) {
          _engine.reset(startScore: _progress.endlessState.savedScore);
        }
        unawaited(_progress.saveEndlessSession(null));
      }
    }
    _notify();
  }

  void onDragStart(BlockModel block) {
    if (!_canPlay) return;
    _activeBlock = block;
    _notify();
  }

  void updatePreview(int row, int col) {
    final block = _activeBlock;
    if (!_canPlay || block == null) return;
    _engine.showPreview(block, row, col);
    _notify();
  }

  void cancelDrag() {
    _engine.clearPreview();
    _activeBlock = null;
    _notify();
  }

  /// Thả khối (ER3). Hết nước đi thì thua và lưu (ER6, ER7).
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
    final round = _epoch;
    if (result.clearedAnyLine) {
      _feedback.cleared();
      if (result.comboStreak > 1) _feedback.combo();
      _clearing = true;
      _notify();
      await _engine.applyClear();
      if (_isStale(round)) return;
      _clearing = false;
    }
    if (_status != EndlessStatus.playing) {
      // Người chơi đã xác nhận QUIT trong lúc animation.
      _saveSession();
      _notify();
      return;
    }
    _engine.refillTrayIfEmpty();
    if (!_engine.hasMoves) {
      _status = EndlessStatus.saving;
      _notify();
      unawaited(_progress.saveEndlessSession(null));
      await _save(_progress.endlessState.afterLoss(score), 'loss');
      if (_isStale(round)) return;
      _status = EndlessStatus.lost;
      _feedback.gameOver();
    } else {
      _saveSession();
    }
    _notify();
  }

  /// Back hệ thống hoặc [←]. Trả true nếu được rời màn ngay. Khi đang chơi
  /// thì UI hỏi "Quit?" rồi gọi [confirmQuit]; khi đang lưu thì bỏ qua.
  bool requestBack() {
    switch (_status) {
      case EndlessStatus.playing:
      case EndlessStatus.saving:
        return false;
      case EndlessStatus.lost:
      case EndlessStatus.quit:
        return true;
    }
  }

  /// QUIT: lưu điểm hiện tại (kể cả 0) và high score, rồi sang `quit` (ER4,
  /// ER7). Trả false nếu không đang chơi.
  Future<bool> confirmQuit() async {
    if (_status != EndlessStatus.playing) return false;
    _status = EndlessStatus.saving;
    _activeBlock = null;
    _engine.clearPreview();
    _notify();
    _saveSession();
    await _save(_progress.endlessState.saving(score), 'quit');
    _status = EndlessStatus.quit;
    _notify();
    return true;
  }

  /// App vào nền khi đang chơi: lưu điểm và ván dở (ER5, ER7).
  Future<void> saveOnPause() async {
    if (_status != EndlessStatus.playing) return;
    _engine.clearPreview();
    _saveSession();
    await _save(_progress.endlessState.saving(score), 'pause');
  }

  /// Lưu bảng, khay, điểm và combo. Bỏ qua khi đang xóa dòng (bảng chưa ổn
  /// định); lần lưu sau animation sẽ bù lại.
  void _saveSession() {
    if (_disposed || _clearing) return;
    unawaited(
      _progress.saveEndlessSession(_engine.snapshot(mode: GameMode.endless)),
    );
  }

  /// PLAY AGAIN sau khi thua: ván mới từ 0 (ER6).
  void playAgain() {
    if (_status != EndlessStatus.lost) return;
    start();
  }

  // ----- Nội bộ -----

  Future<void> _save(EndlessState state, String reason) async {
    try {
      await _progress.saveEndlessState(state);
    } catch (e) {
      GjLog.error('Endless', 'saving endless state failed: $reason', e);
    }
  }

  bool _isStale(int round) => _disposed || round != _epoch;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }
}
