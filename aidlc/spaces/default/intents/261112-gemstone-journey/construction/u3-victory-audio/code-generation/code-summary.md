# Code Summary — U3 `u3-victory-audio`

## Kết quả kiểm chứng

Chạy trên máy của AI bằng Flutter Linux 3.41.5, ngày 2026-11-18:

- `flutter analyze`: **No issues found**.
- `flutter test --coverage`: **340/340 test xanh** (sau U4 có 298 test).
- Coverage dòng toàn codebase: **98.0%** (1804/1841).

Coverage các file U3 tạo hoặc sửa (DoD-2, ngưỡng 80%):

| File | Coverage |
|------|----------|
| `lib/core/audio/audio_controller.dart` (viết lại) | 81.0% (17/21) |
| `lib/features/victory/widgets/victory_overlay.dart` (mới) | 100% |
| `lib/features/victory/widgets/confetti_layer.dart` (mới) | 97.9% (46/47) |
| `lib/features/victory/widgets/gem_unlock_animation.dart` (mới) | 100% |
| `lib/features/victory/models/victory_variant.dart` (mới) | 100% |
| `lib/features/game/engine/board_geometry.dart` | 94.7% (18/19) |
| `lib/features/game/widgets/draggable_block.dart` | 100% |
| `lib/features/game/widgets/block_palette.dart` | 100% |
| `lib/features/game/services/game_feedback.dart` | 100% |
| `lib/features/game/screens/game_screen.dart` | 99.3% (150/151) |
| `lib/features/home/screens/home_screen.dart` | 100% |
| `lib/features/journey/controllers/level_game_controller.dart` | 98.8% (169/171) |
| `lib/features/journey/services/app_bootstrap.dart` | 98.3% (59/60) |
| `lib/features/journey/services/progress_repository.dart` | 99.2% (121/122) |
| `lib/shared/widgets/gem_primary_button.dart` (sửa lỗi sau U4) | 100% |
| `lib/features/game/widgets/quit_dialog.dart` (sửa lỗi sau U4) | 100% |

Phần chưa phủ của `audio_controller.dart` là `AudioplayersSfxPlayer`, lớp bọc plugin `audioplayers` thật. Test dùng `FakeSfxPlayer` nên không gọi plugin. `lib/core/audio/sfx.dart` là enum hằng, không có dòng nào để đo.

## File đã tạo, sửa, xóa

**Mới**
- `lib/core/audio/sfx.dart`: enum 6 âm thanh và đường dẫn asset.
- `lib/features/victory/models/victory_variant.dart`.
- `lib/features/victory/widgets/victory_overlay.dart`, `confetti_layer.dart`, `gem_unlock_animation.dart`.
- `assets/sounds/victory.wav` (bản sao của `combo.wav`) và `assets/sounds/unlock.wav` (bản sao của `clear.wav`): placeholder theo AC8.3.2.
- Test: `test/core/audio/{sfx,audio_controller}_test.dart`, `test/features/victory/{victory_variant,victory_overlay}_test.dart`, `test/fakes/fake_sfx_player.dart`.

**Sửa**
- `audio_controller.dart`: viết lại thành class instance. Mute lưu qua `sound_muted`, khi mute không gọi player, lỗi được log, có `stopSfx`. Bỏ API static và player nhạc nền không dùng.
- `progress_repository.dart`: key `sound_muted` (`soundMuted`, `setSoundMuted`).
- `app_bootstrap.dart`: `AppServices.audio`; tham số `sfxPlayerFactory` để test. `main.dart` bỏ `AudioController.init()`.
- `game_feedback.dart`: thêm `victory`, `unlock`, `stopSfx`. `DeviceGameFeedback` nhận `AudioController`.
- `level_game_controller.dart`:
  - `victoryVariant`.
  - Phát victory khi thắng; với Bling và level 36, phát unlock sau 600ms.
  - CONTINUE dừng âm thanh và hủy unlock; level 36 không có CONTINUE.
  - Rời Victory bằng back cũng dừng âm thanh.
- `game_screen.dart`: dùng `VictoryOverlay`; truyền kích thước ô của bảng xuống khay. Victory tạm của U1 đã bị xóa.
- `home_screen.dart`: Settings dùng `services.audio` (lưu được); `feedback` mặc định dựng từ `services.audio`.
- Kéo-thả: `board_geometry.dart`, `draggable_block.dart`, `block_palette.dart` (xem bên dưới).
- Test: `progress_repository_test`, `level_game_controller_test`, `game_feedback_test`, `board_geometry_test`, `game_screen_test`, `splash_home_test`, `legacy_widgets_test`, `ui_test_helpers`.

**Xóa**: không có file nào bị xóa.

## Kéo khối theo hướng 2 (yêu cầu của người dùng)

- Khối đang kéo được vẽ bằng **đúng kích thước ô trên bảng** và nằm **phía trên ngón tay 1.5 ô**, căn giữa theo chiều ngang (`BoardGeometry.feedbackAnchor`).
- Ô đặt khối được tính từ tâm của khối đã nâng (`BoardGeometry.liftedCenter`). Cùng một công thức được dùng cho cả hai việc, nên preview luôn nằm dưới khối người chơi thấy.
- Khoảng nâng là hằng số `BoardGeometry.liftCells = 1.5`, chỉnh tại một chỗ.
- Bỏ hiệu ứng phóng to 1.15 khi kéo, vì nó làm khối lệch khỏi lưới.
- Khối trong khay giữ kích thước 28dp như cũ.
- Hệ quả cần biết:
  - Để đặt khối ở hàng trên cùng, ngón tay phải ở trên hàng đó khoảng 2 ô, nghĩa là khối được vẽ ngay trên mép bảng.
  - Để đặt ở hàng dưới cùng, ngón tay nằm dưới bảng. Test `board_geometry_test` kiểm cả hai trường hợp.

## Lệch so với kế hoạch

- **Cách thực thi**: orchestrator tự viết code, vì developer subagent vẫn không có công cụ.
- **`gem_primary_button.dart` và `quit_dialog.dart`**: hai file này được sửa theo phản hồi của người dùng sau U4 (CONTINUE xuống dòng, font của dialog), trước khi kế hoạch U3 được viết. Chúng được đưa vào manifest của U3 để có chủ, và đã được kiểm lại trong lần chạy này.
- **Hẹn giờ trong test**: dùng `unlockDelay` tiêm được (30ms) và thời gian thật thay vì `fakeAsync`, vì luồng thắng có nhiều `await` lồng nhau.
- **Thứ tự lớp**: `HomeScreen` được sửa ở Bước 7 (cùng với `AudioController`), vì API static cũ bị gỡ và code phải biên dịch được trước khi chạy test logic.

## Việc còn lại cho người dùng

- Chạy `flutter pub get` trên Windows trước khi build.
- Thử trên máy thật:
  - Kéo khối: khối nằm trên ngón tay, preview khớp. Nếu thấy cao hoặc thấp quá, chỉnh `BoardGeometry.liftCells`.
  - Thắng level con, Bling và level 36: kiểm hiệu ứng và âm thanh.
  - Tắt âm thanh, kill app, mở lại: âm thanh vẫn tắt.
- Thay `assets/sounds/victory.wav` và `unlock.wav` bằng âm thanh thật nếu muốn, giữ nguyên tên file.
