# Security Requirements: u1-app-shell

Nguồn: requirements.md (NFR4, NFR7), technology-stack.md (code KB). Unit này chỉ đổi tên hiển thị, màn splash và tài nguyên khởi động; không có xác thực, dữ liệu người dùng hay mạng mới. Vì unit này không có chức năng riêng (functional-design đã được bỏ qua tự động), ngữ cảnh NFR được lấy từ requirements và code KB.

| ID | Yêu cầu | Cách kiểm |
|---|---|---|
| NFR4.1 | Mọi chuỗi mới hoặc đổi trên UI (tên game, splash) bằng tiếng Anh | đọc chuỗi trong test splash và Home |
| NFR7.1 | `applicationId`/`namespace` `com.h2.game.block_blast`, bundle id iOS và tên package Dart `block_blast` không đổi, để dữ liệu tiến trình đã lưu vẫn dùng được | so sánh `build.gradle.kts`, `Info.plist`, `pubspec.yaml` trước và sau |
| NFR7.2 | Không thêm quyền Android/iOS, không thêm gói phụ thuộc mới | so sánh `AndroidManifest.xml`, `Info.plist`, `pubspec.yaml` |

## Mối đe dọa
Không có mối đe dọa mới: không có dữ liệu nhạy cảm, không có mã mới chạy ngoài giao diện.
