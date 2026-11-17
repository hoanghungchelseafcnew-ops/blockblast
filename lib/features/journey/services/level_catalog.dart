import '../../../core/config/level_config.dart';
import '../models/level.dart';

/// Danh mục 36 level bất biến trong phiên (contract C3, BR2.1..BR2.4).
class LevelCatalog {
  LevelCatalog._(this.levels);

  /// Dựng từ cấu hình đã validate. Cấu hình activate muộn hơn không đổi
  /// catalog đang dùng (BR2.4).
  factory LevelCatalog.from(LevelConfig config) {
    final built = <Level>[];
    for (final gem in config.levels.values) {
      for (final sub in gem.subLevels.values) {
        built.add(
          Level(
            levelIndex: Level.indexOf(gem.order, sub.order),
            gemId: gem.gemId,
            gemName: gem.name,
            gemOrder: gem.order,
            subId: sub.subId,
            subName: sub.name,
            subOrder: sub.order,
            targetScore: sub.targetScore,
            backgroundUrl: sub.backgroundUrl,
            assetPath: Level.assetPathOf(gem.order, sub.order),
          ),
        );
      }
    }
    built.sort((a, b) => a.levelIndex.compareTo(b.levelIndex));
    return LevelCatalog._(List<Level>.unmodifiable(built));
  }

  /// Đúng 36 phần tử, sắp theo `levelIndex` 1..36, không sửa được.
  final List<Level> levels;

  /// Level theo chỉ số 1..36. Ném [RangeError] nếu ngoài khoảng.
  Level byIndex(int levelIndex) {
    RangeError.checkValueInInterval(levelIndex, 1, levels.length, 'levelIndex');
    return levels[levelIndex - 1];
  }

  /// Level theo chỉ số, hoặc [fallback] nếu ngoài 1..36.
  Level byIndexOr(int levelIndex, Level fallback) {
    if (levelIndex < 1 || levelIndex > levels.length) return fallback;
    return levels[levelIndex - 1];
  }

  /// Level kế tiếp, hoặc null ở level 36 (BR2.2).
  Level? next(Level level) {
    if (level.levelIndex >= levels.length) return null;
    return levels[level.levelIndex];
  }

  /// Level đầu tiên (Rough Stone) của một gem.
  Level firstSubOf(String gemId) =>
      levels.firstWhere((l) => l.gemId == gemId && l.subOrder == 1);

  bool isBling(Level level) => level.subOrder == Level.levelsPerGem;

  bool isFinal(Level level) => level.levelIndex == levels.length;
}
