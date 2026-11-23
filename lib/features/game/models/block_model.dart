import 'package:flutter/material.dart';

class BlockModel {
  final List<List<int>> shape;
  final Color color;

  bool isClearing;

  final bool isIce;
  final int iceHealth;
  final bool isBomb;

  BlockModel({
    required this.shape,
    required this.color,
    this.isClearing = false,
    this.isIce = false,
    this.iceHealth = 0,
    this.isBomb = false,
  });

  int get rows => shape.length;
  int get cols => shape[0].length;
}
