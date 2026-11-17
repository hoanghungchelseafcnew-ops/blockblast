import 'level.dart';

/// Kết quả trả về sau khi xử lý thắng (contract C1).
class JourneyOutcome {
  const JourneyOutcome({
    required this.nextLevel,
    required this.highestLevelReached,
    this.unlockedGemId,
    this.journeyCompleted = false,
  });

  /// Null khi vừa thắng level 36 (BR4.2).
  final Level? nextLevel;
  final int highestLevelReached;

  /// U1 luôn null; U2 điền.
  final String? unlockedGemId;

  /// U1 luôn false; U2 điền.
  final bool journeyCompleted;
}
