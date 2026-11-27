# Sổ ràng buộc: Quảng cáo và Remote Config

| ID | Loại | Ràng buộc | Nguồn |
|----|------|-----------|-------|
| C1 | Kỹ thuật | Các tham số quảng cáo và phiên bản nằm cùng dự án Firebase và cùng Remote Config đang dùng cho level | Q1 |
| C2 | Kỹ thuật | Ứng dụng tự chạy thứ tự gọi từng mạng quảng cáo theo `ads_priority`, không dựa vào một lớp mediation có sẵn | Q2 |
| C3 | Kỹ thuật | Kiểm tra được trên cả Android và iOS | Q6 |
| C4 | Tổ chức | Không có mốc thời gian cố định và không có ngân sách riêng | Q3 |
| C5 | Tổ chức | Rào cản đã biết là thời gian duyệt bản phát hành trên cửa hàng ứng dụng | Q8 |
| C6 | Tổ chức | Link cửa hàng chưa có vì ứng dụng chưa phát hành, dùng link giả tạm, đổi qua Remote Config sau | Q7 |
| C7 | Pháp lý | Phát hành toàn cầu gồm cả EU/EEA, cần xử lý đồng ý của người dùng (GDPR/ATT hoặc tương đương) | Q4, Q8 của intent-capture |
| C8 | Chính sách | Đối tượng người chơi hướng tới trên 13 tuổi, không nhắm riêng tới trẻ em | Q5 |
| C9 | Quy ước đội | Mọi chuỗi hiển thị trên UI chỉ dùng tiếng Anh | `intent-statement.md` mục Constraints Already Known |

## Assumptions & Open Questions

None.
