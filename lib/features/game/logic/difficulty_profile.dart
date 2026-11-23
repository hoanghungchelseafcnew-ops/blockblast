import 'difficulty_constants.dart';
import 'tray_models.dart';

/// Đường cong độ khó thuần: (level, độ đầy bảng) → [TrayRates].
///
/// Không trạng thái, không ngẫu nhiên, không I/O (BR2.3, BR3.1, BR3.2).
class DifficultyProfile {
  const DifficultyProfile();

  /// Tỉ lệ chọn khối ở [level] (1..36, ngoài khoảng thì kẹp lại) khi bảng có
  /// [filledCells] ô đã lấp.
  TrayRates ratesFor({required int level, required int filledCells}) {
    final clamped = level.clamp(
      DifficultyConstants.levelMin,
      DifficultyConstants.levelMax,
    );
    final t =
        (clamped - DifficultyConstants.levelMin) /
        (DifficultyConstants.levelMax - DifficultyConstants.levelMin);

    double lerp(double start, double end) => start + (end - start) * t;

    var small = lerp(
      DifficultyConstants.smallRateStart,
      DifficultyConstants.smallRateEnd,
    );
    var medium = DifficultyConstants.mediumRate;
    var large = lerp(
      DifficultyConstants.largeRateStart,
      DifficultyConstants.largeRateEnd,
    );
    final rescue = lerp(
      DifficultyConstants.rescueRateStart,
      DifficultyConstants.rescueRateEnd,
    );

    if (filledCells > DifficultyConstants.fullBoardThresholdCells) {
      small += DifficultyConstants.fullBoardSmallBonus;
      large *= DifficultyConstants.fullBoardLargeFactor;
      medium = (1 - small - large).clamp(0.0, 1.0).toDouble();
    }

    return TrayRates(
      smallRate: small,
      mediumRate: medium,
      largeRate: large,
      rescueRate: rescue,
    );
  }
}
