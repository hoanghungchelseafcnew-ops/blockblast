import 'package:audioplayers/audioplayers.dart';
import 'package:block_blast/core/audio/audio_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fakes/log_capture.dart';

void main() {
  late LogCapture log;
  setUp(() => log = LogCapture()..start());

  group('game audio mixes with other apps (CR-3)', () {
    test('Android does not take audio focus', () {
      final context = AudioplayersSfxPlayer.mixWithOthersContext;
      expect(context.android.audioFocus, AndroidAudioFocus.none);
    });

    test('iOS plays with the mixWithOthers option', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final context = AudioplayersSfxPlayer.mixWithOthersContext;
      expect(
        context.iOS.options,
        contains(AVAudioSessionOptions.mixWithOthers),
      );
    });

    test('the shared context is set once, before playing', () async {
      final applied = <AudioContext>[];
      final player = AudioplayersSfxPlayer(
        setGlobalContext: (context) async => applied.add(context),
      );
      await player.ensureAudioContext();
      await player.ensureAudioContext();
      expect(applied, hasLength(1));
      expect(applied.single.android.audioFocus, AndroidAudioFocus.none);
    });

    test('a failure to set the context is logged and not thrown', () async {
      final player = AudioplayersSfxPlayer(
        setGlobalContext: (_) async => throw StateError('no plugin'),
      );
      await player.ensureAudioContext();
      expect(
        log.lines.join('\n'),
        contains('mix-with-others audio context failed'),
      );
    });
  });
}
