# RAID Log — Gemstone Journey

## Sources

- [intent] `ideation/intent-capture/intent-statement.md`
- [market] `ideation/market-research/`
- [Q1]–[Q10] `feasibility-questions.md`
- [code] `android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`

## Risks

| ID | Rủi ro | Khả năng | Tác động | Giảm thiểu | Nguồn |
|----|--------|----------|----------|------------|-------|
| R1 | App bị store từ chối vì khai báo quyền riêng tư sai hoặc thiếu (Analytics, AdMob, ATT) | Trung bình | Cao | Lập checklist Data safety, Privacy label và ATT trước khi submit | [Q1] [market] |
| R2 | Bundle ID iOS chứa `_` không hợp lệ | Cao | Thấp | Dùng `com.h2.game.blockBlast` (hoặc biến thể có `-`) cho iOS | [Q8] [code] |
| R3 | Người chơi mất tiến trình khi gỡ app hoặc đổi máy | Trung bình | Trung bình | Chấp nhận theo C-T2. Có thể thêm đồng bộ cloud sau | [Q2] |
| R4 | Remote Config fetch lỗi hoặc offline, làm sai mục tiêu điểm | Trung bình | Trung bình | Đặt giá trị mặc định trong app, kèm cache | [Q1] |
| R5 | Một developer phải tự gánh hỗ trợ và vận hành ở quy mô trên 100.000 người chơi | Trung bình | Trung bình | Dùng dịch vụ quản lý (Firebase). Theo dõi crash và analytics | [Q9] [market] [assumption] |
| R6 | Dung lượng app tăng do 36 ảnh nền | Trung bình | Thấp | Nén ảnh (WebP) hoặc tải theo nhu cầu | [Q7] [assumption] |
| R7 | Quảng cáo làm giảm trải nghiệm, đi ngược mục tiêu retention | Trung bình | Trung bình | Đặt quảng cáo ở điểm chuyển level, giới hạn tần suất | [market] [intent] [assumption] |

## Assumptions

| ID | Giả định | Nguồn |
|----|----------|-------|
| A1 | App chưa phát hành, nên đổi ID không ảnh hưởng người dùng hiện tại | [code] [assumption] |
| A2 | Gói miễn phí của Firebase đủ dùng cho quy mô trên 100.000 người chơi | [Q6] [assumption] |
| A3 | Developer có thiết bị và máy Mac để build và test iOS (Q9 không nêu trở ngại nào) | [Q9] [assumption] |

## Issues

| ID | Vấn đề | Nguồn |
|----|--------|-------|
| I1 | Package ID hiện tại vẫn là mặc định `com.example.*`, cần đổi trước khi phát hành | [code] [Q8] |

## Dependencies

| ID | Phụ thuộc | Nguồn |
|----|-----------|-------|
| D1 | Firebase project (Android + iOS app), tạo theo package ID mới | [Q1] [Q8] |
| D2 | Tài khoản AdMob và ad unit cho cả hai nền tảng | [Q1] |
| D3 | Tài khoản Google Play Console và Apple Developer (cấu hình IAP, phân phối không gồm EU) | [Q1] [Q3] |
| D4 | Bộ 36 ảnh nền đã có sẵn | [Q7] |

## Assumptions & Open Questions

- [assumption] A1, A2, A3 cần được xác minh trước giai đoạn Construction.
