# Security Requirements: u2-victory-share

Nguồn: functional-spec.md (BR1.4, BR1.7), requirements.md (NFR4, NFR6, NFR7).

| ID | Yêu cầu | Cách kiểm |
|---|---|---|
| NFR6.1 | Ảnh chỉ ghi vào thư mục tạm của app (`getTemporaryDirectory`), tên cố định `victory.png`, ghi đè mỗi lần | đọc code |
| NFR6.2 | Ảnh chỉ được gửi khi người chơi bấm SHARE; không tự chia sẻ | widget test: không bấm thì service giả không được gọi |
| NFR4.1 | Văn bản chia sẻ và nhãn nút bằng tiếng Anh | unit test chuỗi |
| NFR7.1 | Không thêm quyền hay gói mới (đã có `share_plus`, `screenshot`, `path_provider`) | so sánh `pubspec.yaml`, manifest |

## Mối đe dọa
Ảnh chụp có thể lộ nội dung màn hình; chỉ gồm màn chơi và tên level, không có dữ liệu cá nhân.
