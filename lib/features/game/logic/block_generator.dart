import 'package:flutter/material.dart';
import '../models/block_model.dart';
import 'dart:math';

class BlockGenerator {
  static final Random _random = Random();

  // Premium colors based on actual Block Blast game
  static final List<Color> _blockColors = [
    const Color(0xFFFF3366), // Pink/Red
    const Color(0xFF33CCFF), // Light Blue
    const Color(0xFFFFCC00), // Yellow
    const Color(0xFF9933FF), // Purple
    const Color(0xFF33FF99), // Green
    const Color(0xFFFF9933), // Orange
    const Color(0xFF0066FF), // Dark Blue
  ];

  static List<BlockModel> generateThree() {
    List<BlockModel> blocks = [];

    // Smart distribution: 
    // We want a mix to avoid 3 giant pieces which causes instant game over.
    // E.g., we can force at least one small/medium piece if the first two are large.
    
    int largeCount = 0;

    while (blocks.length < 3) {
      bool forceSmall = largeCount >= 2;
      final block = _generateSingleBlock(forceSmall: forceSmall);
      
      // Keep track of sizes to balance the batch
      if (block.rows >= 3 || block.cols >= 3) {
        largeCount++;
      }

      blocks.add(block);
    }

    return blocks;
  }

  static BlockModel _generateSingleBlock({bool forceSmall = false}) {
    List<List<int>> shape;
    
    if (forceSmall) {
      shape = _smallShapes[_random.nextInt(_smallShapes.length)];
    } else {
      final roll = _random.nextInt(100);
      if (roll < 30) {
        shape = _smallShapes[_random.nextInt(_smallShapes.length)];
      } else if (roll < 80) {
        shape = _mediumShapes[_random.nextInt(_mediumShapes.length)];
      } else {
        shape = _largeShapes[_random.nextInt(_largeShapes.length)];
      }
    }

    final color = _blockColors[_random.nextInt(_blockColors.length)];
    
    // 10% chance for a special block
    final specialRoll = _random.nextInt(100);
    bool isIce = false;
    int iceHealth = 0;
    bool isBomb = false;

    if (specialRoll < 5) {
      isIce = true;
      iceHealth = 2;
    } else if (specialRoll < 10) {
      isBomb = true;
    }

    return BlockModel(
      shape: shape, 
      color: color,
      isIce: isIce,
      iceHealth: iceHealth,
      isBomb: isBomb,
    );
  }

  // ======================== AUTHENTIC SHAPES ========================

  // Small Shapes (1x1, 1x2, 2x1, 2x2, small Ls)
  static final List<List<List<int>>> _smallShapes = [
    [[1]], // 1x1
    [[1, 1]], // 1x2
    [[1], [1]], // 2x1
    [[1, 1], [1, 1]], // 2x2
    [[1, 1], [1, 0]], // Small L 1
    [[1, 1], [0, 1]], // Small L 2
    [[1, 0], [1, 1]], // Small L 3
    [[0, 1], [1, 1]], // Small L 4
  ];

  // Medium Shapes (1x3, 3x1, 1x4, 4x1, T-shapes, Z-shapes)
  static final List<List<List<int>>> _mediumShapes = [
    [[1, 1, 1]], // 1x3
    [[1], [1], [1]], // 3x1
    [[1, 1, 1, 1]], // 1x4
    [[1], [1], [1], [1]], // 4x1
    // T-shapes
    [[1, 1, 1], [0, 1, 0]],
    [[0, 1, 0], [1, 1, 1]],
    [[1, 0], [1, 1], [1, 0]],
    [[0, 1], [1, 1], [0, 1]],
    // Z-shapes
    [[1, 1, 0], [0, 1, 1]],
    [[0, 1, 1], [1, 1, 0]],
  ];

  // Large Shapes (3x3, 1x5, 5x1, Large Ls)
  static final List<List<List<int>>> _largeShapes = [
    [[1, 1, 1], [1, 1, 1], [1, 1, 1]], // 3x3
    [[1, 1, 1, 1, 1]], // 1x5
    [[1], [1], [1], [1], [1]], // 5x1
    // Large Ls
    [[1, 0, 0], [1, 0, 0], [1, 1, 1]],
    [[0, 0, 1], [0, 0, 1], [1, 1, 1]],
    [[1, 1, 1], [1, 0, 0], [1, 0, 0]],
    [[1, 1, 1], [0, 0, 1], [0, 0, 1]],
  ];
}
