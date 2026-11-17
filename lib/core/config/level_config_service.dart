import 'dart:async';

import '../firebase/default_level_config.dart';
import '../log/gj_log.dart';
import 'level_config.dart';
import 'level_config_validator.dart';
import 'remote_config_client.dart';

/// Kết quả của bước fetch, dùng cho log tổng kết khởi động (D-O2).
enum FetchStatus {
  ok('ok'),
  timeout('timeout'),
  skipped('skipped'),
  error('error');

  const FetchStatus(this.label);
  final String label;
}

class LevelConfigLoadResult {
  const LevelConfigLoadResult({required this.config, required this.fetch});

  final LevelConfig config;
  final FetchStatus fetch;
}

/// Nạp cấu hình level: remote, cached hoặc mặc định (BR1.1, BR1.2, BR1.4).
///
/// `initialize` không bao giờ throw: luôn trả về một cấu hình dùng được.
class LevelConfigService {
  LevelConfigService({required RemoteConfigClient client}) : _client = client;

  final RemoteConfigClient _client;

  /// Cấu hình mặc định kèm log `config_source` (dùng khi Firebase không có).
  static LevelConfigLoadResult fallbackToDefault(FetchStatus fetch) {
    final config = DefaultLevelConfig.config;
    GjLog.info('LevelConfig', 'config_source=${config.source.label}');
    return LevelConfigLoadResult(config: config, fetch: fetch);
  }

  /// [fetchBudget] là thời gian tối đa chờ fetch (BR1.1). Không dương thì bỏ
  /// qua fetch và chỉ đọc giá trị đã activate.
  Future<LevelConfigLoadResult> initialize({
    required Duration fetchBudget,
  }) async {
    var fetch = FetchStatus.skipped;
    if (fetchBudget > Duration.zero) {
      try {
        await _fetch().timeout(fetchBudget);
        fetch = FetchStatus.ok;
      } on TimeoutException catch (e) {
        fetch = FetchStatus.timeout;
        GjLog.warn('LevelConfig', 'fetch timed out', e);
      } catch (e) {
        fetch = FetchStatus.error;
        GjLog.warn('LevelConfig', 'fetch failed', e);
      }
    } else {
      GjLog.warn('LevelConfig', 'fetch skipped: no time budget left');
    }

    final source =
        fetch == FetchStatus.ok ? ConfigSource.remote : ConfigSource.cached;
    final config = _readAndValidate(source);
    if (config == null) return fallbackToDefault(fetch);
    GjLog.info('LevelConfig', 'config_source=${config.source.label}');
    return LevelConfigLoadResult(config: config, fetch: fetch);
  }

  Future<void> _fetch() async {
    await _client.configure();
    await _client.fetchAndActivate();
  }

  LevelConfig? _readAndValidate(ConfigSource source) {
    final String? raw;
    try {
      raw = _client.readLevelConfig();
    } catch (e) {
      GjLog.error('LevelConfig', 'reading activated config failed', e);
      return null;
    }
    if (raw == null || raw.trim().isEmpty) {
      GjLog.warn('LevelConfig', 'no activated config, using default');
      return null;
    }

    final result = LevelConfigValidator.validate(raw, source: source);
    for (final warning in result.warnings) {
      GjLog.warn('LevelConfig', warning);
    }
    final config = result.config;
    if (config == null) {
      // Chỉ ghi mã lỗi đầu tiên, không ghi JSON thô (D-S5).
      GjLog.error(
        'LevelConfig',
        'invalid ${source.label} config (${result.firstError}), using default',
      );
      return null;
    }
    GjLog.info(
      'LevelConfig',
      'config accepted: version=${config.version} gems=${config.levels.length}',
    );
    return config;
  }
}
