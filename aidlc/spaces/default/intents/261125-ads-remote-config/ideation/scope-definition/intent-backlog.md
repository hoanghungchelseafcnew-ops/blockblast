# Intent Backlog: Quảng cáo và Remote Config

Danh sách mục việc (proto-Unit) theo thứ tự đề xuất. Mức ưu tiên MoSCoW: tất cả Must Have. (Q1, Q2 của scope-definition)

| Thứ tự | ID | Mục việc | MoSCoW | Phụ thuộc | Căn cứ |
|--------|----|----------|--------|-----------|--------|
| 1 | B1 | Phần nền dùng chung: đọc tham số từ Remote Config, thứ tự mạng quảng cáo (hạng mục 4), tải quảng cáo, xử lý đồng ý người dùng | Must Have | Không | Q4, Q5, hạng mục 4 |
| 2 | B2 | Interstitial sau mỗi N lần bấm Start (hạng mục 3) | Must Have | B1 | Q1, Q3 |
| 3 | B3 | Reward ads để tiếp tục level hiện tại, có cờ bật/tắt (hạng mục 2) | Must Have | B1 | Q1, Q3 |
| 4 | B4 | Banner ở màn chơi từ lần vào thứ N (hạng mục 1) | Must Have | B1 | Q1, Q3 |
| 5 | B5 | Kiểm tra phiên bản và popup cập nhật (hạng mục 5) | Must Have | Đọc cấu hình trong B1 | Q1 |
| 6 | B6 | Link cửa hàng trong nội dung chia sẻ (hạng mục 6) | Must Have | Giá trị link từ cấu hình trong B5 | Q1 |

## Ghi chú về thứ tự

- B1 đứng đầu vì các mục B2, B3, B4 phụ thuộc nó. (Q4)
- Thứ tự giữa B2, B3, B4 và B5, B6 là đề xuất của quản lý sản phẩm theo hướng giá trị trước, chưa được bạn xác nhận từng vị trí. Giả thuyết: quảng cáo chèn và reward mang lại nhiều doanh thu hơn banner. Bạn có thể đổi thứ tự khi duyệt. (Q3)

## Assumptions & Open Questions

None.
