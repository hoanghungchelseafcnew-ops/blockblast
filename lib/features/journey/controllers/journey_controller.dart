import '../../../core/log/gj_log.dart';
import '../models/journey_outcome.dart';
import '../models/level.dart';
import '../models/player_progress.dart';
import '../services/level_catalog.dart';
import '../services/progress_repository.dart';

/// Quy tắc hành trình ở U1: thắng một level thì sang level kế (contract C1).
/// Thuần: không analytics. `onLevelLost` do U2 thêm.
class JourneyController {
  JourneyController({
    required ProgressRepository repository,
    required LevelCatalog catalog,
  })  : _repository = repository,
        _catalog = catalog;

  final ProgressRepository _repository;
  final LevelCatalog _catalog;

  /// Level người chơi sẽ chơi khi bấm PLAY.
  Level get currentLevel {
    return _catalog.byIndexOr(
      _repository.progress.currentLevelIndex,
      _catalog.byIndex(1),
    );
  }

  /// Có từ U1, luôn false cho tới U2.
  bool get journeyCompleted => false;

  /// Kết quả tính từ cache hiện tại (không I/O). Dùng cho timeout resolving.
  JourneyOutcome outcomeFor(Level level) {
    return JourneyOutcome(
      nextLevel: _catalog.next(level),
      highestLevelReached: _repository.progress.highestLevelReached,
    );
  }

  /// Ghi nhận thắng [level] (BR4.1, BR4.2). Cập nhật cache ngay, hoàn tất sau
  /// khi ghi xong hoặc ghi lỗi (BR4.3). Không bao giờ throw.
  Future<JourneyOutcome> onLevelWon(Level level, int score) async {
    try {
      GjLog.info('Journey', 'level won: levelId=${level.levelIndex} score=$score');
      final updated = _applyWin(_repository.progress, level);
      await _repository.savePlayerProgress(updated);
    } catch (e) {
      GjLog.error('Journey', 'saving win failed: levelId=${level.levelIndex}', e);
    }
    try {
      return outcomeFor(level);
    } catch (e) {
      GjLog.error('Journey', 'computing outcome failed', e);
      return JourneyOutcome(
        nextLevel: null,
        highestLevelReached: level.levelIndex,
      );
    }
  }

  static PlayerProgress _applyWin(PlayerProgress progress, Level level) {
    final k = level.levelIndex;
    final completed = <int>{...progress.completedLevels, k};
    if (k < Level.totalLevels) {
      final next = k + 1;
      final highest =
          next > progress.highestLevelReached ? next : progress.highestLevelReached;
      return progress.copyWith(
        currentLevelIndex: next,
        completedLevels: completed,
        highestLevelReached: highest,
      );
    }
    // BR4.2: thắng level 36 vẫn ở level 36; journeyCompleted là việc của U2.
    return progress.copyWith(
      currentLevelIndex: Level.totalLevels,
      completedLevels: completed,
      highestLevelReached: Level.totalLevels,
    );
  }
}
