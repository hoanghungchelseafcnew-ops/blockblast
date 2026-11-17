import 'dart:convert';
import 'dart:io';

import 'package:block_blast/core/config/level_config.dart';
import 'package:block_blast/core/config/level_config_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_remote_config_client.dart';
import '../../fakes/log_capture.dart';

String _validJson({int rough = 500}) {
  final cfg = jsonDecode(
    File('test/fixtures/level_config_valid.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  ((cfg['levels'] as Map<String, dynamic>)['rose_quartz']
          as Map<String, dynamic>)['sub_levels']['rough_stone']['target_score'] =
      rough;
  return jsonEncode(cfg);
}

const _budget = Duration(milliseconds: 200);

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  int roughTarget(LevelConfig c) =>
      c.levels['rose_quartz']!.subLevels['rough_stone']!.targetScore;

  group('LevelConfigService.initialize', () {
    test('valid remote config is used with source remote', () async {
      final client = FakeRemoteConfigClient(valueAfterFetch: _validJson(rough: 300));
      final result =
          await LevelConfigService(client: client).initialize(fetchBudget: _budget);
      expect(result.config.source, ConfigSource.remote);
      expect(roughTarget(result.config), 300);
      expect(result.fetch, FetchStatus.ok);
      expect(client.configureCalls, 1);
      expect(client.fetchCalls, 1);
      expect(log.where('config_source=remote'), hasLength(1));
    });

    test('invalid remote config falls back to the default (BR1.2)', () async {
      final client = FakeRemoteConfigClient(valueAfterFetch: '{"version":1,"levels":{}}');
      final result =
          await LevelConfigService(client: client).initialize(fetchBudget: _budget);
      expect(result.config.source, ConfigSource.defaults);
      expect(roughTarget(result.config), 500);
      expect(result.fetch, FetchStatus.ok);
      expect(log.where('invalid_levels'), hasLength(1));
      expect(log.where('config_source=default'), hasLength(1));
    });

    test('fetch timeout uses the previously activated config as cached',
        () async {
      final client = FakeRemoteConfigClient(
        activatedValue: _validJson(rough: 450),
        hangFetch: true,
      );
      final result = await LevelConfigService(client: client)
          .initialize(fetchBudget: const Duration(milliseconds: 30));
      expect(result.fetch, FetchStatus.timeout);
      expect(result.config.source, ConfigSource.cached);
      expect(roughTarget(result.config), 450);
      expect(log.where('fetch timed out'), hasLength(1));
    });

    test('fetch timeout with nothing activated uses the default', () async {
      final client = FakeRemoteConfigClient(hangFetch: true);
      final result = await LevelConfigService(client: client)
          .initialize(fetchBudget: const Duration(milliseconds: 30));
      expect(result.config.source, ConfigSource.defaults);
      expect(roughTarget(result.config), 500);
    });

    test('a corrupt cached config is treated as lost (BR1.4)', () async {
      final client = FakeRemoteConfigClient(
        activatedValue: '{"broken":',
        fetchError: StateError('offline'),
      );
      final result =
          await LevelConfigService(client: client).initialize(fetchBudget: _budget);
      expect(result.fetch, FetchStatus.error);
      expect(result.config.source, ConfigSource.defaults);
      expect(roughTarget(result.config), 500);
      expect(log.where('parse_error'), hasLength(1));
    });

    test('a zero budget skips the fetch and still reads the cached value',
        () async {
      final client = FakeRemoteConfigClient(activatedValue: _validJson(rough: 410));
      final result = await LevelConfigService(client: client)
          .initialize(fetchBudget: Duration.zero);
      expect(result.fetch, FetchStatus.skipped);
      expect(client.fetchCalls, 0);
      expect(result.config.source, ConfigSource.cached);
      expect(roughTarget(result.config), 410);
    });

    test('a failing read of the activated value falls back to default',
        () async {
      final client = FakeRemoteConfigClient(
        valueAfterFetch: _validJson(),
        readError: StateError('sdk'),
      );
      final result =
          await LevelConfigService(client: client).initialize(fetchBudget: _budget);
      expect(result.config.source, ConfigSource.defaults);
      expect(log.where('reading activated config failed'), hasLength(1));
    });

    test('logs never contain a full URL or the raw JSON (D-S5)', () async {
      final cfg = jsonDecode(_validJson()) as Map<String, dynamic>;
      ((cfg['levels'] as Map<String, dynamic>)['amethyst']
              as Map<String, dynamic>)['sub_levels']['shaping']['background_url'] =
          'https://evil.example.com/secret.jpg?token=abc';
      final client = FakeRemoteConfigClient(valueAfterFetch: jsonEncode(cfg));
      final result =
          await LevelConfigService(client: client).initialize(fetchBudget: _budget);
      expect(result.config.source, ConfigSource.remote);
      expect(log.where('background_url_rejected:amethyst.shaping'), hasLength(1));
      expect(log.leaksUrlOrRawJson, isFalse);
      expect(log.lines.any((l) => l.contains('token=abc')), isFalse);
    });
  });

  group('LevelConfigService.fallbackToDefault', () {
    test('returns the default config and logs its source once', () {
      final result = LevelConfigService.fallbackToDefault(FetchStatus.skipped);
      expect(result.config.source, ConfigSource.defaults);
      expect(result.fetch, FetchStatus.skipped);
      expect(log.where('config_source=default'), hasLength(1));
    });
  });
}
