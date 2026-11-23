# Code Summary — U6 `u6-endless-mode`

## Kết quả kiểm chứng

Chạy trên máy của AI bằng Flutter Linux 3.41.5:

- `flutter analyze`: **No issues found**.
- `flutter test --coverage`: **428/428 test xanh** (sau U5 có 376 test).
- Coverage dòng toàn codebase: **97.8%** (2170/2219).

| File | Coverage |
|------|----------|
| `endless/models/endless_state.dart` (mới) | 100% (16/16) |
| `endless/controllers/endless_game_controller.dart` (mới) | 97.8% (89/91) |
| `endless/screens/endless_game_screen.dart` (mới) | 97.5% (78/80) |
| `game/widgets/board_play_area.dart` (mới) | 97.6% (40/41) |
| `game/widgets/game_over_overlay.dart` | 100% |
| `game/widgets/quit_dialog.dart` | 100% |
| `game/screens/game_screen.dart` | 100% |
| `game/engine/board_engine.dart` | 100% |
| `home/screens/home_screen.dart` | 97.9% (141/144) |
| `journey/services/progress_repository.dart` | 99.3% (150/151) |

Chưa phủ: nhánh `catch` trong `EndlessGameController._save` (`ProgressRepository.saveEndlessState` tự nuốt lỗi ghi nên không bao giờ throw), và vài dòng phòng hờ trong `BoardPlayAreaState`.

## Thay đổi chính

- Chế độ Endless: `EndlessGameController` (bắt đầu từ điểm đã lưu trên bảng trống, QUIT và vào nền thì lưu, thua thì điểm lưu về 0 và giữ high score), không nhận `AnalyticsService` nên không gửi event `level_*`.
- `BoardPlayArea` tách từ `GameScreen` để dùng chung kéo-thả (khối nâng lên trên ngón tay).
- `QuitDialog` có `QuitMode.endless` ("Quit?" + "Your score will be saved."). `GameOverOverlay.endless` hiện FINAL SCORE và BEST.
- Home State C: 6 viên đá, "Journey Complete", "Endless · Best N" ("—" khi chưa có điểm), PLAY mở Endless.
- `ProgressRepository`: key `endless_saved_score`, `endless_high_score`.
