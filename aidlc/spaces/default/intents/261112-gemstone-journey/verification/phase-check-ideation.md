# Phase Check — Ideation → Inception

## Intent → Scope → Intent Backlog consistency

| Kiểm tra | Kết quả | Ghi chú |
|----------|---------|---------|
| Mục tiêu trong intent (36 level, retention) có mặt trong scope | ✅ Pass | S-01 đến S-06, S-08 |
| Mỗi hạng mục in-scope có proto-unit tương ứng | ⚠️ Pass có lưu ý | PU-4 (chọn level, S-07) đã bị bỏ ở Rough Mockups (D-11). Ở bước Units Generation cần loại PU-4 khỏi backlog |
| Màn W-2a và W-5a (thêm ở Rough Mockups) có proto-unit chứa chúng | ✅ Pass | Nằm trong PU-3 (hệ thống level) và PU-6 (Victory) |
| Out-of-scope không còn xuất hiện trong mockup | ✅ Pass | Không còn quảng cáo/IAP, Daily Gift, chọn level |

## Scope items có feasibility backing

| Hạng mục | Backing | Kết quả |
|----------|---------|---------|
| S-01, S-02, S-08 Level & tiến trình | feasibility-assessment: khả thi cao | ✅ |
| S-03, S-04, S-10 Firebase Remote Config, Analytics, offline | Khả thi cao. Developer đã dùng Firebase | ✅ |
| S-05 Ảnh nền (Firebase Storage) | Ảnh đã có sẵn. Hạn mức Storage gói miễn phí là rủi ro đã được chấp nhận | ⚠️ Rủi ro được chấp nhận |
| S-06 Victory / Journey Complete | Dùng `flutter_animate` và `audioplayers` có sẵn | ✅ |
| S-09 Đổi package | Khả thi. iOS dùng ID không có `_` | ✅ |
| S-11, S-12 Asset & ràng buộc kỹ thuật | Tái sử dụng code và asset hiện có | ✅ |

## Kết luận

**PASS có lưu ý.** Có hai điểm cần mang sang Inception:
1. Loại S-07 và PU-4 khỏi requirements và units.
2. Chốt hành vi của Home sau level 36, và hành vi của BACK TO MENU sau khi thua.
