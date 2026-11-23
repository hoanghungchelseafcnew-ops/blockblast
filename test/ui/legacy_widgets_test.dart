import 'package:block_blast/features/game/models/block_model.dart';
import 'package:block_blast/features/game/models/cell_model.dart';
import 'package:block_blast/features/game/widgets/board_cell.dart';
import 'package:block_blast/features/game/widgets/draggable_block.dart';
import 'package:block_blast/features/game/widgets/game_board.dart';
import 'package:block_blast/features/game/widgets/particle_explosion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/game/engine/engine_test_helpers.dart';

/// Không còn Provider theme: các widget render thẳng (FR12.2).
Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

BoxDecoration _decorationOf(WidgetTester tester, Finder within) {
  final container = tester
      .widgetList<Container>(
        find.descendant(of: within, matching: find.byType(Container)),
      )
      .firstWhere((c) => c.decoration is BoxDecoration);
  return container.decoration! as BoxDecoration;
}

void main() {
  group('BoardCell renders without a theme provider', () {
    testWidgets('empty, filled and preview cells look different', (
      tester,
    ) async {
      await _pump(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: BoardCell(filled: false, preview: false),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: BoardCell(
                filled: true,
                preview: false,
                cellColor: Colors.red,
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: BoardCell(
                filled: false,
                preview: true,
                previewColor: Colors.blue,
              ),
            ),
          ],
        ),
      );
      final cells = find.byType(BoardCell);
      expect(cells, findsNWidgets(3));
      final empty = _decorationOf(tester, cells.at(0));
      final filled = _decorationOf(tester, cells.at(1));
      final preview = _decorationOf(tester, cells.at(2));
      expect(filled.color, isNot(empty.color));
      expect(preview.color, Colors.blue);
      expect(preview.boxShadow, isNotEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ice and bomb cells show their icons', (tester) async {
      await _pump(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: BoardCell(
                filled: true,
                preview: false,
                cellColor: Colors.green,
                isIce: true,
              ),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: BoardCell(
                filled: true,
                preview: false,
                cellColor: Colors.green,
                isBomb: true,
              ),
            ),
          ],
        ),
      );
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.byIcon(Icons.brightness_low), findsOneWidget);
    });
  });

  group('GameBoard', () {
    testWidgets('renders 64 cells without a theme provider', (tester) async {
      final board = List.generate(
        8,
        (_) => List.generate(8, (_) => CellModel()),
      );
      board[0][0].filled = true;
      await _pump(tester, SizedBox(width: 360, child: GameBoard(board: board)));
      expect(find.byType(BoardCell), findsNWidgets(64));
      expect(tester.takeException(), isNull);
    });
  });

  group('DraggableBlock', () {
    testWidgets('shows the block and reports drag start and end', (
      tester,
    ) async {
      var started = 0;
      var ended = 0;
      await _pump(
        tester,
        DraggableBlock(
          boardCellSize: 40,
          block: line(2),
          onDragStart: () => started++,
          onDragUpdate: (_) {},
          onDragEnd: () => ended++,
        ),
      );
      expect(find.byType(DraggableBlock), findsOneWidget);

      final gesture = await tester.startGesture(
        tester.getTopLeft(find.byType(DraggableBlock)) + const Offset(12, 12),
      );
      for (var i = 0; i < 6; i++) {
        await gesture.moveBy(const Offset(0, -10));
        await tester.pump();
      }
      expect(started, 1);
      await gesture.up();
      await tester.pump();
      expect(ended, 1);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ice and bomb blocks show their icons', (tester) async {
      final ice = BlockModel(
        shape: const [
          [1],
        ],
        color: Colors.teal,
        isIce: true,
      );
      await _pump(
        tester,
        DraggableBlock(
          boardCellSize: 40,
          block: ice,
          onDragStart: () {},
          onDragUpdate: (_) {},
          onDragEnd: () {},
        ),
      );
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      final bomb = BlockModel(
        shape: const [
          [1],
        ],
        color: Colors.teal,
        isBomb: true,
      );
      await _pump(
        tester,
        DraggableBlock(
          boardCellSize: 40,
          block: bomb,
          onDragStart: () {},
          onDragUpdate: (_) {},
          onDragEnd: () {},
        ),
      );
      expect(find.byIcon(Icons.brightness_low), findsOneWidget);
    });
  });

  group('ParticleExplosion', () {
    testWidgets('animates and calls onComplete once', (tester) async {
      var completed = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ParticleExplosion(
                color: Colors.orange,
                onComplete: () => completed++,
              ),
            ),
          ),
        ),
      );
      expect(find.byType(ParticleExplosion), findsOneWidget);
      expect(completed, 0);
      await tester.pump(const Duration(milliseconds: 300));
      expect(completed, 0, reason: 'still animating halfway');
      await tester.pump(const Duration(milliseconds: 400));
      expect(completed, 1);
      await tester.pump(const Duration(seconds: 1));
      expect(completed, 1, reason: 'onComplete fires only once');
    });
  });
}
