# Feasibility Assessment — Gemstone Journey

## Sources

- [intent] `ideation/intent-capture/intent-statement.md`: 36 level (6 × 6) chủ đề đá quý, mục tiêu session time và retention.
- [market] `ideation/market-research/` (`competitive-analysis.md`, `market-trends.md`, `build-vs-buy.md`)
- [Q1]–[Q10] Câu trả lời đã xác nhận trong `feasibility-questions.md`.
- [code] Codebase hiện tại: `pubspec.yaml`, `android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`.

## Kết luận tổng quan

**Khả thi — rủi ro thấp đến trung bình.** Phần lớn công việc nằm trong năng lực hiện có: thành thạo Flutter và đã dùng Firebase [Q5], không có deadline cứng [Q6], ảnh nền đã có sẵn [Q7], không có trở ngại tổ chức [Q9]. Các rủi ro chính đến từ việc tuân thủ chính sách store khi thêm quảng cáo và IAP, và từ việc chỉ có một developer.

## Đánh giá theo khía cạnh

| Khía cạnh | Mức khả thi | Nhận định | Nguồn |
|-----------|-------------|-----------|-------|
| Hệ thống 36 level, lock/unlock, mục tiêu điểm | Cao | App Flutter đã có gameplay. Tiến trình lưu cục bộ bằng `shared_preferences`, thư viện này đã có trong dự án | [intent] [Q2] [code] |
| Firebase Remote Config + Analytics | Cao | Developer đã có kinh nghiệm. Hai dịch vụ này thuộc gói miễn phí | [Q1] [Q5] [Q6] |
| Quảng cáo + in-app purchase | Trung bình | Cần tài khoản AdMob, cấu hình sản phẩm IAP trên cả hai store, và khai báo quyền riêng tư (iOS ATT) | [Q1] [market] |
| Ảnh nền 36 level | Cao | Đã có sẵn ảnh. Cần chú ý dung lượng app | [Q7] |
| Đổi package ID | Cao (kèm lưu ý) | ID hiện tại là mặc định `com.example.*`. iOS không chấp nhận dấu `_` trong bundle ID | [Q8] [code] |
| Quy mô trên 100.000 người chơi | Trung bình | Analytics, Remote Config và AdMob không giới hạn theo số người chơi ở gói miễn phí. Rủi ro chủ yếu nằm ở hỗ trợ người dùng và vận hành, vì chỉ có một developer | [market] [Q6] [assumption] |

## Tuân thủ quy định

- **GDPR:** không áp dụng, vì không phát hành ở EU. [Q3] Cần cấu hình loại trừ EU trên Google Play Console và App Store Connect.
- **COPPA / chính sách Families:** không áp dụng trực tiếp, vì game nhắm đến người từ 13 tuổi trở lên. [Q4] Cần khai báo đúng nhóm tuổi trên store.
- **Bắt buộc:** form Data safety (Google Play) và Privacy nutrition label (App Store) cho Firebase Analytics và AdMob. Trên iOS cần prompt App Tracking Transparency nếu dùng quảng cáo cá nhân hóa. [market] [Q1]

## Hạ tầng

Không dùng AWS. Toàn bộ backend là dịch vụ quản lý của Firebase/Google. [Q10] Không có hạ tầng tự vận hành.

## Assumptions & Open Questions

- [assumption] App chưa phát hành trên store, dựa trên việc ID vẫn là `com.example.*`. Nếu app đã phát hành, đổi ID sẽ tạo ra một app mới trên store.
- [assumption] Gói miễn phí của Firebase Analytics và Remote Config không giới hạn số người dùng. Thông tin này cần xác minh lại trên trang giá của Firebase.
- [assumption] Tổng dung lượng 36 ảnh nền chưa được đo.
