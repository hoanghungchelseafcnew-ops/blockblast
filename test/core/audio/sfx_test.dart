import 'dart:io';

import 'package:block_blast/core/audio/sfx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the sound set is the thirteen sounds of the game (FR13.1)', () {
    expect(Sfx.values.map((s) => s.name), [
      'place',
      'place2',
      'place3',
      'clear',
      'clear2',
      'clear3',
      'combo',
      'combo2',
      'combo3',
      'bomb',
      'gameOver',
      'victory',
      'unlock',
    ]);
  });

  test('every sound asset exists under assets/ (AC8.3.2)', () {
    for (final sfx in Sfx.values) {
      expect(
        File('assets/${sfx.asset}').existsSync(),
        isTrue,
        reason: sfx.asset,
      );
    }
  });

  test('assets are relative to assets/ as audioplayers expects', () {
    for (final sfx in Sfx.values) {
      expect(sfx.asset, startsWith('sounds/'));
      expect(sfx.asset, endsWith('.wav'));
    }
  });

  test('every file really is a PCM WAV, not another format renamed', () {
    for (final sfx in Sfx.values) {
      final bytes = File('assets/${sfx.asset}').readAsBytesSync();
      expect(
        String.fromCharCodes(bytes.sublist(0, 4)),
        'RIFF',
        reason: sfx.asset,
      );
      expect(
        String.fromCharCodes(bytes.sublist(8, 12)),
        'WAVE',
        reason: sfx.asset,
      );
    }
  });

  test('effects are short and no two sounds are the same file', () {
    final seen = <String, String>{};
    for (final sfx in Sfx.values) {
      final bytes = File('assets/${sfx.asset}').readAsBytesSync();
      // PCM 16 bit mono 44.1 kHz: 88200 byte mỗi giây, trừ 44 byte tiêu đề.
      final seconds = (bytes.length - 44) / 88200;
      final limit = switch (sfx) {
        Sfx.place || Sfx.place2 || Sfx.place3 => 0.3,
        Sfx.unlock => 5.0,
        _ => 3.0,
      };
      expect(seconds, lessThan(limit), reason: sfx.asset);
      final key = bytes.join(',');
      expect(
        seen.containsKey(key),
        isFalse,
        reason: '${sfx.asset} duplicates ${seen[key]}',
      );
      seen[key] = sfx.asset;
    }
  });
}
