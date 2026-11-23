import 'board_cell.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/game_constants.dart';
import '../models/cell_model.dart';

/// Bảng 8×8. Nền kính mờ cố định, không theo theme (FR12.2).
class GameBoard extends StatelessWidget {
  final List<List<CellModel>> board;

  const GameBoard({super.key, required this.board});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(GameConstants.boardPadding),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.boardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: GameConstants.boardSize,
              crossAxisSpacing: GameConstants.cellSpacing,
              mainAxisSpacing: GameConstants.cellSpacing,
            ),
            itemCount: GameConstants.boardSize * GameConstants.boardSize,
            itemBuilder: (_, index) {
              final row = index ~/ GameConstants.boardSize;
              final col = index % GameConstants.boardSize;
              final cell = board[row][col];

              return BoardCell(
                filled: cell.filled,
                preview: cell.preview,
                previewColor: cell.previewColor,
                cellColor: cell.color,
                isIce: cell.isIce,
                isBomb: cell.isBomb,
              );
            },
          ),
        ),
      ),
    );
  }
}
