# Security Design: u1-app-shell

Nguồn: security-requirements.md, tech-stack-decisions.md (nfr-requirements của unit này). Chưa có functional-spec vì stage functional-design được bỏ qua tự động cho unit đóng gói; ngữ cảnh lấy từ yêu cầu và code KB.

Unit này chỉ đổi tên, splash và tài nguyên khởi động nên không có mẫu bảo mật mới. Bảng dưới ánh xạ yêu cầu sang giải pháp thiết kế.

| ID | Giải pháp thiết kế |
|---|---|
| NFR3.1 | Cập nhật test splash và Home theo chuỗi mới; đo coverage bằng `flutter test --coverage` |
| NFR4.1 | Chuỗi "BLOCK JEWEL" và "Gemstone Journey" viết trực tiếp bằng tiếng Anh ở splash/Home, không qua bản dịch |
| NFR5.1 | `flutter analyze` và `dart format` trong lệnh kiểm tra của intent |
| NFR5.2 | Gỡ khối `flutter_native_splash` và dev-dependency khỏi `pubspec.yaml` |
| NFR5.3 | Sửa tay `styles.xml`, `launch_background.xml`, `LaunchScreen.storyboard`: chỉ nền `#0F0C29`, không bitmap |
| NFR7.1 | Không đụng `applicationId`, `namespace`, bundle id, tên package Dart |
| NFR7.2 | Không thêm quyền hay gói phụ thuộc; chỉ gỡ một gói dev |

## Rủi ro còn lại
Android 12+ luôn hiện splash hệ thống nền `#0F0C29`; giới hạn của nền tảng, không có biện pháp khác.
