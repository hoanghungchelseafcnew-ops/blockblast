import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/background_image_service.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/shared/widgets/level_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes/fake_images.dart';
import '../fakes/log_capture.dart';

const _url =
    'https://firebasestorage.googleapis.com/v0/b/demo/o/bg%2Fx.jpg?alt=media';

Level _copy(Level base, {String? url, String? assetPath}) => Level(
  levelIndex: base.levelIndex,
  gemId: base.gemId,
  gemName: base.gemName,
  gemOrder: base.gemOrder,
  subId: base.subId,
  subName: base.subName,
  subOrder: base.subOrder,
  targetScore: base.targetScore,
  assetPath: assetPath ?? base.assetPath,
  backgroundUrl: url,
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SizedBox.expand(child: child)),
    ),
  );
}

void main() {
  late LogCapture log;
  final catalog = LevelCatalog.from(DefaultLevelConfig.config);

  setUp(() {
    log = LogCapture()..start();
  });

  testWidgets('shows the level asset with the gem gradient and no network '
      'image when there is no URL (AC7.1.1, AC7.2.2)', (tester) async {
    final level = catalog.byIndex(17);
    await _pump(tester, LevelBackground(level: level));
    final asset = tester.widget<Image>(find.byKey(const Key('level-bg-asset')));
    expect((asset.image as AssetImage).assetName, 'assets/design/Level3/5.jpg');
    expect(find.byKey(const Key('level-bg-network')), findsNothing);
    expect(find.byKey(const Key('level-bg-gradient')), findsOneWidget);
    expect(find.byKey(const Key('level-bg-dim')), findsOneWidget);
    expect(find.byKey(const Key('level-bg-blur')), findsNothing);
  });

  testWidgets('blurred adds a sigma 12 blur behind the board (FR5.3)', (
    tester,
  ) async {
    await _pump(
      tester,
      LevelBackground(level: catalog.byIndex(1), blurred: true),
    );
    expect(find.byKey(const Key('level-bg-blur')), findsOneWidget);
    expect(LevelBackground.blurSigma, 12);
  });

  testWidgets('overlay variants: gem tint for Home, none for Victory', (
    tester,
  ) async {
    await _pump(
      tester,
      LevelBackground(
        level: catalog.byIndex(1),
        overlay: BackgroundOverlay.gem,
      ),
    );
    expect(find.byKey(const Key('level-bg-gem-tint')), findsOneWidget);
    await _pump(
      tester,
      LevelBackground(
        level: catalog.byIndex(1),
        overlay: BackgroundOverlay.none,
      ),
    );
    expect(find.byKey(const Key('level-bg-dim')), findsNothing);
    expect(find.byKey(const Key('level-bg-gem-tint')), findsNothing);
  });

  testWidgets('a network image is layered over the asset and fades in', (
    tester,
  ) async {
    final factory = FakeNetworkImageFactory();
    final service = BackgroundImageService(networkFactory: factory.call);
    await _pump(
      tester,
      LevelBackground(
        level: _copy(catalog.byIndex(2), url: _url),
        service: service,
      ),
    );
    expect(find.byKey(const Key('level-bg-asset')), findsOneWidget);
    expect(find.byKey(const Key('level-bg-network')), findsOneWidget);
    expect(factory.calls, [_url]);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump(LevelBackground.crossFade);
    expect(find.byType(AnimatedOpacity), findsWidgets);
  });

  testWidgets('a broken network image keeps the asset and logs (AC7.2.2)', (
    tester,
  ) async {
    final factory = FakeNetworkImageFactory(fails: true);
    final service = BackgroundImageService(networkFactory: factory.call);
    await _pump(
      tester,
      LevelBackground(
        level: _copy(catalog.byIndex(2), url: _url),
        service: service,
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.byKey(const Key('level-bg-asset')), findsOneWidget);
    expect(log.where('network failed, keeping asset'), hasLength(1));
    expect(log.leaksUrlOrRawJson, isFalse);
  });

  testWidgets('a missing asset leaves the gem gradient and logs', (
    tester,
  ) async {
    await _pump(
      tester,
      LevelBackground(
        level: _copy(
          catalog.byIndex(1),
          assetPath: 'assets/design/missing.jpg',
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    expect(find.byKey(const Key('level-bg-gradient')), findsOneWidget);
    expect(log.where('asset failed: levelId=1'), hasLength(1));
  });
}
