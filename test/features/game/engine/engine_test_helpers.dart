import 'package:block_blast/features/game/models/block_model.dart';
import 'package:flutter/material.dart';

/// Khối từ ma trận 0/1, dùng chung cho test engine và controller.
BlockModel makeBlock(
  List<List<int>> shape, {
  bool isBomb = false,
  bool isIce = false,
}) {
  return BlockModel(
    shape: shape,
    color: Colors.blue,
    isBomb: isBomb,
    isIce: isIce,
  );
}

BlockModel single() => makeBlock([
  [1],
]);

BlockModel line(int length) => makeBlock([List<int>.filled(length, 1)]);
