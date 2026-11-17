import 'dart:convert';

import '../../../core/config/level_config.dart';
import '../../../core/log/gj_log.dart';
import 'level.dart';

/// Tiến trình hành trình đã lưu (key `progress`, contract E3).
class PlayerProgress {
  const PlayerProgress({
    required this.currentLevelIndex,
    required this.completedLevels,
    required this.unlockedGems,
    required this.journeyCompleted,
    required this.highestLevelReached,
  });

  /// Level 1, rỗng, chưa hoàn thành (BR3.1).
  static const PlayerProgress initial = PlayerProgress(
    currentLevelIndex: 1,
    completedLevels: <int>{},
    unlockedGems: <String>{},
    journeyCompleted: false,
    highestLevelReached: 1,
  );

  final int currentLevelIndex;
  final Set<int> completedLevels;

  /// U1 không ghi; U2 dùng.
  final Set<String> unlockedGems;

  /// U1 luôn false.
  final bool journeyCompleted;

  /// Level cao nhất người chơi từng mở được, không phải đã hoàn thành (BR4.1).
  final int highestLevelReached;

  PlayerProgress copyWith({
    int? currentLevelIndex,
    Set<int>? completedLevels,
    Set<String>? unlockedGems,
    bool? journeyCompleted,
    int? highestLevelReached,
  }) {
    return PlayerProgress(
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      completedLevels: completedLevels ?? this.completedLevels,
      unlockedGems: unlockedGems ?? this.unlockedGems,
      journeyCompleted: journeyCompleted ?? this.journeyCompleted,
      highestLevelReached: highestLevelReached ?? this.highestLevelReached,
    );
  }

  String toJsonString() {
    final sorted = completedLevels.toList()..sort();
    return jsonEncode({
      'currentLevelIndex': currentLevelIndex,
      'completedLevels': sorted,
      'unlockedGems': unlockedGems.toList()..sort(),
      'journeyCompleted': journeyCompleted,
      'highestLevelReached': highestLevelReached,
    });
  }

  /// Parse tolerant (BR3.1, D-S4). Trả `null` nếu giá trị hỏng hoặc
  /// `currentLevelIndex` ngoài 1..36; caller dùng [initial]. Trường lạ bị bỏ
  /// qua, phần tử `completedLevels` ngoài 1..36 bị bỏ.
  static PlayerProgress? tryParse(Object? raw) {
    if (raw is! String) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      GjLog.warn('Progress', 'progress json decode failed', e);
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    final current = decoded['currentLevelIndex'];
    if (current is! int || !_inRange(current)) return null;

    final completed = <int>{};
    final completedRaw = decoded['completedLevels'];
    if (completedRaw is List) {
      for (final item in completedRaw) {
        if (item is int && _inRange(item)) completed.add(item);
      }
    }

    final gems = <String>{};
    final gemsRaw = decoded['unlockedGems'];
    if (gemsRaw is List) {
      for (final item in gemsRaw) {
        if (item is String && GemIds.all.contains(item)) gems.add(item);
      }
    }

    final journeyDone = decoded['journeyCompleted'];
    final highestRaw = decoded['highestLevelReached'];
    final highest = (highestRaw is int && _inRange(highestRaw)) ? highestRaw : 1;

    return PlayerProgress(
      currentLevelIndex: current,
      completedLevels: completed,
      unlockedGems: gems,
      journeyCompleted: journeyDone is bool ? journeyDone : false,
      highestLevelReached: highest > current ? highest : current,
    );
  }

  static bool _inRange(int value) => value >= 1 && value <= Level.totalLevels;
}
