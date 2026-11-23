/// Mọi hằng số cân bằng của thuật toán sinh khay, ở một nơi (BR5.1, FR4.7).
///
/// Giá trị khởi điểm; chỉnh ở đây mà không phải sửa logic.
class DifficultyConstants {
  const DifficultyConstants._();

  static const int levelMin = 1;
  static const int levelMax = 36;

  /// Endless dùng mức độ khó của level giữa hành trình (BR4.2).
  static const int endlessLevel = 18;

  /// Tỉ lệ khối nhỏ ở level 1 và level 36 (tuyến tính giữa hai mốc).
  static const double smallRateStart = 0.40;
  static const double smallRateEnd = 0.25;

  /// Tỉ lệ khối vừa không đổi theo level.
  static const double mediumRate = 0.45;

  /// Tỉ lệ khối lớn ở level 1 và level 36.
  static const double largeRateStart = 0.15;
  static const double largeRateEnd = 0.30;

  /// Tỉ lệ khối "cứu" (xóa ít nhất một dòng) ở level 1 và level 36.
  static const double rescueRateStart = 0.30;
  static const double rescueRateEnd = 0.10;

  /// Bảng coi là đầy khi số ô đã lấp lớn hơn giá trị này (hơn 60% của 64 ô).
  static const int fullBoardThresholdCells = 38;

  /// Khi bảng đầy: cộng thêm vào tỉ lệ khối nhỏ.
  static const double fullBoardSmallBonus = 0.25;

  /// Khi bảng đầy: nhân tỉ lệ khối lớn với hệ số này.
  static const double fullBoardLargeFactor = 0.40;

  /// Số khối lớn tối đa trong một khay.
  static const int maxLargePerTray = 2;

  /// Số khay ứng viên tối đa cho mỗi mức bảo đảm.
  static const int maxStrictCandidates = 30;
  static const int maxRelaxedCandidates = 30;

  /// Tổng số nút bộ giải được duyệt cho một lần chuẩn bị khay (NFR1.2).
  /// Mức strict dùng 60%, mức relaxed dùng phần còn lại. Một nút tốn vài chục
  /// micro giây, nên 1500 nút giữ trường hợp xấu nhất quanh mục tiêu 16 ms;
  /// thiết kế ban đầu ghi 20000 và đã hạ vì lý do này, cần đo trên máy thật.
  static const int solverNodeBudget = 1500;

  /// Xác suất khối đặc biệt, giữ như cũ (BR5.3): băng 5%, bom 5%.
  static const int iceChancePercent = 5;
  static const int bombChancePercent = 5;
  static const int iceHealth = 2;
}
