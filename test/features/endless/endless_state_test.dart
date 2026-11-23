import 'package:block_blast/features/endless/models/endless_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the initial state is 0 / 0', () {
    expect(EndlessState.initial.savedScore, 0);
    expect(EndlessState.initial.highScore, 0);
  });

  test('saving keeps the score and raises the high score (ER4, ER7)', () {
    final s = const EndlessState(highScore: 500).saving(1200);
    expect(s, const EndlessState(savedScore: 1200, highScore: 1200));
  });

  test('saving a lower score never lowers the high score (ER7)', () {
    final s = const EndlessState(highScore: 5000).saving(1200);
    expect(s, const EndlessState(savedScore: 1200, highScore: 5000));
  });

  test('saving 0 is allowed (AC4.2.3) and negatives become 0', () {
    expect(EndlessState.initial.saving(0), EndlessState.initial);
    expect(EndlessState.initial.saving(-5).savedScore, 0);
  });

  test('a loss resets the saved score to 0 and keeps the best (ER6)', () {
    final higher = const EndlessState(
      savedScore: 900,
      highScore: 1000,
    ).afterLoss(1500);
    expect(higher, const EndlessState(highScore: 1500));
    final lower = const EndlessState(
      savedScore: 900,
      highScore: 1000,
    ).afterLoss(300);
    expect(lower, const EndlessState(highScore: 1000));
    expect(EndlessState.initial.afterLoss(-1), EndlessState.initial);
  });

  test('equality, hashCode and toString', () {
    const a = EndlessState(savedScore: 1, highScore: 2);
    const b = EndlessState(savedScore: 1, highScore: 2);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(const EndlessState(savedScore: 2, highScore: 2)));
    expect(a.toString(), 'EndlessState(saved: 1, high: 2)');
  });
}
