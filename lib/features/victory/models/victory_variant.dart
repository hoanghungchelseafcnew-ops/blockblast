import '../../journey/models/journey_outcome.dart';

/// Biến thể của màn Victory (interaction-spec, VictoryScreen).
enum VictoryVariant {
  /// Hoàn thành level con 1–5 (M-4).
  sub,

  /// Hoàn thành Bling của gem 1–5: mở khóa gem (M-5).
  gemUnlock,

  /// Hoàn thành level 36: hết hành trình, không có CONTINUE (M-5a).
  journeyComplete;

  /// Chọn biến thể từ kết quả thắng (contract C1).
  static VictoryVariant of(JourneyOutcome outcome) {
    if (outcome.journeyCompleted) return VictoryVariant.journeyComplete;
    if (outcome.unlockedGemId != null) return VictoryVariant.gemUnlock;
    return VictoryVariant.sub;
  }

  /// Có nút CONTINUE hay không (AC3.3.2).
  bool get canContinue => this != VictoryVariant.journeyComplete;

  /// Có phát âm thanh unlock sau victory hay không (FR6.2).
  bool get playsUnlock => this != VictoryVariant.sub;
}
