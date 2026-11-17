/// Nguồn của cấu hình đang có hiệu lực (contract E1, BR1.7).
enum ConfigSource {
  remote('remote'),
  cached('cached'),
  defaults('default');

  const ConfigSource(this.label);

  /// Giá trị ghi vào log `config_source=<label>`.
  final String label;
}

/// Mã gem theo thứ tự hành trình (BR2.1).
abstract final class GemIds {
  static const List<String> all = [
    'rose_quartz',
    'amethyst',
    'blue_topaz',
    'emerald',
    'sapphire',
    'ruby',
  ];
}

/// Mã level con theo thứ tự trong một gem (BR2.1).
abstract final class SubIds {
  static const List<String> all = [
    'rough_stone',
    'slabbing',
    'shaping',
    'sanding',
    'polishing',
    'bling',
  ];
}

/// Cấu hình một level con.
class SubLevelConfig {
  const SubLevelConfig({
    required this.subId,
    required this.order,
    required this.name,
    required this.targetScore,
    this.backgroundUrl,
  });

  final String subId;
  final int order;
  final String name;
  final int targetScore;

  /// Đã qua `ImageUrlPolicy`; null nếu không có hoặc bị loại.
  final String? backgroundUrl;
}

/// Cấu hình một đá quý.
class GemConfig {
  const GemConfig({
    required this.gemId,
    required this.order,
    required this.name,
    required this.subLevels,
  });

  final String gemId;
  final int order;
  final String name;

  /// Đúng 6 level con, khóa là `subId`.
  final Map<String, SubLevelConfig> subLevels;
}

/// Cấu hình 36 mốc điểm đã được validate toàn bộ.
class LevelConfig {
  const LevelConfig({
    required this.version,
    required this.levels,
    required this.source,
  });

  final int version;

  /// Đúng 6 gem, khóa là `gemId`.
  final Map<String, GemConfig> levels;
  final ConfigSource source;

  LevelConfig withSource(ConfigSource newSource) =>
      LevelConfig(version: version, levels: levels, source: newSource);
}
