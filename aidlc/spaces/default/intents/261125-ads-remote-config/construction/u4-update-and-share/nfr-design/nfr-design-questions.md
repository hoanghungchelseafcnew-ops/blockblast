# Câu hỏi thiết kế phi chức năng: u4-update-and-share

Các chỉ tiêu đã chốt ở NFR Requirements: kiểm tra phiên bản không chặn Home (NFR1.2), dùng cấu hình đã kích hoạt (NFR6.2), chỉ mở đường dẫn `https` bằng ứng dụng ngoài (NFR8.1, NFR8.2), lỗi không dừng game (NFR2.23). Câu hỏi dưới đây chốt cách nhớ "popup đã hiện trong lần mở này" (BR8.4), phần dễ sai nhất.

Bộ đếm lần mở hiện nằm trong phần quảng cáo (`AdCounters`, qua `AdsService`). Khi quảng cáo không dựng được, ứng dụng dùng bản không có quảng cáo, và bản này không đếm lần mở.

## Q1. Cách nhớ popup đã hiện trong lần mở này

- A. Dùng bộ đếm lần mở của quảng cáo: nhớ số lần mở lúc popup hiện, và chỉ hiện lại khi số đó tăng. Khi không có quảng cáo, popup hiện tối đa một lần mỗi lần khởi động
- B. Phần cập nhật tự theo dõi lúc ứng dụng quay lại từ nền, độc lập với quảng cáo. Cách này không loại trừ lần quay lại sau khi chia sẻ hay xem quảng cáo, nên popup có thể hiện lại sau những lần đó
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Assumptions & Open Questions

None.
