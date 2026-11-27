# Yêu cầu hiệu năng: u4-update-and-share

Nguồn: `functional-spec.md`, `requirements.md` (FR6, FR7, NFR1, NFR6), `contract-summary.md` (hợp đồng 3) và `nfr-requirements-questions.md`.

| ID | Yêu cầu | Tiêu chí pass | Nguồn |
|----|---------|---------------|-------|
| NFR1.2 | Kiểm tra phiên bản chạy sau khung hình đầu của Home và không chặn việc vào Home hay bấm PLAY | Kiểm thử widget: Home hiện và PLAY bấm được trong khi đọc phiên bản đang treo | NFR1 |
| NFR6.2 | Kiểm tra phiên bản và link chia sẻ dùng cấu hình đã kích hoạt lúc khởi động, không tải thêm | Kiểm thử đơn vị: không gọi tải cấu hình khi kiểm tra phiên bản | NFR6, hợp đồng 3 |
| NFR2.23 | Lỗi khi đọc phiên bản đang cài hoặc khi mở cửa hàng được ghi log và không làm dừng game; khi đó popup không hiện hoặc đóng lại | Kiểm thử đơn vị với bản giả ném lỗi | NFR2, BR8.6 |

## Assumptions & Open Questions

None.
