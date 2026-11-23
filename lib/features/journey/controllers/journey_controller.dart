import '../../../core/log/gj_log.dart';
import '../models/journey_outcome.dart';
import '../models/level.dart';
import '../models/player_progress.dart';
import '../services/level_catalog.dart';
import '../services/progress_repository.dart';

/// Quy tắc hành trình (contract C1). Thuần: không analytics.
///
/// - Thắng: sang level kế; thắng Bling thì mở khóa gem; thắng level 36 thì
///   hoàn thành hành trình (FR2.5).
/// - Thua: về Rough Stone của gem đang chơi và xóa các level con của gem đó
///   khỏi `completedLevels` (FR2.3, FR2.3a).
/// - High score theo level được cập nhật khi thắng và khi thua (AC1.7.2).
class JourneyController {
  JourneyController({
    required ProgressRepository repository,
    required LevelCatalog catalog,
  }) : _repository = repository,
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

  /// True sau khi thắng Ruby · Bling (level 36).
  bool get journeyCompleted => _repository.progress.journeyCompleted;

  /// High score đã lưu của [level], hoặc 0.
  int bestScoreFor(Level level) => _repository.highScore(level.levelIndex);

  /// Rough Stone của gem chứa [level]: nơi người chơi quay về khi thua.
  Level returnLevelFor(Level level) => _catalog.firstSubOf(level.gemId);

  /// Level đứng sau [level] trong hành trình, hoặc null ở level 36. Dùng để
  /// nạp sẵn ảnh nền (FR5.4).
  Level? nextLevelFor(Level level) => _catalog.next(level);

  /// Kết quả thắng tính từ cache hiện tại (không I/O). Dùng cho timeout.
  JourneyOutcome outcomeFor(Level level) {
    final isFinal = _catalog.isFinal(level);
    return JourneyOutcome(
      nextLevel: _catalog.next(level),
      highestLevelReached: _repository.progress.highestLevelReached,
      unlockedGemId: _catalog.isBling(level) ? level.gemId : null,
      journeyCompleted: isFinal,
    );
  }

  /// Kết quả thua tính từ cache hiện tại (không I/O). Dùng cho timeout.
  JourneyOutcome lostOutcomeFor(Level level) {
    return JourneyOutcome(
      nextLevel: returnLevelFor(level),
      highestLevelReached: _repository.progress.highestLevelReached,
      journeyCompleted: _repository.progress.journeyCompleted,
    );
  }

  /// Ghi nhận thắng [level]. Cập nhật cache ngay, hoàn tất sau khi ghi xong
  /// hoặc ghi lỗi. Không bao giờ throw (C1 `errors`).
  Future<JourneyOutcome> onLevelWon(Level level, int score) async {
    try {
      GjLog.info(
        'Journey',
        'level won: levelId=${level.levelIndex} score=$score',
      );
      final updated = _applyWin(_repository.progress, level);
      await Future.wait<void>([
        _repository.savePlayerProgress(updated),
        _repository.saveHighScore(level.levelIndex, score),
      ]);
    } catch (e) {
      GjLog.error(
        'Journey',
        'saving win failed: levelId=${level.levelIndex}',
        e,
      );
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

  /// Ghi nhận thua [level] (FR2.3..FR2.4). `currentLevel` thành Rough Stone
  /// của gem đang chơi; high score và `highestLevelReached` không giảm.
  /// Không bao giờ throw.
  Future<JourneyOutcome> onLevelLost(Level level, int score) async {
    try {
      GjLog.info(
        'Journey',
        'level lost: levelId=${level.levelIndex} score=$score',
      );
      final updated = _applyLoss(_repository.progress, level);
      await Future.wait<void>([
        _repository.savePlayerProgress(updated),
        _repository.saveHighScore(level.levelIndex, score),
      ]);
    } catch (e) {
      GjLog.error(
        'Journey',
        'saving loss failed: levelId=${level.levelIndex}',
        e,
      );
    }
    try {
      return lostOutcomeFor(level);
    } catch (e) {
      GjLog.error('Journey', 'computing lost outcome failed', e);
      return JourneyOutcome(
        nextLevel: level,
        highestLevelReached: level.levelIndex,
      );
    }
  }

  PlayerProgress _applyWin(PlayerProgress progress, Level level) {
    final k = level.levelIndex;
    final completed = <int>{...progress.completedLevels, k};
    final gems = _catalog.isBling(level)
        ? <String>{...progress.unlockedGems, level.gemId}
        : progress.unlockedGems;
    if (k < Level.totalLevels) {
      final next = k + 1;
      final highest = next > progress.highestLevelReached
          ? next
          : progress.highestLevelReached;
      return progress.copyWith(
        currentLevelIndex: next,
        completedLevels: completed,
        unlockedGems: gems,
        highestLevelReached: highest,
      );
    }
    // Thắng level 36: ở lại level 36 và đánh dấu hoàn thành hành trình.
    return progress.copyWith(
      currentLevelIndex: Level.totalLevels,
      completedLevels: completed,
      unlockedGems: gems,
      journeyCompleted: true,
      highestLevelReached: Level.totalLevels,
    );
  }

  PlayerProgress _applyLoss(PlayerProgress progress, Level level) {
    return progress
        .withoutGem(level.gemOrder)
        .copyWith(currentLevelIndex: returnLevelFor(level).levelIndex);
  }
}
