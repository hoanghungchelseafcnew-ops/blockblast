import 'dart:io';

import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/background_image_service.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_images.dart';
import '../../fakes/log_capture.dart';

const _url =
    'https://firebasestorage.googleapis.com/v0/b/demo/o/bg%2Fx.jpg?alt=media';

Level _withUrl(Level base, String? url) => Level(
  levelIndex: base.levelIndex,
  gemId: base.gemId,
  gemName: base.gemName,
  gemOrder: base.gemOrder,
  subId: base.subId,
  subName: base.subName,
  subOrder: base.subOrder,
  targetScore: base.targetScore,
  assetPath: base.assetPath,
  backgroundUrl: url,
);

void main() {
  late LogCapture log;
  final catalog = LevelCatalog.from(DefaultLevelConfig.config);

  setUp(() {
    log = LogCapture()..start();
  });

  group('BackgroundImageService (FR5.1, FR5.2)', () {
    test('the asset of Blue Topaz · Polishing is Level3/5.jpg (AC7.1.1)', () {
      final level = catalog.byIndex(17);
      expect(level.displayName, 'Blue Topaz · Polishing');
      final asset = BackgroundImageService().assetFor(level) as AssetImage;
      expect(asset.assetName, 'assets/design/Level3/5.jpg');
    });

    test('no URL means no network image (AC7.2.2)', () {
      final factory = FakeNetworkImageFactory();
      final service = BackgroundImageService(networkFactory: factory.call);
      expect(service.networkFor(catalog.byIndex(1)), isNull);
      expect(service.networkFor(_withUrl(catalog.byIndex(1), '')), isNull);
      expect(factory.calls, isEmpty);
    });

    test('a URL builds one network provider that is reused (AC7.2.3)', () {
      final factory = FakeNetworkImageFactory();
      final service = BackgroundImageService(networkFactory: factory.call);
      final level = _withUrl(catalog.byIndex(2), _url);
      final first = service.networkFor(level);
      final second = service.networkFor(level);
      expect(first, isNotNull);
      expect(identical(first, second), isTrue);
      expect(factory.calls, [_url]);
    });

    test('the default factory uses the cached network provider (AC7.2.1)', () {
      final provider = BackgroundImageService().networkFor(
        _withUrl(catalog.byIndex(3), _url),
      );
      expect(provider.runtimeType.toString(), 'CachedNetworkImageProvider');
    });

    test('all 36 level assets exist on disk (AC8.3.1, AC7.4.1)', () {
      for (final level in catalog.levels) {
        expect(
          File(level.assetPath).existsSync(),
          isTrue,
          reason: level.assetPath,
        );
      }
    });
  });

  group('BackgroundImageService.precache (FR5.4, AC7.3.1)', () {
    Future<BuildContext> pumpContext(WidgetTester tester) async {
      late BuildContext captured;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            captured = context;
            return const SizedBox();
          },
        ),
      );
      return captured;
    }

    testWidgets('precaches the network image of a level with a URL', (
      tester,
    ) async {
      final factory = FakeNetworkImageFactory();
      final service = BackgroundImageService(networkFactory: factory.call);
      final context = await pumpContext(tester);
      await tester.runAsync(
        () => service.precache(context, _withUrl(catalog.byIndex(2), _url)),
      );
      expect(factory.calls, [_url]);
      expect(log.where('precache network failed'), isEmpty);
    });

    testWidgets('a broken network image is only logged, without the URL', (
      tester,
    ) async {
      final factory = FakeNetworkImageFactory(fails: true);
      final service = BackgroundImageService(networkFactory: factory.call);
      final context = await pumpContext(tester);
      await tester.runAsync(
        () => service.precache(context, _withUrl(catalog.byIndex(2), _url)),
      );
      expect(log.where('precache network failed: levelId=2'), hasLength(1));
      expect(log.leaksUrlOrRawJson, isFalse);
    });

    testWidgets('a level without a URL precaches only its asset', (
      tester,
    ) async {
      final factory = FakeNetworkImageFactory();
      final service = BackgroundImageService(networkFactory: factory.call);
      final context = await pumpContext(tester);
      await tester.runAsync(
        () => service.precache(context, catalog.byIndex(1)),
      );
      expect(factory.calls, isEmpty);
    });
  });
}
