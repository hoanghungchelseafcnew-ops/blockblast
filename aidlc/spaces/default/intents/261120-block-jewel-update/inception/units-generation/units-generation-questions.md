# Units Generation Questions

Đề xuất: 3 unit theo nhóm tính năng, cùng một ứng dụng Flutter (một lần build, không có triển khai riêng từng unit).

| Unit | Nội dung | Story | Loại | Độ phức tạp |
|---|---|---|---|---|
| U1 `u1-app-shell` | Đổi tên Block Jewel, một splash, gỡ splash native | US1.1–US1.3, US2.1, US2.2 | packaging | S |
| U2 `u2-victory-share` | Nút SHARE ở Victory, `shareVictory`, chuỗi chia sẻ mới | US2.3, US3.1–US3.5 | ui | M |
| U3 `u3-tray-algorithm` | `TrayGenerator`, `DifficultyProfile`, nối vào engine và controller | US4.1–US4.6 | library | L |

## Question 1
Cách chia unit:

A. Ba unit như bảng trên (theo nhóm tính năng).
B. Hai unit: giao diện (U1 và U2 gộp) và thuật toán (U3).
C. Một unit cho toàn bộ.
X. Other (please specify)

[Answer]:A

## Question 2
Quan hệ phụ thuộc giữa các unit:

A. Độc lập hoàn toàn (không unit nào phụ thuộc unit khác); chuỗi "Block Jewel" ở U2 là hằng số trong chính U2.
B. U2 phụ thuộc U1 (dùng chung hằng tên game do U1 tạo).
X. Other (please specify)

[Answer]:A

## Question 3
Unit đầu tiên trong DAG (bản mỏng chạy xuyên suốt, theo quy ước team):

A. U1 (nhỏ nhất, chạy được cả app từ khởi động đến chơi 1 level).
B. U3 (rủi ro lớn nhất, kiểm chứng sớm thuật toán).
X. Other (please specify)

[Answer]:A
