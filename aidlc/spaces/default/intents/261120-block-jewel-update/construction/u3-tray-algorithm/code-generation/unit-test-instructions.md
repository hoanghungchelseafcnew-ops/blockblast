# Unit Test Instructions: u3-tray-algorithm

Chiến lược Standard, test-after: mỗi lớp được implement trước, rồi viết và chạy test của lớp đó. AI chỉ sinh code và test; người dùng chạy lệnh và báo kết quả.

## Khung test
- `flutter_test` (đã có), không thêm gói.
- `Random` được tiêm với seed cố định (`Random(42)`...) để test tất định.
- Bảng test dựng bằng `BoardLogic.createEmptyBoard()` rồi gán `filled`; khối dựng bằng helper có sẵn trong `test/features/game/engine/engine_test_helpers.dart` (`single()`, `line(n)`).

## Lệnh chạy riêng cho unit này
```
flutter test test/features/game/logic/block_catalog_test.dart test/features/game/logic/difficulty_profile_test.dart test/features/game/logic/tray_solver_test.dart test/features/game/logic/tray_generator_test.dart test/features/game/engine/board_engine_test.dart test/features/journey/level_game_controller_test.dart test/features/endless/endless_game_controller_test.dart
```
Lệnh này chạy được trước bước đầu tiên vì `flutter_test` và các test engine, controller đã có.

## Test cần có
- **BlockCatalog (5):** 8 hình nhỏ, 10 hình vừa, 7 hình lớn, 7 màu; `isLarge` đúng; mỗi hình có ít nhất một ô.
- **DifficultyProfile (6–8):** level 1, 18, 36 cho tỉ lệ đúng; tổng ba tỉ lệ bằng 1; bảng trên 60% (ví dụ level 1: 65/29/6); đúng ngưỡng 38 ô vẫn dùng mức thường, 39 ô dùng mức đầy; `rescueRate` 30% → 10%; level ngoài 1..36 được kẹp.
- **TraySolver (6–8):** bảng trống với khay bất kỳ là `solvable` ở cả hai chế độ; khay có khối không còn chỗ là `unsolvable`; xóa dòng giữa chừng làm một khay giải được; strict yêu cầu mọi thứ tự (một khay chỉ giải được theo một thứ tự thì strict `unsolvable`, relaxed `solvable`); đối chiếu với bộ vét cạn viết trong test trên bảng nhỏ; ngân sách quá thấp trả `unknown`; cùng đầu vào cho cùng kết quả.
- **TrayGenerator (6–8):** bảng trống cho tier strict; bảng khiến strict không đạt thì ra relaxed; bảng chỉ đủ ô cho khay 1×1 ra fallback; bảng đầy cho `gameOver`; khay trả về không sửa được; khối cứu xuất hiện khi có hình xóa dòng, không có thì dùng luật thường; không quá 2 khối lớn; cùng seed cùng khay; nhiều seed trên bảng ngẫu nhiên có từ 3 ô trống không bao giờ `gameOver` (NFR2.1); tỉ lệ băng và bom xấp xỉ 5% trên nhiều lần sinh.
- **Hiệu năng (1–2):** chuẩn bị khay trên bảng đầy 60–90% có thời gian trung bình dưới 16 ms trong môi trường test; chỉ là kiểm thô, người dùng đo trên máy thật.
- **BoardEngine (3):** khay mặc định đến từ `TrayGenerator`; `blockSource` truyền vào vẫn được dùng; khay rỗng khi Game Over nên `hasMoves` là false.
- **Controller (2–4):** `LevelGameController.start(level)` đặt `difficultyLevel` bằng `levelIndex`; `EndlessGameController.start` đặt 18.

## Coverage
Toàn codebase tối thiểu 80% dòng (`flutter test --coverage`), `test/widget_test.dart` phải pass trước khi đo. Các file mới của unit hướng tới độ phủ cao hơn mức này.

## Mock và dữ liệu
Không dùng mock cho `TrayGenerator` và `TraySolver` (lớp thuần). Test controller dùng `GameHarness` và engine có sẵn như test hiện có.
