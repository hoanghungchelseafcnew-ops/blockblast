import 'package:block_blast/core/audio/audio_controller.dart';
import 'package:block_blast/core/audio/sfx.dart';
import 'package:block_blast/features/journey/services/progress_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/fake_progress_store.dart';
import '../../fakes/fake_sfx_player.dart';
import '../../fakes/log_capture.dart';

Future<(AudioController, FakeSfxPlayer, FakeProgressStore)> _audio({
  Map<String, Object>? initial,
}) async {
  final store = FakeProgressStore(initial: initial);
  final repo = ProgressRepository(store);
  await repo.load();
  final player = FakeSfxPlayer();
  return (AudioController(progress: repo, player: player), player, store);
}

void main() {
  late LogCapture log;

  setUp(() {
    log = LogCapture()..start();
  });

  group('AudioController (FR13)', () {
    test('plays the asset of each sound when not muted', () async {
      final (audio, player, _) = await _audio();
      for (final sfx in Sfx.values) {
        await audio.play(sfx);
      }
      expect(player.played, Sfx.values.map((s) => s.asset).toList());
    });

    test(
      'muted: none of the six sounds reaches the player (AC5.3.3)',
      () async {
        final (audio, player, _) = await _audio();
        await audio.setMuted(true);
        for (final sfx in Sfx.values) {
          await audio.play(sfx);
        }
        expect(player.played, isEmpty);
      },
    );

    test(
      'the mute choice is saved and restored after a restart (AC5.3.2)',
      () async {
        final (audio, _, store) = await _audio();
        expect(audio.isMuted, isFalse);
        await audio.setMuted(true);
        expect(store.data[ProgressRepository.soundMutedKey], true);

        final (restarted, player, _) = await _audio(initial: store.data);
        expect(restarted.isMuted, isTrue);
        await restarted.play(Sfx.victory);
        expect(player.played, isEmpty);
      },
    );

    test('muting stops the current sound and notifies listeners', () async {
      final (audio, player, _) = await _audio();
      var notified = 0;
      audio.addListener(() => notified++);
      await audio.setMuted(true);
      expect(player.stops, 1);
      expect(notified, 1);
      await audio.setMuted(true);
      expect(notified, 1, reason: 'no change, no notification');
      await audio.setMuted(false);
      expect(notified, 2);
      expect(player.stops, 1, reason: 'unmuting does not stop anything');
    });

    test('a failing player is logged, not swallowed, and never throws '
        '(FR13.3)', () async {
      final (audio, player, _) = await _audio();
      player.failPlay = true;
      await audio.play(Sfx.unlock);
      expect(log.where('play failed: unlock'), hasLength(1));
      player.failStop = true;
      await audio.stopSfx();
      expect(log.where('stop failed'), hasLength(1));
    });

    test(
      'the default player is created lazily, so building costs nothing',
      () async {
        final repo = ProgressRepository(FakeProgressStore());
        await repo.load();
        final audio = AudioController(progress: repo);
        await audio.stopSfx();
        expect(log.lines, isEmpty, reason: 'stop before any play is a no-op');
      },
    );
  });
}
