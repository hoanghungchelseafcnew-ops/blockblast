import 'package:block_blast/core/analytics/session_tracker.dart';
import 'package:block_blast/core/audio/audio_controller.dart';
import 'package:block_blast/core/config/remote_config_client.dart';
import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/core/firebase/firebase_gateway.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/screens/game_screen.dart';
import 'package:block_blast/features/game/services/game_feedback.dart';
import 'package:block_blast/features/game/services/score_share_service.dart';
import 'package:block_blast/features/journey/controllers/journey_controller.dart';
import 'package:block_blast/features/journey/controllers/level_game_controller.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/app_bootstrap.dart';
import 'package:block_blast/features/journey/services/background_image_service.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fakes/fake_analytics.dart';
import '../fakes/fake_clock.dart';
import '../fakes/fake_progress_store.dart';
import '../fakes/fake_remote_config_client.dart';
import '../fakes/fake_sfx_player.dart';
import '../features/game/engine/engine_test_helpers.dart';

/// Màn hình dọc như điện thoại, để bố cục không tràn trong test.
void useMobileScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Prefs trống cho mỗi test UI (Daily Gift đã bị gỡ ở U4, FR10.2).
void mockEmptyPrefs() {
  SharedPreferences.setMockInitialValues({});
}

String get progressKey => ProgressRepository.progressKey;

String progressJson({required int current, int? highest}) =>
    '{"currentLevelIndex":$current,"completedLevels":[],"unlockedGems":[],'
    '"journeyCompleted":false,"highestLevelReached":${highest ?? current}}';

/// Bootstrap không chạm Firebase thật: mọi thứ dùng fake.
AppBootstrap fakeBootstrap({
  FakeProgressStore? store,
  RemoteConfigClient? client,
  FirebaseGateway? gateway,
}) {
  return AppBootstrap(
    gateway: gateway ?? FirebaseGateway(initializer: () async {}),
    remoteConfigFactory: () => client ?? FakeRemoteConfigClient(),
    progress: ProgressRepository(store ?? FakeProgressStore()),
    clock: FakeClock(),
    sfxPlayerFactory: FakeSfxPlayer.new,
    analyticsFactory: FakeAnalytics.new,
  );
}

/// Dịch vụ dựng tay (không qua Splash) cho test Home và Game.
Future<AppServices> buildServices({
  FakeProgressStore? store,
  FakeSfxPlayer? player,
  FakeAnalytics? analytics,
  FakeClock? clock,
}) async {
  final repo = ProgressRepository(store ?? FakeProgressStore());
  await repo.load();
  final catalog = LevelCatalog.from(DefaultLevelConfig.config);
  final tracked = analytics ?? FakeAnalytics();
  return AppServices(
    config: DefaultLevelConfig.config,
    catalog: catalog,
    progress: repo,
    journey: JourneyController(repository: repo, catalog: catalog),
    audio: AudioController(progress: repo, player: player ?? FakeSfxPlayer()),
    analytics: tracked,
    session: SessionTracker(
      analytics: tracked,
      progress: repo,
      clock: clock ?? FakeClock(),
    ),
  );
}

class FakeShareService extends ScoreShareService {
  FakeShareService();

  int shared = 0;
  int lastScore = -1;
  int victoryShared = 0;
  String? lastLevelName;

  @override
  Future<void> shareScore({
    required ScreenshotController screenshot,
    required int score,
  }) async {
    shared++;
    lastScore = score;
  }

  @override
  Future<void> shareVictory({
    required ScreenshotController screenshot,
    required String levelName,
    required int score,
  }) async {
    victoryShared++;
    lastLevelName = levelName;
    lastScore = score;
  }
}

class GameHarness {
  GameHarness({
    required this.controller,
    required this.engine,
    required this.store,
    required this.repo,
    required this.catalog,
    required this.share,
  });

  final LevelGameController controller;
  final BoardEngine engine;
  final FakeProgressStore store;
  final ProgressRepository repo;
  final LevelCatalog catalog;
  final FakeShareService share;

  static Future<GameHarness> create({
    int levelIndex = 1,
    int target = 1000,
    Map<String, Object>? initial,
    List<BlockModel> Function()? source,
  }) async {
    final store = FakeProgressStore(initial: initial);
    final repo = ProgressRepository(store);
    await repo.load();
    final catalog = LevelCatalog.from(DefaultLevelConfig.config);
    final engine = BoardEngine(
      blockSource: source ?? () => [single(), line(2), line(2)],
      clearDelay: Duration.zero,
    );
    final controller = LevelGameController(
      journey: JourneyController(repository: repo, catalog: catalog),
      progress: repo,
      engine: engine,
      feedback: const NoopGameFeedback(),
      comboTextDuration: const Duration(milliseconds: 100),
    );
    addTearDown(controller.dispose);
    final base = catalog.byIndex(levelIndex);
    controller.start(
      Level(
        levelIndex: base.levelIndex,
        gemId: base.gemId,
        gemName: base.gemName,
        gemOrder: base.gemOrder,
        subId: base.subId,
        subName: base.subName,
        subOrder: base.subOrder,
        targetScore: target,
        assetPath: base.assetPath,
      ),
    );
    return GameHarness(
      controller: controller,
      engine: engine,
      store: store,
      repo: repo,
      catalog: catalog,
      share: FakeShareService(),
    );
  }

  /// Mỗi hàng và cột còn đúng hai ô trống, không ô nào kề nhau: đặt khối đơn
  /// vào (0,0) thì hết nước đi mà không xóa dòng nào.
  void fillBoardLeavingIsolatedGaps() {
    for (final row in engine.board) {
      for (final cell in row) {
        cell.filled = true;
      }
    }
    for (var i = 0; i < engine.board.length; i++) {
      engine.board[i][i].filled = false;
      engine.board[i][(i + 4) % engine.board.length].filled = false;
    }
  }
}

/// Đẩy [GameScreen] lên trên một route nền để nút back có chỗ quay về.
Future<GlobalKey<NavigatorState>> pumpGameScreen(
  WidgetTester tester,
  GameHarness harness, {
  BackgroundImageService? images,
}) async {
  useMobileScreen(tester);
  mockEmptyPrefs();
  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navKey,
      home: const Scaffold(body: Text('base-route')),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<LevelGameController>.value(
        value: harness.controller,
        child: GameScreen(shareService: harness.share, images: images),
      ),
    ),
  );
  // Frame đầu bắt đầu animation chuyển route; frame sau cho nó chạy xong.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
  return navKey;
}
