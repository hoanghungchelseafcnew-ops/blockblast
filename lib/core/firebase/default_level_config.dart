import 'package:flutter/foundation.dart';

import '../config/level_config.dart';
import '../config/level_config_validator.dart';

/// Cấu hình 36 mốc điểm mặc định nhúng trong app (FR3.1, D-P2).
///
/// Hằng số Dart: không đọc file, không I/O, luôn có sẵn. Giống hệt JSON mẫu
/// trong requirements và không có `background_url`.
abstract final class DefaultLevelConfig {
  static const String json = '''
{
  "version": 1,
  "levels": {
    "rose_quartz": {
      "order": 1,
      "name": "Rose Quartz",
      "sub_levels": {
        "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 500},
        "slabbing": {"order": 2, "name": "Slabbing", "target_score": 800},
        "shaping": {"order": 3, "name": "Shaping", "target_score": 1200},
        "sanding": {"order": 4, "name": "Sanding", "target_score": 1500},
        "polishing": {"order": 5, "name": "Polishing", "target_score": 2000},
        "bling": {"order": 6, "name": "Bling", "target_score": 2500}
      }
    },
    "amethyst": {
      "order": 2,
      "name": "Amethyst",
      "sub_levels": {
        "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 3000},
        "slabbing": {"order": 2, "name": "Slabbing", "target_score": 3500},
        "shaping": {"order": 3, "name": "Shaping", "target_score": 4200},
        "sanding": {"order": 4, "name": "Sanding", "target_score": 5000},
        "polishing": {"order": 5, "name": "Polishing", "target_score": 6000},
        "bling": {"order": 6, "name": "Bling", "target_score": 7000}
      }
    },
    "blue_topaz": {
      "order": 3,
      "name": "Blue Topaz",
      "sub_levels": {
        "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 8000},
        "slabbing": {"order": 2, "name": "Slabbing", "target_score": 9500},
        "shaping": {"order": 3, "name": "Shaping", "target_score": 11000},
        "sanding": {"order": 4, "name": "Sanding", "target_score": 13000},
        "polishing": {"order": 5, "name": "Polishing", "target_score": 15000},
        "bling": {"order": 6, "name": "Bling", "target_score": 18000}
      }
    },
    "emerald": {
      "order": 4,
      "name": "Emerald",
      "sub_levels": {
        "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 20000},
        "slabbing": {"order": 2, "name": "Slabbing", "target_score": 24000},
        "shaping": {"order": 3, "name": "Shaping", "target_score": 28000},
        "sanding": {"order": 4, "name": "Sanding", "target_score": 33000},
        "polishing": {"order": 5, "name": "Polishing", "target_score": 40000},
        "bling": {"order": 6, "name": "Bling", "target_score": 48000}
      }
    },
    "sapphire": {
      "order": 5,
      "name": "Sapphire",
      "sub_levels": {
        "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 55000},
        "slabbing": {"order": 2, "name": "Slabbing", "target_score": 65000},
        "shaping": {"order": 3, "name": "Shaping", "target_score": 75000},
        "sanding": {"order": 4, "name": "Sanding", "target_score": 88000},
        "polishing": {"order": 5, "name": "Polishing", "target_score": 100000},
        "bling": {"order": 6, "name": "Bling", "target_score": 120000}
      }
    },
    "ruby": {
      "order": 6,
      "name": "Ruby",
      "sub_levels": {
        "rough_stone": {"order": 1, "name": "Rough Stone", "target_score": 140000},
        "slabbing": {"order": 2, "name": "Slabbing", "target_score": 165000},
        "shaping": {"order": 3, "name": "Shaping", "target_score": 195000},
        "sanding": {"order": 4, "name": "Sanding", "target_score": 230000},
        "polishing": {"order": 5, "name": "Polishing", "target_score": 280000},
        "bling": {"order": 6, "name": "Bling", "target_score": 350000}
      }
    }
  }
}
''';

  static LevelConfig? _cached;

  /// Cấu hình mặc định đã parse (một lần), `source = default`.
  static LevelConfig get config => _cached ??= parse(json);

  /// Parse [source] như cấu hình mặc định. Hằng số hỏng là lỗi lập trình nên
  /// fail fast bằng [StateError] thay vì âm thầm chơi với dữ liệu sai.
  @visibleForTesting
  static LevelConfig parse(String source) {
    final result = LevelConfigValidator.validate(
      source,
      source: ConfigSource.defaults,
    );
    return result.config ??
        (throw StateError(
          'DefaultLevelConfig is invalid: ${result.firstError}',
        ));
  }
}
