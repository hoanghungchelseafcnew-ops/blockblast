import 'dart:math';

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
    return (DeviceGameFeedback(audio, random: Random(1)), player);
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

  test('placed vibrates lightly and plays one of the place sounds', () async {
    final (feedback, player) = await device();
    feedback.placed();
    await Future<void>.delayed(Duration.zero);
    expect(haptics, ['HapticFeedbackType.lightImpact']);
    expect(player.played, hasLength(1));
    expect([
      Sfx.place.asset,
      Sfx.place2.asset,
      Sfx.place3.asset,
    ], contains(player.played.single));
  });

  test('place sounds vary from move to move', () async {
    final (feedback, player) = await device();
    for (var i = 0; i < 30; i++) {
      feedback.placed();
    }
    await Future<void>.delayed(Duration.zero);
    expect(player.played.toSet().length, greaterThan(1));
  });

  test('each event plays its own sound (FR13.1)', () async {
    final (feedback, player) = await device();
    feedback
      ..cleared()
      ..combo()
      ..gameOver()
      ..victory()
      ..unlock();
    await Future<void>.delayed(Duration.zero);
    expect(player.played, [
      Sfx.clear.asset,
      Sfx.combo.asset,
      Sfx.gameOver.asset,
      Sfx.victory.asset,
      Sfx.unlock.asset,
    ]);
  });

  test('more lines cleared play a fuller chime', () async {
    final (feedback, player) = await device();
    feedback
      ..clearedLines(1)
      ..clearedLines(2)
      ..clearedLines(3)
      ..clearedLines(5);
    await Future<void>.delayed(Duration.zero);
    expect(player.played, [
      Sfx.clear.asset,
      Sfx.clear2.asset,
      Sfx.clear3.asset,
      Sfx.clear3.asset,
    ]);
  });

  test('a higher combo plays a higher sound', () async {
    final (feedback, player) = await device();
    feedback
      ..comboStreak(2)
      ..comboStreak(3)
      ..comboStreak(4)
      ..comboStreak(9);
    await Future<void>.delayed(Duration.zero);
    expect(player.played, [
      Sfx.combo.asset,
      Sfx.combo2.asset,
      Sfx.combo3.asset,
      Sfx.combo3.asset,
    ]);
  });

  test('a bomb explosion has its own sound and a strong vibration', () async {
    final (feedback, player) = await device();
    feedback.bombExploded();
    await Future<void>.delayed(Duration.zero);
    expect(player.played, [Sfx.bomb.asset]);
    expect(haptics, ['HapticFeedbackType.heavyImpact']);
  });

  test('stopSfx stops the player', () async {
    final (feedback, player) = await device();
    feedback.stopSfx();
    await Future<void>.delayed(Duration.zero);
    expect(player.stops, 1);
  });
}
