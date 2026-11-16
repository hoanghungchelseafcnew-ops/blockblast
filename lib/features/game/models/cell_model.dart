import 'package:flutter/material.dart';

class CellModel {
  bool filled;
  bool preview;
  bool clearing;
  
  // Special Properties
  bool isIce;
  int iceHealth;
  bool isBomb;

  Color? color;
  Color? previewColor;
  Color? clearingColor;

  CellModel({
    this.filled = false,
    this.preview = false,
    this.clearing = false,
    this.isIce = false,
    this.iceHealth = 0,
    this.isBomb = false,
    this.color,
    this.previewColor,
    this.clearingColor,
  });
}
