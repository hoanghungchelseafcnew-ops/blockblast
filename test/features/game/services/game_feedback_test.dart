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
      ..combo()
      ..gameOver()
      ..victory()
      ..unlock()
      ..stopSfx();
  });

  test('placed vibrates and plays the place sound', () async {
    final (feedback, player) = await device();
    feedback.placed();
    await Future<void>.delayed(Duration.zero);
    expect(haptics, ['HapticFeedbackType.heavyImpact']);
    expect(player.played, [Sfx.place.asset]);
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

  test('stopSfx stops the player', () async {
    final (feedback, player) = await device();
    feedback.stopSfx();
    await Future<void>.delayed(Duration.zero);
    expect(player.stops, 1);
  });
}
