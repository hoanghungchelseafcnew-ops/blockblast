# Câu hỏi thiết kế phi chức năng: u2-reward-ads

Các chỉ tiêu đã chốt ở NFR Requirements: lớp phủ hiện ngay, tải trước reward khi bắt đầu level, không chờ khi bấm nút, thua ghi nhận đúng một lần (NFR2.8 đến NFR2.14). Câu hỏi dưới đây chốt cách lưu dấu lần thua chưa ghi nhận, phần dễ sai nhất.

## Q1. Ghi dấu lần thua chưa ghi nhận lúc nào

Dấu này cho biết có một lần thua chưa ghi nhận (BR6.7). Nếu ghi dấu chậm, tắt ứng dụng ngay lúc thua có thể mất dấu và người chơi không bị hạ tiến trình.

- A. Ghi dấu ngay khi hết nước đi, cùng lúc với lúc lớp phủ hiện, và chờ ghi xong trước khi cho bấm nút trên lớp phủ
- B. Ghi dấu ngay khi hết nước đi nhưng không chờ ghi xong; nếu lỗi thì chỉ ghi log
- C. Not yet defined (chưa xác định)
- X. Other (please specify)

[Answer]:A
