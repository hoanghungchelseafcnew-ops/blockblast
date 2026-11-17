import 'package:block_blast/core/theme/theme_manager.dart';
import 'package:block_blast/features/game/widgets/board_cell.dart';
import 'package:block_blast/features/game/widgets/draggable_block.dart';
import 'package:block_blast/features/game/widgets/particle_explosion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/game/engine/engine_test_helpers.dart';

/// Renders [child] under a [ThemeManager] switched to [theme].
Future<void> _pumpThemed(
  WidgetTester tester,
  AppThemeType theme,
  Widget child,
) async {
  SharedPreferences.setMockInitialValues({});
  final manager = ThemeManager();
  await manager.setTheme(theme);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeManager>.value(
      value: manager,
      child: MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
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
  group('BoardCell renders every theme', () {
    for (final theme in AppThemeType.values) {
      testWidgets('$theme: empty, filled and preview cells', (tester) async {
        await _pumpThemed(
          tester,
          theme,
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
        expect(
          filled.color,
          isNot(empty.color),
          reason: 'a filled cell must look different from an empty one',
        );
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('ice and bomb cells render without errors', (tester) async {
      await _pumpThemed(
        tester,
        AppThemeType.neon,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: BoardCell(filled: true, preview: false, isIce: true),
            ),
            SizedBox(
              width: 40,
              height: 40,
              child: BoardCell(filled: true, preview: false, isBomb: true),
            ),
          ],
        ),
      );
      expect(find.byType(BoardCell), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('DraggableBlock renders every theme', () {
    for (final theme in AppThemeType.values) {
      testWidgets('$theme: shows the block and reports drag start/end', (
        tester,
      ) async {
        var started = 0;
        var ended = 0;
        await _pumpThemed(
          tester,
          theme,
          DraggableBlock(
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
    }
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
