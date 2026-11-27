# Bằng chứng

## Ai đã xem gì

Lưu ý quan trọng: các trợ lý chuyên trách không có công cụ đọc, ghi file trong phiên này. Theo lựa chọn của bạn, conductor tự làm cả bốn vai (người dẫn và ba chuyên gia). Ba file trong `contributions/` do cùng một người viết nên không độc lập như thiết kế.

| Vai | Đã xem | Nguồn |
|-----|--------|-------|
| Người phụ trách phát hành (lead) | Lịch sử git (nhánh `main`, 4 commit, commit mới nhất `0cbba99` ngày 2026-11-23), không có `.github` hay tệp pipeline, nội dung đã chốt trong `team.md` và `project.md` | git, repo, `memory/team.md` |
| Chất lượng | 508 ca kiểm thử, `coverage/lcov.info`, `test/widget_test.dart`, không có CI | `contributions/aidlc-quality-agent.md` |
| Developer | Cấu trúc feature-first, `provider`, mẫu interface cộng `Noop` hoặc fake | `contributions/aidlc-developer-agent.md` |
| Bảo mật | `flutter_lints`, `.gitignore`, hai file Firebase đang được theo dõi trong git, bề mặt chuỗi cung ứng khi thêm SDK quảng cáo | `contributions/aidlc-devsecops-agent.md` |

## Các quyết định phỏng vấn

- Cách làm việc và quản lý phiên bản: giữ nguyên (Q1: A).
- Bản mỏng chạy xuyên suốt: có, gồm đọc cấu hình cộng interstitial (Q2: A). Thay thế nội dung đã cũ của đợt trước.
- Kiểm thử: giữ nguyên, thêm ghi chú về giả lập SDK quảng cáo qua interface (Q3: A).
- Triển khai: giữ nguyên (Q4: A).
- Phong cách code: giữ nguyên (Q5: A).
- Quy tắc cứng về khóa bí mật: không thêm. Bạn cho biết các mạng quảng cáo bạn dùng không có khóa bí mật (Q6: Other).

## Bất đồng được ghi nhận

Chuyên gia bảo mật phản đối việc đặt khóa bí mật của mạng quảng cáo trong Remote Config. Người dùng giải quyết bằng cách cho biết các mạng quảng cáo đang dùng không có khóa bí mật, nên không thêm quy tắc.

## Điểm chưa chắc chắn

- Hai file Firebase đang được theo dõi trong git (`google-services.json`, `GoogleService-Info.plist`). Chưa kiểm tra việc hạn chế khóa API theo ứng dụng trong Firebase và Google Cloud.
- Khẳng định "các mạng quảng cáo không có khóa bí mật" là lời của người dùng, chưa được kiểm chứng với tài liệu của từng mạng (AdMob, Unity, AppLovin).
