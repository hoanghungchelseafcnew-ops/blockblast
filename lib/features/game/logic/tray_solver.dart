import '../../../core/constants/game_constants.dart';
import '../models/block_model.dart';
import '../models/cell_model.dart';

/// Kết quả một lần giải.
enum SolveOutcome {
  /// Có cách đặt hết các khối theo yêu cầu.
  solvable,

  /// Đã duyệt hết và không có cách.
  unsolvable,

  /// Ngân sách nút cạn trước khi kết luận.
  unknown,
}

/// Bộ đếm nút còn lại cho một lần giải (BR5.4). Tính theo số nút, không theo
/// đồng hồ, để kết quả tất định theo seed (BR5.2).
class NodeBudget {
  NodeBudget(this.remaining);

  int remaining;

  bool get exhausted => remaining <= 0;

  /// Trừ một nút. Trả false nếu đã hết ngân sách.
  bool spend() {
    if (remaining <= 0) return false;
    remaining--;
    return true;
  }
}

/// Kiểm tra một khay có đặt hết được lên bảng không, tính cả việc xóa dòng
/// giữa chừng (BR1.2, BR1.3).
///
/// Bảng được rút thành [GameConstants.boardSize] số nguyên, mỗi số là một hàng
/// (bit c = ô cột c đã lấp). Bom và băng không được mô phỏng: bom chỉ làm trống
/// thêm ô và băng không chặn việc xóa dòng, nên bộ giải chỉ bảo thủ hơn thực tế.
class TraySolver {
  const TraySolver._();

  static const int _size = GameConstants.boardSize;
  static const int _fullRow = (1 << _size) - 1;

  /// Ba hoán vị chỉ số của khay ba khối: cả 6 thứ tự đặt.
  static const List<List<int>> _orders = [
    [0, 1, 2],
    [0, 2, 1],
    [1, 0, 2],
    [1, 2, 0],
    [2, 0, 1],
    [2, 1, 0],
  ];

  /// Rút bảng thành mask các hàng.
  static List<int> rowsOf(List<List<CellModel>> board) {
    final rows = List<int>.filled(_size, 0);
    for (var r = 0; r < _size; r++) {
      var mask = 0;
      for (var c = 0; c < _size; c++) {
        if (board[r][c].filled) mask |= 1 << c;
      }
      rows[r] = mask;
    }
    return rows;
  }

  /// Số ô đã lấp trong [rows].
  static int filledCount(List<int> rows) {
    var count = 0;
    for (final row in rows) {
      count += popCount(row);
    }
    return count;
  }

  static int popCount(int value) {
    var v = value;
    var count = 0;
    while (v != 0) {
      v &= v - 1;
      count++;
    }
    return count;
  }

  /// Mask từng hàng của [shape] (bit c = ô cột c thuộc hình).
  static List<int> shapeMask(List<List<int>> shape) {
    return [
      for (final row in shape)
        () {
          var mask = 0;
          for (var c = 0; c < row.length; c++) {
            if (row[c] == 1) mask |= 1 << c;
          }
          return mask;
        }(),
    ];
  }

  /// Hình [shape] có đặt được ở đâu đó mà làm đầy ít nhất một hàng hoặc cột.
  static bool canClearLine(List<int> rows, List<List<int>> shape) {
    final mask = shapeMask(shape);
    final width = shape.first.length;
    for (final p in _placements(rows, mask, width)) {
      if (p.clears > 0) return true;
    }
    return false;
  }

  /// Giải khay [blocks] (3 khối) trên bảng [rows].
  ///
  /// [strict]: mọi thứ tự đặt đều phải có cách đặt hết. Ngược lại chỉ cần một
  /// thứ tự. Nút được trừ vào [budget]; cạn thì trả [SolveOutcome.unknown].
  static SolveOutcome solve(
    List<int> rows,
    List<BlockModel> blocks, {
    required bool strict,
    required NodeBudget budget,
  }) {
    final masks = [for (final b in blocks) shapeMask(b.shape)];
    final widths = [for (final b in blocks) b.cols];
    final orders = blocks.length == 3
        ? _orders
        : [List<int>.generate(blocks.length, (i) => i)];

    var sawUnknown = false;
    for (final order in orders) {
      final outcome = _search(rows, masks, widths, order, 0, budget);
      if (strict) {
        if (outcome != SolveOutcome.solvable) return outcome;
      } else {
        if (outcome == SolveOutcome.solvable) return outcome;
        if (outcome == SolveOutcome.unknown) sawUnknown = true;
      }
    }
    if (strict) return SolveOutcome.solvable;
    return sawUnknown ? SolveOutcome.unknown : SolveOutcome.unsolvable;
  }

  static SolveOutcome _search(
    List<int> rows,
    List<List<int>> masks,
    List<int> widths,
    List<int> order,
    int index,
    NodeBudget budget,
  ) {
    if (index == order.length) return SolveOutcome.solvable;
    final which = order[index];
    final candidates = _placements(rows, masks[which], widths[which]);
    for (final p in candidates) {
      if (!budget.spend()) return SolveOutcome.unknown;
      final outcome = _search(p.rows, masks, widths, order, index + 1, budget);
      if (outcome != SolveOutcome.unsolvable) return outcome;
    }
    return SolveOutcome.unsolvable;
  }

  /// Mọi vị trí đặt hợp lệ, vị trí xóa nhiều dòng hơn đi trước; cùng số dòng
  /// thì theo thứ tự hàng rồi cột (tất định).
  static List<_Placement> _placements(
    List<int> rows,
    List<int> shape,
    int width,
  ) {
    final height = shape.length;
    final found = <_Placement>[];
    var order = 0;
    for (var r = 0; r + height <= _size; r++) {
      for (var c = 0; c + width <= _size; c++) {
        var fits = true;
        for (var i = 0; i < height; i++) {
          if ((rows[r + i] & (shape[i] << c)) != 0) {
            fits = false;
            break;
          }
        }
        if (!fits) continue;
        final placed = List<int>.of(rows);
        for (var i = 0; i < height; i++) {
          placed[r + i] |= shape[i] << c;
        }
        found.add(_resolve(placed, order++));
      }
    }
    found.sort((a, b) {
      final byClears = b.clears.compareTo(a.clears);
      return byClears != 0 ? byClears : a.order.compareTo(b.order);
    });
    return found;
  }

  /// Xóa các hàng và cột đầy của [placed], đếm số dòng đã xóa.
  static _Placement _resolve(List<int> placed, int order) {
    var fullRows = 0;
    var columnMask = _fullRow;
    var clears = 0;
    for (var r = 0; r < _size; r++) {
      if (placed[r] == _fullRow) {
        fullRows |= 1 << r;
        clears++;
      }
      columnMask &= placed[r];
    }
    clears += popCount(columnMask);
    if (clears == 0) return _Placement(placed, 0, order);
    final cleared = List<int>.filled(_size, 0);
    for (var r = 0; r < _size; r++) {
      cleared[r] = (fullRows & (1 << r)) != 0 ? 0 : placed[r] & ~columnMask;
    }
    return _Placement(cleared, clears, order);
  }
}

class _Placement {
  const _Placement(this.rows, this.clears, this.order);

  final List<int> rows;
  final int clears;
  final int order;
}
