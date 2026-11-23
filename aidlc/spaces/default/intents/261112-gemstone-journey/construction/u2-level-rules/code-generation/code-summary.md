# Code Summary — U2 `u2-level-rules`

## Kết quả kiểm chứng

Chạy trên máy của AI bằng Flutter Linux 3.41.5, ngày 2026-11-18:

- `flutter analyze`: **No issues found**.
- `flutter test --coverage`: **254/254 test xanh** (U1 có 213 test, U2 thêm 41 test và thay các test REVIVE).
- Coverage dòng toàn codebase: **96.3%** (1468/1524).

Coverage của từng file U2 tạo hoặc sửa (DoD-2, ngưỡng 80%):

| File | Coverage |
|------|----------|
| `lib/features/journey/models/high_scores.dart` (mới) | 100.0% (24/24) |
| `lib/features/journey/models/player_progress.dart` | 100.0% (43/43) |
| `lib/features/journey/services/progress_repository.dart` | 99.1% (108/109) |
| `lib/features/journey/services/progress_store.dart` | 81.2% (13/16) |
| `lib/features/journey/controllers/journey_controller.dart` | 83.3% (50/60) |
| `lib/features/journey/controllers/level_game_controller.dart` | 98.7% (152/154) |
| `lib/features/game/engine/board_engine.dart` | 100.0% (36/36) |
| `lib/features/game/screens/game_screen.dart` | 99.3% (139/140) |
| `lib/features/game/widgets/quit_dialog.dart` (mới) | 100.0% (13/13) |
| `lib/features/game/widgets/game_over_overlay.dart` (mới) | 100.0% (35/35) |
| `lib/features/journey/services/app_bootstrap.dart` (chỉ format) | 98.2% (56/57) |

Phần chưa phủ của `journey_controller.dart` là các nhánh `catch` phòng hờ khi tính outcome. Repository không bao giờ throw nên các nhánh này không thể kích hoạt qua API công khai. Phần chưa phủ của `progress_store.dart` là các nhánh `setString`/`setBool`/`remove` trả `false` của SharedPreferences thật.

## File đã tạo, sửa, xóa

**Mới**
- `lib/features/journey/models/high_scores.dart`: model bất biến cho key `high_scores`, parse tolerant (E3 R-07), điểm không giảm.
- `lib/features/game/widgets/quit_dialog.dart`: dialog "Quit this level?" với CANCEL (autofocus) và QUIT, mỗi nút ≥ 48dp.
- `lib/features/game/widgets/game_over_overlay.dart`: Game Over mới (FINAL SCORE, Target, "You will return to …", SHARE SCORE, PLAY AGAIN, BACK TO MENU) và `OverlayButton` dùng chung.
- `test/features/journey/high_scores_test.dart`.

**Sửa**
- `player_progress.dart`: thêm `withoutGem(gemOrder)`.
- `progress_store.dart`: thêm `remove(key)`.
- `progress_repository.dart`: key `high_scores` (đọc, `highScore`, `saveHighScore`, dirty, thử lại, chỉ đọc), gỡ `high_score` và key Time Attack cũ sau `load()`.
- `journey_controller.dart`: mở khóa gem khi thắng Bling, journey complete ở level 36, `onLevelLost`, high score khi thắng/thua, `bestScoreFor`, `returnLevelFor`, `lostOutcomeFor`.
- `level_game_controller.dart`: nhánh `playing → resolving → lost` gọi `onLevelLost` (timeout 3s), bỏ REVIVE, `confirmQuit`, `needsQuitConfirmation`, `bestScore` thật, `returnLevel`, PLAY AGAIN ở Rough Stone.
- `board_engine.dart`: gỡ `clearCenter` (chỉ REVIVE dùng).
- `game_screen.dart`: hỏi QUIT qua dialog cho [←] và back hệ thống, dùng `GameOverOverlay`, hiện "BEST N" trên header.
- Test: `fake_progress_store.dart`, `progress_repository_test.dart`, `journey_controller_test.dart`, `level_game_controller_test.dart`, `board_engine_test.dart`, `game_screen_test.dart`, `splash_home_test.dart`.
- Chỉ format bằng `dart format` (không đổi logic): `app_bootstrap.dart`, `app_bootstrap_test.dart`, `level_catalog_test.dart`.

**Xóa**: không có file nào bị xóa.

## Quyết định chính

- **Thua được lưu trước khi hiện Game Over**: dùng cùng cơ chế `resolving` với khi thắng (ADR-008). `outcome.nextLevel` là Rough Stone. Nếu lần lưu mất quá 3 giây, outcome lấy từ cache qua `lostOutcomeFor`.
- **Back khi đang chơi**: `requestBack()` trả false, UI mở `QuitDialog`. QUIT gọi `confirmQuit()` rồi rời màn. Back trong lúc `resolving` vẫn bị bỏ qua. BACK TO MENU ở Game Over rời màn ngay, không hỏi, vì tiến trình đã được lưu.
- **BEST** = `max(high score đã lưu lúc start, score hiện tại)`, chỉ hiện khi > 0.
- **Level 36**: `journeyCompleted = true`, `unlockedGemId = 'ruby'`, `nextLevel = null`.
- **Key cũ**: chỉ gỡ `high_score` và key điểm Time Attack. `theme_index` và `last_login_date` được giữ cho tới U4.

## Lệch so với kế hoạch

- **Cách thực thi**: stage quy định giao code cho developer subagent. Subagent trong phiên Kiro này không có công cụ đọc/ghi file (trả `NO-TOOLS`), nên người dùng chọn để orchestrator tự viết code theo đúng kế hoạch đã duyệt.
- **Tên key Time Attack trong `lib/`**: AC2.1.2 yêu cầu grep `high_score_time` trong `lib/` cho 0 kết quả, còn E3 yêu cầu xóa key này khỏi máy người chơi. Tên key được ghép từ `'high_score'` và `'_time'` trong `ProgressRepository.legacyKeys`, kèm chú thích giải thích. Test `time_attack_removed_test.dart` vẫn xanh. Đây là chỗ tham chiếu duy nhất và chỉ dùng để xóa key.
- **`OverlayButton`**: được đặt trong `game_over_overlay.dart` và dùng chung cho nút CONTINUE của Victory tạm, thay cho helper riêng trong `game_screen.dart`. Key của nút nằm trên `SizedBox` bao ngoài; test bấm và đo kích thước vẫn đúng.
- **Dialog QUIT**: chỉ có tiêu đề và hai nút, không thêm dòng mô tả nào ngoài spec.

## Rủi ro và việc còn lại

- Chưa build trên thiết bị thật. Người dùng nên chơi thử: thua ở level con thứ 3 trở lên thì quay về Rough Stone, mở lại app vẫn ở Rough Stone.
- `android/local.properties` đã bị Flutter Linux ghi `flutter.sdk=/home/pc/flutter`. Flutter trên Windows sẽ tự ghi lại giá trị này ở lần build tiếp theo.
