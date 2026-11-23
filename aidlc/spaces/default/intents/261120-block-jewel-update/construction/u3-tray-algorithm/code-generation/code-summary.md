# Code Summary: u3-tray-algorithm

## Files mới
- `lib/features/game/logic/difficulty_constants.dart`: mọi hằng số cân bằng ở một nơi (BR5.1).
- `lib/features/game/logic/tray_models.dart`: `TrayRates`, `SolvabilityTier`, `TrayResult` (khay trả về là `List.unmodifiable`, BR1.1).
- `lib/features/game/logic/block_catalog.dart`: hình và màu chuyển nguyên giá trị từ `BlockGenerator` (8 nhỏ, 10 vừa, 7 lớn, 7 màu).
- `lib/features/game/logic/difficulty_profile.dart`: `ratesFor(level, filledCells)` theo BR2.3, BR3.1, BR3.2.
- `lib/features/game/logic/tray_solver.dart`: bộ giải bitmask, DFS có ngân sách, strict (6 thứ tự) và relaxed (một thứ tự), vị trí xóa dòng đi trước.
- `lib/features/game/logic/tray_generator.dart`: `prepare(board, level)`: strict → relaxed → khay 1×1 → Game Over; khối cứu; tối đa 2 khối lớn; băng 5%, bom 5%.
- Test: `block_catalog_test.dart`, `difficulty_profile_test.dart`, `tray_solver_test.dart`, `tray_generator_test.dart` trong `test/features/game/logic/`.

## Files đã sửa
- `lib/features/game/engine/board_engine.dart`: thêm `difficultyLevel` (mặc định 18) và `trayGenerator`; khi không truyền `blockSource`, khay lấy từ `TrayGenerator`; Game Over cho khay rỗng nên `hasMoves` là false.
- `lib/features/journey/controllers/level_game_controller.dart`: `start` gán `engine.difficultyLevel = level.levelIndex` trước `reset()`.
- `lib/features/endless/controllers/endless_game_controller.dart`: `start` gán `DifficultyConstants.endlessLevel`.
- `test/features/game/engine/board_engine_test.dart`: +4 test (nguồn khay mặc định, `difficultyLevel`, khay rỗng khi bảng đầy, `blockSource` vẫn được ưu tiên).
- `test/features/journey/level_game_controller_test.dart`: +2 test (độ khó theo `levelIndex`).
- `test/features/endless/endless_game_controller_test.dart`: +2 test (độ khó cố định 18).

## File đã xóa
- `lib/features/game/logic/block_generator.dart`: thay bằng `BlockCatalog` và `TrayGenerator`; không còn nơi nào import.

## Quyết định chính
- Bộ giải mô phỏng bảng thành 8 mask hàng, chỉ theo ô đã lấp. Bom và băng không mô phỏng; điều đó chỉ làm bộ giải bảo thủ hơn thực tế.
- Khay đã sinh không bao giờ bị sửa; bảo đảm có nước đi nằm ở bước chọn khay.
- Khi Game Over ở bước chuẩn bị khay, `BoardEngine` để khay rỗng, nên luồng Game Over hiện có của hai controller chạy tiếp mà không thêm nhánh.
- Ngân sách bộ giải: strict 60%, relaxed 40%, mỗi mức có ngân sách riêng để một mức không làm cạn mức kia.

## Lệch so với thiết kế
- `solverNodeBudget` khởi điểm là **1500** thay vì 20000 trong `logical-components.md`. Lý do: một nút tốn vài chục micro giây, 20000 nút sẽ vượt 16 ms ở trường hợp xấu nhất. Giá trị này chưa đo trên máy thật; cần đo và chỉnh trong `DifficultyConstants`.
- Mô phỏng chỉ theo ô đã lấp, không theo bom hay băng (đã nêu trong kế hoạch).

## Test
Chưa chạy. Theo team practices, người dùng chạy `dart format .`, `flutter analyze` và `flutter test --coverage` rồi báo kết quả; tôi chỉ sinh code và test. Lệnh riêng cho unit nằm trong `unit-test-instructions.md`.
