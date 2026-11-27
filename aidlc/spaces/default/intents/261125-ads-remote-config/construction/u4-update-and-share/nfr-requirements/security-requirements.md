# Yêu cầu bảo mật: u4-update-and-share

Nguồn: `functional-spec.md`, `rules.md`, `requirements.md` (FR6, FR7, NFR3), `contract-summary.md` và `nfr-requirements-questions.md`. Unit này không thêm khóa bí mật hay dữ liệu cá nhân. Rủi ro chính là đường dẫn từ Remote Config, một nguồn dữ liệu từ ngoài, được mở ra hoặc gửi cho bạn bè của người chơi.

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR8.1 | Chỉ mở hoặc chia sẻ đường dẫn tuyệt đối có scheme `https` và có tên máy chủ; mọi giá trị khác bị bỏ qua | Kiểm thử đơn vị với `http://`, `javascript:`, `market://`, chuỗi rỗng, chuỗi không phải URL | BR8.3 |
| NFR8.2 | Đường dẫn được mở bằng ứng dụng ngoài (cửa hàng hoặc trình duyệt hệ thống), không mở trong trình duyệt nhúng trong game | Kiểm thử đơn vị: bản giả trình mở nhận chế độ mở ngoài | Q1 |
| NFR8.3 | Chuỗi phiên bản từ cấu hình chỉ được dùng để so sánh, không hiện ra giao diện hay ghi vào log nguyên văn quá 32 ký tự | Xem lại mã và kiểm thử với chuỗi dài | BR8.1 |
| NFR3.4 | Đọc phiên bản và mở đường dẫn nằm sau interface có bản giả để test, không cần nền tảng thật | Có kiểm thử đơn vị và widget dùng bản giả | NFR3 |

## Mối đe dọa đã cân nhắc

- Ai đó sửa Remote Config thành một đường dẫn độc hại: chặn một phần bằng NFR8.1. Chỉ người có quyền trên dự án Firebase mới sửa được cấu hình.
- Nội dung chia sẻ mang link lạ đến bạn bè người chơi: cùng biện pháp NFR8.1.

## Assumptions & Open Questions

None.
