import 'package:block_blast/features/journey/models/journey_outcome.dart';
import 'package:block_blast/features/victory/models/victory_variant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('VictoryVariant.of (C1)', () {
    test('a plain win is a sub-level victory with CONTINUE', () {
      final v = VictoryVariant.of(
        const JourneyOutcome(nextLevel: null, highestLevelReached: 3),
      );
      expect(v, VictoryVariant.sub);
      expect(v.canContinue, isTrue);
      expect(v.playsUnlock, isFalse);
    });

    test('an unlocked gem is the gem unlock variant', () {
      final v = VictoryVariant.of(
        const JourneyOutcome(
          nextLevel: null,
          highestLevelReached: 7,
          unlockedGemId: 'rose_quartz',
        ),
      );
      expect(v, VictoryVariant.gemUnlock);
      expect(v.canContinue, isTrue);
      expect(v.playsUnlock, isTrue);
    });

    test('journey completion wins over the unlocked gem (AC3.3.2)', () {
      final v = VictoryVariant.of(
        const JourneyOutcome(
          nextLevel: null,
          highestLevelReached: 36,
          unlockedGemId: 'ruby',
          journeyCompleted: true,
        ),
      );
      expect(v, VictoryVariant.journeyComplete);
      expect(v.canContinue, isFalse);
      expect(v.playsUnlock, isTrue);
    });
  });
}
