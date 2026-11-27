# Câu hỏi yêu cầu phi chức năng: u4-update-and-share

Đọc phiên bản đang cài dùng `package_info_plus` (^9.0.1), đã thêm ở `u1-ads-core` (ADR-006). Cấu hình phiên bản và đường dẫn là cấu hình đã kích hoạt lúc khởi động, có hiệu lực trong khoảng 12 giờ (NFR6), nên kiểm tra phiên bản không tốn thêm thời gian tải. Dự án chưa có thư viện mở đường dẫn ra ngoài, nên nút UPDATE cần thêm một thư viện.

## Q1. Cách mở trang cửa hàng khi bấm UPDATE

- A. Thêm `url_launcher` (thư viện chính thức của nhóm Flutter) và mở bằng ứng dụng ngoài: Android mở Google Play, iOS mở App Store, nếu không có thì mở trình duyệt
- B. Thêm `url_launcher` và mở trong trình duyệt nhúng trong game
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Assumptions & Open Questions

- [assumption] Kiểm tra phiên bản chạy sau khung hình đầu của Home, không làm chậm việc vào Home (NFR1).
- [assumption] Đường dẫn từ Remote Config được kiểm tra (chỉ `https`, có tên máy chủ) trước khi mở hay đưa vào nội dung chia sẻ, vì đây là dữ liệu từ ngoài (BR8.3).
