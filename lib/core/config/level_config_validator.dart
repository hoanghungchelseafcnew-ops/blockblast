import 'dart:convert';

import '../log/gj_log.dart';
import 'image_url_policy.dart';
import 'level_config.dart';

/// Kết quả validate. `config == null` nghĩa là bỏ toàn bộ cấu hình.
class ValidationResult {
  const ValidationResult({
    this.config,
    this.errors = const [],
    this.warnings = const [],
  });

  final LevelConfig? config;

  /// Mã lỗi, ví dụ `invalid_target_score:amethyst.shaping`. Không chứa JSON thô.
  final List<String> errors;

  /// Cảnh báo không loại cấu hình: URL bị bỏ, mốc không tăng dần.
  final List<String> warnings;

  bool get isValid => config != null;

  /// Lỗi đầu tiên, để log (D-S5).
  String? get firstError => errors.isEmpty ? null : errors.first;
}

/// Validate JSON `level_config` (BR1.2, BR1.3, BR1.6, E1, D-S1).
///
/// Hàm thuần, không throw. Chỉ cần một lỗi cấu trúc là loại toàn bộ; URL ảnh
/// xấu chỉ bị bỏ cho riêng level đó. Trường lạ được bỏ qua.
class LevelConfigValidator {
  const LevelConfigValidator._();

  static const int maxRawBytes = 65536;
  static const int minTargetScore = 1;
  static const int maxTargetScore = 10000000;

  static ValidationResult validate(String raw, {required ConfigSource source}) {
    try {
      return _validate(raw, source);
    } catch (e) {
      GjLog.error('LevelConfig', 'validation crashed', e);
      return const ValidationResult(errors: ['unexpected_error']);
    }
  }

  static ValidationResult _validate(String raw, ConfigSource source) {
    if (utf8.encode(raw).length > maxRawBytes) {
      return const ValidationResult(errors: ['too_large']);
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (e) {
      GjLog.warn('LevelConfig', 'json decode failed', e);
      return const ValidationResult(errors: ['parse_error']);
    }
    if (decoded is! Map<String, dynamic>) {
      return const ValidationResult(errors: ['invalid_root']);
    }

    final version = decoded['version'];
    if (version is! int || version < 1) {
      return const ValidationResult(errors: ['invalid_version']);
    }
    final levelsRaw = decoded['levels'];
    if (levelsRaw is! Map<String, dynamic> ||
        levelsRaw.length != GemIds.all.length) {
      return const ValidationResult(errors: ['invalid_levels']);
    }

    final warnings = <String>[];
    final gems = <String, GemConfig>{};
    final gemOrders = <int>{};
    for (final gemId in GemIds.all) {
      final gemRaw = levelsRaw[gemId];
      if (gemRaw is! Map<String, dynamic>) {
        return ValidationResult(errors: ['missing_gem:$gemId']);
      }
      final order = gemRaw['order'];
      if (order is! int || order < 1 || order > 6 || !gemOrders.add(order)) {
        return ValidationResult(errors: ['invalid_gem_order:$gemId']);
      }
      final name = gemRaw['name'];
      if (name is! String || name.trim().isEmpty) {
        return ValidationResult(errors: ['invalid_gem_name:$gemId']);
      }
      final subsRaw = gemRaw['sub_levels'];
      if (subsRaw is! Map<String, dynamic> ||
          subsRaw.length != SubIds.all.length) {
        return ValidationResult(errors: ['invalid_sub_levels:$gemId']);
      }
      final subs = <String, SubLevelConfig>{};
      final subOrders = <int>{};
      for (final subId in SubIds.all) {
        final path = '$gemId.$subId';
        final subRaw = subsRaw[subId];
        if (subRaw is! Map<String, dynamic>) {
          return ValidationResult(errors: ['missing_sub:$path']);
        }
        final subOrder = subRaw['order'];
        if (subOrder is! int ||
            subOrder < 1 ||
            subOrder > 6 ||
            !subOrders.add(subOrder)) {
          return ValidationResult(errors: ['invalid_sub_order:$path']);
        }
        final subName = subRaw['name'];
        if (subName is! String || subName.trim().isEmpty) {
          return ValidationResult(errors: ['invalid_sub_name:$path']);
        }
        final target = subRaw['target_score'];
        if (target is! int ||
            target < minTargetScore ||
            target > maxTargetScore) {
          return ValidationResult(errors: ['invalid_target_score:$path']);
        }
        String? url;
        final urlRaw = subRaw['background_url'];
        if (urlRaw != null) {
          if (urlRaw is String && ImageUrlPolicy.isAllowed(urlRaw)) {
            url = urlRaw.trim();
          } else if (!(urlRaw is String && urlRaw.trim().isEmpty)) {
            warnings.add('background_url_rejected:$path');
          }
        }
        subs[subId] = SubLevelConfig(
          subId: subId,
          order: subOrder,
          name: subName,
          targetScore: target,
          backgroundUrl: url,
        );
      }
      gems[gemId] = GemConfig(
        gemId: gemId,
        order: order,
        name: name,
        subLevels: subs,
      );
    }

    final config = LevelConfig(version: version, levels: gems, source: source);
    final nonIncreasing = _nonIncreasingLevels(config);
    if (nonIncreasing.isNotEmpty) {
      warnings.add('non_increasing_target:${nonIncreasing.join(",")}');
    }
    return ValidationResult(config: config, warnings: warnings);
  }

  /// Chỉ số level (1..36) có mốc ≤ mốc level liền trước (BR1.6).
  static List<int> _nonIncreasingLevels(LevelConfig config) {
    final byIndex = <int, int>{};
    for (final gem in config.levels.values) {
      for (final sub in gem.subLevels.values) {
        byIndex[(gem.order - 1) * 6 + sub.order] = sub.targetScore;
      }
    }
    final result = <int>[];
    for (var i = 2; i <= 36; i++) {
      final current = byIndex[i];
      final previous = byIndex[i - 1];
      if (current != null && previous != null && current <= previous) {
        result.add(i);
      }
    }
    return result;
  }
}
