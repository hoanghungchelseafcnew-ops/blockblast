# Bản đồ phụ thuộc bên ngoài

Nguồn: `delivery-planning-questions.md` (Q5), `feasibility-assessment.md` và `raid-log.md`. Mỗi mục ghi bên sở hữu, thời gian chờ, Bolt bị ảnh hưởng và cách xử lý nếu chậm. Một Bolt là một lượt xây dựng cho một phần việc (xem `bolt-plan.md`).

| Mục | Bên sở hữu | Thời gian | Bolt bị ảnh hưởng | Nếu chậm |
|-----|-----------|-----------|-------------------|----------|
| Trang cửa hàng thật (link cho popup và chia sẻ) | Bạn, qua Google Play Console và App Store Connect | Phụ thuộc thời gian duyệt của cửa hàng | B4 `u4-update-and-share` | Dùng link giả và đổi qua Firebase sau |
| Tài khoản và ad unit của ba mạng | Bạn (đã có) | Không | B1 | Dùng quảng cáo thử |
| Quảng cáo thật thay cho quảng cáo thử | Mạng quảng cáo | Phụ thuộc mạng duyệt ứng dụng | B1, B2, B3 | Kiểm thử bằng quảng cáo thử, quảng cáo thật khi ứng dụng lên cửa hàng |
| Giá trị cấu hình trên Firebase Console | Bạn | Ngay lập tức | B1 đến B4 | Dùng giá trị mặc định |

(Q5 của delivery-planning)

## Assumptions & Open Questions

None.
