import 'package:block_blast/core/audio/audio_controller.dart';
import 'package:block_blast/core/audio/sfx.dart';
import 'package:block_blast/features/game/services/game_feedback.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../fakes/fake_progress_store.dart';
import '../../../fakes/fake_sfx_player.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final haptics = <String>[];

  setUp(() {
    haptics.clear();
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        haptics.add(call.arguments as String);
      }
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<(DeviceGameFeedback, FakeSfxPlayer)> device() async {
    final repo = ProgressRepository(FakeProgressStore());
    await repo.load();
    final player = FakeSfxPlayer();
    final audio = AudioController(progress: repo, player: player);
    return (DeviceGameFeedback(audio), player);
  }

  test('NoopGameFeedback does nothing and never throws', () {
    const feedback = NoopGameFeedback();
    feedback
      ..placed()
      ..cleared()
      ..clearedLines(3)
      ..combo()
      ..comboStreak(4)
      ..bombExploded()
      ..gameOver()
      ..victory()
      ..unlock()
      ..stopSfx();
  });

  group('only the level-complete sounds play (CR-2)', () {
    test('placing a block makes no sound and no vibration', () async {
      final (feedback, player) = await device();
      for (var i = 0; i < 5; i++) {
        feedback.placed();
      }
      await Future<void>.delayed(Duration.zero);
      expect(player.played, isEmpty);
      expect(haptics, isEmpty);
    });

    test('clearing lines and combos are silent', () async {
      final (feedback, player) = await device();
      feedback
        ..cleared()
        ..clearedLines(1)
        ..clearedLines(3)
        ..combo()
        ..comboStreak(2)
        ..comboStreak(9);
      await Future<void>.delayed(Duration.zero);
      expect(player.played, isEmpty);
    });

    test('a bomb is silent and does not vibrate', () async {
      final (feedback, player) = await device();
      feedback.bombExploded();
      await Future<void>.delayed(Duration.zero);
      expect(player.played, isEmpty);
      expect(haptics, isEmpty);
    });

    test('losing is silent, so Endless is fully silent (2b)', () async {
      final (feedback, player) = await device();
      feedback.gameOver();
      await Future<void>.delayed(Duration.zero);
      expect(player.played, isEmpty);
    });

    test('winning a level and unlocking a gem still play (2a)', () async {
      final (feedback, player) = await device();
      feedback
        ..victory()
        ..unlock();
      await Future<void>.delayed(Duration.zero);
      expect(player.played, [Sfx.victory.asset, Sfx.unlock.asset]);
    });
  });

  test('stopSfx stops the player', () async {
    final (feedback, player) = await device();
    feedback.stopSfx();
    await Future<void>.delayed(Duration.zero);
    expect(player.stops, 1);
  });
}
