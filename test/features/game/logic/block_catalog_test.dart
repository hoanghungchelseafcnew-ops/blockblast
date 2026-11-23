import 'package:block_blast/features/game/logic/block_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlockCatalog', () {
    test('keeps the original shape groups and palette (AC4.6.3)', () {
      expect(BlockCatalog.small.length, 8);
      expect(BlockCatalog.medium.length, 10);
      expect(BlockCatalog.large.length, 7);
      expect(BlockCatalog.colors.length, 7);
      expect(BlockCatalog.all.length, 25);
    });

    test('the smallest shape is a single cell', () {
      expect(BlockCatalog.small.first, [
        [1],
      ]);
    });

    test('every shape is rectangular and has at least one filled cell', () {
      for (final shape in BlockCatalog.all) {
        expect(shape, isNotEmpty);
        final width = shape.first.length;
        expect(shape.every((row) => row.length == width), isTrue);
        expect(shape.expand((row) => row).any((v) => v == 1), isTrue);
      }
    });

    test('isLarge is true only for the large group', () {
      expect(BlockCatalog.large.every(BlockCatalog.isLarge), isTrue);
      expect(BlockCatalog.small.any(BlockCatalog.isLarge), isFalse);
      expect(BlockCatalog.medium.any(BlockCatalog.isLarge), isFalse);
    });

    test('groups do not share shapes', () {
      for (final s in BlockCatalog.small) {
        expect(BlockCatalog.medium.any((m) => identical(m, s)), isFalse);
        expect(BlockCatalog.large.any((m) => identical(m, s)), isFalse);
      }
    });
  });
}
