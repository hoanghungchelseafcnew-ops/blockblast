# Danh sách kiểm trợ năng

Mức áp dụng: cơ bản, theo Q7 của `refined-mockups-questions.md`: tương phản chữ so với nền tối thiểu 4.5 trên 1, vùng chạm tối thiểu 48dp, và mỗi nút có nhãn đọc được bởi trình đọc màn hình.

| Mục | Thành phần | Tiêu chí | Trạng thái |
|-----|-----------|---------|-----------|
| A1 | RewardAdButton | Vùng chạm cao tối thiểu 48dp (thiết kế dùng 56dp) | Đạt theo thiết kế |
| A2 | RewardAdButton | Tương phản chữ so với nền nút tối thiểu 4.5 trên 1 | Cần kiểm với từng bảng màu viên đá lúc làm code, có `lib/core/theme/contrast.dart` hỗ trợ |
| A3 | RewardAdButton | Nhãn "WATCH AD TO TRY AGAIN" đọc được bởi trình đọc màn hình | Đạt theo thiết kế |
| A4 | UpdateDialog | Mỗi nút tối thiểu 112 x 48dp | Đạt theo thiết kế |
| A5 | UpdateDialog | Tương phản chữ so với nền `0xFF1C1C2E` tối thiểu 4.5 trên 1 | Đạt theo mẫu `QuitDialog` hiện có, cần kiểm lại khi làm code |
| A6 | UpdateDialog | Nút quay lại của hệ điều hành tương đương LATER | Đạt theo thiết kế |
| A7 | Dòng "Watch an ad to stay on this level" | Tương phản chữ `Colors.white70` trên nền tối của lớp phủ tối thiểu 4.5 trên 1 | Cần kiểm lúc làm code |
| A8 | AdBannerSlot | Không cản thao tác kéo thả của người chơi | Đạt theo thiết kế, banner không che bàn cờ hay khay (AC4.1.6) |

## Assumptions & Open Questions

None.
