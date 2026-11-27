import 'dart:math';

import '../../../core/constants/game_constants.dart';
import '../../../core/log/gj_log.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';
import 'block_catalog.dart';
import 'difficulty_constants.dart';
import 'difficulty_profile.dart';
import 'tray_models.dart';
import 'tray_solver.dart';

/// Sinh khay 3 khối theo bảng hiện tại và level (BR1.x–BR3.x).
///
/// Khay trả về bất biến. Trước khi trả, bộ giải bảo đảm đặt đúng thì không
/// thua: ưu tiên mức strict, hạ xuống relaxed, rồi khay ba khối 1x1; không còn
/// khay nào đặt hết được thì báo Game Over (BR1.4).
class TrayGenerator {
  TrayGenerator({
    Random? random,
    DifficultyProfile profile = const DifficultyProfile(),
  }) : _random = random ?? Random(),
       _profile = profile;

  final Random _random;
  final DifficultyProfile _profile;

  /// Chuẩn bị khay mới cho [board] ở độ khó [level].
  TrayResult prepare(List<List<CellModel>> board, int level) {
    final rows = TraySolver.rowsOf(board);
    final filled = TraySolver.filledCount(rows);
    final rates = _profile.ratesFor(level: level, filledCells: filled);
    final clearingShapes = BlockCatalog.all
        .where((shape) => TraySolver.canClearLine(rows, shape))
        .toList();

    final strictBudgetSize = DifficultyConstants.solverNodeBudget * 3 ~/ 5;
    final relaxedBudgetSize =
        DifficultyConstants.solverNodeBudget - strictBudgetSize;

    try {
      final strict = _findTray(
        rows,
        rates,
        clearingShapes,
        strict: true,
        attempts: DifficultyConstants.maxStrictCandidates,
        budget: NodeBudget(strictBudgetSize),
      );
      if (strict != null) {
        return TrayResult.ready(strict, SolvabilityTier.strict);
      }
      final relaxed = _findTray(
        rows,
        rates,
        clearingShapes,
        strict: false,
        attempts: DifficultyConstants.maxRelaxedCandidates,
        budget: NodeBudget(relaxedBudgetSize),
      );
      if (relaxed != null) {
        return TrayResult.ready(relaxed, SolvabilityTier.relaxed);
      }
    } catch (e) {
      // Lỗi bất ngờ trong bộ giải không được làm hỏng ván: rơi về khay 1x1.
      GjLog.error('Tray', 'solver failed: level=$level filled=$filled', e);
    }
    return _fallback(rows, filled);
  }

  List<BlockModel>? _findTray(
    List<int> rows,
    TrayRates rates,
    List<List<List<int>>> clearingShapes, {
    required bool strict,
    required int attempts,
    required NodeBudget budget,
  }) {
    for (var i = 0; i < attempts && !budget.exhausted; i++) {
      final candidate = _candidate(rates, clearingShapes);
      final outcome = TraySolver.solve(
        rows,
        candidate,
        strict: strict,
        budget: budget,
      );
      if (outcome == SolveOutcome.solvable) return candidate;
    }
    return null;
  }

  /// Khay ba khối 1x1: đặt hết được khi còn từ 3 ô trống (BR1.5); ít hơn thì
  /// nhờ bộ giải xét cả việc xóa dòng giữa chừng.
  TrayResult _fallback(List<int> rows, int filled) {
    final blocks = [for (var i = 0; i < 3; i++) _singleCell()];
    const total = GameConstants.boardSize * GameConstants.boardSize;
    if (total - filled >= 3) {
      return TrayResult.ready(blocks, SolvabilityTier.fallback);
    }
    final outcome = TraySolver.solve(
      rows,
      blocks,
      strict: false,
      budget: NodeBudget(DifficultyConstants.solverNodeBudget),
    );
    if (outcome == SolveOutcome.solvable) {
      return TrayResult.ready(blocks, SolvabilityTier.fallback);
    }
    return TrayResult.gameOver();
  }

  BlockModel _singleCell() => BlockModel(
    shape: BlockCatalog.small.first,
    color: BlockCatalog.colors[_random.nextInt(BlockCatalog.colors.length)],
  );

  /// Ba khối ứng viên theo tỉ lệ [rates].
  List<BlockModel> _candidate(
    TrayRates rates,
    List<List<List<int>>> clearingShapes,
  ) {
    final blocks = <BlockModel>[];
    var largeCount = 0;
    while (blocks.length < 3) {
      final atLargeLimit = largeCount >= DifficultyConstants.maxLargePerTray;
      var rescued = false;
      List<List<int>>? shape;

      final rescuePool = atLargeLimit
          ? clearingShapes.where((s) => !BlockCatalog.isLarge(s)).toList()
          : clearingShapes;
      if (rescuePool.isNotEmpty && _random.nextDouble() < rates.rescueRate) {
        shape = rescuePool[_random.nextInt(rescuePool.length)];
        rescued = true;
      }
      shape ??= _shapeBySize(rates, atLargeLimit);

      if (BlockCatalog.isLarge(shape)) largeCount++;
      blocks.add(_makeBlock(shape, rescued));
    }
    return blocks;
  }

  List<List<int>> _shapeBySize(TrayRates rates, bool noLarge) {
    final List<List<List<int>>> group;
    if (noLarge) {
      final roll = _random.nextDouble() * (rates.smallRate + rates.mediumRate);
      group = roll < rates.smallRate ? BlockCatalog.small : BlockCatalog.medium;
    } else {
      final roll = _random.nextDouble();
      if (roll < rates.smallRate) {
        group = BlockCatalog.small;
      } else if (roll < rates.smallRate + rates.mediumRate) {
        group = BlockCatalog.medium;
      } else {
        group = BlockCatalog.large;
      }
    }
    return group[_random.nextInt(group.length)];
  }

  BlockModel _makeBlock(List<List<int>> shape, bool rescued) {
    final color =
        BlockCatalog.colors[_random.nextInt(BlockCatalog.colors.length)];
    final specialRoll = _random.nextInt(100);
    var isIce = false;
    var iceHealth = 0;
    var isBomb = false;
    if (specialRoll < DifficultyConstants.iceChancePercent) {
      isIce = true;
      iceHealth = DifficultyConstants.iceHealth;
    } else if (specialRoll <
        DifficultyConstants.iceChancePercent +
            DifficultyConstants.bombChancePercent) {
      isBomb = true;
    }
    return BlockModel(
      shape: shape,
      color: color,
      isClearing: rescued,
      isIce: isIce,
      iceHealth: iceHealth,
      isBomb: isBomb,
    );
  }
}
