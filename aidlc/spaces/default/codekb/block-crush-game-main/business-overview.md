# Business Overview — Block Crush (`block_blast`)

## Mục đích

**Block Crush** là game xếp khối (block puzzle) trên mobile viết bằng Flutter. Người chơi kéo khối từ khay 3 khối vào bảng 8×8 và lấp đầy hàng hoặc cột để xóa và ghi điểm. Game kết thúc khi không còn chỗ đặt khối nào trong khay.

## Chức năng hiện có

| Chức năng | Mô tả | Vị trí |
|-----------|-------|--------|
| Classic mode | Chơi không giới hạn thời gian, lưu high score `high_score` | `features/game/screens/game_screen.dart` |
| Time Attack | Đếm ngược 120 giây, đặt khối +2 giây, xóa dòng +5 giây/dòng, lưu `high_score_time` | `game_screen.dart` |
| Combo | Xóa dòng liên tiếp tăng hệ số, hiện "COMBO xN" hoặc "INCREDIBLE!" | `game_screen.dart` |
| Khối đặc biệt | Ice và bomb (bomb nổ vùng 3×3 khi bị xóa) | `logic/block_generator.dart`, `logic/board_logic.dart` |
| Revive (free) | Mỗi ván được hồi sinh một lần, xóa vùng 3×3 ở giữa bảng | `game_screen.dart` |
| Share score | Chụp màn hình và chia sẻ qua `share_plus` | `game_screen.dart` |
| Tutorial | Overlay hướng dẫn ở lần chơi đầu (`tutorial_completed`) | `game_screen.dart` |
| Daily Gift | Popup mỗi ngày một lần. Chỉ hiển thị, không cộng điểm thật | `features/home/screens/home_screen.dart` |
| Settings | Bật/tắt âm thanh (không được lưu), chọn theme Neon/Wood/Jewel (được lưu) | `home_screen.dart`, `core/theme/theme_manager.dart` |

## Luật tính điểm hiện tại

- Mỗi ô đặt xuống được **10 điểm**.
- Xóa dòng được thêm **`dòng_xóa × 100 × comboStreak`** điểm.
- `comboStreak` bị reset về 0 khi một lần đặt khối không xóa được dòng nào.

## Bối cảnh intent Gemstone Journey

Intent `gemstone-journey` chuyển game sang hệ thống 36 level chủ đề đá quý, chỉ giữ Classic. Ảnh nền cho 36 level đã có sẵn ở `assets/design/Level1..6/1..6.jpg`, nhưng chưa được khai báo trong `pubspec.yaml`.
