# Units of Work

Nguồn: components.md, decisions.md (domain-design), requirements.md, stories.md. Ba unit cùng nằm trong một ứng dụng Flutter, triển khai bằng một lần build.

| Unit ID | Directory | Kind | Complexity | Deployment |
|---|---|---|---|---|
| U1 | u1-app-shell | packaging | S | embedded (cùng app) |
| U2 | u2-victory-share | ui | M | embedded |
| U3 | u3-tray-algorithm | library | L | embedded |

## U1 u1-app-shell
- **Mô tả:** tên Block Jewel, một màn splash thấy được, gỡ splash native.
- **Thành phần:** AppShell.
- **Trách nhiệm:** nhãn Android/iOS, `title` app, chữ trên splash ("BLOCK JEWEL", giữ "◆ Gemstone Journey ◆"), nền khởi động Android/iOS `#0F0C29` không ảnh, gỡ `flutter_native_splash` khỏi `pubspec.yaml`, cập nhật README.
- **Ràng buộc:** giữ applicationId, bundle id, tên package Dart; cập nhật test tham chiếu 'BLOCK CRUSH'.
- **Story:** US1.1, US1.2, US1.3, US2.1, US2.2.

## U2 u2-victory-share
- **Mô tả:** chia sẻ ảnh chụp toàn màn hình khi thắng.
- **Thành phần:** ScoreShareService, VictoryOverlay, GameScreen.
- **Trách nhiệm:** `shareVictory`, nút SHARE ở 3 biến thể Victory, chuỗi chia sẻ "Block Jewel", xử lý lỗi chia sẻ, giữ `shareScore` ở Game Over.
- **Ràng buộc:** hằng số tên game riêng trong U2; nút không che CONTINUE/BACK TO MENU; fake `ScoreShareService` trong test.
- **Story:** US2.3, US3.1, US3.2, US3.3, US3.4, US3.5.

## U3 u3-tray-algorithm
- **Mô tả:** thuật toán sinh khay mới theo bảng và level.
- **Thành phần:** TrayGenerator, DifficultyProfile, BlockCatalog, BoardEngine, LevelGameController, EndlessGameController (BoardLogic dùng lại).
- **Trách nhiệm:** bảo đảm có nước đi, khối "cứu", ưu tiên khối nhỏ khi bảng đầy trên 60%, độ khó theo level, Endless dùng level 18, hằng số ở một nơi, `Random` tiêm được.
- **Ràng buộc:** giữ băng 5%, bom 5%, bảng màu; test theo seed; hiệu năng chọn khay dưới 16 ms.
- **Story:** US4.1–US4.6.
