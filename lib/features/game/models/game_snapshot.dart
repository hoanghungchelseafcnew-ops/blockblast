import 'package:flutter/painting.dart';

/// Chế độ chơi của một bản lưu ván dở.
enum GameMode { level, endless }

/// Một ô trên bảng đã lấp (ô trống không có bản ghi).
class SavedCell {
  const SavedCell({
    required this.color,
    required this.isIce,
    required this.iceHealth,
    required this.isBomb,
  });

  final int color;
  final bool isIce;
  final int iceHealth;
  final bool isBomb;

  Object toJson() => <Object>[color, isIce, iceHealth, isBomb];

  static SavedCell? tryParse(Object? raw) {
    if (raw is! List || raw.length != 4) return null;
    final color = raw[0];
    final ice = raw[1];
    final health = raw[2];
    final bomb = raw[3];
    if (color is! int || ice is! bool || health is! int || bomb is! bool) {
      return null;
    }
    if (health < 0 || health > 9) return null;
    return SavedCell(color: color, isIce: ice, iceHealth: health, isBomb: bomb);
  }
}

/// Một khối trong khay.
class SavedBlock {
  const SavedBlock({
    required this.shape,
    required this.color,
    required this.isIce,
    required this.iceHealth,
    required this.isBomb,
  });

  final List<List<int>> shape;
  final int color;
  final bool isIce;
  final int iceHealth;
  final bool isBomb;

  Map<String, Object> toJson() => <String, Object>{
    'shape': shape,
    'color': color,
    'ice': isIce,
    'iceHealth': iceHealth,
    'bomb': isBomb,
  };

  static SavedBlock? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final rawShape = raw['shape'];
    final color = raw['color'];
    final ice = raw['ice'];
    final health = raw['iceHealth'];
    final bomb = raw['bomb'];
    if (rawShape is! List ||
        color is! int ||
        ice is! bool ||
        health is! int ||
        bomb is! bool) {
      return null;
    }
    if (health < 0 || health > 9) return null;
    if (rawShape.isEmpty || rawShape.length > GameSnapshot.maxShapeSide) {
      return null;
    }
    final shape = <List<int>>[];
    var width = -1;
    var cells = 0;
    for (final row in rawShape) {
      if (row is! List ||
          row.isEmpty ||
          row.length > GameSnapshot.maxShapeSide) {
        return null;
      }
      if (width == -1) width = row.length;
      if (row.length != width) return null;
      final parsed = <int>[];
      for (final v in row) {
        if (v != 0 && v != 1) return null;
        parsed.add(v as int);
        if (v == 1) cells++;
      }
      shape.add(parsed);
    }
    if (cells == 0) return null;
    return SavedBlock(
      shape: shape,
      color: color,
      isIce: ice,
      iceHealth: health,
      isBomb: bomb,
    );
  }
}

/// Bản lưu một ván đang chơi dở: điểm, combo, bảng và khay. Chỉ lưu trạng thái
/// ổn định (không lưu hiệu ứng xem trước hay đang xóa dòng).
class GameSnapshot {
  GameSnapshot({
    required this.mode,
    required this.levelIndex,
    required this.score,
    required this.comboStreak,
    required this.board,
    required this.tray,
  });

  static const int version = 1;
  static const int boardSize = 8;
  static const int maxShapeSide = 5;
  static const int maxTray = 3;

  final GameMode mode;

  /// Level đang chơi; 0 với Endless.
  final int levelIndex;
  final int score;
  final int comboStreak;

  /// 8 hàng × 8 cột; null là ô trống.
  final List<List<SavedCell?>> board;
  final List<SavedBlock> tray;

  Map<String, Object> toJson() => <String, Object>{
    'v': version,
    'mode': mode.name,
    'level': levelIndex,
    'score': score,
    'combo': comboStreak,
    'board': [
      for (final row in board) [for (final cell in row) cell?.toJson() ?? 0],
    ],
    'tray': [for (final b in tray) b.toJson()],
  };

  /// Trả null nếu [raw] không phải bản lưu hợp lệ của phiên bản hiện tại.
  static GameSnapshot? tryParse(Object? raw) {
    if (raw is! Map || raw['v'] != version) return null;
    final modeName = raw['mode'];
    final level = raw['level'];
    final score = raw['score'];
    final combo = raw['combo'];
    final rawBoard = raw['board'];
    final rawTray = raw['tray'];
    if (modeName is! String ||
        level is! int ||
        score is! int ||
        combo is! int ||
        rawBoard is! List ||
        rawTray is! List) {
      return null;
    }
    GameMode? mode;
    for (final m in GameMode.values) {
      if (m.name == modeName) mode = m;
    }
    if (mode == null || level < 0 || score < 0 || combo < 0) return null;
    if (rawBoard.length != boardSize) return null;

    final board = <List<SavedCell?>>[];
    for (final rawRow in rawBoard) {
      if (rawRow is! List || rawRow.length != boardSize) return null;
      final row = <SavedCell?>[];
      for (final rawCell in rawRow) {
        if (rawCell == 0) {
          row.add(null);
          continue;
        }
        final cell = SavedCell.tryParse(rawCell);
        if (cell == null) return null;
        row.add(cell);
      }
      board.add(row);
    }

    if (rawTray.isEmpty || rawTray.length > maxTray) return null;
    final tray = <SavedBlock>[];
    for (final rawBlock in rawTray) {
      final block = SavedBlock.tryParse(rawBlock);
      if (block == null) return null;
      tray.add(block);
    }

    return GameSnapshot(
      mode: mode,
      levelIndex: level,
      score: score,
      comboStreak: combo,
      board: board,
      tray: tray,
    );
  }

  /// Màu lưu dưới dạng ARGB 32 bit.
  static int colorToInt(Color color) => color.toARGB32();
}
