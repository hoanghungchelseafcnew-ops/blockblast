import 'package:flutter/material.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';
import '../../../core/constants/game_constants.dart';

class BoardLogic {
  static List<List<CellModel>> createEmptyBoard() {
    return List.generate(
      GameConstants.boardSize,
      (_) => List.generate(
        GameConstants.boardSize,
        (_) => CellModel(),
      ),
    );
  }

  static bool canPlaceBlock(List<List<CellModel>> board, BlockModel block, int startRow, int startCol) {
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.cols; c++) {
        if (block.shape[r][c] == 1) {
          final row = startRow + r;
          final col = startCol + c;
          if (row < 0 || col < 0 || row >= GameConstants.boardSize || col >= GameConstants.boardSize || board[row][col].filled) {
            return false;
          }
        }
      }
    }
    return true;
  }

  static void placeBlock(List<List<CellModel>> board, BlockModel block, int startRow, int startCol) {
    for (int r = 0; r < block.rows; r++) {
      for (int c = 0; c < block.cols; c++) {
        if (block.shape[r][c] == 1) {
          final cell = board[startRow + r][startCol + c];
          cell.filled = true;
          cell.color = block.color;
          cell.isIce = block.isIce;
          cell.isBomb = block.isBomb;
        }
      }
    }
  }

  static int clearCompletedLines(List<List<CellModel>> board) {
    final size = board.length;
    int linesCleared = 0;
    List<int> fullRows = [];
    List<int> fullCols = [];

    for (int r = 0; r < size; r++) {
      if (board[r].every((cell) => cell.filled)) {
        fullRows.add(r);
        linesCleared++;
      }
    }

    for (int c = 0; c < size; c++) {
      bool full = true;
      for (int r = 0; r < size; r++) {
        if (!board[r][c].filled) {
          full = false;
          break;
        }
      }
      if (full) {
        fullCols.add(c);
        linesCleared++;
      }
    }

    for (int r in fullRows) for (int c = 0; c < size; c++) _markForClearing(board[r][c]);
    for (int c in fullCols) for (int r = 0; r < size; r++) _markForClearing(board[r][c]);

    return linesCleared;
  }

  static void _markForClearing(CellModel cell) {
    cell.clearing = true;
    cell.clearingColor = cell.color ?? Colors.yellow;
  }

  static Future<void> applyClearAnimated(
    List<List<CellModel>> board, {
    Duration delay = const Duration(milliseconds: 180),
  }) async {
    final size = board.length;
    List<Point> bombExplosions = [];

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final cell = board[r][c];
        if (cell.clearing) {
          if (cell.isBomb) bombExplosions.add(Point(r, c));
          cell.preview = true;
          cell.previewColor = cell.clearingColor;
        }
      }
    }

    for (var bomb in bombExplosions) {
      for (int r = bomb.y - 1; r <= bomb.y + 1; r++) {
        for (int c = bomb.x - 1; c <= bomb.x + 1; c++) {
          if (r >= 0 && r < size && c >= 0 && c < size) {
            board[r][c].clearing = true;
            board[r][c].preview = true;
            board[r][c].previewColor = Colors.orangeAccent;
          }
        }
      }
    }

    await Future.delayed(delay);

    for (int r = 0; r < size; r++) {
      for (int c = 0; c < size; c++) {
        final cell = board[r][c];
        if (cell.clearing) {
          cell.filled = false;
          cell.clearing = false;
          cell.isIce = false;
          cell.isBomb = false;
          cell.color = null;
          cell.preview = false;
          cell.previewColor = null;
        }
      }
    }
  }

  static bool canPlaceAnyBlock(List<List<CellModel>> board, List<BlockModel> blocks) {
    final size = board.length;
    for (final block in blocks) {
      for (int row = 0; row <= size - block.rows; row++) {
        for (int col = 0; col <= size - block.cols; col++) {
          if (canPlaceBlock(board, block, row, col)) return true;
        }
      }
    }
    return false;
  }
}

class Point {
  final int y, x;
  Point(this.y, this.x);
}
