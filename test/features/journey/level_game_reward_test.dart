import 'dart:async';

import 'package:block_blast/core/firebase/default_level_config.dart';
import 'package:block_blast/features/ads/services/ad_mediator.dart';
import 'package:block_blast/features/ads/services/pending_loss_store.dart';
import 'package:block_blast/features/game/engine/board_engine.dart';
import 'package:block_blast/features/journey/controllers/journey_controller.dart';
import 'package:block_blast/features/journey/controllers/level_game_controller.dart';
import 'package:block_blast/features/journey/models/level.dart';
import 'package:block_blast/features/journey/services/level_catalog.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';
import '../../fakes/log_capture.dart';
import '../ads/ads_fakes.dart';
import '../game/engine/engine_test_helpers.dart';

/// Tiến trình đang ở level 9 (Amethyst · Shaping). Rough Stone của Amethyst
/// là level 7.
const String _atLevel9 =
    '{"currentLevelIndex":9,"completedLevels":[1,2,3,4,5,6,7,8],'
    '"unlockedGems":["rose_quartz"],"journeyCompleted":false,'
    '"highestLevelReached":9}';

class _RewardGame {
  _RewardGame(
    this.store,
    this.repo,
    this.engine,
    this.controller,
    this.ads,
    this.pendingStore,
  );

  final FakeProgressStore store;
  final ProgressRepository repo;
  final BoardEngine engine;
  final LevelGameController controller;
  final FakeAdsService ads;
  final FakeProgressStore pendingStore;

  static Future<_RewardGame> create({
    bool rewardEnabled = true,
    bool adsActive = true,
    RewardOutcome outcome = RewardOutcome.earned,
    Map<String, Object>? initial,
  }) async {
    final store = FakeProgressStore(
      initial: initial ?? {ProgressRepository.progressKey: _atLevel9},
    );
    final repo = ProgressRepository(store);
    await repo.load();
    final catalog = LevelCatalog.from(DefaultLevelConfig.config);
    final engine = BoardEngine(
      blockSource: () => [single(), line(2), line(2)],
      clearDelay: Duration.zero,
    );
    final ads = FakeAdsService(rewardOutcome: outcome);
    final pendingStore = FakeProgressStore();
    final controller = LevelGameController(
      journey: JourneyController(repository: repo, catalog: catalog),
      progress: repo,
      engine: engine,
      ads: adsActive ? ads : const NoopAdsService(),
      rewardEnabled: rewardEnabled,
      pendingLoss: PendingLossStore(pendingStore),
    );
    addTearDown(controller.dispose);
    final base = catalog.byIndex(9);
    controller.start(
      Level(
        levelIndex: base.levelIndex,
        gemId: base.gemId,
        gemName: base.gemName,
        gemOrder: base.gemOrder,
        subId: base.subId,
        subName: base.subName,
        subOrder: base.subOrder,
        targetScore: 100000,
        assetPath: base.assetPath,
      ),
    );
    return _RewardGame(store, repo, engine, controller, ads, pendingStore);
  }

  /// Đặt khối đơn vào (0,0) trên bảng chỉ còn ô lẻ: hết nước đi, điểm 10.
  Future<void> lose() async {
    for (final row in engine.board) {
      for (final cell in row) {
        cell.filled = true;
      }
    }
    for (var i = 0; i < engine.board.length; i++) {
      engine.board[i][i].filled = false;
      engine.board[i][(i + 4) % engine.board.length].filled = false;
    }
    controller.onDragStart(controller.tray.first);
    await controller.placeAt(0, 0);
  }

  bool get boardEmpty =>
      engine.board.every((row) => row.every((cell) => !cell.filled));
}

void main() {
  setUp(() => LogCapture().start());

  group('LevelGameController reward (US3.1)', () {
    test(
      'a loss shows the reward button and does not demote yet (BR6.2)',
      () async {
        final g = await _RewardGame.create();
        await g.lose();
        final c = g.controller;
        expect(c.status, LevelStatus.lost);
        expect(c.canWatchAd, isTrue);
        expect(g.repo.progress.currentLevelIndex, 9);
        expect(c.outcome!.nextLevel!.levelIndex, 7, reason: 'shown, not saved');
        expect(g.pendingStore.data[PendingLossStore.key], '9:10');
        expect(g.ads.preloadRewardCalls, 1, reason: 'preloaded at level start');
      },
    );

    test('no reward button when reward_enabled is false (FR3.2)', () async {
      final g = await _RewardGame.create(rewardEnabled: false);
      await g.lose();
      expect(g.controller.canWatchAd, isFalse);
      expect(g.repo.progress.currentLevelIndex, 7, reason: 'old path');
      expect(g.ads.preloadRewardCalls, 0);
    });

    test('no reward button when ads are not running', () async {
      final g = await _RewardGame.create(adsActive: false);
      await g.lose();
      expect(g.controller.canWatchAd, isFalse);
      expect(g.repo.progress.currentLevelIndex, 7);
    });

    test(
      'earning the reward replays the same level from zero (BR6.3)',
      () async {
        final g = await _RewardGame.create();
        await g.lose();
        await g.controller.watchAd();
        await pumpEventQueue();
        final c = g.controller;
        expect(c.status, LevelStatus.playing);
        expect(c.level.levelIndex, 9);
        expect(c.score, 0);
        expect(g.boardEmpty, isTrue);
        expect(c.tray, isNotEmpty);
        expect(g.repo.progress.currentLevelIndex, 9, reason: 'not demoted');
        expect(g.pendingStore.data.containsKey(PendingLossStore.key), isFalse);
        expect(g.ads.rewardCalls, 1);
      },
    );

    test('no ad available still rewards the player (ADR-007)', () async {
      final g = await _RewardGame.create(outcome: RewardOutcome.noAd);
      await g.lose();
      await g.controller.watchAd();
      expect(g.controller.status, LevelStatus.playing);
      expect(g.repo.progress.currentLevelIndex, 9);
    });

    test('the lost score is kept as the high score (BR6.6)', () async {
      final g = await _RewardGame.create();
      await g.lose();
      await g.controller.watchAd();
      await pumpEventQueue();
      expect(g.repo.highScore(9), 10);
      expect(g.controller.bestScore, 10);
    });

    test(
      'closing early keeps the overlay so the player can retry (BR6.4)',
      () async {
        final g = await _RewardGame.create(outcome: RewardOutcome.closedEarly);
        await g.lose();
        await g.controller.watchAd();
        expect(g.controller.status, LevelStatus.lost);
        expect(g.controller.canWatchAd, isTrue);
        expect(g.controller.watchingAd, isFalse);
        expect(g.repo.progress.currentLevelIndex, 9);
      },
    );

    test('the button is locked while the ad is showing', () async {
      final g = await _RewardGame.create();
      await g.lose();
      final hold = Completer<void>();
      g.ads.holdReward = hold;
      final watching = g.controller.watchAd();
      expect(g.controller.watchingAd, isTrue);
      await g.controller.watchAd();
      expect(g.ads.rewardCalls, 1, reason: 'second tap ignored');
      hold.complete();
      await watching;
      expect(g.controller.watchingAd, isFalse);
    });

    test(
      'a new loss after continuing offers the reward again (BR6.5)',
      () async {
        final g = await _RewardGame.create();
        await g.lose();
        await g.controller.watchAd();
        await g.lose();
        expect(g.controller.status, LevelStatus.lost);
        expect(g.controller.canWatchAd, isTrue);
      },
    );

    test('PLAY AGAIN records the loss exactly once (BR6.8)', () async {
      final g = await _RewardGame.create();
      await g.lose();
      g.controller.playAgain();
      await pumpEventQueue();
      expect(g.repo.progress.currentLevelIndex, 7);
      expect(g.controller.level.levelIndex, 7);
      expect(g.controller.canWatchAd, isFalse);
      expect(g.pendingStore.data.containsKey(PendingLossStore.key), isFalse);
      expect(g.repo.highScore(9), 10);
    });

    test('leaving the overlay records the loss (BR6.2)', () async {
      final g = await _RewardGame.create();
      await g.lose();
      expect(g.controller.requestBack(), isTrue);
      await pumpEventQueue();
      expect(g.repo.progress.currentLevelIndex, 7);
      expect(g.pendingStore.data.containsKey(PendingLossStore.key), isFalse);
      expect(g.controller.canWatchAd, isFalse);
    });

    test('a reward that throws is treated as no ad', () async {
      final g = await _RewardGame.create();
      await g.lose();
      g.ads.holdReward = Completer<void>()..completeError(StateError('x'));
      await g.controller.watchAd();
      expect(g.controller.status, LevelStatus.playing);
      expect(g.repo.progress.currentLevelIndex, 9);
    });
  });
}
