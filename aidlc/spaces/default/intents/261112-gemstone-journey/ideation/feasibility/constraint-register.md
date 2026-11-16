# Constraint Register — Gemstone Journey

## Sources

- [intent] `ideation/intent-capture/intent-statement.md`
- [market] `ideation/market-research/`
- [Q1]–[Q10] `feasibility-questions.md`
- [code] `pubspec.yaml`, `android/app/build.gradle.kts`, `ios/Runner.xcodeproj/project.pbxproj`

## Ràng buộc kỹ thuật

| ID | Ràng buộc | Tác động | Nguồn |
|----|-----------|----------|-------|
| C-T1 | Nền tảng là Flutter (Dart SDK ^3.9.2), giữ kiến trúc hiện tại (`provider`) | Tính năng mới phải theo cấu trúc `lib/core`, `lib/features` | [code] |
| C-T2 | Tiến trình chỉ lưu cục bộ trên thiết bị (`shared_preferences`) | Mất tiến trình khi gỡ app. Không đồng bộ giữa các thiết bị | [Q2] |
| C-T3 | Mục tiêu điểm của level được cấu hình qua Firebase Remote Config | Cần có giá trị mặc định trong app khi offline hoặc khi fetch lỗi | [Q1] [market] |
| C-T4 | Hỗ trợ cả Android và iOS | Mọi tích hợp (Firebase, AdMob, IAP) phải cấu hình cho cả hai nền tảng | [intent] [Q1] |
| C-T5 | Đổi package/application ID sang `com.h2.game.block_blast` trên tất cả nền tảng | Trên iOS phải dùng biến thể hợp lệ, không có `_` | [Q8] [code] |

## Ràng buộc tổ chức

| ID | Ràng buộc | Tác động | Nguồn |
|----|-----------|----------|-------|
| C-O1 | Chỉ có một developer, người này tự quyết định scope và priority | Không có review chéo. Năng lực vận hành hạn chế | [intent] [Q9] |
| C-O2 | Không có ngân sách, chỉ dùng gói miễn phí | Không dùng dịch vụ trả phí | [Q6] |
| C-O3 | Không có deadline cứng | Linh hoạt về lịch | [Q6] |

## Ràng buộc quy định

| ID | Ràng buộc | Tác động | Nguồn |
|----|-----------|----------|-------|
| C-R1 | Không phát hành ở EU | Loại EU khỏi danh sách quốc gia phân phối | [Q3] |
| C-R2 | Đối tượng 13+, không nhắm đến trẻ em | Khai báo nhóm tuổi trên store. Không tham gia chương trình Families | [Q4] |
| C-R3 | Khai báo dữ liệu thu thập (Data safety, Privacy label) | Bắt buộc khi dùng Firebase Analytics và AdMob | [Q1] [market] |
| C-R4 | iOS App Tracking Transparency | Cần prompt ATT nếu dùng quảng cáo cá nhân hóa | [Q1] [market] |

## Assumptions & Open Questions

- [assumption] C-T5: biến thể bundle ID cụ thể cho iOS (ví dụ `com.h2.game.blockBlast`) chưa được chọn.
