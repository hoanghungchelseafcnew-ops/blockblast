import 'dart:io';

import 'package:block_blast/core/audio/sfx.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('there are exactly the six sounds of FR13.1', () {
    expect(Sfx.values.map((s) => s.name), [
      'place',
      'clear',
      'combo',
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
}
