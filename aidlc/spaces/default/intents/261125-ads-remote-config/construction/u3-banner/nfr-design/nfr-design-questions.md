# Câu hỏi thiết kế phi chức năng: u3-banner

Các chỉ tiêu đã chốt ở NFR Requirements: vào màn chơi không chờ banner, 5 giây mỗi mạng, mỗi mạng tự làm mới banner, giải phóng banner khi rời màn, Unity không dùng cho banner (NFR2.15 đến NFR2.22, NFR3.3). Câu hỏi dưới đây chốt cách màn chơi biết lần mở thứ N vừa đến khi đang mở (BR7.2), phần dễ sai nhất vì nó phụ thuộc thứ tự giữa hai việc chạy cùng lúc.

## Q1. Màn chơi biết bộ đếm vừa chạm ngưỡng bằng cách nào

Khi ứng dụng quay lại từ nền, `AdMediator` ghi thêm một lần mở. Vùng banner cần biết điều đó để tải ngay (BR7.2).

- A. `AdsService` báo cho vùng banner mỗi khi một lần mở được ghi xong; vùng banner kiểm tra lại điều kiện ngay sau đó
- B. Vùng banner tự lắng nghe sự kiện quay lại từ nền, chờ một nhịp rồi hỏi `AdsService` có nên hiện banner không
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A

## Assumptions & Open Questions

None.
