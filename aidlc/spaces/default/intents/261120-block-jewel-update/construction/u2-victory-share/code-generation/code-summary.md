# Code Summary: u2-victory-share

## Files đã sửa
- `lib/features/game/services/score_share_service.dart`: hằng `gameName = 'Block Jewel'`; hàm `scoreShareText`, `victoryShareText`; phương thức mới `shareVictory`; helper chung `_captureAndShare` (ảnh `score.png` / `victory.png` trong thư mục tạm, lỗi ghi `GjLog.error`, khi không chụp được cũng ghi log).
- `lib/features/victory/widgets/victory_overlay.dart`: prop `onShare`, state `_sharing`, nút `SHARE` (`victory-share-button`, 240dp, cao 56dp) dưới CONTINUE/BACK TO MENU ở cả 3 biến thể; bấm lại khi đang chia sẻ bị bỏ qua; lỗi `onShare` được bắt và ghi log.
- `lib/features/game/screens/game_screen.dart`: nối `onShare` với `shareVictory(screenshot, level.displayName, score)`.
- `test/ui/ui_test_helpers.dart`: `FakeShareService` thêm `shareVictory`, `victoryShared`, `lastLevelName`.
- `test/features/game/services/score_share_service_test.dart`: +4 test (chuỗi, chưa chụp được, chụp được kèm văn bản, kênh share lỗi).
- `test/features/victory/victory_overlay_test.dart`: +6 test (3 biến thể, ẩn khi không có `onShare`, chống bấm lặp, lỗi chia sẻ).
- `test/ui/game_screen_test.dart`: +2 test (SHARE gọi `shareVictory` đúng tên level và điểm, có ở màn mở khóa gem).

## Quyết định chính
- Ảnh chụp toàn bộ Scaffold của `GameScreen` (nền, bảng, overlay Victory), dùng `ScreenshotController` sẵn có.
- SHARE không đánh dấu rời màn, nên CONTINUE và BACK TO MENU vẫn bấm được sau khi chia sẻ.
- Chế độ Endless vẫn chỉ có chia sẻ ở Game Over (ngoài phạm vi), nhưng dùng chuỗi Block Jewel mới.

## Test
`flutter analyze lib test`: không có lỗi. `flutter test` 3 file của unit: 45 test pass.

## Lệch so với kế hoạch
Không có.
