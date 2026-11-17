/// Một trong 36 level của hành trình, bất biến trong phiên (contract C3).
class Level {
  const Level({
    required this.levelIndex,
    required this.gemId,
    required this.gemName,
    required this.gemOrder,
    required this.subId,
    required this.subName,
    required this.subOrder,
    required this.targetScore,
    required this.assetPath,
    this.backgroundUrl,
  });

  static const int levelsPerGem = 6;
  static const int totalLevels = 36;

  /// `levelIndex = (gemOrder − 1) × 6 + subOrder` (BR2.1).
  static int indexOf(int gemOrder, int subOrder) =>
      (gemOrder - 1) * levelsPerGem + subOrder;

  /// `assets/design/Level<gemOrder>/<subOrder>.jpg` (BR2.3).
  static String assetPathOf(int gemOrder, int subOrder) =>
      'assets/design/Level$gemOrder/$subOrder.jpg';

  final int levelIndex;
  final String gemId;
  final String gemName;
  final int gemOrder;
  final String subId;
  final String subName;
  final int subOrder;
  final int targetScore;
  final String assetPath;
  final String? backgroundUrl;

  /// Nhãn hiển thị `"<gemName> · <subName>"`.
  String get displayName => '$gemName · $subName';

  bool get isFinal => levelIndex == totalLevels;
}
