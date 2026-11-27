# Ánh xạ hệ thống thiết kế

Nguồn: `mockups.md`, `interaction-spec.md` và mã nguồn hiện có (`lib/shared/widgets/gem_primary_button.dart`, `lib/features/game/widgets/game_over_overlay.dart`, `lib/features/game/widgets/quit_dialog.dart`, `lib/core/theme/`).

| Thành phần mới | Dùng lại thành phần hiện có | Ghi chú |
|----------------|----------------------------|---------|
| RewardAdButton | `GemPrimaryButton` (nút chính, cao tối thiểu 56dp, rộng 220dp, nhãn một dòng) | Dùng màu theo `GemPalette` của viên đá hiện tại |
| PLAY AGAIN (khi có nút reward) | `OverlayButton` (nút phụ, tối thiểu 220 x 52dp) | Hiện là `GemPrimaryButton`, chuyển thành nút phụ chỉ khi nút reward hiện |
| UpdateDialog | `AlertDialog` theo mẫu `QuitDialog` | Nền `0xFF1C1C2E`, tiêu đề `AppTypography.title()`, nội dung `AppTypography.body()`, nút tối thiểu 112 x 48dp |
| Nút LATER | `TextButton` như CANCEL trong `QuitDialog` | |
| Nút UPDATE | `ElevatedButton` với `palette.buttonFill`, như QUIT trong `QuitDialog` | |
| Dòng "Watch an ad to stay on this level" | `Text` kiểu nhỏ, màu `Colors.white70` như dòng "Target" của lớp phủ | |
| AdBannerSlot | Dải nền dùng `AppColors.background` (`0xFF151525`) phía sau quảng cáo | Banner do SDK quảng cáo vẽ, không theo font của game |

Font: tiêu đề dùng Righteous, nội dung dùng Montserrat (`AppTypography`). Chuỗi mới: "WATCH AD TO TRY AGAIN", "Watch an ad to stay on this level", "Update available", "A new version of Block Jewel is ready.", "LATER", "UPDATE". Tất cả bằng tiếng Anh.

## Assumptions & Open Questions

None.
