/// Kết quả tính điểm của một lượt đặt khối (BR5.1, BR5.2).
class TurnResult {
  const TurnResult({
    required this.cellsPlaced,
    required this.linesCleared,
    required this.comboStreak,
    required this.placementScore,
    required this.lineScore,
  });

  /// Số ô của khối vừa đặt.
  final int cellsPlaced;

  /// Số dòng và cột đầy được xóa trong lượt.
  final int linesCleared;

  /// `comboStreak` sau lượt này (0 nếu lượt không xóa dòng).
  final int comboStreak;

  /// Điểm đặt khối: ô × 10.
  final int placementScore;

  /// Điểm xóa dòng: dòng × 100 × combo.
  final int lineScore;

  int get totalScore => placementScore + lineScore;

  bool get clearedAnyLine => linesCleared > 0;
}
